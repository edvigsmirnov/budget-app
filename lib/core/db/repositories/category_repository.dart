import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/repositories/payment_repository.dart';
import 'package:budget_app/core/db/synced_repository.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:drift/drift.dart';

/// Raised when a rename is attempted on a category that already has visible
/// payments. Renaming then would rewrite history the user actually recorded
/// (spec 7).
class CategoryTitleFrozen implements Exception {
  const CategoryTitleFrozen(this.categoryId);

  final String categoryId;

  @override
  String toString() => 'CategoryTitleFrozen: $categoryId';
}

class CategoryRepository extends SyncedRepository<$CategoriesTable, Category> {
  CategoryRepository({
    required super.db,
    required super.clock,
    required super.userId,
    required this.payments,
  });

  final PaymentRepository payments;

  @override
  TableInfo<$CategoriesTable, Category> get table => db.categories;

  /// The picker list: active categories in drag order.
  Future<List<Category>> inSpace(String spaceId) =>
      _selectInSpace(spaceId).get();

  Stream<List<Category>> watchInSpace(String spaceId) =>
      _selectInSpace(spaceId).watch();

  SimpleSelectStatement<$CategoriesTable, Category> _selectInSpace(
    String spaceId,
  ) =>
      selectAliveInSpace(spaceId)
        ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
          ($CategoriesTable t) => OrderingTerm(expression: t.sortOrder),
          ($CategoriesTable t) => OrderingTerm(expression: t.title),
        ]);

  /// Including soft-deleted ones. Analytics still names them, suffixed
  /// "(deleted)" (spec 7).
  Future<List<Category>> allEverInSpace(String spaceId) =>
      _selectAllEver(spaceId).get();

  Stream<List<Category>> watchAllEverInSpace(String spaceId) =>
      _selectAllEver(spaceId).watch();

  SimpleSelectStatement<$CategoriesTable, Category> _selectAllEver(
    String spaceId,
  ) =>
      db.select(db.categories)
        ..where(($CategoriesTable t) => t.spaceId.equals(spaceId));

  Future<Category> create({
    required String spaceId,
    required String title,
    String? color,
    String? icon,
    ExpenseType expenseType = ExpenseType.variable,
    int? sortOrder,
  }) async {
    final ({String author, DateTime editedAt}) s = stamp();
    return db
        .into(db.categories)
        .insertReturning(
          CategoriesCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            title: title.trim(),
            color: Value<String?>(color),
            icon: Value<String?>(icon),
            expenseType: Value<ExpenseType>(expenseType),
            sortOrder: Value<int>(sortOrder ?? await _nextSortOrder(spaceId)),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
        );
  }

  /// The starter set, written in one batch at Space creation (spec 7).
  /// Titles come from the caller, already translated.
  Future<void> createStarterSet(String spaceId, List<String> titles) {
    final ({String author, DateTime editedAt}) s = stamp();
    return db.batch((Batch b) {
      b.insertAll(db.categories, <CategoriesCompanion>[
        for (int i = 0; i < titles.length; i++)
          CategoriesCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            title: titles[i].trim(),
            sortOrder: Value<int>(i * PaymentRepository.sortOrderGap),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
      ]);
    });
  }

  /// False once any visible payment binds to the category. The UI greys the
  /// field, but the guarantee is here — [rename] throws either way.
  Future<bool> canRename(String categoryId) async =>
      !await payments.anyVisibleInCategory(categoryId);

  Future<int> rename(String categoryId, String title) async {
    if (!await canRename(categoryId)) {
      throw CategoryTitleFrozen(categoryId);
    }
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.categories,
    )..where(($CategoriesTable t) => t.id.equals(categoryId))).write(
      CategoriesCompanion(
        title: Value<String>(title.trim()),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// Colour, icon and default type are editable forever: changing them cannot
  /// distort a recorded figure, and existing payments keep their own
  /// `expense_type` (spec 7).
  Future<int> updateAppearance(
    String categoryId, {
    Value<String?> color = const Value<String?>.absent(),
    Value<String?> icon = const Value<String?>.absent(),
    Value<ExpenseType> expenseType = const Value<ExpenseType>.absent(),
    Value<int> sortOrder = const Value<int>.absent(),
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.categories,
    )..where(($CategoriesTable t) => t.id.equals(categoryId))).write(
      CategoriesCompanion(
        color: color,
        icon: icon,
        expenseType: expenseType,
        sortOrder: sortOrder,
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  Future<int> _nextSortOrder(String spaceId) async {
    final List<Category> rows = await inSpace(spaceId);
    if (rows.isEmpty) return 0;
    return rows.last.sortOrder + PaymentRepository.sortOrderGap;
  }
}
