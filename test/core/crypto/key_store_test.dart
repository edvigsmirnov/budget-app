import 'dart:io';
import 'dart:typed_data';

import 'package:budget_app/core/crypto/database_key.dart';
import 'package:budget_app/core/crypto/key_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the platform keystore, which no test can reach.
class _MemoryKeyStore implements WrappingKeyStore {
  Uint8List? _key;

  @override
  Future<Uint8List?> read() async => _key;

  @override
  Future<void> write(Uint8List key) async => _key = key;

  @override
  Future<void> delete() async => _key = null;
}

void main() {
  late Directory dir;
  late _MemoryKeyStore keyStore;

  DatabaseKeyManager manager() =>
      DatabaseKeyManager(directory: dir, keyStore: keyStore);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('budget_keystore_');
    keyStore = _MemoryKeyStore();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('first run mints a key and writes envelope A', () async {
    final DatabaseKey key = await manager().resolve();

    expect(key.bytes, hasLength(32));
    expect(manager().envelopeAFile.existsSync(), isTrue);
    expect(await keyStore.read(), isNotNull);
  });

  test('a later run returns the same key', () async {
    final DatabaseKey first = await manager().resolve();
    final DatabaseKey second = await manager().resolve();
    expect(second, first);
  });

  test('a lost keystore entry reports the recoverable failure', () async {
    await manager().resolve();
    // What a device migration or a keystore invalidation looks like: the file
    // survived, the hardware-bound key did not (spec 2.2).
    await keyStore.delete();

    expect(
      manager().resolve(),
      throwsA(
        isA<DatabaseKeyUnavailable>().having(
          (DatabaseKeyUnavailable e) => e.reason,
          'reason',
          DatabaseKeyFailure.wrappingKeyMissing,
        ),
      ),
    );
  });

  test('a missing envelope is reported separately', () async {
    await manager().resolve();
    manager().envelopeAFile.deleteSync();

    expect(
      manager().resolve(),
      throwsA(
        isA<DatabaseKeyUnavailable>().having(
          (DatabaseKeyUnavailable e) => e.reason,
          'reason',
          DatabaseKeyFailure.envelopeMissing,
        ),
      ),
    );
  });

  test('a corrupted envelope is reported as unreadable', () async {
    await manager().resolve();
    final File file = manager().envelopeAFile;
    final Uint8List bytes = file.readAsBytesSync();
    bytes[bytes.length - 1] ^= 0xFF;
    file.writeAsBytesSync(bytes);

    expect(
      manager().resolve(),
      throwsA(
        isA<DatabaseKeyUnavailable>().having(
          (DatabaseKeyUnavailable e) => e.reason,
          'reason',
          DatabaseKeyFailure.envelopeUnreadable,
        ),
      ),
    );
  });

  test('destroy clears both halves, and the next run starts fresh', () async {
    final DatabaseKey first = await manager().resolve();
    await manager().destroy();

    expect(manager().envelopeAFile.existsSync(), isFalse);
    expect(await keyStore.read(), isNull);
    expect(await manager().resolve(), isNot(first));
  });

  test('the envelope file does not contain the key', () async {
    final DatabaseKey key = await manager().resolve();
    final String onDisk = manager().envelopeAFile.readAsBytesSync().join(',');
    expect(onDisk, isNot(contains(key.bytes.join(','))));
  });
}
