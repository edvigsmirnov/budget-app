import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the dictionaries against the failure that shows up only at runtime:
/// a key added to one locale and forgotten in the other renders as the raw
/// key, because useFallbackTranslations is off.
void main() {
  const Set<String> pluralCategories = <String>{
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other',
  };

  Map<String, dynamic> read(String locale) {
    final String raw = File('assets/translations/$locale.json')
        .readAsStringSync();
    return json.decode(raw) as Map<String, dynamic>;
  }

  bool isPluralNode(Map<String, dynamic> node) =>
      node.isNotEmpty && node.keys.every(pluralCategories.contains);

  /// Leaf paths. A plural block counts as one leaf: its categories differ by
  /// language and must not be compared across locales.
  void collect(Map<String, dynamic> node, String prefix, Set<String> out) {
    if (isPluralNode(node)) {
      out.add('$prefix (plural)');
      return;
    }
    for (final MapEntry<String, dynamic> entry in node.entries) {
      final String path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final Object? value = entry.value;
      if (value is Map<String, dynamic>) {
        collect(value, path, out);
      } else {
        out.add(path);
      }
    }
  }

  Set<String> keysOf(String locale) {
    final Set<String> out = <String>{};
    collect(read(locale), '', out);
    return out;
  }

  void forEachString(
    Map<String, dynamic> node,
    String prefix,
    void Function(String path, String value) visit,
  ) {
    for (final MapEntry<String, dynamic> entry in node.entries) {
      final String path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final Object? value = entry.value;
      if (value is Map<String, dynamic>) {
        forEachString(value, path, visit);
      } else if (value is String) {
        visit(path, value);
      }
    }
  }

  test('en and ru cover the same keys', () {
    final Set<String> en = keysOf('en');
    final Set<String> ru = keysOf('ru');
    expect(ru.difference(en), isEmpty, reason: 'in ru but not en');
    expect(en.difference(ru), isEmpty, reason: 'in en but not ru');
  });

  test('ru plurals carry every category Russian needs', () {
    final Map<String, dynamic> ru = read('ru');
    final List<Map<String, dynamic>> blocks = <Map<String, dynamic>>[];
    void walk(Map<String, dynamic> node) {
      if (isPluralNode(node)) {
        blocks.add(node);
        return;
      }
      for (final Object? value in node.values) {
        if (value is Map<String, dynamic>) walk(value);
      }
    }

    walk(ru);
    expect(blocks, isNotEmpty, reason: 'no plural block to check');
    for (final Map<String, dynamic> block in blocks) {
      expect(
        block.keys,
        containsAll(<String>['one', 'few', 'many', 'other']),
        reason: 'Russian resolves one/few/many; other is the fallback',
      );
    }
  });

  test('pubspec declares the dictionaries as assets', () {
    // The widget tests read these off disk rather than through rootBundle, so
    // nothing else proves the running app can find them.
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- assets/translations/'),
    );
  });

  test('no empty strings', () {
    for (final String locale in <String>['en', 'ru']) {
      forEachString(read(locale), '', (String path, String value) {
        expect(value.trim(), isNotEmpty, reason: '$locale:$path is empty');
      });
    }
  });
}
