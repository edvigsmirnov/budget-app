import 'package:budget_app/app/startup.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/repositories/income_repository.dart';
import 'package:budget_app/core/db/repositories/payment_repository.dart';
import 'package:budget_app/core/db/repositories/space_repository.dart';
import 'package:budget_app/core/time/space_clock.dart';
import 'package:budget_app/domain/ledger/ledger_entry.dart';
import 'package:budget_app/domain/ledger/ledger_walker.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:budget_app/features/space/space_ledger.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

/// Flow, end to end from the tables: repositories write, the ledger reads.
/// Where the domain tests pin the arithmetic, these pin the wiring — which
/// rows reach the walk and what the available sum is built from.
void main() {
  late AppDatabase db;
  late SpaceRepository spaces;
  late PaymentRepository payments;
  late IncomeRepository incomes;
  late Space space;

  final CalendarDate today = d('2026-03-10');

  // Before any SpaceClock is constructed: the constructor resolves its zone
  // eagerly, and the IANA database has to be loaded by then.
  SpaceClock.initialize();
  final SpaceClock clock = SpaceClock(
    timezone: 'UTC',
    now: () => DateTime.utc(2026, 3, 10, 12),
  );

  setUp(() async {
    db = inMemoryDatabase();
    spaces = SpaceRepository(db: db, clock: clock);
    payments = PaymentRepository(db: db, clock: clock, userId: 'tester');
    incomes = IncomeRepository(db: db, clock: clock, userId: 'tester');
    space = await spaces.create(
      title: 'Flow',
      spaceType: SpaceType.personal,
      budgetMode: BudgetMode.flow,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
  });

  tearDown(() => db.close());

  Future<FlowLedger> build() async => buildFlowLedger(
    space: (await spaces.byId(space.id))!,
    payments: await payments.inSpace(space.id),
    incomes: await incomes.inSpace(space.id),
    today: today,
  );

  Future<Payment> addExpense(
    String title,
    String date,
    String amount, {
    bool isPaid = false,
    ExpenseType type = ExpenseType.mandatory,
  }) => payments.create(
    spaceId: space.id,
    title: title,
    amount: m(amount),
    dueDate: d(date),
    expenseType: type,
    isPaid: isPaid,
  );

  group('available money', () {
    test('with no balance set, available is zero', () async {
      final FlowLedger ledger = await build();
      expect(ledger.available, Decimal.zero);
      expect(ledger.coverage, Coverage.exact);
    });

    test('the manual balance is the starting sum', () async {
      await spaces.setManualBalance(space.id, m('1000'));
      await addExpense('rent', '2026-03-20', '600');

      final FlowLedger ledger = await build();
      expect(ledger.available, m('1000'));
      expect(ledger.freeCash, m('400'));
    });

    test('a receipt after the snapshot adds to it', () async {
      await spaces.setManualBalance(space.id, m('1000'));
      await incomes.create(
        spaceId: space.id,
        title: 'bonus',
        expectedDate: d('2026-03-12'),
        amount: m('200'),
        isPaid: true,
      );

      final FlowLedger ledger = await build();
      expect(ledger.available, m('1200'));
    });

    test('a receipt before the snapshot is already inside it', () async {
      // The mirror of the double-count rule for expenses (plan G1): the
      // balance was taken after that money landed.
      await incomes.create(
        spaceId: space.id,
        title: 'salary',
        expectedDate: d('2026-03-01'),
        amount: m('900'),
        isPaid: true,
      );
      await spaces.setManualBalance(space.id, m('1000'));

      final FlowLedger ledger = await build();
      expect(ledger.available, m('1000'));
    });

    test('an unreceived income stays in the ledger, not the sum', () async {
      await spaces.setManualBalance(space.id, m('100'));
      await incomes.create(
        spaceId: space.id,
        title: 'salary',
        expectedDate: d('2026-03-26'),
        amount: m('900'),
      );
      await addExpense('rent', '2026-03-15', '500');

      final FlowLedger ledger = await build();
      expect(ledger.available, m('100'));
      // The money arrives too late to cover the rent (spec 4.9, rule 3).
      expect(ledger.coverage, Coverage.short);
      expect(ledger.lastCoveredDay, d('2026-03-14'));
    });

    test('an income with no amount contributes nothing', () async {
      // A floating salary is unknown, not zero (spec 4.7).
      await spaces.setManualBalance(space.id, m('100'));
      await incomes.create(
        spaceId: space.id,
        title: 'floating',
        expectedDate: d('2026-03-26'),
      );

      final FlowLedger ledger = await build();
      expect(ledger.entries.where((LedgerEntry e) => e.isIncome), isEmpty);
      expect(ledger.available, m('100'));
    });
  });

  group('the double-count rule', () {
    test('an expense paid before the snapshot is dropped', () async {
      await addExpense('rent', '2026-03-01', '600', isPaid: true);
      await spaces.setManualBalance(space.id, m('1000'));
      await addExpense('food', '2026-03-20', '200');

      final FlowLedger ledger = await build();
      // Without the rule this would read 200: rent charged twice.
      expect(ledger.freeCash, m('800'));
      expect(ledger.excludedCount, 1);
    });

    test('an expense paid but due later still counts', () async {
      await spaces.setManualBalance(space.id, m('1000'));
      await addExpense('prepaid', '2026-03-20', '150', isPaid: true);

      final FlowLedger ledger = await build();
      expect(ledger.freeCash, m('850'));
      expect(ledger.excludedCount, 0);
    });
  });

  group('cascade and totals', () {
    setUp(() async {
      await spaces.setManualBalance(space.id, m('1000'));
      await addExpense('rent', '2026-03-15', '600');
      await addExpense(
        'clothes',
        '2026-03-18',
        '300',
        type: ExpenseType.variable,
      );
      await addExpense('paid bill', '2026-03-16', '50', isPaid: true);
    });

    test('mandatory alone leaves more than everything does', () async {
      final FlowLedger ledger = await build();
      expect(ledger.baseRemainder, m('350'));
      expect(ledger.freeCash, m('50'));
    });

    test('planned, paid and remaining add up', () async {
      final FlowLedger ledger = await build();
      expect(ledger.totalPlanned, m('950'));
      expect(ledger.totalPaid, m('50'));
      expect(ledger.totalRemaining, m('900'));
    });
  });

  group('nearest income', () {
    test('is the first unreceived one from today onwards', () async {
      await incomes.create(
        spaceId: space.id,
        title: 'later',
        expectedDate: d('2026-04-01'),
        amount: m('500'),
      );
      await incomes.create(
        spaceId: space.id,
        title: 'sooner',
        expectedDate: d('2026-03-14'),
        amount: m('300'),
      );

      final FlowLedger ledger = await build();
      expect(ledger.nearestIncome?.title, 'sooner');
    });

    test('a received income is not upcoming', () async {
      await incomes.create(
        spaceId: space.id,
        title: 'arrived',
        expectedDate: d('2026-03-14'),
        amount: m('300'),
        isPaid: true,
      );

      final FlowLedger ledger = await build();
      expect(ledger.nearestIncome, isNull);
    });

    test('an income due today still counts as upcoming', () async {
      await incomes.create(
        spaceId: space.id,
        title: 'today',
        expectedDate: today,
        amount: m('300'),
      );

      final FlowLedger ledger = await build();
      expect(ledger.nearestIncome?.title, 'today');
    });
  });

  test('soft-deleted rows never reach the walk', () async {
    await spaces.setManualBalance(space.id, m('1000'));
    final Payment gone = await addExpense('cancelled', '2026-03-20', '400');
    await payments.softDelete(gone.id);

    final FlowLedger ledger = await build();
    expect(ledger.freeCash, m('1000'));
    expect(ledger.entries, isEmpty);
  });

  test('the coverage map marks the rows past the cutoff', () async {
    await spaces.setManualBalance(space.id, m('100'));
    final Payment first = await addExpense('a', '2026-03-15', '60');
    final Payment second = await addExpense('b', '2026-03-16', '60');

    final FlowLedger ledger = await build();
    expect(ledger.coverageByEntry[first.id], isTrue);
    expect(ledger.coverageByEntry[second.id], isFalse);
  });
}
