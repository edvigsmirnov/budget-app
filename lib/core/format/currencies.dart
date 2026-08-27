import 'package:intl/intl.dart';

/// Currency selection for Space creation (spec 9.2).
///
/// The list is a convenience, not a constraint: the stored value is a plain
/// ISO 4217 code, and the detected one is always offered even when it is not
/// in the list below.
abstract final class Currencies {
  /// Common codes, in no particular order of preference.
  static const List<String> common = <String>[
    'EUR',
    'USD',
    'GBP',
    'RUB',
    'CHF',
    'PLN',
    'CZK',
    'SEK',
    'NOK',
    'DKK',
    'TRY',
    'GEL',
    'RSD',
    'UAH',
    'KZT',
    'AMD',
    'AED',
    'CAD',
    'AUD',
    'JPY',
    'CNY',
    'INR',
    'BRL',
    'ILS',
  ];

  /// The currency the device locale implies. Falls back to EUR when intl has
  /// no data for the locale.
  static String forLocale(String locale) {
    try {
      final String? name = NumberFormat.simpleCurrency(locale: locale)
          .currencyName;
      if (name != null && name.length == 3) return name;
    } on Exception {
      // No currency data for this locale; the fallback below applies.
    }
    return 'EUR';
  }

  /// "EUR €" — the code plus its symbol, for a picker row.
  static String label(String code, String locale) {
    try {
      final String symbol = NumberFormat.simpleCurrency(
        locale: locale,
        name: code,
      ).currencySymbol;
      return symbol == code ? code : '$code $symbol';
    } on Exception {
      return code;
    }
  }

  /// [detected] first, then the common list without duplicates.
  static List<String> offered(String detected) => <String>[
    detected,
    ...common.where((String code) => code != detected),
  ];
}
