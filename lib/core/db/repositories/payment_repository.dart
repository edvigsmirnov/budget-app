import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/synced_repository.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

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

  /// The Feed's day order: date, then manual position, then id.
  ///
  /// `sort_order` carries no uniqueness constraint — one would break the
  /// moment the Space switches feed mode (plan G2) — so id breaks ties and
  /// keeps the order stable across rebuilds.
  Future<List<Payment>> inSpace(String spaceId) =>
      (selectAliveInSpace(spaceId)
            ..orderBy(<OrderClauseGenerator<$PaymentsTable>>[
              ($PaymentsTable t) => OrderingTerm(expression: t.dueDate),
              ($PaymentsTable t) => OrderingTerm(expression: t.sortOrder),
              ($PaymentsTable t) => OrderingTerm(expression: t.id),
            ]))
          .get();

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
  }) {
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
