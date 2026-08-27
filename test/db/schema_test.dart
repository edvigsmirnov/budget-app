import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sqlite3/sqlite3.dart';

/// Guards the schema invariants the whole sync design rests on. Breaking one
/// of these is cheap to do by accident and expensive to discover at M8.
void main() {
  late AppDatabase db;

  /// Tables that will be uploaded, and so must carry the sync columns
  /// (plan section 2, invariant 2).
  const List<String> syncableTables = <String>[
    'payments',
    'incomes',
    'categories',
    'income_recurrence_rules',
    'budget_periods',
    'member_local_labels',
    'user_profiles',
  ];

  setUp(() async {
    db = inMemoryDatabase();
    // Forces onCreate, so the tests run against a real migration.
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  test('schema version is 1', () {
    expect(db.schemaVersion, 1);
  });

  test('every syncable table carries all five sync columns', () async {
    for (final String table in syncableTables) {
      final List<QueryRow> columns = await db
          .customSelect('PRAGMA table_info($table)')
          .get();
      final Set<String> names = columns
          .map((QueryRow r) => r.read<String>('name'))
          .toSet();
      expect(
        names,
        containsAll(<String>[
          'is_deleted',
          'sync_status',
          'client_edited_at',
          'server_received_at',
          'last_modified_by',
        ]),
        reason: '$table is missing sync columns',
      );
    }
  });

  test('no table uses an autoincrementing key', () async {
    // UUIDv4 everywhere: two offline devices must not mint the same id.
    final List<QueryRow> rows = await db
        .customSelect(
          "SELECT name, sql FROM sqlite_schema WHERE type = 'table'",
        )
        .get();
    expect(rows, isNotEmpty);
    for (final QueryRow row in rows) {
      expect(
        row.read<String>('sql').toUpperCase(),
        isNot(contains('AUTOINCREMENT')),
        reason: '${row.read<String>('name')} autoincrements',
      );
    }
  });

  test('timestamps are stored as text, not unix seconds', () async {
    // Second precision would drop real LWW conflicts (spec 10.2).
    final List<QueryRow> columns = await db
        .customSelect('PRAGMA table_info(payments)')
        .get();
    final QueryRow editedAt = columns.firstWhere(
      (QueryRow r) => r.read<String>('name') == 'client_edited_at',
    );
    expect(editedAt.read<String>('type').toUpperCase(), 'TEXT');
  });

  test('two active categories cannot share a name', () async {
    await _seedSpace(db);
    await _insertCategory(db, id: 'c1', title: 'Rent');

    await expectLater(
      _insertCategory(db, id: 'c2', title: 'rent'),
      throwsA(isA<SqliteException>()),
      reason: 'the unique index is case-insensitive',
    );
  });

  test('deleting a category frees its name', () async {
    await _seedSpace(db);
    await _insertCategory(db, id: 'c1', title: 'Rent');
    await db.customStatement(
      "UPDATE categories SET is_deleted = 1 WHERE id = 'c1'",
    );

    await _insertCategory(db, id: 'c2', title: 'Rent');
    final List<Category> live = await (db.select(
      db.categories,
    )..where(($CategoriesTable t) => t.isDeleted.equals(false))).get();
    expect(live.single.id, 'c2');
  });

  test('a payment amount may be zero but never negative', () async {
    await _seedSpace(db);
    // Zero is a Budget-mode to-do with a deadline (spec 4.8).
    await _insertPayment(db, id: 'p0', amount: Decimal.zero);

    await expectLater(
      _insertPayment(db, id: 'p1', amount: Decimal.parse('-5')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a blank title is rejected', () async {
    await _seedSpace(db);
    await expectLater(
      _insertPayment(db, id: 'p2', amount: Decimal.one, title: '   '),
      throwsA(isA<SqliteException>()),
    );
  });

  test('money survives a round trip exactly', () async {
    await _seedSpace(db);
    // The value that makes doubles wrong.
    final Decimal amount = Decimal.parse('0.1') + Decimal.parse('0.2');
    await _insertPayment(db, id: 'p3', amount: amount);

    final Payment row = await (db.select(
      db.payments,
    )..where(($PaymentsTable t) => t.id.equals('p3'))).getSingle();
    expect(row.amount, Decimal.parse('0.3'));
    expect(row.amount.toString(), '0.3');
  });

  test('a period cannot end before it starts', () async {
    await _seedSpace(db);
    await expectLater(
      db.customStatement(
        'INSERT INTO budget_periods '
        '(id, space_id, period_type, start_date, end_date, client_edited_at) '
        "VALUES ('bp1','s1','incomeDriven','2026-03-10','2026-03-01','x')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a schedule must carry the fields its type needs', () async {
    await _seedSpace(db);
    await expectLater(
      db.customStatement(
        'INSERT INTO income_recurrence_rules '
        '(id, space_id, title, schedule_type, client_edited_at) '
        "VALUES ('r1','s1','Salary','fixedDate','x')",
      ),
      throwsA(isA<SqliteException>()),
      reason: 'fixedDate needs fixed_day',
    );
  });

  test('dates round-trip as calendar days', () async {
    await _seedSpace(db);
    await _insertPayment(db, id: 'p4', amount: Decimal.one);

    final Payment row = await (db.select(
      db.payments,
    )..where(($PaymentsTable t) => t.id.equals('p4'))).getSingle();
    expect(row.dueDate, const CalendarDate(2026, 3, 15));
  });

  test('enums are stored by name, not ordinal', () async {
    await _seedSpace(db);
    final QueryRow row = await db
        .customSelect("SELECT budget_mode FROM spaces WHERE id = 's1'")
        .getSingle();
    expect(row.read<String>('budget_mode'), 'incomeDriven');
  });
}

Future<void> _seedSpace(AppDatabase db) => db
    .into(db.spaces)
    .insert(
      SpacesCompanion.insert(
        id: 's1',
        title: 'Household',
        spaceType: SpaceType.family,
        budgetMode: BudgetMode.incomeDriven,
        ownerId: 'u1',
        storageMode: StorageMode.local,
        timezone: 'Europe/Berlin',
        currencyCode: 'EUR',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

Future<void> _insertCategory(
  AppDatabase db, {
  required String id,
  required String title,
}) => db
    .into(db.categories)
    .insert(
      CategoriesCompanion.insert(
        id: id,
        spaceId: 's1',
        title: title,
        createdAt: DateTime.utc(2026, 1, 1),
        clientEditedAt: DateTime.utc(2026, 1, 1),
      ),
    );

Future<void> _insertPayment(
  AppDatabase db, {
  required String id,
  required Decimal amount,
  String title = 'Rent',
}) => db
    .into(db.payments)
    .insert(
      PaymentsCompanion.insert(
        id: id,
        spaceId: 's1',
        title: title,
        amount: amount,
        dueDate: const CalendarDate(2026, 3, 15),
        expenseType: ExpenseType.mandatory,
        createdAt: DateTime.utc(2026, 1, 1),
        clientEditedAt: DateTime.utc(2026, 1, 1),
      ),
    );
