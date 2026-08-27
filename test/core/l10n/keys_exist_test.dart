import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every `tr()` and `plural()` key the app names has to exist in the
/// dictionaries.
///
/// `useFallbackTranslations` is off, so a missing key renders as the raw key
/// on screen — `payment.fieldPeriod` where a label should be. The parity test
/// next door catches en and ru drifting apart; this one catches a key that was
/// used but never written down.
void main() {
  test('every key used in lib exists in en.json', () {
    final Map<String, dynamic> dictionary = jsonDecode(
      File('assets/translations/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    bool has(String key) {
      Object? node = dictionary;
      for (final String part in key.split('.')) {
        if (node is! Map<String, dynamic>) return false;
        node = node[part];
        if (node == null) return false;
      }
      return true;
    }

    // Only literal keys are checked. A key built by interpolation —
    // `mode.${space.budgetMode.name}.name` — cannot be resolved statically,
    // and guessing at its shape would report failures that are not real.
    final RegExp call = RegExp(r"""(?:tr|plural)\(\s*'([a-zA-Z0-9_.]+)'""");

    final List<String> missing = <String>[];
    for (final FileSystemEntity entity in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final String source = entity.readAsStringSync();
      for (final RegExpMatch match in call.allMatches(source)) {
        final String key = match.group(1)!;
        if (!has(key)) missing.add('$key  (${entity.path})');
      }
    }

    expect(
      missing,
      isEmpty,
      reason:
          'these keys are used in lib but absent from en.json, so they render '
          'as raw keys:\n${missing.join('\n')}',
    );
  });
}
