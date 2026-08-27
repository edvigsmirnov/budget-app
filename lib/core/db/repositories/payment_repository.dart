import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/freeze_guard.dart';
import 'package:sielto/core/db/synced_repository.dart';
import 'package:sielto/domain/period/freeze.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

class PaymentRepository extends SyncedRepository<$PaymentsTable, Payment> {
  PaymentRepository({
    required super.db,
    required super.clock,
    required super.userId,
  });

  /// Gap between manual positions. Sparse so a drag between two neighbours
  /// usually needs one write instead of renumbering the day (plan G2).
  static const int sortOrderGap = 1024;

  @override
  TableInfo<$PaymentsTable, Payment> get table => db.payments;

  late final FreezeGuard _freeze = FreezeGuard(db: db, clock: clock);

  /// Which fields a frozen period protects (spec 5.5).
  ///
  /// Category and notes are absent on purpose: reclassifying a payment does
  /// not change the fact of it, and notes may only be appended.
  static bool _touchesProtected({
    required bool amount,
    required bool dueDate,
    required bool expenseType,
    required bool isPaid,
  }) => amount || dueDate || expenseType || isPaid;

  /// The Feed's day order: date, then manual position, then id.
  ///
  /// `sort_order` carries no uniqueness constraint — one would break the
  /// moment the Space switches feed mode (plan G2) — so id breaks ties and
  /// keeps the order stable across rebuilds.
  Future<List<Payment>> inSpace(String spaceId) =>
      _selectInSpace(spaceId).get();

  /// The same list as [inSpace], re-emitted on every change. The Feed and the
  /// Dashboard both read this so a write anywhere refreshes both.
  Stream<List<Payment>> watchInSpace(String spaceId) =>
      _selectInSpace(spaceId).watch();

  /// The window the Feed opens with: three months either side of [around]
  /// (spec 4.5). Rows outside it load only when the user scrolls that far.
  Stream<List<Payment>> watchAround(
    String spaceId,
    CalendarDate from,
    CalendarDate to,
  ) =>
      (_selectInSpace(spaceId)..where(
            ($PaymentsTable t) =>
                t.dueDate.isBiggerOrEqualValue(from.toIso()) &
                t.dueDate.isSmallerOrEqualValue(to.toIso()),
          ))
          .watch();

  SimpleSelectStatement<$PaymentsTable, Payment> _selectInSpace(
    String spaceId,
  ) =>
      selectAliveInSpace(spaceId)
        ..orderBy(<OrderClauseGenerator<$PaymentsTable>>[
          ($PaymentsTable t) => OrderingTerm(expression: t.dueDate),
          ($PaymentsTable t) => OrderingTerm(expression: t.sortOrder),
          ($PaymentsTable t) => OrderingTerm(expression: t.id),
        ]);

  Future<List<Payment>> onDay(String spaceId, CalendarDate day) =>
      (selectAliveInSpace(spaceId)
            ..where(($PaymentsTable t) => t.dueDate.equals(day.toIso()))
            ..orderBy(<OrderClauseGenerator<$PaymentsTable>>[
              ($PaymentsTable t) => OrderingTerm(expression: t.sortOrder),
              ($PaymentsTable t) => OrderingTerm(expression: t.id),
            ]))
          .get();

  Future<Payment?> byId(String id) =>
      (selectAlive()..where(($PaymentsTable t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Appends a payment to the end of its day.
  Future<Payment> create({
    required String spaceId,
    required String title,
    required Decimal amount,
    required CalendarDate dueDate,
    required ExpenseType expenseType,
    String? categoryId,
    String? budgetPeriodId,
    String? groupRecurringId,
    String? notes,
    bool isPaid = false,
  }) async {
    final ({String author, DateTime editedAt}) s = stamp();
    final PaymentsCompanion row = PaymentsCompanion.insert(
      id: SyncedRepository.newId(),
      spaceId: spaceId,
      title: title.trim(),
      amount: amount,
      dueDate: dueDate,
      expenseType: expenseType,
      categoryId: Value<String?>(categoryId),
      budgetPeriodId: Value<String?>(budgetPeriodId),
      groupRecurringId: Value<String?>(groupRecurringId),
      notes: Value<String?>(notes),
      isPaid: Value<bool>(isPaid),
      sortOrder: Value<int>(await nextSortOrder(spaceId, dueDate)),
      syncStatus: const Value<SyncStatus>(SyncStatus.pending),
      lastModifiedBy: Value<String?>(s.author),
      clientEditedAt: s.editedAt,
      createdAt: s.editedAt,
    );
    return db.into(db.payments).insertReturning(row);
  }

  /// Applies only the fields passed, and always re-stamps the row.
  Future<int> update(
    String id, {
    Value<String> title = const Value<String>.absent(),
    Value<Decimal> amount = const Value<Decimal>.absent(),
    Value<CalendarDate> dueDate = const Value<CalendarDate>.absent(),
    Value<ExpenseType> expenseType = const Value<ExpenseType>.absent(),
    Value<String?> categoryId = const Value<String?>.absent(),
    Value<String?> notes = const Value<String?>.absent(),
    Value<bool> isPaid = const Value<bool>.absent(),
    Value<int> sortOrder = const Value<int>.absent(),
  }) async {
    // Reordering is not restricted by the freeze: it changes no protected
    // field and distorts no history (spec 4.5).
    if (_touchesProtected(
      amount: amount.present,
      dueDate: dueDate.present,
      expenseType: expenseType.present,
      isPaid: isPaid.present,
    )) {
      final Payment? row = await byId(id);
      await _freeze.refuseIfFrozen(row?.budgetPeriodId);
    }

    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.payments,
    )..where(($PaymentsTable t) => t.id.equals(id))).write(
      PaymentsCompanion(
        title: title.present
            ? Value<String>(title.value.trim())
            : const Value<String>.absent(),
        amount: amount,
        dueDate: dueDate,
        expenseType: expenseType,
        categoryId: categoryId,
        notes: notes,
        isPaid: isPaid,
        sortOrder: sortOrder,
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  Future<int> setPaid(String id, {required bool isPaid}) =>
      update(id, isPaid: Value<bool>(isPaid));

  /// Deleting is a protected change too: a frozen period keeps its rows
  /// (spec 5.5).
  @override
  Future<int> softDelete(String id) async {
    final Payment? row = await byId(id);
    await _freeze.refuseIfFrozen(row?.budgetPeriodId);
    return super.softDelete(id);
  }

  /// The freeze state of one payment, for a screen deciding what to enable.
  Future<FreezeState> freezeStateOf(String id) async {
    final Payment? row = await byId(id);
    return _freeze.stateOf(row?.budgetPeriodId);
  }

  /// Materialises a repeating payment as one row per occurrence, sharing a
  /// `group_recurring_id` (spec 6.3).
  ///
  /// Physical rows, not a rule evaluated at read time: it is what lets one
  /// month be corrected — a final instalment that is a little smaller — without
  /// rebuilding the series.
  Future<String> createSeries({
    required String spaceId,
    required String title,
    required Decimal amount,
    required List<CalendarDate> dates,
    required ExpenseType expenseType,
    String? categoryId,
    String? notes,
  }) async {
    final String groupId = SyncedRepository.newId();
    final ({String author, DateTime editedAt}) s = stamp();

    await db.batch((Batch b) {
      b.insertAll(db.payments, <PaymentsCompanion>[
        for (final CalendarDate date in dates)
          PaymentsCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            title: title.trim(),
            amount: amount,
            dueDate: date,
            expenseType: expenseType,
            categoryId: Value<String?>(categoryId),
            groupRecurringId: Value<String>(groupId),
            notes: Value<String?>(notes),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
      ]);
    });

    return groupId;
  }

  /// The "all future" branch of the series edit dialog (spec 6.3).
  ///
  /// Rows already marked paid are left alone: they record what happened, and
  /// a change to the plan does not rewrite history.
  Future<int> updateSeriesFrom(
    String groupRecurringId,
    CalendarDate from, {
    Value<String> title = const Value<String>.absent(),
    Value<Decimal> amount = const Value<Decimal>.absent(),
    Value<ExpenseType> expenseType = const Value<ExpenseType>.absent(),
    Value<String?> categoryId = const Value<String?>.absent(),
    Value<String?> notes = const Value<String?>.absent(),
  }) => _writeSeries(
    groupRecurringId,
    from: from,
    title: title,
    amount: amount,
    expenseType: expenseType,
    categoryId: categoryId,
    notes: notes,
  );

  /// The "whole series" branch: every occurrence, past ones included, except
  /// those already paid.
  Future<int> updateWholeSeries(
    String groupRecurringId, {
    Value<String> title = const Value<String>.absent(),
    Value<Decimal> amount = const Value<Decimal>.absent(),
    Value<ExpenseType> expenseType = const Value<ExpenseType>.absent(),
    Value<String?> categoryId = const Value<String?>.absent(),
    Value<String?> notes = const Value<String?>.absent(),
  }) => _writeSeries(
    groupRecurringId,
    title: title,
    amount: amount,
    expenseType: expenseType,
    categoryId: categoryId,
    notes: notes,
  );

  /// Soft-deletes a whole series, or its future half.
  Future<int> deleteSeries(String groupRecurringId, {CalendarDate? from}) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(db.payments)..where(
          ($PaymentsTable t) => _seriesFilter(t, groupRecurringId, from),
        ))
        .write(
          PaymentsCompanion(
            isDeleted: const Value<bool>(true),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: Value<DateTime>(s.editedAt),
          ),
        );
  }

  Future<int> _writeSeries(
    String groupRecurringId, {
    CalendarDate? from,
    Value<String> title = const Value<String>.absent(),
    Value<Decimal> amount = const Value<Decimal>.absent(),
    Value<ExpenseType> expenseType = const Value<ExpenseType>.absent(),
    Value<String?> categoryId = const Value<String?>.absent(),
    Value<String?> notes = const Value<String?>.absent(),
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(db.payments)..where(
          ($PaymentsTable t) =>
              _seriesFilter(t, groupRecurringId, from) & t.isPaid.equals(false),
        ))
        .write(
          PaymentsCompanion(
            title: title.present
                ? Value<String>(title.value.trim())
                : const Value<String>.absent(),
            amount: amount,
            expenseType: expenseType,
            categoryId: categoryId,
            notes: notes,
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: Value<DateTime>(s.editedAt),
          ),
        );
  }

  Expression<bool> _seriesFilter(
    $PaymentsTable t,
    String groupRecurringId,
    CalendarDate? from,
  ) {
    final Expression<bool> base =
        t.groupRecurringId.equals(groupRecurringId) & t.isDeleted.equals(false);
    return from == null
        ? base
        : base & t.dueDate.isBiggerOrEqualValue(from.toIso());
  }

  /// Binds a payment to a period.
  ///
  /// [assignment] records *how* it was bound, which decides what a later
  /// recompute may do: an `auto` row is rebound by date, a `manual` one holds
  /// the period the user chose (spec 5.3).
  Future<int> setPeriod(
    String id,
    String? periodId, {
    PeriodAssignment? assignment,
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.payments,
    )..where(($PaymentsTable t) => t.id.equals(id))).write(
      PaymentsCompanion(
        budgetPeriodId: Value<String?>(periodId),
        periodAssignment: assignment == null
            ? const Value<PeriodAssignment>.absent()
            : Value<PeriodAssignment>(assignment),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// Every live payment bound by date rather than by hand. These are the rows
  /// a recompute is allowed to rebind.
  Future<List<Payment>> autoAssignedIn(String spaceId) =>
      (selectAliveInSpace(spaceId)..where(
            ($PaymentsTable t) =>
                t.periodAssignment.equalsValue(PeriodAssignment.auto),
          ))
          .get();

  /// Rows pinned to a period that no longer exists. They return to `auto`
  /// rather than dangling (spec 5.3).
  Future<List<Payment>> manuallyAssignedIn(String spaceId) =>
      (selectAliveInSpace(spaceId)..where(
            ($PaymentsTable t) =>
                t.periodAssignment.equalsValue(PeriodAssignment.manual),
          ))
          .get();

  /// One gap past the last row of that day.
  Future<int> nextSortOrder(String spaceId, CalendarDate day) async {
    final List<Payment> rows = await onDay(spaceId, day);
    if (rows.isEmpty) return 0;
    return rows.last.sortOrder + sortOrderGap;
  }

  /// Whether any visible payment uses [categoryId]. Drives the category title
  /// freeze (spec 7); soft-deleted payments do not count.
  Future<bool> anyVisibleInCategory(String categoryId) async {
    final Payment? hit =
        await (selectAlive()
              ..where(($PaymentsTable t) => t.categoryId.equals(categoryId))
              ..limit(1))
            .getSingleOrNull();
    return hit != null;
  }
}
