import 'package:meta/meta.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// Which days are not working days, for one country.
///
/// Three sources, merged (spec 5.1.1): weekends, public holidays from the
/// cache, and the days the user marked by hand. With no country configured the
/// last two are simply empty and only weekends count — that is a supported
/// state, not a degraded one.
@immutable
class WorkingDayCalendar {
  WorkingDayCalendar({
    Set<CalendarDate> holidays = const <CalendarDate>{},
    Set<CalendarDate> customNonWorkingDays = const <CalendarDate>{},
    this.weekendDays = defaultWeekend,
  }) : _nonWorking = <CalendarDate>{...holidays, ...customNonWorkingDays};

  /// Saturday and Sunday, per [DateTime.weekday] numbering.
  static const Set<int> defaultWeekend = <int>{
    DateTime.saturday,
    DateTime.sunday,
  };

  /// Weekends only. The state when no country is set and the user has marked
  /// nothing.
  factory WorkingDayCalendar.weekendsOnly() => WorkingDayCalendar();

  final Set<CalendarDate> _nonWorking;
  final Set<int> weekendDays;

  bool isWorkingDay(CalendarDate date) =>
      !weekendDays.contains(date.weekday) && !_nonWorking.contains(date);

  bool isNonWorkingDay(CalendarDate date) => !isWorkingDay(date);

  /// The first working day on or before [date].
  CalendarDate workingDayOnOrBefore(CalendarDate date) =>
      _search(date, step: -1);

  /// The first working day on or after [date].
  CalendarDate workingDayOnOrAfter(CalendarDate date) => _search(date, step: 1);

  /// Walks day by day. [maxSteps] is a guard, not a business rule: no real
  /// calendar has a month of consecutive holidays, and an unbounded loop over
  /// a malformed holiday set would hang the app instead of failing.
  CalendarDate _search(CalendarDate from, {required int step}) {
    const int maxSteps = 60;
    CalendarDate candidate = from;
    for (int i = 0; i <= maxSteps; i++) {
      if (isWorkingDay(candidate)) return candidate;
      candidate = candidate.addDays(step);
    }
    throw StateError(
      'no working day within $maxSteps days of $from; '
      'the holiday set is almost certainly wrong',
    );
  }
}
