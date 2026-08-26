import 'package:budget_app/domain/schedule/income_window.dart';
import 'package:budget_app/domain/schedule/working_days.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:meta/meta.dart';

/// The four schedule shapes (spec 5.1).
///
/// Each answers one question — which days of a given month could this income
/// land on — before weekends and holidays are considered. [resolveFor] then
/// hands that to [resolveIncomeWindow].
@immutable
sealed class IncomeSchedule {
  const IncomeSchedule();

  /// Days in [year]/[month] the schedule points at, ignoring working days.
  /// A precise schedule returns a null [end].
  ({CalendarDate start, CalendarDate? end}) baseRangeFor(int year, int month);

  /// The window and anchor for this schedule in a given month.
  IncomeWindow resolveFor(
    int year,
    int month, {
    required WorkingDayCalendar calendar,
  }) {
    final ({CalendarDate? end, CalendarDate start}) base = baseRangeFor(
      year,
      month,
    );
    return resolveIncomeWindow(
      start: base.start,
      end: base.end,
      calendar: calendar,
    );
  }

  /// Days in [month] of [year]. Handles leap years by construction.
  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;
}

/// "The 26th of every month."
///
/// Short months clamp to their last day rather than spilling into the next
/// one: the 31st is the 28th in February and the 30th in April. Clamping
/// happens here, before working days are considered (spec 5.1).
class FixedDateSchedule extends IncomeSchedule {
  const FixedDateSchedule(this.day);

  final int day;

  @override
  ({CalendarDate start, CalendarDate? end}) baseRangeFor(int year, int month) {
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', 'outside 1..31');
    }
    final int clamped = day.clamp(1, IncomeSchedule.daysInMonth(year, month));
    return (start: CalendarDate(year, month, clamped), end: null);
  }
}

/// "The last Friday", "the second Wednesday."
///
/// The ordinal stops at fourth: every month has at least four of each weekday
/// and exactly one last one, so this always resolves. A fifth option would
/// need a rule for the months that have no fifth Monday, and the enum avoids
/// inventing one (spec 4.7).
class WeekdayRuleSchedule extends IncomeSchedule {
  const WeekdayRuleSchedule(this.ordinal, this.weekday);

  final WeekdayOrdinal ordinal;
  final Weekday weekday;

  /// 1 = Monday, matching [DateTime.weekday].
  int get _targetWeekday => weekday.index + 1;

  @override
  ({CalendarDate start, CalendarDate? end}) baseRangeFor(int year, int month) {
    final int length = IncomeSchedule.daysInMonth(year, month);

    if (ordinal == WeekdayOrdinal.last) {
      for (int day = length; day >= 1; day--) {
        final CalendarDate date = CalendarDate(year, month, day);
        if (date.weekday == _targetWeekday) {
          return (start: date, end: null);
        }
      }
    } else {
      final int wanted = ordinal.index + 1;
      int seen = 0;
      for (int day = 1; day <= length; day++) {
        final CalendarDate date = CalendarDate(year, month, day);
        if (date.weekday != _targetWeekday) continue;
        if (++seen == wanted) return (start: date, end: null);
      }
    }

    // Unreachable: every month holds four of each weekday and one last one.
    throw StateError('$ordinal $weekday does not occur in $year-$month');
  }
}

/// "Between the 23rd and the 25th."
///
/// The exact day is unknown in advance, so the whole span is the window and
/// the anchor is its last working day — the latest-day rule (spec 5.3).
class DateRangeSchedule extends IncomeSchedule {
  const DateRangeSchedule(this.startDay, this.endDay);

  final int startDay;
  final int endDay;

  @override
  ({CalendarDate start, CalendarDate? end}) baseRangeFor(int year, int month) {
    if (startDay < 1 || startDay > 31 || endDay < 1 || endDay > 31) {
      throw ArgumentError('date range $startDay..$endDay is outside 1..31');
    }
    if (endDay < startDay) {
      throw ArgumentError(
        'date range $startDay..$endDay ends before it starts',
      );
    }
    final int length = IncomeSchedule.daysInMonth(year, month);
    return (
      start: CalendarDate(year, month, startDay.clamp(1, length)),
      end: CalendarDate(year, month, endDay.clamp(1, length)),
    );
  }
}

/// "The first three days of the month", "the last three days."
///
/// The readable form of a range, expanded against the real month length so
/// "last 3 days" is 26-28 in February and 29-31 in March. Capped at 15 days:
/// past that, "the first N days" stops describing anything and the user wants
/// a fixed date instead (spec 5.1).
class BoundaryDaysSchedule extends IncomeSchedule {
  const BoundaryDaysSchedule(this.anchor, this.count);

  static const int maxCount = 15;

  final BoundaryAnchor anchor;
  final int count;

  @override
  ({CalendarDate start, CalendarDate? end}) baseRangeFor(int year, int month) {
    if (count < 1 || count > maxCount) {
      throw ArgumentError.value(count, 'count', 'outside 1..$maxCount');
    }
    final int length = IncomeSchedule.daysInMonth(year, month);
    return switch (anchor) {
      BoundaryAnchor.start => (
        start: CalendarDate(year, month, 1),
        end: CalendarDate(year, month, count.clamp(1, length)),
      ),
      BoundaryAnchor.end => (
        start: CalendarDate(year, month, (length - count + 1).clamp(1, length)),
        end: CalendarDate(year, month, length),
      ),
    };
  }
}
