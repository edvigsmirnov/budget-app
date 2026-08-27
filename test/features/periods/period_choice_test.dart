import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/periods/period_choice.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

/// "Current period / Next period" on the payment form (spec 5.3).
///
/// The control offers two targets, so what it shows for a row pinned to
/// neither of them matters as much as the happy path.
void main() {
  late AppDatabase db;
  late Repositories repos;
  late Space space;
  late BudgetPeriod march;
  late BudgetPeriod april;

  SpaceClock.initialize();
  final SpaceClock clock = SpaceClock(
    timezone: 'UTC',
    now: () => DateTime.utc(2026, 3, 10, 12),
  );

  setUp(() async {
    db = inMemoryDatabase();
    repos = Repositories(db: db, clock: clock, userId: 'tester');
    space = await repos.spaces.create(
      title: 'Family',
      spaceType: SpaceType.family,
      budgetMode: BudgetMode.incomeDriven,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
    march = await repos.periods.createIncomeDriven(
      spaceId: space.id,
      startDate: d('2026-03-05'),
      endDate: d('2026-04-04'),
      anchorDate: d('2026-03-05'),
    );
    april = await repos.periods.createIncomeDriven(
      spaceId: space.id,
      startDate: d('2026-04-05'),
      endDate: d('2026-05-04'),
      anchorDate: d('2026-04-05'),
    );
  });

  tearDown(() => db.close());

  Future<List<BudgetPeriod>> periods() =>
      repos.periods.incomeDrivenIn(space.id);

  Future<Payment> paymentOn(String iso) => repos.payments.create(
    spaceId: space.id,
    title: 'Rent',
    amount: m('900'),
    dueDate: d(iso),
    expenseType: ExpenseType.mandatory,
  );

  group('periodsAround', () {
    test('finds the containing cycle and the one after it', () async {
      final PeriodPair pair = periodsAround(await periods(), d('2026-03-20'));
      expect(pair.current?.id, march.id);
      expect(pair.next?.id, april.id);
    });

    test('the last cycle has no next', () async {
      final PeriodPair pair = periodsAround(await periods(), d('2026-04-20'));
      expect(pair.current?.id, april.id);
      expect(pair.next, isNull);
    });

    test('a date before the first anchor lands in nothing', () async {
      final PeriodPair pair = periodsAround(await periods(), d('2026-01-01'));
      expect(pair.isEmpty, isTrue);
    });

    test('a date past the last cycle lands in nothing', () async {
      final PeriodPair pair = periodsAround(await periods(), d('2026-09-01'));
      expect(pair.isEmpty, isTrue);
    });

    test('the continuous period is not a candidate', () async {
      // Flow's open row overlaps every date and would swallow the search.
      await repos.periods.ensureContinuous(
        spaceId: space.id,
        startDate: d('2020-01-01'),
      );
      final PeriodPair pair = periodsAround(
        await repos.periods.inSpace(space.id),
        d('2026-03-20'),
      );
      expect(pair.current?.id, march.id);
    });
  });

  group('choiceOf', () {
    test('a row bound by date reads as byDate', () async {
      final Payment payment = await paymentOn('2026-03-20');
      final PeriodPair pair = periodsAround(await periods(), payment.dueDate);
      expect(choiceOf(payment, pair), PeriodChoice.byDate);
    });

    test('a hand-pinned row on its own cycle reads as current', () async {
      final Payment payment = await paymentOn('2026-03-20');
      await repos.payments.setPeriod(
        payment.id,
        march.id,
        assignment: PeriodAssignment.manual,
      );
      final Payment pinned = (await repos.payments.byId(payment.id))!;
      final PeriodPair pair = periodsAround(await periods(), pinned.dueDate);
      expect(choiceOf(pinned, pair), PeriodChoice.current);
    });

    test('a row pushed forward reads as next', () async {
      final Payment payment = await paymentOn('2026-03-20');
      await repos.payments.setPeriod(
        payment.id,
        april.id,
        assignment: PeriodAssignment.manual,
      );
      final Payment pinned = (await repos.payments.byId(payment.id))!;
      final PeriodPair pair = periodsAround(await periods(), pinned.dueDate);
      expect(choiceOf(pinned, pair), PeriodChoice.next);
    });

    test('a pin to some third cycle falls back to byDate', () async {
      // The control has two targets and this is neither; claiming one of them
      // would misreport where the payment actually sits.
      final BudgetPeriod may = await repos.periods.createIncomeDriven(
        spaceId: space.id,
        startDate: d('2026-05-05'),
        endDate: d('2026-06-04'),
        anchorDate: d('2026-05-05'),
      );
      final Payment payment = await paymentOn('2026-03-20');
      await repos.payments.setPeriod(
        payment.id,
        may.id,
        assignment: PeriodAssignment.manual,
      );
      final Payment pinned = (await repos.payments.byId(payment.id))!;
      final PeriodPair pair = periodsAround(await periods(), pinned.dueDate);
      expect(choiceOf(pinned, pair), PeriodChoice.byDate);
    });
  });

  group('periodIsAmbiguousOn', () {
    // The control is only worth showing where the boundary is genuinely in
    // doubt — inside an anchor's uncertainty window (spec 5.1.1).
    Future<BudgetPeriod> withWindow(
      String start,
      String end,
      String windowStart,
      String windowEnd,
    ) => repos.periods.createIncomeDriven(
      spaceId: space.id,
      startDate: d(start),
      endDate: d(end),
      anchorDate: d(windowEnd),
      windowStart: d(windowStart),
      windowEnd: d(windowEnd),
    );

    test('a date inside a real window is ambiguous', () async {
      await withWindow('2026-06-01', '2026-06-30', '2026-05-29', '2026-06-01');
      final List<BudgetPeriod> all = await repos.periods.incomeDrivenIn(
        space.id,
      );
      expect(periodIsAmbiguousOn(all, d('2026-05-30')), isTrue);
    });

    test('a date outside every window is not', () async {
      await withWindow('2026-06-01', '2026-06-30', '2026-05-29', '2026-06-01');
      final List<BudgetPeriod> all = await repos.periods.incomeDrivenIn(
        space.id,
      );
      expect(periodIsAmbiguousOn(all, d('2026-06-15')), isFalse);
    });

    test('a window of one day resolved, so it asks nothing', () async {
      // The anchor landed on a working day: there was never a span.
      await withWindow('2026-06-02', '2026-06-30', '2026-06-02', '2026-06-02');
      final List<BudgetPeriod> all = await repos.periods.incomeDrivenIn(
        space.id,
      );
      expect(periodIsAmbiguousOn(all, d('2026-06-02')), isFalse);
    });

    test('the periods created without windows ask nothing either', () async {
      expect(periodIsAmbiguousOn(await periods(), d('2026-03-20')), isFalse);
    });
  });

  test('forChoice maps byDate and current onto the same cycle', () async {
    final PeriodPair pair = periodsAround(await periods(), d('2026-03-20'));
    expect(pair.forChoice(PeriodChoice.byDate)?.id, march.id);
    expect(pair.forChoice(PeriodChoice.current)?.id, march.id);
    expect(pair.forChoice(PeriodChoice.next)?.id, april.id);
  });
}
