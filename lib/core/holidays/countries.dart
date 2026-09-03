import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// A country the holiday source knows about.
@immutable
class HolidayCountry {
  const HolidayCountry({required this.code, required this.name});

  final String code;

  /// The country's name in the reading language, from Unicode's CLDR data.
  /// Falls back to the source's English name where CLDR has no entry.
  final String name;
}

const String _dir = 'assets/holidays';

/// Every country the source covers, named in [language].
///
/// Bundled rather than fetched so the picker works offline and before any
/// consent has been given — choosing a country must not itself require the
/// network (spec 5.1.1).
///
/// Keyed by language code because a provider cannot read the locale off a
/// `BuildContext`; callers pass `context.locale.languageCode`.
///
/// The type is inferred rather than written out, unlike every other provider
/// here: `flutter_riverpod` does not export `FutureProviderFamily`.
final holidayCountriesProvider =
    FutureProvider.family<List<HolidayCountry>, String>((
      Ref ref,
      String language,
    ) async {
      final Object? parsed = jsonDecode(
        await rootBundle.loadString('$_dir/countries.json'),
      );
      if (parsed is! List<dynamic>) return const <HolidayCountry>[];

      final Map<String, String> localized = await _namesFor(language);
      final List<HolidayCountry> countries = <HolidayCountry>[
        for (final Object? row in parsed)
          if (row is Map<String, dynamic> &&
              row['code'] is String &&
              row['name'] is String)
            HolidayCountry(
              code: row['code'] as String,
              name: localized[row['code'] as String] ?? row['name'] as String,
            ),
      ];

      // Sorted here, not in the asset: the order depends on the language the
      // names are read in, and countries.json is sorted by the English ones.
      countries.sort(
        (HolidayCountry a, HolidayCountry b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return countries;
    });

/// Country names for [language], or empty when none are bundled for it.
///
/// A missing overlay is the ordinary case for a language whose names have not
/// been generated yet; the English names in `countries.json` stand in.
Future<Map<String, String>> _namesFor(String language) async {
  final String raw;
  try {
    raw = await rootBundle.loadString('$_dir/countries.$language.json');
  } on Object {
    // A missing asset throws FlutterError, which is an Error rather than an
    // Exception, so this cannot be narrowed to `on Exception`.
    return const <String, String>{};
  }

  final Object? parsed = jsonDecode(raw);
  if (parsed is! Map<String, dynamic>) return const <String, String>{};
  return <String, String>{
    for (final MapEntry<String, dynamic> e in parsed.entries)
      if (e.value is String) e.key: e.value as String,
  };
}
