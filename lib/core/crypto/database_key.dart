import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// The 256-bit key the database file is encrypted with.
///
/// Never stored in the clear. It lives only inside envelopes: envelope A,
/// wrapped by a device key from the platform keystore, and — from M7 —
/// envelope B, wrapped by a key derived from the user's Recovery Key
/// (spec 2.2). Two independent ways to the same key, so losing the keystore
/// is not losing the data.
@immutable
class DatabaseKey {
  const DatabaseKey(this.bytes);

  /// 32 bytes from [Random.secure]. Generated once, at first install.
  factory DatabaseKey.generate() {
    final Random rng = Random.secure();
    return DatabaseKey(
      Uint8List.fromList(List<int>.generate(length, (_) => rng.nextInt(256))),
    );
  }

  factory DatabaseKey.fromBase64(String encoded) =>
      DatabaseKey(base64Decode(encoded));

  static const int length = 32;

  final Uint8List bytes;

  String toBase64() => base64Encode(bytes);

  /// The literal for `PRAGMA key`.
  ///
  /// `x'<hex>'` hands SQLCipher the raw key and skips its passphrase KDF —
  /// this key is already random, so deriving from it would only cost time.
  /// SQLCipher documents that value wrapped in double quotes, which this build
  /// rejects (SQLITE_DQS=0), so the quotes are single and doubled to escape.
  String toPragmaLiteral() {
    final String hex = bytes
        .map((int b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return "'x''$hex'''";
  }

  @override
  bool operator ==(Object other) {
    if (other is! DatabaseKey || other.bytes.length != bytes.length) {
      return false;
    }
    // Constant time: this runs on secret material.
    int diff = 0;
    for (int i = 0; i < bytes.length; i++) {
      diff |= bytes[i] ^ other.bytes[i];
    }
    return diff == 0;
  }

  @override
  int get hashCode => bytes.length;

  /// Never print key material, not even truncated.
  @override
  String toString() => 'DatabaseKey(32 bytes)';
}
