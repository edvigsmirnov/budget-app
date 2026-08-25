import 'dart:io';

import 'package:budget_app/core/crypto/database_key.dart';
import 'package:budget_app/core/crypto/key_store.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/time/space_clock.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

/// Outcome of opening the encrypted database at launch.
sealed class Startup {
  const Startup();
}

class StartupReady extends Startup {
  const StartupReady(this.database);

  final AppDatabase database;
}

/// The database file is there but the key is not. Never a crash and never a
/// silent wipe — the user chooses what happens next (spec 2.2).
class StartupLocked extends Startup {
  const StartupLocked(this.reason, this.manager);

  final DatabaseKeyFailure reason;
  final DatabaseKeyManager manager;
}

/// Resolves the key, then opens the database with it.
///
/// [directory] is injectable so tests run against a temp folder instead of the
/// real application support directory.
Future<Startup> openDatabase({Directory? directory}) async {
  SpaceClock.initialize();

  final Directory dir = directory ?? await getApplicationSupportDirectory();
  final DatabaseKeyManager manager = DatabaseKeyManager(directory: dir);

  final DatabaseKey key;
  try {
    key = await manager.resolve();
  } on DatabaseKeyUnavailable catch (e) {
    return StartupLocked(e.reason, manager);
  }

  return StartupReady(
    AppDatabase(openEncryptedDatabase(directory: dir, key: key)),
  );
}

/// Deletes the database and its key material, then starts fresh. The "Start
/// over" branch of the decryption-failure screen: the data is unrecoverable
/// either way, so this only removes what can no longer be read.
Future<Startup> startOver(DatabaseKeyManager manager) async {
  await manager.destroy();
  for (final String suffix in <String>['', '-wal', '-shm']) {
    final File f = File('${manager.directory.path}/budget.sqlite$suffix');
    if (f.existsSync()) f.deleteSync();
  }
  return openDatabase(directory: manager.directory);
}

/// Opens an in-memory database with the full schema. Tests only.
@visibleForTesting
AppDatabase inMemoryDatabase() => AppDatabase(NativeDatabase.memory());
