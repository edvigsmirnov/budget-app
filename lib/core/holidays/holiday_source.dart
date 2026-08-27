import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:sielto/domain/value/calendar_date.dart';

/// The public holidays shipped inside the app (spec 5.1.1).
///
/// Twenty countries, two years, taken from the same source the network path
/// uses. It exists so the base case works with no network and no API at all:
/// a user who declines the download still gets correct windows for their
/// country until the bundle runs out of years.
///
/// Regional days are deliberately absent. A holiday observed in one federal
/// state must not shift a national pay date, so only entries the source marks
/// as nationwide were kept.
class HolidayBundle {
  const HolidayBundle();

  static const String _dir = 'assets/holidays';

  /// The dates bundled for [countryCode] in [year], or null when the bundle
  /// covers neither. Null is the signal to try the network.
  Future<List<CalendarDate>?> datesFor(String countryCode, int year) async {
    final String code = countryCode.toUpperCase();
    final String raw;
    try {
      raw = await rootBundle.loadString('$_dir/$code.json');
    } on Exception {
      return null;
    }

    final Object? parsed = jsonDecode(raw);
    if (parsed is! Map<String, dynamic>) return null;
    final Object? dates = parsed['$year'];
    if (dates is! List<dynamic>) return null;
    return <CalendarDate>[
      for (final Object? d in dates)
        if (d is String) CalendarDate.parse(d),
    ];
  }
}

/// Public holidays from date.nager.at (spec 5.1.1).
///
/// Only ever called behind explicit consent and with the offline switch off;
/// the class itself makes no such check, so the decision stays in one place
/// rather than being re-derived here.
class NagerHolidayApi {
  const NagerHolidayApi({this.client});

  /// Injected in tests. Null uses a client created and closed per call, which
  /// is right for a request the app makes once or twice a year.
  final http.Client? client;

  static const Duration _timeout = Duration(seconds: 10);

  /// Null when the request failed for any reason — no network, a timeout, an
  /// unknown country. The caller treats every failure the same way: keep the
  /// data it has and flag the period (spec 5.1.1).
  Future<List<CalendarDate>?> fetch(String countryCode, int year) async {
    final Uri url = Uri.https(
      'date.nager.at',
      '/api/v3/PublicHolidays/$year/${countryCode.toUpperCase()}',
    );
    final http.Client c = client ?? http.Client();
    try {
      final http.Response response = await c.get(url).timeout(_timeout);
      if (response.statusCode != 200) return null;

      final Object? parsed = jsonDecode(response.body);
      if (parsed is! List<dynamic>) return null;

      return <CalendarDate>[
        for (final Object? row in parsed)
          if (row is Map<String, dynamic> &&
              row['global'] == true &&
              row['date'] is String)
            CalendarDate.parse(row['date'] as String),
      ];
    } on Exception {
      return null;
    } finally {
      if (client == null) c.close();
    }
  }
}
