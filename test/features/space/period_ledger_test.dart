import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/income_repository.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/periods/period_service.dart';
import 'package:sielto/features/space/period_ledger.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

/// One income cycle, read from the tables the service wrote.
///
/// These pin the two ways the figures above the Feed can disagree with the
/// list under it: a record the ledger ignores, and an anchor counted more than
/// once.
void main() {
  late AppDatabase db;
  late Repositories repos;
  late PeriodService service;
  late Space space;

  SpaceClock.initialize();
  final SpaceClock clock = SpaceClock(
    timezone: 'UTC',
    now: () => DateTime.utc(2026, 3, 10, 12),
  );
  final CalendarDate today = d('2026-03-10');

  setUp(() async {
    db = inMemoryDatabase();
    repos = Repositories(db: db, clock: clock, userId: 'tester');
    service = PeriodService(
      repos: repos,
      calendar: WorkingDayCalendar.weekendsOnly(),
    );
    space = await repos.spaces.create(
      title: 'Family',
      spaceType: SpaceType.family,
      budgetMode: BudgetMode.incomeDriven,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
  });

  tearDown(() => db.close());

  Future<PeriodLedger> ledgerOf(BudgetPeriod period) async {
    final List<IncomeRecurrenceRule> rules = await repos.incomeRules.inSpace(
      space.id,
    );
    return buildPeriodLedger(
      period: period,
      payments: await repos.payments.inSpace(space.id),
      incomes: await repos.incomes.inSpace(space.id),
      anchorRuleIds: <String>{
        for (final IncomeRecurrenceRule r in rules)
          if (r.isAnchor) r.id,
      },
      today: today,
    );
  }

  Future<BudgetPeriod> currentPeriod() async {
    final List<BudgetPeriod> all = await repos.periods.incomeDrivenIn(space.id);
    return all.firstWhere(
      (BudgetPeriod p) =>
          !p.startDate.isAfter(today) &&
          (p.endDate == null || !p.endDate!.isBefore(today)),
    );
  }

  /// A salary already on file before the cycle under test opened.
  ///
  /// Written through a repository on an earlier clock on purpose: a rule
  /// created today materialises nothing behind it, so a rule stamped today
  /// would leave the current cycle without the salary that opened it — true
  /// to the rules, but not the case these tests are about.
  Future<void> addSalary({String? amount = '3224'}) async {
    await IncomeRuleRepository(
      db: db,
      clock: SpaceClock(
        timezone: 'UTC',
        now: () => DateTime.utc(2026, 1, 4, 12),
      ),
      userId: 'tester',
    ).create(
      spaceId: space.id,
      title: 'Salary',
      scheduleType: ScheduleType.fixedDate,
      fixedDay: 5,
      amount: amount == null ? null : m(amount),
      isAnchor: true,
    );
    await service.refresh(space, today);
  }

  test('the anchor is counted once, not once per materialised month', () async {
    // The order the bug was reported in: expenses first, then the salary.
    await repos.payments.create(
      spaceId: space.id,
      title: 'Rent',
      amount: m('900'),
      dueDate: d('2026-03-12'),
      expenseType: ExpenseType.mandatory,
    );
    await addSalary();

    final PeriodLedger ledger = await ledgerOf(await currentPeriod());
    expect(ledger.anchorAmount, m('3224'));
  });

  test('a payment written before the recompute still counts', () async {
    await addSalary();
    // Written straight to the table with no period, which is what every form
    // does: the binding happens on the next refresh.
    await repos.payments.create(
      spaceId: space.id,
      title: 'Rent',
      amount: m('900'),
      dueDate: d('2026-03-12'),
      expenseType: ExpenseType.mandatory,
    );

    final PeriodLedger ledger = await ledgerOf(await currentPeriod());
    expect(ledger.totalPlanned, m('900'));
    expect(ledger.freeCash, m('2324'));
  });

  group('no figure', () {
    // Two ways to have no anchor figure, and they are different answers.
    test('a cycle with no income at all computes from zero', () async {
      await addSalary();
      // Every occurrence removed: nothing is coming, and nothing is what it
      // is worth.
      for (final Income i in await repos.incomes.inSpace(space.id)) {
        await repos.incomes.softDelete(i.id);
      }

      final PeriodLedger ledger = await ledgerOf(await currentPeriod());
      expect(ledger.anchorAmount, Decimal.zero);
      expect(ledger.isComputable, isTrue);
      expect(ledger.freeCash, Decimal.zero);
    });

    test('an anchor with no amount stays uncomputable', () async {
      // A floating salary: money is coming and its size is not known, so any
      // figure would be invented (spec 4.7).
      await addSalary(amount: null);

      final PeriodLedger ledger = await ledgerOf(await currentPeriod());
      expect(ledger.anchorAmount, isNull);
      expect(ledger.isComputable, isFalse);
    });

    test('an empty cycle still reports what it owes', () async {
      await addSalary();
      for (final Income i in await repos.incomes.inSpace(space.id)) {
        await repos.incomes.softDelete(i.id);
      }
      await repos.payments.create(
        spaceId: space.id,
        title: 'Rent',
        amount: m('900'),
        dueDate: d('2026-03-12'),
        expenseType: ExpenseType.mandatory,
      );

      final PeriodLedger ledger = await ledgerOf(await currentPeriod());
      // Zero income against a real bill is not covered, and says so.
      expect(ledger.totalPlanned, m('900'));
      expect(ledger.freeCash, isNull);
    });
  });

  test('a payment dated outside the cycle does not count', () async {
    await addSalary();
    await repos.payments.create(
      spaceId: space.id,
      title: 'Next month',
      amount: m('900'),
      dueDate: d('2026-06-20'),
      expenseType: ExpenseType.mandatory,
    );

    final PeriodLedger ledger = await ledgerOf(await currentPeriod());
    expect(ledger.totalPlanned, Decimal.zero);
  });

  test('the figures follow the payment once it is bound', () async {
    await addSalary();
    await repos.payments.create(
      spaceId: space.id,
      title: 'Rent',
      amount: m('900'),
      dueDate: d('2026-03-12'),
      expenseType: ExpenseType.mandatory,
    );
    // The recompute binds it; the answer must not change when it does.
    await service.refresh(space, today);

    final PeriodLedger ledger = await ledgerOf(await currentPeriod());
    expect(ledger.freeCash, m('2324'));
  });
}
