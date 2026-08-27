import 'package:intl/intl.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// Renders a [CalendarDate] for display.
///
/// A calendar date has no zone, so it is handed to intl as UTC midnight — the
/// arithmetic anchor the type already uses. Any other conversion would risk
/// printing the day before.
class DateLabels {
  DateLabels(this.locale)
    : _dayMonth = DateFormat.MMMMd(locale),
      _dayMonthYear = DateFormat.yMMMMd(locale),
      _weekday = DateFormat.EEEE(locale),
      _short = DateFormat.yMd(locale);

  final String locale;
  final DateFormat _dayMonth;
  final DateFormat _dayMonthYear;
  final DateFormat _weekday;
  final DateFormat _short;

  /// "14 August". The year is dropped when it matches [reference], which is
  /// almost always the current year.
  String dayMonth(CalendarDate date, {CalendarDate? reference}) {
    final bool sameYear = reference == null || reference.year == date.year;
    final DateFormat format = sameYear ? _dayMonth : _dayMonthYear;
    return format.format(date.toUtcMidnight());
  }

  String weekday(CalendarDate date) => _weekday.format(date.toUtcMidnight());

  /// Numeric, for dense contexts.
  String short(CalendarDate date) => _short.format(date.toUtcMidnight());
}
