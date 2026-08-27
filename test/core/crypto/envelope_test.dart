import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/core/crypto/database_key.dart';
import 'package:sielto/core/crypto/envelope.dart';

void main() {
  Uint8List randomBytes(int n) {
    final Random rng = Random.secure();
    return Uint8List.fromList(List<int>.generate(n, (_) => rng.nextInt(256)));
  }

  group('DatabaseKey', () {
    test('generates 256 bits', () {
      expect(DatabaseKey.generate().bytes, hasLength(32));
    });

    test('two keys differ', () {
      expect(DatabaseKey.generate(), isNot(DatabaseKey.generate()));
    });

    test('survives base64', () {
      final DatabaseKey key = DatabaseKey.generate();
      expect(DatabaseKey.fromBase64(key.toBase64()), key);
    });

    test('never prints its material', () {
      final DatabaseKey key = DatabaseKey.generate();
      expect(key.toString(), 'DatabaseKey(32 bytes)');
      expect(key.toString(), isNot(contains(key.toBase64().substring(0, 6))));
    });

    test('renders the raw-key pragma literal', () {
      final DatabaseKey key = DatabaseKey(
        Uint8List.fromList(<int>[0, 15, 255]),
      );
      // Single quotes, doubled to escape: this build rejects double quotes.
      expect(key.toPragmaLiteral(), "'x''000fff'''");
    });
  });

  group('Envelope', () {
    test('round-trips the key', () async {
      final DatabaseKey dek = DatabaseKey.generate();
      final Uint8List wrapping = randomBytes(32);

      final Envelope sealed = await Envelope.seal(dek, wrappingKey: wrapping);
      expect(await sealed.open(wrapping), dek);
    });

    test('does not open under a different key', () async {
      final Envelope sealed = await Envelope.seal(
        DatabaseKey.generate(),
        wrappingKey: randomBytes(32),
      );
      expect(
        () => sealed.open(randomBytes(32)),
        throwsA(isA<EnvelopeException>()),
      );
    });

    test('detects tampering', () async {
      final Uint8List wrapping = randomBytes(32);
      final Envelope sealed = await Envelope.seal(
        DatabaseKey.generate(),
        wrappingKey: wrapping,
      );

      // Flip one ciphertext bit. AES-GCM authenticates, so this must fail
      // rather than yield a wrong key that silently corrupts the database.
      final Uint8List damaged = Uint8List.fromList(sealed.bytes);
      damaged[20] ^= 0x01;

      expect(
        () => Envelope(damaged).open(wrapping),
        throwsA(isA<EnvelopeException>()),
      );
    });

    test('rejects a truncated blob', () async {
      expect(
        () =>
            Envelope(Uint8List.fromList(<int>[0x76, 0x31, 1, 2]))
                .open(randomBytes(32)),
        throwsA(isA<EnvelopeException>()),
      );
    });

    test('rejects an unknown format marker', () async {
      final Envelope sealed = await Envelope.seal(
        DatabaseKey.generate(),
        wrappingKey: randomBytes(32),
      );
      final Uint8List foreign = Uint8List.fromList(sealed.bytes);
      foreign[0] = 0x99;

      expect(
        () => Envelope(foreign).open(randomBytes(32)),
        throwsA(isA<EnvelopeException>()),
      );
    });

    test('does not hold the key in the clear', () async {
      final DatabaseKey dek = DatabaseKey.generate();
      final Envelope sealed = await Envelope.seal(
        dek,
        wrappingKey: randomBytes(32),
      );
      expect(
        _contains(sealed.bytes, dek.bytes),
        isFalse,
        reason: 'the DEK appears verbatim in its own envelope',
      );
    });
  });
}

bool _contains(Uint8List haystack, Uint8List needle) {
  for (int i = 0; i + needle.length <= haystack.length; i++) {
    bool match = true;
    for (int j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}
