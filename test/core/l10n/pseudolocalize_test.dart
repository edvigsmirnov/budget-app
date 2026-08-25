import 'package:budget_app/core/l10n/pseudolocalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brackets the string so truncation shows at either end', () {
    final String out = pseudolocalize('Rent');
    expect(out, startsWith('['));
    expect(out, endsWith(']'));
  });

  test('accents letters', () {
    expect(pseudolocalize('Cancel'), contains('Çáñçéł'));
  });

  test('runs longer than the source', () {
    const String source = 'Not covered before the next income';
    expect(pseudolocalize(source).length, greaterThan(source.length));
  });

  test('expansion scales the padding', () {
    final int short = pseudolocalize('Rent', expansion: 0.1).length;
    final int long = pseudolocalize('Rent', expansion: 1).length;
    expect(long, greaterThan(short));
  });

  test('copies placeholders verbatim', () {
    // Accenting a placeholder name would break interpolation.
    expect(pseudolocalize('Paid {date}'), contains('{date}'));
    expect(pseudolocalize('{} paid expenses excluded'), contains('{}'));
  });

  test('leaves digits and punctuation alone', () {
    expect(pseudolocalize('1 240,00'), contains('1 240,00'));
  });

  test('pads nothing when there is nothing to translate', () {
    expect(pseudolocalize(''), '[]');
  });
}
