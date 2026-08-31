import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/deadline_guard.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/space/budget_ledger.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

/// Budget mode, end to end from the tables (spec 4.8).
///
/// Both limits are optional and independent, which is most of what these pin:
/// no fund is a valid state, no deadline is a valid state, and a deadline that
/// moves backwards over existing records must not lose them.
void main() {
  late AppDatabase db;
  late Repositories repos;
  late Space space;
  late BudgetPeriod period;

  final CalendarDate today = d('2026-03-10');

  SpaceClock.initialize();
  final SpaceClock clock = SpaceClock(
    timezone: 'UTC',
    now: () => DateTime.utc(2026, 3, 10, 12),
  );

  setUp(() async {
    db = inMemoryDatabase();
    repos = Repositories(db: db, clock: clock, userId: 'tester');
    space = await repos.spaces.create(
      title: 'Spain',
      spaceType: SpaceType.personal,
      budgetMode: BudgetMode.budget,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
    period = await repos.periods.ensureContinuous(
      spaceId: space.id,
      startDate: today,
    );
  });

  tearDown(() => db.close());

  Future<Payment> expense(
    String title,
    String date,
    String amount, {
    bool isPaid = false,
  }) => repos.payments.create(
    spaceId: space.id,
    title: title,
    amount: m(amount),
    dueDate: d(date),
    expenseType: ExpenseType.mandatory,
    isPaid: isPaid,
  );

  Future<Income> topUp(String title, String date, String amount) =>
      repos.incomes.create(
        spaceId: space.id,
        title: title,
        expectedDate: d(date),
        amount: m(amount),
      );

  Future<BudgetLedger> build() async => buildBudgetLedger(
    period: (await repos.periods.continuousFor(space.id))!,
    payments: await repos.payments.inSpace(space.id),
    incomes: await repos.incomes.inSpace(space.id),
    today: today,
  );

  group('the fund', () {
    test('with no target there is nothing to fit into', () async {
      await expense('Hotel', '2026-04-01', '600', isPaid: true);

      final BudgetLedger ledger = await build();
      expect(ledger.hasFund, isFalse);
      // No walk, so no cutoff and no verdict — only what has been spent.
      expect(ledger.cascade, isNull);
      expect(ledger.coverage, isNull);
      expect(ledger.moneyEndsAt, isEmpty);
      expect(ledger.totalPaid, m('600'));
    });

    test('a top-up adds to the fund rather than to the walk', () async {
      await repos.periods.setBudgetTarget(period.id, m('1000'));
      await topUp('Anna', '2026-03-15', '400');
      await expense('Hotel', '2026-04-01', '600');

      final BudgetLedger ledger = await build();
      expect(ledger.contributions, m('400'));
      expect(ledger.available, m('1400'));
      expect(ledger.remaining, m('800'));
      expect(ledger.coverage, Coverage.covered);
      // The top-up is not an entry: it joined the starting sum, so the walk
      // sees the one expense only.
      expect(ledger.entries.length, 1);
    });

    test('spending past the fund is an overspend', () async {
      await repos.periods.setBudgetTarget(period.id, m('500'));
      await expense('Hotel', '2026-04-01', '600');

      final BudgetLedger ledger = await build();
      expect(ledger.remaining, isNull);
      expect(ledger.coverage, Coverage.short);
      expect(ledger.cascade!.all.finalBalance, m('-100'));
    });

    test('clearing the target puts it back to plain tracking', () async {
      await repos.periods.setBudgetTarget(period.id, m('500'));
      await repos.periods.setBudgetTarget(period.id, null);

      expect((await build()).hasFund, isFalse);
    });
  });

  group('the deadline', () {
    test('a soft one refuses nothing', () async {
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-04-01'),
        isHard: false,
      );

      await expense('Late', '2026-05-01', '100');
      expect((await build()).beyondDeadline, isEmpty);
    });

    test('a hard one refuses a record dated after it', () async {
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-04-01'),
        isHard: true,
      );

      expect(
        () => expense('Late', '2026-05-01', '100'),
        throwsA(isA<BeyondHardDeadline>()),
      );
      expect(
        () => topUp('Late', '2026-05-01', '100'),
        throwsA(isA<BeyondHardDeadline>()),
      );
      // On the day itself is inside it.
      await expense('On time', '2026-04-01', '100');
      expect((await build()).totalPlanned, m('100'));
    });

    test('moving it backwards marks records, never deletes them', () async {
      await repos.periods.setBudgetTarget(period.id, m('1000'));
      final Payment late = await expense('Hotel', '2026-05-01', '600');
      await expense('Flights', '2026-03-20', '300');
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-04-01'),
        isHard: true,
      );

      final BudgetLedger ledger = await build();
      expect(ledger.beyondDeadline, <String>{late.id});
      // Out of the reckoning while it sits there.
      expect(ledger.totalPlanned, m('300'));
      expect(ledger.remaining, m('700'));
      // Still on file.
      expect(await repos.payments.byId(late.id), isNotNull);
    });

    test('moving it forward again brings them back', () async {
      await repos.periods.setBudgetTarget(period.id, m('1000'));
      await expense('Hotel', '2026-05-01', '600');
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-04-01'),
        isHard: true,
      );
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-06-01'),
        isHard: true,
      );

      final BudgetLedger ledger = await build();
      expect(ledger.beyondDeadline, isEmpty);
      expect(ledger.totalPlanned, m('600'));
    });

    test('clearing the date clears its hardness with it', () async {
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-04-01'),
        isHard: true,
      );
      await repos.periods.setDeadline(period.id, date: null, isHard: true);

      final BudgetLedger ledger = await build();
      expect(ledger.deadline, isNull);
      expect(ledger.deadlineIsHard, isFalse);
      // And nothing is refused any more.
      await expense('Late', '2026-05-01', '100');
    });

    test('the countdown is signed', () async {
      await repos.periods.setDeadline(
        period.id,
        date: d('2026-03-15'),
        isHard: false,
      );
      expect((await build()).daysToDeadline, 5);

      await repos.periods.setDeadline(
        period.id,
        date: d('2026-03-05'),
        isHard: false,
      );
      expect((await build()).daysToDeadline, -5);
    });
  });

  test('a zero-amount expense is a dated to-do, not an error', () async {
    // Budget mode doubles as a task list against the event (spec 4.8).
    await repos.payments.create(
      spaceId: space.id,
      title: 'Book the tickets',
      amount: Decimal.zero,
      dueDate: d('2026-03-20'),
      expenseType: ExpenseType.variable,
    );

    final BudgetLedger ledger = await build();
    expect(ledger.entries.length, 1);
    expect(ledger.totalPlanned, Decimal.zero);
  });
}
