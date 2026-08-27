import 'package:decimal/decimal.dart';
// drift exports isNull/isNotNull as SQL expressions; the matchers win here.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/budget_period_repository.dart';
import 'package:sielto/core/db/repositories/category_repository.dart';
import 'package:sielto/core/db/repositories/income_repository.dart';
import 'package:sielto/core/db/repositories/payment_repository.dart';
import 'package:sielto/core/db/repositories/space_repository.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

/// The invariants the spec puts in the data layer on purpose, so no screen can
/// route around them.
void main() {
  late AppDatabase db;
  late SpaceClock clock;
  late SpaceRepository spaces;
  late PaymentRepository payments;
  late CategoryRepository categories;
  late IncomeRepository incomes;
  late IncomeRuleRepository rules;
  late BudgetPeriodRepository periods;

  setUpAll(SpaceClock.initialize);

  setUp(() {
    db = inMemoryDatabase();
    clock = SpaceClock(
      timezone: 'Europe/Berlin',
      now: () => DateTime.utc(2026, 3, 10, 12),
    );
    spaces = SpaceRepository(db: db, clock: clock);
    payments = PaymentRepository(db: db, clock: clock, userId: 'user-1');
    categories = CategoryRepository(
      db: db,
      clock: clock,
      userId: 'user-1',
      payments: payments,
    );
    incomes = IncomeRepository(db: db, clock: clock, userId: 'user-1');
    rules = IncomeRuleRepository(db: db, clock: clock, userId: 'user-1');
    periods = BudgetPeriodRepository(db: db, clock: clock, userId: 'user-1');
  });

  tearDown(() => db.close());

  Future<Space> makeSpace({BudgetMode mode = BudgetMode.incomeDriven}) =>
      spaces.create(
        title: 'Household',
        spaceType: SpaceType.family,
        budgetMode: mode,
        ownerId: 'user-1',
        timezone: 'Europe/Berlin',
        currencyCode: 'EUR',
      );

  group('spaces', () {
    test('an unknown timezone is refused at creation', () {
      expect(
        () => spaces.create(
          title: 'X',
          spaceType: SpaceType.personal,
          budgetMode: BudgetMode.flow,
          ownerId: 'user-1',
          timezone: 'Mars/Olympus',
          currencyCode: 'EUR',
        ),
        throwsArgumentError,
      );
    });

    test('currency is editable until the first record', () async {
      final Space space = await makeSpace();
      expect(await spaces.canChangeCurrency(space.id), isTrue);
      await spaces.setCurrency(space.id, 'USD');
      expect((await spaces.byId(space.id))!.currencyCode, 'USD');
    });

    test('a payment freezes the currency', () async {
      final Space space = await makeSpace();
      await payments.create(
        spaceId: space.id,
        title: 'Rent',
        amount: Decimal.fromInt(1200),
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
      );

      expect(await spaces.canChangeCurrency(space.id), isFalse);
      expect(
        () => spaces.setCurrency(space.id, 'USD'),
        throwsA(isA<CurrencyFrozen>()),
      );
    });

    test('an income freezes it too', () async {
      final Space space = await makeSpace();
      await incomes.create(
        spaceId: space.id,
        title: 'Salary',
        expectedDate: const CalendarDate(2026, 3, 26),
        amount: Decimal.fromInt(3000),
      );
      expect(await spaces.canChangeCurrency(space.id), isFalse);
    });

    test('a soft-deleted record does not freeze it', () async {
      // "First record" means a non-deleted payment or income (plan G9).
      final Space space = await makeSpace();
      final Payment p = await payments.create(
        spaceId: space.id,
        title: 'Rent',
        amount: Decimal.fromInt(1200),
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
      );
      await payments.softDelete(p.id);

      expect(await spaces.canChangeCurrency(space.id), isTrue);
    });

    test('setting the manual balance stamps when it was true', () async {
      final Space space = await makeSpace(mode: BudgetMode.flow);
      await spaces.setManualBalance(space.id, Decimal.fromInt(842));

      final Space updated = (await spaces.byId(space.id))!;
      expect(updated.manualBalance, Decimal.fromInt(842));
      // The walker needs the timestamp, not just the figure (plan G1).
      expect(updated.manualBalanceUpdatedAt, DateTime.utc(2026, 3, 10, 12));
    });
  });

  group('payments', () {
    test('new rows land at the end of their day, spaced apart', () async {
      final Space space = await makeSpace();
      const CalendarDate day = CalendarDate(2026, 3, 1);
      for (final String title in <String>['Rent', 'Internet', 'Gym']) {
        await payments.create(
          spaceId: space.id,
          title: title,
          amount: Decimal.one,
          dueDate: day,
          expenseType: ExpenseType.mandatory,
        );
      }

      final List<Payment> rows = await payments.onDay(space.id, day);
      expect(rows.map((Payment p) => p.title), <String>[
        'Rent',
        'Internet',
        'Gym',
      ]);
      expect(rows.map((Payment p) => p.sortOrder), <int>[0, 1024, 2048]);
    });

    test('a duplicate sort_order still orders deterministically', () async {
      // sort_order is not unique on purpose (plan G2), so id breaks the tie.
      final Space space = await makeSpace();
      const CalendarDate day = CalendarDate(2026, 3, 1);
      final Payment a = await payments.create(
        spaceId: space.id,
        title: 'A',
        amount: Decimal.one,
        dueDate: day,
        expenseType: ExpenseType.variable,
      );
      final Payment b = await payments.create(
        spaceId: space.id,
        title: 'B',
        amount: Decimal.one,
        dueDate: day,
        expenseType: ExpenseType.variable,
      );
      await payments.update(b.id, sortOrder: const Value<int>(0));

      final List<String> first = (await payments.onDay(
        space.id,
        day,
      )).map((Payment p) => p.id).toList();
      final List<String> second = (await payments.onDay(
        space.id,
        day,
      )).map((Payment p) => p.id).toList();
      expect(first, second);
      expect(first, <String>[a.id, b.id]..sort());
    });

    test('titles are trimmed on the way in and on update', () async {
      final Space space = await makeSpace();
      final Payment p = await payments.create(
        spaceId: space.id,
        title: '  Rent  ',
        amount: Decimal.one,
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
      );
      expect(p.title, 'Rent');

      await payments.update(p.id, title: const Value<String>('  Flat  '));
      expect((await payments.byId(p.id))!.title, 'Flat');
    });

    test('an update re-stamps the row', () async {
      final Space space = await makeSpace();
      final Payment p = await payments.create(
        spaceId: space.id,
        title: 'Rent',
        amount: Decimal.one,
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
      );
      await payments.setPaid(p.id, isPaid: true);

      final Payment updated = (await payments.byId(p.id))!;
      expect(updated.isPaid, isTrue);
      expect(updated.syncStatus, SyncStatus.pending);
      expect(updated.lastModifiedBy, 'user-1');
    });
  });

  group('categories', () {
    test('the title is editable while nothing visible is bound', () async {
      final Space space = await makeSpace();
      final Category c = await categories.create(
        spaceId: space.id,
        title: 'Rnet',
      );

      expect(await categories.canRename(c.id), isTrue);
      await categories.rename(c.id, 'Rent');
      expect((await categories.inSpace(space.id)).single.title, 'Rent');
    });

    test('a visible payment freezes the title forever', () async {
      final Space space = await makeSpace();
      final Category c = await categories.create(
        spaceId: space.id,
        title: 'Rent',
      );
      await payments.create(
        spaceId: space.id,
        title: 'March rent',
        amount: Decimal.one,
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
        categoryId: c.id,
      );

      expect(await categories.canRename(c.id), isFalse);
      expect(
        () => categories.rename(c.id, 'Housing'),
        throwsA(isA<CategoryTitleFrozen>()),
      );
    });

    test('a soft-deleted payment does not freeze it', () async {
      // Nothing visible is distorted by the rename, so it stays allowed
      // (spec 7).
      final Space space = await makeSpace();
      final Category c = await categories.create(
        spaceId: space.id,
        title: 'Rent',
      );
      final Payment p = await payments.create(
        spaceId: space.id,
        title: 'March rent',
        amount: Decimal.one,
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
        categoryId: c.id,
      );
      await payments.softDelete(p.id);

      expect(await categories.canRename(c.id), isTrue);
    });

    test('appearance stays editable once the title is frozen', () async {
      final Space space = await makeSpace();
      final Category c = await categories.create(
        spaceId: space.id,
        title: 'Rent',
      );
      await payments.create(
        spaceId: space.id,
        title: 'March rent',
        amount: Decimal.one,
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
        categoryId: c.id,
      );

      await categories.updateAppearance(
        c.id,
        color: const Value<String?>('#8FB996'),
        expenseType: const Value<ExpenseType>(ExpenseType.mandatory),
      );
      final Category updated = (await categories.inSpace(space.id)).single;
      expect(updated.color, '#8FB996');
      expect(updated.expenseType, ExpenseType.mandatory);
      expect(updated.title, 'Rent');
    });

    test('a deleted category keeps its payments intact', () async {
      final Space space = await makeSpace();
      final Category c = await categories.create(
        spaceId: space.id,
        title: 'Rent',
      );
      final Payment p = await payments.create(
        spaceId: space.id,
        title: 'March rent',
        amount: Decimal.one,
        dueDate: const CalendarDate(2026, 3, 1),
        expenseType: ExpenseType.mandatory,
        categoryId: c.id,
      );
      await categories.softDelete(c.id);

      expect(await categories.inSpace(space.id), isEmpty);
      // category_id is untouched: history still reads the same (spec 7).
      expect((await payments.byId(p.id))!.categoryId, c.id);
      expect(await categories.allEverInSpace(space.id), hasLength(1));
    });

    test('the starter set lands in order, dressed', () async {
      final Space space = await makeSpace();
      await categories.createStarterSet(
        space.id,
        <({String title, String? icon, String? color, ExpenseType type})>[
          (
            title: 'Rent',
            icon: '🏠',
            color: '#8FB996',
            type: ExpenseType.mandatory,
          ),
          (
            title: 'Utilities',
            icon: '💡',
            color: '#CBB98F',
            type: ExpenseType.mandatory,
          ),
          (
            title: 'Groceries',
            icon: '🛒',
            color: '#E29A5C',
            type: ExpenseType.variable,
          ),
        ],
      );

      final List<Category> rows = await categories.inSpace(space.id);
      expect(rows.map((Category c) => c.title), <String>[
        'Rent',
        'Utilities',
        'Groceries',
      ]);
      // A starter set arrives ready to look at, not as three blank names.
      expect(rows.first.icon, '🏠');
      expect(rows.first.color, '#8FB996');
      expect(rows.first.expenseType, ExpenseType.mandatory);
      expect(rows.last.expenseType, ExpenseType.variable);
    });
  });

  group('income anchors', () {
    Future<IncomeRecurrenceRule> addRule(
      Space space, {
      required bool anchor,
      String title = 'Salary',
    }) => rules.create(
      spaceId: space.id,
      title: title,
      scheduleType: ScheduleType.fixedDate,
      fixedDay: 26,
      isAnchor: anchor,
    );

    test('the first regular income becomes the anchor', () async {
      final Space space = await makeSpace();
      final IncomeRecurrenceRule rule = await rules.createFirstAsAnchor(
        spaceId: space.id,
        mode: BudgetMode.incomeDriven,
        title: 'Salary',
        scheduleType: ScheduleType.fixedDate,
        fixedDay: 26,
      );
      expect(rule.isAnchor, isTrue);
    });

    test('the second one does not', () async {
      final Space space = await makeSpace();
      await rules.createFirstAsAnchor(
        spaceId: space.id,
        mode: BudgetMode.incomeDriven,
        title: 'Salary',
        scheduleType: ScheduleType.fixedDate,
        fixedDay: 26,
      );
      final IncomeRecurrenceRule second = await rules.createFirstAsAnchor(
        spaceId: space.id,
        mode: BudgetMode.incomeDriven,
        title: 'Freelance',
        scheduleType: ScheduleType.fixedDate,
        fixedDay: 10,
      );
      expect(second.isAnchor, isFalse);
    });

    test('Flow never anchors, since it has no periods', () async {
      final Space space = await makeSpace(mode: BudgetMode.flow);
      final IncomeRecurrenceRule rule = await rules.createFirstAsAnchor(
        spaceId: space.id,
        mode: BudgetMode.flow,
        title: 'Salary',
        scheduleType: ScheduleType.fixedDate,
        fixedDay: 26,
      );
      expect(rule.isAnchor, isFalse);
    });

    test('the last anchor cannot be demoted', () async {
      final Space space = await makeSpace();
      final IncomeRecurrenceRule only = await addRule(space, anchor: true);

      expect(
        () => rules.setAnchor(
          only.id,
          isAnchor: false,
          mode: BudgetMode.incomeDriven,
        ),
        throwsA(isA<LastAnchorRequired>()),
      );
    });

    test('the last anchor cannot be deleted', () async {
      final Space space = await makeSpace();
      final IncomeRecurrenceRule only = await addRule(space, anchor: true);

      expect(
        () => rules.deleteRule(only.id, mode: BudgetMode.incomeDriven),
        throwsA(isA<LastAnchorRequired>()),
      );
    });

    test('one of two anchors can go', () async {
      final Space space = await makeSpace();
      final IncomeRecurrenceRule first = await addRule(space, anchor: true);
      await addRule(space, anchor: true, title: 'Partner salary');

      await rules.deleteRule(first.id, mode: BudgetMode.incomeDriven);
      expect(await rules.anchorsInSpace(space.id), hasLength(1));
    });

    test('a non-anchor rule deletes freely', () async {
      final Space space = await makeSpace();
      await addRule(space, anchor: true);
      final IncomeRecurrenceRule extra = await addRule(
        space,
        anchor: false,
        title: 'Bonus',
      );

      await rules.deleteRule(extra.id, mode: BudgetMode.incomeDriven);
      expect(await rules.inSpace(space.id), hasLength(1));
    });

    test('Flow ignores the anchor rule entirely', () async {
      final Space space = await makeSpace(mode: BudgetMode.flow);
      final IncomeRecurrenceRule rule = await addRule(space, anchor: true);
      await rules.deleteRule(rule.id, mode: BudgetMode.flow);
      expect(await rules.inSpace(space.id), isEmpty);
    });
  });

  group('incomes', () {
    test('an income with no amount needs one to be received', () async {
      // Otherwise the period's Free Cash stays uncomputable (spec 4.7).
      final Space space = await makeSpace();
      final Income row = await incomes.create(
        spaceId: space.id,
        title: 'Salary',
        expectedDate: const CalendarDate(2026, 3, 26),
      );

      expect(() => incomes.markReceived(row.id), throwsArgumentError);

      await incomes.markReceived(row.id, amount: Decimal.fromInt(3120));
      final Income updated = (await incomes.inSpace(space.id)).single;
      expect(updated.isPaid, isTrue);
      expect(updated.amount, Decimal.fromInt(3120));
    });

    test('a known amount receives without repeating it', () async {
      final Space space = await makeSpace();
      final Income row = await incomes.create(
        spaceId: space.id,
        title: 'Salary',
        expectedDate: const CalendarDate(2026, 3, 26),
        amount: Decimal.fromInt(3000),
      );

      await incomes.markReceived(
        row.id,
        actualDate: const CalendarDate(2026, 3, 25),
      );
      final Income updated = (await incomes.inSpace(space.id)).single;
      expect(updated.isPaid, isTrue);
      expect(updated.amount, Decimal.fromInt(3000));
      // The actual date never moves the expected one (spec 5.4).
      expect(updated.expectedDate, const CalendarDate(2026, 3, 26));
      expect(updated.actualDate, const CalendarDate(2026, 3, 25));
    });
  });

  group('budget periods', () {
    test('the continuous row is created once', () async {
      final Space space = await makeSpace(mode: BudgetMode.flow);
      final BudgetPeriod first = await periods.ensureContinuous(
        spaceId: space.id,
        startDate: const CalendarDate(2026, 1, 1),
      );
      final BudgetPeriod second = await periods.ensureContinuous(
        spaceId: space.id,
        startDate: const CalendarDate(2026, 2, 1),
      );

      // Idempotent, so calling it on every space open is safe (plan G8).
      expect(second.id, first.id);
      expect(await periods.inSpace(space.id), hasLength(1));
      expect(first.endDate, isNull);
    });

    test('a continuous period contains every later date', () async {
      final Space space = await makeSpace(mode: BudgetMode.flow);
      await periods.ensureContinuous(
        spaceId: space.id,
        startDate: const CalendarDate(2026, 1, 1),
      );

      expect(
        await periods.containing(space.id, const CalendarDate(2030, 6, 1)),
        isNotNull,
      );
      expect(
        await periods.containing(space.id, const CalendarDate(2025, 12, 31)),
        isNull,
      );
    });

    test('income-driven bounds are inclusive at both ends', () async {
      final Space space = await makeSpace();
      await periods.createIncomeDriven(
        spaceId: space.id,
        startDate: const CalendarDate(2026, 3, 10),
        endDate: const CalendarDate(2026, 4, 9),
        anchorDate: const CalendarDate(2026, 3, 10),
      );

      for (final CalendarDate inside in <CalendarDate>[
        const CalendarDate(2026, 3, 10),
        const CalendarDate(2026, 3, 25),
        const CalendarDate(2026, 4, 9),
      ]) {
        expect(
          await periods.containing(space.id, inside),
          isNotNull,
          reason: '$inside should be inside',
        );
      }
      expect(
        await periods.containing(space.id, const CalendarDate(2026, 4, 10)),
        isNull,
        reason: 'the next anchor day belongs to the next period',
      );
    });
  });
}
