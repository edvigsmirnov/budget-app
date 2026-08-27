import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/core/format/money_input.dart';

void main() {
  Decimal? parse(String input) => parseMoney(input);

  test('plain digits parse', () {
    expect(parse('1200'), Decimal.fromInt(1200));
  });

  test('both decimal separators mean the same thing', () {
    // A Russian keyboard's comma and a numpad's dot must not disagree.
    expect(parse('12.50'), parse('12,50'));
    expect(parse('12,50'), Decimal.parse('12.5'));
  });

  test('group separators are stripped', () {
    expect(parse('1 200,50'), Decimal.parse('1200.5'));
    // Including the non-breaking space intl emits.
    expect(parse('1 200.50'), Decimal.parse('1200.5'));
  });

  test('zero parses', () {
    // A zero-amount record is a dated to-do, not an invalid entry (spec 4.8).
    expect(parse('0'), Decimal.zero);
  });

  test('exactness survives the classic float case', () {
    expect(parse('0.1')! + parse('0.2')!, Decimal.parse('0.3'));
  });

  test('empty and non-numeric text produce null', () {
    expect(parse(''), isNull);
    expect(parse('   '), isNull);
    expect(parse('abc'), isNull);
    expect(parse('12,,50'), isNull);
  });

  test('a negative value parses, and is the form s job to refuse', () {
    // The sign comes from the record type, never from the number (spec 6.7).
    expect(parse('-5'), Decimal.fromInt(-5));
  });
}
