import 'package:budget_app/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated_migrations/schema.dart';

/// Migration harness (spec 10.6).
///
/// Two jobs. Today it pins the shipped schema against its snapshot, so a table
/// edited without bumping [AppDatabase.currentSchemaVersion] fails here rather
/// than on a user's device. From v2 on, the loop below walks every prior
/// version forward — the part that must not rot, so it exists before it is
/// needed.
///
/// Regenerate after any schema change:
///   dart run drift_dev schema dump lib/core/db/app_database.dart drift_schemas/
///   dart run drift_dev schema generate drift_schemas/ test/db/generated_migrations/
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('the shipped schema matches its snapshot', () async {
    // Catches a column added or a constraint changed without a version bump.
    final InitializedSchema schema = await verifier.schemaAt(
      AppDatabase.currentSchemaVersion,
    );
    final AppDatabase db = AppDatabase(schema.newConnection());
    addTearDown(db.close);

    await verifier.migrateAndValidate(
      db,
      AppDatabase.currentSchemaVersion,
      // Also fail if the database grew a table, view or trigger the snapshot
      // does not know about.
      options: const ValidationOptions(validateDropped: true),
    );
  });

  test('every prior version migrates forward', () async {
    // Empty at v1, deliberately: this covers v2 the day it lands.
    for (int from = 1; from < AppDatabase.currentSchemaVersion; from++) {
      final InitializedSchema schema = await verifier.schemaAt(from);
      final AppDatabase db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, AppDatabase.currentSchemaVersion);
      await db.close();
    }
  });

  test('a fresh database reports the current user_version', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final QueryRow row = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(row.read<int>('user_version'), AppDatabase.currentSchemaVersion);
  });
}
