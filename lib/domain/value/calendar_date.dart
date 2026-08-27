import 'package:meta/meta.dart';

/// A calendar day: no time, no zone.
///
/// `due_date` and `expected_date` are days on a wall calendar, not instants.
/// Holding them in a [DateTime] invites the bug this type exists to prevent —
/// a midnight local timestamp that lands on the previous day once the Space
/// timezone is applied. Converting to an instant is deliberate and explicit;
/// see `SpaceClock` for resolving "today".
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate(this.year, this.month, this.day);

  /// Normalises out-of-range values the way [DateTime] does, so
  /// `CalendarDate.from(2026, 2, 30)` is 2026-03-02 rather than an error.
  factory CalendarDate.from(int year, int month, int day) {
    final DateTime d = DateTime.utc(year, month, day);
    return CalendarDate(d.year, d.month, d.day);
  }

  /// Parses `YYYY-MM-DD`. Rejects anything else, including timestamps: a value
  /// carrying a time has already lost the distinction this type protects.
  factory CalendarDate.parse(String iso) {
    final Match? m = _isoPattern.firstMatch(iso);
    if (m == null) {
      throw FormatException('expected YYYY-MM-DD', iso);
    }
    return CalendarDate(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  /// Takes the year, month and day as they read on [dateTime], whatever zone
  /// it carries. Call this only where that reading is the intended one.
  factory CalendarDate.fromDateTime(DateTime dateTime) =>
      CalendarDate(dateTime.year, dateTime.month, dateTime.day);

  static final RegExp _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// `YYYY-MM-DD`. The storage format, and lexicographically sortable.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Midnight UTC. Arithmetic anchor only — not a moment in any real zone.
  DateTime toUtcMidnight() => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) {
    final DateTime d = toUtcMidnight().add(Duration(days: days));
    return CalendarDate(d.year, d.month, d.day);
  }

  /// The same day-of-month [months] later, clamped to the target month's
  /// length: the 31st plus one month is 28 or 29 February, not 2 or 3 March.
  /// Overflow would silently move a monthly series into the wrong month.
  CalendarDate addMonths(int months) {
    final int total = year * 12 + (month - 1) + months;
    final int targetYear = total ~/ 12;
    final int targetMonth = total % 12 + 1;
    final int lastDay = CalendarDate.from(
      targetYear,
      targetMonth + 1,
      1,
    ).addDays(-1).day;
    return CalendarDate(targetYear, targetMonth, day > lastDay ? lastDay : day);
  }

  /// Whole days from this date to [other]; negative if [other] is earlier.
  int daysUntil(CalendarDate other) =>
      other.toUtcMidnight().difference(toUtcMidnight()).inDays;

  /// 1 = Monday through 7 = Sunday, matching [DateTime.weekday].
  int get weekday => toUtcMidnight().weekday;

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
