import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// M1 exit criterion: the file on disk is unreadable by a third-party client.
///
/// Also proves the SQLCipher build is actually linked. Plain SQLite ignores
/// `PRAGMA key` silently and would leave a readable file, so these assertions
/// fail loudly if the `hooks` block in pubspec.yaml stops taking effect.
void main() {
  late Directory dir;
  late String path;

  /// SQLCipher takes a raw key as the string `x'<hex>'`, skipping its
  /// passphrase KDF — the DEK is already random, deriving from it adds nothing.
  /// The documented spelling wraps that in double quotes, which this build
  /// rejects (SQLITE_DQS=0), so the quotes are single and doubled to escape.
  String rawKeyLiteral(Uint8List bytes) {
    final String hex = bytes
        .map((int b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return "'x''$hex'''";
  }

  Uint8List randomKey() {
    final Random rng = Random.secure();
    return Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
  }

  Database openKeyed(String at, Uint8List key) {
    final Database db = sqlite3.open(at);
    addTearDown(db.close);
    db.execute('PRAGMA key = ${rawKeyLiteral(key)}');
    return db;
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('budget_sqlcipher_');
    path = '${dir.path}/test.sqlite';
  });

  tearDown(() {
    // Windows keeps a lock until every handle is gone; a failed test can leave
    // one behind, and a stale temp directory is not worth failing over.
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // ignored
    }
  });

  test('SQLCipher is the linked build', () {
    // cipher_version is absent from plain SQLite.
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);
    final ResultSet result = db.select('PRAGMA cipher_version');
    expect(result, isNotEmpty, reason: 'not a SQLCipher build');
  });

  test('an encrypted database is unreadable without the key', () {
    final Database db = openKeyed(path, randomKey());
    db.execute('CREATE TABLE secret (note TEXT NOT NULL)');
    db.execute("INSERT INTO secret (note) VALUES ('rent 1200')");
    db.close();

    final Uint8List bytes = File(path).readAsBytesSync();
    expect(
      String.fromCharCodes(bytes.take(16)),
      isNot(startsWith('SQLite format 3')),
      reason: 'plaintext SQLite header',
    );
    expect(
      String.fromCharCodes(bytes),
      isNot(contains('rent 1200')),
      reason: 'row payload readable on disk',
    );

    final Database unkeyed = sqlite3.open(path);
    addTearDown(unkeyed.close);
    expect(
      () => unkeyed.select('SELECT * FROM secret'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('the same key reopens it', () {
    final Uint8List key = randomKey();

    final Database first = openKeyed(path, key);
    first.execute('CREATE TABLE secret (note TEXT NOT NULL)');
    first.execute("INSERT INTO secret (note) VALUES ('rent 1200')");
    first.close();

    final Database second = openKeyed(path, key);
    expect(
      second.select('SELECT note FROM secret').single['note'],
      'rent 1200',
    );
  });

  test('a different key does not', () {
    final Database first = openKeyed(path, randomKey());
    first.execute('CREATE TABLE secret (note TEXT NOT NULL)');
    first.close();

    final Database second = openKeyed(path, randomKey());
    expect(
      () => second.select('SELECT * FROM secret'),
      throwsA(isA<SqliteException>()),
    );
  });
}
