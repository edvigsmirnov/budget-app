import 'package:decimal/decimal.dart';

/// Parses what a person types into an amount field.
///
/// Both separators are accepted regardless of locale: a Russian keyboard's
/// comma and a numpad's dot mean the same thing, and rejecting one of them
/// would be a puzzle rather than a validation. Group separators are stripped,
/// so "1 200,50" and "1200.5" both parse.
///
/// Returns null when the text is not a number. Negative values parse but are
/// rejected by the form: the sign comes from the record type, never from the
/// number (spec 6.7).
Decimal? parseMoney(String input) {
  final String cleaned = input
      .replaceAll(RegExp(r'[\s  ]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return Decimal.tryParse(cleaned);
}
