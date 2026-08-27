import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Renders money for display.
///
/// Locale and currency are separate inputs on purpose (spec 9.2): the number
/// format follows the interface language, the symbol follows the Space.
///
/// This is the one place a [Decimal] becomes a double, and it is display-only.
/// The value is rounded to the currency's digits first, so the double that
/// carries it formats back to exactly those digits; no arithmetic happens on
/// the far side. Nothing else in the app may do this — see CLAUDE.md.
class MoneyFormat {
  MoneyFormat({required this.locale, required this.currencyCode})
    : _format = NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
        decimalDigits: _decimalDigits,
      );

  static const int _decimalDigits = 2;

  final String locale;
  final String currencyCode;
  final NumberFormat _format;

  String get symbol => _format.currencySymbol;

  String format(Decimal amount) =>
      _format.format(amount.round(scale: _decimalDigits).toDouble());

  /// With an explicit `+` on positive values. Used where a figure is a change
  /// rather than a total.
  String formatSigned(Decimal amount) {
    final String base = format(amount);
    return amount > Decimal.zero ? '+$base' : base;
  }
}
