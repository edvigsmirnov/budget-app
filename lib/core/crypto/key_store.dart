import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sielto/core/crypto/database_key.dart';
import 'package:sielto/core/crypto/envelope.dart';

/// Where the envelope A wrapping key lives. Abstracted so tests can run
/// without a platform keystore, and so the Linux passphrase fallback
/// (spec 2.2) can slot in at M7 without touching callers.
abstract class WrappingKeyStore {
  /// The stored key, or null if this device has none yet.
  Future<Uint8List?> read();

  Future<void> write(Uint8List key);

  Future<void> delete();
}

/// Keystore on Android, Credential Manager on Windows, libsecret on Linux.
class SecureStorageKeyStore implements WrappingKeyStore {
  const SecureStorageKeyStore({this.storage = const FlutterSecureStorage()});

  static const String _key = 'envelope_a_wrapping_key';

  final FlutterSecureStorage storage;

  @override
  Future<Uint8List?> read() async {
    final String? encoded = await storage.read(key: _key);
    return encoded == null ? null : base64Decode(encoded);
  }

  @override
  Future<void> write(Uint8List key) =>
      storage.write(key: _key, value: base64Encode(key));

  @override
  Future<void> delete() => storage.delete(key: _key);
}

/// Resolves the database key at startup.
///
/// First run mints a DEK and an envelope A. Later runs unwrap the existing
/// envelope. When the envelope will not open — a wiped keystore, a device
/// migration — this reports [DatabaseKeyUnavailable] rather than guessing, and
/// the caller shows the decryption-failure screen (spec 2.2).
class DatabaseKeyManager {
  DatabaseKeyManager({required this.directory, WrappingKeyStore? keyStore})
    : _keyStore = keyStore ?? const SecureStorageKeyStore();

  /// Application support directory: holds the database and its envelopes.
  final Directory directory;
  final WrappingKeyStore _keyStore;

  File get envelopeAFile => File(p.join(directory.path, 'envelope_a.bin'));

  /// Loads the key, creating one on first run.
  Future<DatabaseKey> resolve() async {
    final bool hasEnvelope = envelopeAFile.existsSync();
    final Uint8List? wrappingKey = await _keyStore.read();

    if (!hasEnvelope && wrappingKey == null) return _createFirstRun();

    if (wrappingKey == null) {
      // The envelope survived but its key did not: the migration case
      // envelope B exists for. Envelope B lands in M7.
      throw const DatabaseKeyUnavailable(DatabaseKeyFailure.wrappingKeyMissing);
    }
    if (!hasEnvelope) {
      // A key with nothing to unwrap. Safe to restart only if no database
      // exists; the caller decides.
      throw const DatabaseKeyUnavailable(DatabaseKeyFailure.envelopeMissing);
    }

    try {
      return await Envelope(envelopeAFile.readAsBytesSync()).open(wrappingKey);
    } on EnvelopeException {
      throw const DatabaseKeyUnavailable(DatabaseKeyFailure.envelopeUnreadable);
    }
  }

  Future<DatabaseKey> _createFirstRun() async {
    final Random rng = Random.secure();
    final Uint8List wrappingKey = Uint8List.fromList(
      List<int>.generate(DatabaseKey.length, (_) => rng.nextInt(256)),
    );
    final DatabaseKey dek = DatabaseKey.generate();

    final Envelope envelope = await Envelope.seal(
      dek,
      wrappingKey: wrappingKey,
    );
    directory.createSync(recursive: true);
    envelopeAFile.writeAsBytesSync(envelope.bytes, flush: true);
    // Written second: a wrapping key with no envelope is recoverable, an
    // envelope with no key is not.
    await _keyStore.write(wrappingKey);

    return dek;
  }

  /// Discards the key material and the envelope. The database file becomes
  /// permanently unreadable, so callers delete it in the same step. This is
  /// the "Start over" branch of the decryption-failure screen.
  Future<void> destroy() async {
    await _keyStore.delete();
    if (envelopeAFile.existsSync()) envelopeAFile.deleteSync();
  }
}

enum DatabaseKeyFailure {
  /// Envelope A is present but the keystore entry is gone. Recoverable with a
  /// Recovery Key once envelope B exists (M7).
  wrappingKeyMissing,

  /// Keystore entry present, envelope file gone.
  envelopeMissing,

  /// Both present, but the envelope does not open.
  envelopeUnreadable,
}

class DatabaseKeyUnavailable implements Exception {
  const DatabaseKeyUnavailable(this.reason);

  final DatabaseKeyFailure reason;

  @override
  String toString() => 'DatabaseKeyUnavailable: ${reason.name}';
}
