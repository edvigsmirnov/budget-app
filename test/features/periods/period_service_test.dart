import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/periods/period_service.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

/// The period service is where the M2 engine meets the tables. These tests pin
/// the rules that make history trustworthy: closed periods are never touched,
/// open ones move in place, and a received income is immovable.
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

  Future<IncomeRecurrenceRule> anchorOn(
    int day, {
    String title = 'Salary',
    String? amount = '3000',
  }) => repos.incomeRules.create(
    spaceId: space.id,
    title: title,
    scheduleType: ScheduleType.fixedDate,
    fixedDay: day,
    amount: amount == null ? null : m(amount),
    isAnchor: true,
  );

  Future<List<BudgetPeriod>> periods() =>
      repos.periods.incomeDrivenIn(space.id);

  group('with no anchor', () {
    test('a Space with no income at all is a valid state', () async {
      // Not an error, and not a blocked screen: the dashboard says to add an
      // anchor and the rest of the app keeps working (spec 4.7).
      final PeriodRefresh result = await service.refresh(space, today);
      expect(result.isEmpty, isTrue);
      expect(await periods(), isEmpty);
    });

    test('a non-anchor rule alone still produces no periods', () async {
      await repos.incomeRules.create(
        spaceId: space.id,
        title: 'Rent from tenants',
        scheduleType: ScheduleType.fixedDate,
        fixedDay: 5,
        amount: m('400'),
      );
      await service.refresh(space, today);
      expect(await periods(), isEmpty);
    });
  });

  group('materialisation', () {
    test('one anchor produces the six-period horizon', () async {
      await anchorOn(26);
      await service.refresh(space, today);

      final List<BudgetPeriod> rows = await periods();
      expect(rows, hasLength(6));
      expect(rows.first.startDate, d('2026-02-26'));
      expect(rows.first.endDate, d('2026-03-25'));
    });

    test('boundaries abut without gaps or overlaps', () async {
      await anchorOn(15);
      await service.refresh(space, today);

      final List<BudgetPeriod> rows = await periods();
      for (int i = 0; i < rows.length - 1; i++) {
        expect(rows[i].endDate!.addDays(1), rows[i + 1].startDate);
      }
    });

    test('two anchors split the month between them', () async {
      await anchorOn(10, title: 'Mine');
      await anchorOn(25, title: 'Partner');
      await service.refresh(space, today);

      final List<String> anchors = (await periods())
          .take(3)
          .map((BudgetPeriod p) => p.anchorDate!.toIso())
          .toList();
      expect(anchors, <String>['2026-03-10', '2026-03-25', '2026-04-10']);
    });

    test('coincident anchors merge into one period', () async {
      // The invariant that rules out zero-length periods (spec 4.7).
      await anchorOn(15, title: 'Mine');
      await anchorOn(15, title: 'Partner');
      await service.refresh(space, today);

      final List<BudgetPeriod> rows = await periods();
      for (final BudgetPeriod p in rows) {
        expect(p.startDate.daysUntil(p.endDate!) + 1, greaterThanOrEqualTo(1));
      }
      expect(
        rows.map((BudgetPeriod p) => p.anchorDate!.toIso()).toSet(),
        hasLength(rows.length),
      );
    });

    test('a second refresh is idempotent', () async {
      await anchorOn(26);
      await service.refresh(space, today);
      final List<String> firstIds = (await periods())
          .map((BudgetPeriod p) => p.id)
          .toList();

      await service.refresh(space, today);
      final List<String> secondIds = (await periods())
          .map((BudgetPeriod p) => p.id)
          .toList();

      expect(secondIds, firstIds);
    });
  });

  group('future incomes', () {
    test(
      'each rule materialises its occurrences up to the last boundary',
      () async {
        // Occurrences stop where the periods do, so every row has a period to
        // belong to; the two horizons move forward together.
        await anchorOn(26);
        await service.refresh(space, today);

        final List<Income> rows = await repos.incomes.inSpace(space.id);
        final CalendarDate lastBoundary = (await periods()).last.endDate!;
        expect(rows, isNotEmpty);
        expect(rows.first.expectedDate, d('2026-03-26'));
        expect(
          rows.every((Income i) => !i.expectedDate.isAfter(lastBoundary)),
          isTrue,
        );
        expect(rows.every((Income i) => i.amount == m('3000')), isTrue);
      },
    );

    test('past dates are not invented', () async {
      // The March occurrence of a 1st-of-month rule is behind us.
      await anchorOn(1);
      await service.refresh(space, today);

      final List<Income> rows = await repos.incomes.inSpace(space.id);
      expect(rows.every((Income i) => !i.expectedDate.isBefore(today)), isTrue);
    });

    test('a second refresh adds nothing', () async {
      await anchorOn(26);
      await service.refresh(space, today);
      final int first = (await repos.incomes.inSpace(space.id)).length;

      final PeriodRefresh again = await service.refresh(space, today);
      expect(again.incomesMaterialised, 0);
      expect(await repos.incomes.inSpace(space.id), hasLength(first));
    });

    test('an occurrence edited by hand survives a refresh', () async {
      await anchorOn(26);
      await service.refresh(space, today);

      final Income first = (await repos.incomes.inSpace(space.id)).first;
      await repos.incomes.update(first.id, amount: Value<Decimal?>(m('3500')));

      await service.refresh(space, today);
      final Income after = (await repos.incomes.inSpace(space.id))
          .firstWhere((Income i) => i.id == first.id);
      expect(after.amount, m('3500'));
    });

    test('a floating salary materialises with no amount', () async {
      // Unknown, not zero (spec 4.7).
      await anchorOn(26, amount: null);
      await service.refresh(space, today);

      final List<Income> rows = await repos.incomes.inSpace(space.id);
      expect(rows, isNotEmpty);
      expect(rows.every((Income i) => i.amount == null), isTrue);
    });

    test('non-anchor rules materialise too', () async {
      await anchorOn(26);
      await repos.incomeRules.create(
        spaceId: space.id,
        title: 'Rent from tenants',
        scheduleType: ScheduleType.fixedDate,
        fixedDay: 15,
        amount: m('400'),
      );
      await service.refresh(space, today);

      final List<Income> rows = await repos.incomes.inSpace(space.id);
      expect(
        rows.where((Income i) => i.title == 'Rent from tenants'),
        isNotEmpty,
      );
    });
  });

  group('closed periods are history', () {
    test('a period whose end has passed is never rewritten', () async {
      await anchorOn(26);
      await service.refresh(space, today);
      final BudgetPeriod closed = (await periods()).first;

      // Move time past the end of that first period and reshape the schedule.
      final CalendarDate later = d('2026-05-10');
      await service.refresh(space, later);

      final BudgetPeriod after = (await repos.periods.inSpace(space.id))
          .firstWhere((BudgetPeriod p) => p.id == closed.id);
      expect(after.startDate, closed.startDate);
      expect(after.endDate, closed.endDate);
    });

    test('open periods move in place, keeping their id', () async {
      await anchorOn(26);
      await service.refresh(space, today);
      final BudgetPeriod current = (await periods()).first;

      // The user corrects the payday: the current, still-open period is
      // recomputed (spec 5.4).
      await repos.incomeRules.softDelete(
        (await repos.incomeRules.inSpace(space.id)).first.id,
      );
      await anchorOn(20);
      await service.refresh(space, today);

      final BudgetPeriod after = (await periods()).first;
      expect(after.id, current.id, reason: 'the row moved, not replaced');
      expect(after.anchorDate, isNot(current.anchorDate));
    });
  });

  group('binding records to periods', () {
    test('an auto payment binds to the period holding its date', () async {
      await anchorOn(26);
      final Payment payment = await repos.payments.create(
        spaceId: space.id,
        title: 'Rent',
        amount: m('600'),
        dueDate: d('2026-03-15'),
        expenseType: ExpenseType.mandatory,
      );
      await service.refresh(space, today);

      final Payment after = (await repos.payments.byId(payment.id))!;
      final BudgetPeriod containing = (await periods()).firstWhere(
        (BudgetPeriod p) => p.startDate == d('2026-02-26'),
      );
      expect(after.budgetPeriodId, containing.id);
    });

    test(
      'a payment due on the next anchor belongs to the next period',
      () async {
        // The money has arrived that day, so it is the new cycle's (spec 4.7).
        await anchorOn(26);
        final Payment payment = await repos.payments.create(
          spaceId: space.id,
          title: 'Card',
          amount: m('100'),
          dueDate: d('2026-03-26'),
          expenseType: ExpenseType.mandatory,
        );
        await service.refresh(space, today);

        final Payment after = (await repos.payments.byId(payment.id))!;
        final BudgetPeriod next = (await periods()).firstWhere(
          (BudgetPeriod p) => p.startDate == d('2026-03-26'),
        );
        expect(after.budgetPeriodId, next.id);
      },
    );

    test('a manual pin survives a recompute', () async {
      await anchorOn(26);
      await service.refresh(space, today);
      final BudgetPeriod chosen = (await periods()).last;

      final Payment payment = await repos.payments.create(
        spaceId: space.id,
        title: 'Deliberate',
        amount: m('100'),
        dueDate: d('2026-03-15'),
        expenseType: ExpenseType.variable,
      );
      await repos.payments.setPeriod(
        payment.id,
        chosen.id,
        assignment: PeriodAssignment.manual,
      );

      await service.refresh(space, today);
      final Payment after = (await repos.payments.byId(payment.id))!;
      expect(after.budgetPeriodId, chosen.id);
      expect(after.periodAssignment, PeriodAssignment.manual);
    });

    test('a pin to a vanished period falls back to auto', () async {
      await anchorOn(26);
      await service.refresh(space, today);
      final BudgetPeriod doomed = (await periods()).last;

      final Payment payment = await repos.payments.create(
        spaceId: space.id,
        title: 'Orphan',
        amount: m('100'),
        dueDate: d('2026-03-15'),
        expenseType: ExpenseType.variable,
      );
      await repos.payments.setPeriod(
        payment.id,
        doomed.id,
        assignment: PeriodAssignment.manual,
      );

      // What a merge of two anchors looks like from here: the row the pin
      // pointed at is gone.
      await repos.periods.softDelete(doomed.id);

      final PeriodRefresh result = await service.refresh(space, today);
      final Payment after = (await repos.payments.byId(payment.id))!;
      expect(after.periodAssignment, PeriodAssignment.auto);
      expect(after.budgetPeriodId, isNotNull);
      expect(result.reboundToAuto, 1);
    });

    test('incomes bind to their period as well', () async {
      await anchorOn(26);
      await service.refresh(space, today);

      final List<Income> rows = await repos.incomes.inSpace(space.id);
      expect(rows.every((Income i) => i.budgetPeriodId != null), isTrue);
    });
  });

  test('Flow spaces are left alone entirely', () async {
    final Space flow = await repos.spaces.create(
      title: 'Freelance',
      spaceType: SpaceType.personal,
      budgetMode: BudgetMode.flow,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
    final PeriodRefresh result = await service.refresh(flow, today);
    expect(result.isEmpty, isTrue);
    expect(await repos.periods.incomeDrivenIn(flow.id), isEmpty);
  });
}
