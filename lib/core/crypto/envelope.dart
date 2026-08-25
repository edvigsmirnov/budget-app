import 'dart:convert';
import 'dart:typed_data';

import 'package:budget_app/core/crypto/database_key.dart';
import 'package:cryptography/cryptography.dart';

/// A DEK wrapped under some other key, as a self-describing byte blob.
///
/// The blob is a plain file next to the database rather than a keystore entry,
/// which is the point: system backups copy files but not hardware-bound keys,
/// so the envelope survives a device migration that destroys the keystore
/// (spec 2.2). The wrapping key never leaves the keystore, so the file alone
/// reveals nothing.
///
/// Layout: `v1` | nonce (12) | ciphertext (32) | MAC (16).
class Envelope {
  const Envelope(this.bytes);

  static const List<int> _magic = <int>[0x76, 0x31]; // 'v1'
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  static final AesGcm _cipher = AesGcm.with256bits();

  final Uint8List bytes;

  /// Wraps [dek] under [wrappingKey], which must be 32 bytes.
  static Future<Envelope> seal(
    DatabaseKey dek, {
    required Uint8List wrappingKey,
  }) async {
    final SecretBox box = await _cipher.encrypt(
      dek.bytes,
      secretKey: SecretKey(wrappingKey),
    );
    return Envelope(
      Uint8List.fromList(<int>[
        ..._magic,
        ...box.nonce,
        ...box.cipherText,
        ...box.mac.bytes,
      ]),
    );
  }

  /// Unwraps the DEK. Throws [EnvelopeException] on a wrong key or a damaged
  /// blob — the caller cannot tell those apart, and does not need to: both
  /// mean this envelope will not open (spec 2.2).
  Future<DatabaseKey> open(Uint8List wrappingKey) async {
    if (bytes.length < _magic.length + _nonceLength + _macLength) {
      throw const EnvelopeException('envelope is truncated');
    }
    if (bytes[0] != _magic[0] || bytes[1] != _magic[1]) {
      throw const EnvelopeException('unrecognised envelope format');
    }

    final int nonceEnd = _magic.length + _nonceLength;
    final int cipherEnd = bytes.length - _macLength;

    try {
      final List<int> clear = await _cipher.decrypt(
        SecretBox(
          bytes.sublist(nonceEnd, cipherEnd),
          nonce: bytes.sublist(_magic.length, nonceEnd),
          mac: Mac(bytes.sublist(cipherEnd)),
        ),
        secretKey: SecretKey(wrappingKey),
      );
      if (clear.length != DatabaseKey.length) {
        throw const EnvelopeException('envelope did not hold a 256-bit key');
      }
      return DatabaseKey(Uint8List.fromList(clear));
    } on SecretBoxAuthenticationError {
      throw const EnvelopeException('wrong key or tampered envelope');
    }
  }

  String toBase64() => base64Encode(bytes);

  static Envelope fromBase64(String encoded) => Envelope(base64Decode(encoded));
}

/// An envelope would not open. Distinct from an I/O failure: the file was read
/// fine, it just does not yield a key.
class EnvelopeException implements Exception {
  const EnvelopeException(this.message);

  final String message;

  @override
  String toString() => 'EnvelopeException: $message';
}
