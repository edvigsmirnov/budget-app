import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Resolves "today" for a Space.
///
/// Every overdue check, freeze cutoff and retention window is answered here,
/// never by `DateTime.now()` at the call site (plan section 2, invariant 7).
/// Two members in different countries share one Space and must agree on which
/// day it is; the Space's timezone decides, not either device's.
///
/// The wall clock is injected so tests are deterministic and so no code below
/// this class ever reads the system clock directly.
class SpaceClock {
  SpaceClock({required String timezone, DateTime Function()? now})
    : _location = tz.getLocation(timezone),
      _now = now ?? DateTime.now;

  /// Loads the IANA database. Call once at startup, before any [SpaceClock].
  static void initialize() => tz_data.initializeTimeZones();

  /// True when [timezone] names a zone the database knows.
  static bool isKnownTimezone(String timezone) {
    try {
      tz.getLocation(timezone);
      return true;
    } on tz.LocationNotFoundException {
      return false;
    }
  }

  final tz.Location _location;
  final DateTime Function() _now;

  String get timezone => _location.name;

  /// The current instant, untouched by the Space timezone.
  DateTime nowUtc() => _now().toUtc();

  /// The date it is in this Space right now.
  CalendarDate today() => dateOf(_now());

  /// The date [instant] falls on in this Space. An 11pm UTC payment stamped in
  /// Berlin already belongs to the next day.
  CalendarDate dateOf(DateTime instant) =>
      CalendarDate.fromDateTime(tz.TZDateTime.from(instant, _location));

  /// Midnight at the start of [date] in this Space, as a UTC instant. The
  /// inverse of [dateOf], for range queries against timestamp columns.
  DateTime startOfDayUtc(CalendarDate date) =>
      tz.TZDateTime(_location, date.year, date.month, date.day).toUtc();

  /// The first instant of the following day, so a half-open range
  /// `[startOfDayUtc(d), endOfDayUtc(d))` covers exactly that day. Computed by
  /// adding a day to the date, not 24 hours to the instant — a DST day is 23
  /// or 25 hours long.
  DateTime endOfDayUtc(CalendarDate date) => startOfDayUtc(date.addDays(1));
}
