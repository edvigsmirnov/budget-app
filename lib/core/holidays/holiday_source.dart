import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:sielto/domain/value/calendar_date.dart';

/// The public holidays shipped inside the app (spec 5.1.1).
///
/// Twenty countries, 2026-2031, taken from the same source the network path
/// uses. It exists so the base case works with no network and no API at all:
/// a user who declines the download still gets correct windows for their
/// country until the bundle runs out of years.
///
/// The span must stay ahead of `recurrenceHorizonMonths` (24), or the app
/// projects payments into years it has no holiday data for. Regenerate with
/// `tools/fetch_holidays.py`.
///
/// Regional days are deliberately absent. A holiday observed in one federal
/// state must not shift a national pay date, so only entries the source marks
/// as nationwide were kept.
class HolidayBundle {
  const HolidayBundle();

  static const String _dir = 'assets/holidays';

  /// The country codes the bundle ships, from `index.json`.
  ///
  /// Consulted before a country file is opened. `countries.json` offers every
  /// country the source knows — ten times what is bundled — so a miss is the
  /// normal case, not an error, and asking the manifest keeps it out of the
  /// exception path.
  Future<Set<String>> bundledCodes() async {
    final Object? parsed = jsonDecode(
      await rootBundle.loadString('$_dir/index.json'),
    );
    if (parsed is! List<dynamic>) return const <String>{};
    return <String>{
      for (final Object? code in parsed)
        if (code is String) code.toUpperCase(),
    };
  }

  /// The dates bundled for [countryCode] in [year], or null when the bundle
  /// covers neither. Null is the signal to try the network.
  Future<List<CalendarDate>?> datesFor(String countryCode, int year) async {
    final String code = countryCode.toUpperCase();
    if (!(await bundledCodes()).contains(code)) return null;

    final String raw;
    try {
      raw = await rootBundle.loadString('$_dir/$code.json');
    } on Object {
      // A missing asset throws FlutterError, which is an Error and not an
      // Exception — `on Exception` let it escape, and choosing any of the
      // countries without bundled data failed the whole calendar resolution.
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
