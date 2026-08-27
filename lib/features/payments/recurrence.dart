import 'package:budget_app/domain/value/calendar_date.dart';

/// How often a repeating payment recurs (spec 6.3).
enum RecurrenceInterval { monthly, weekly }

/// Rows an open-ended series materialises ahead of today.
///
/// "Indefinitely" is not an unbounded INSERT: the series is rolled forward in
/// a 24-month window and extended as that window approaches (spec 6.3). This
/// is the one place where no explicit limit would grow the database without
/// bound, so the limit is stated rather than implied.
const int recurrenceHorizonMonths = 24;

/// The dates of one series.
///
/// [count] is the number of occurrences including the first. Null means
/// open-ended, which fills the horizon instead.
List<CalendarDate> recurrenceDates({
  required CalendarDate start,
  required RecurrenceInterval interval,
  int? count,
}) {
  final CalendarDate horizon = start.addMonths(recurrenceHorizonMonths);
  final List<CalendarDate> dates = <CalendarDate>[];

  CalendarDate current = start;
  int index = 0;
  while (count == null ? !current.isAfter(horizon) : index < count) {
    dates.add(current);
    index++;
    current = switch (interval) {
      // Monthly steps count from the original date, so a series that starts on
      // the 31st returns to the 31st after a short month instead of drifting
      // backwards a day at a time.
      RecurrenceInterval.monthly => start.addMonths(index),
      RecurrenceInterval.weekly => start.addDays(7 * index),
    };
  }

  return dates;
}
