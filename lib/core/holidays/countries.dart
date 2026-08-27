import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// A country the holiday source knows about.
@immutable
class HolidayCountry {
  const HolidayCountry({required this.code, required this.name});

  final String code;

  /// The English name from the source. Not translated: country names are not
  /// in the app dictionaries, and a half-translated list reads worse than a
  /// consistent one.
  final String name;
}

/// Every country the source covers, shipped with the app.
///
/// Bundled rather than fetched so the picker works offline and before any
/// consent has been given — choosing a country must not itself require the
/// network (spec 5.1.1).
final FutureProvider<List<HolidayCountry>> holidayCountriesProvider =
    FutureProvider<List<HolidayCountry>>((Ref ref) async {
      final String raw = await rootBundle.loadString(
        'assets/holidays/countries.json',
      );
      final Object? parsed = jsonDecode(raw);
      if (parsed is! List<dynamic>) return const <HolidayCountry>[];
      return <HolidayCountry>[
        for (final Object? row in parsed)
          if (row is Map<String, dynamic> &&
              row['code'] is String &&
              row['name'] is String)
            HolidayCountry(
              code: row['code'] as String,
              name: row['name'] as String,
            ),
      ];
    });
