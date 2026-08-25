import 'dart:io';

import 'package:budget_app/core/crypto/database_key.dart';
import 'package:budget_app/core/db/converters.dart';
import 'package:budget_app/core/db/tables.dart';
// The generated part file names these types; they must be in scope here.
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

/// The local database — the source of truth. The cloud is transport, never
/// archival storage (spec 10.1).
@DriftDatabase(
  tables: <Type>[
    Spaces,
    SpaceMembers,
    MemberLocalLabels,
    UserProfiles,
    Categories,
    BudgetPeriods,
    IncomeRecurrenceRules,
    Incomes,
    Payments,
    HolidayCache,
    CustomNonWorkingDays,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bumped on every schema change, with a step in [migration] and a test that
  /// walks every prior version forward (spec 10.6).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes(this);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // v1 is the first version; there is nothing to step from yet. Every
      // future version adds a branch here and never edits an earlier one.
    },
    beforeOpen: (OpeningDetails details) async {
      // Drift disables it per connection, and soft deletes lean on it.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Indexes that Drift's table definitions cannot express.
Future<void> _createIndexes(DatabaseConnectionUser db) async {
  // Two active categories cannot share a name; a deleted one frees its name
  // for reuse (spec 7).
  await db.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS categories_unique_active_title '
    'ON categories (space_id, lower(title)) WHERE is_deleted = 0',
  );

  // The Feed and the ledger walker read a Space's rows in date order, always
  // filtered to the undeleted ones.
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS payments_space_due_date '
    'ON payments (space_id, due_date) WHERE is_deleted = 0',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS incomes_space_expected_date '
    'ON incomes (space_id, expected_date) WHERE is_deleted = 0',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS budget_periods_space_start '
    'ON budget_periods (space_id, start_date) WHERE is_deleted = 0',
  );

  // The sync worker scans for unsent rows across tables.
  for (final String table in <String>[
    'payments',
    'incomes',
    'categories',
    'income_recurrence_rules',
    'budget_periods',
  ]) {
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS ${table}_pending_sync '
      "ON $table (space_id) WHERE sync_status = 'pending'",
    );
  }
}

/// Opens the encrypted database file.
///
/// The key is applied before any other statement — SQLCipher requires it as
/// the first operation on the connection — and then verified by a read that
/// touches a page. Without that read a wrong key surfaces later, at a random
/// query, instead of here (spec 2.2).
QueryExecutor openEncryptedDatabase({
  required Directory directory,
  required DatabaseKey key,
  String fileName = 'budget.sqlite',
}) {
  final File file = File(p.join(directory.path, fileName));
  directory.createSync(recursive: true);

  return NativeDatabase.createInBackground(
    file,
    setup: (Database raw) {
      raw.execute('PRAGMA key = ${key.toPragmaLiteral()}');
      raw.execute('SELECT count(*) FROM sqlite_schema');
    },
  );
}
