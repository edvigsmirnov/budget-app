import 'package:meta/meta.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// When an income might land, and the one date the maths uses.
///
/// Payday practice differs by country and employer — some pay before a
/// weekend, some after — so the app does not pick a direction for the span. It
/// shows the whole span as uncertain and computes against one day in it.
///
/// **The anchor moves forward, but never out of its month.** A salary due on
/// the 31st that falls on a Saturday is anchored on the Friday before, not the
/// Monday after: "October's salary" opening November's cycle is a boundary
/// nobody expects, and it makes a month's figures answer for the wrong month.
///
/// This is a deliberate departure from spec 5.1.1, which takes the window's
/// last working day unconditionally. That rule is the more conservative one —
/// it never plans against money that has not arrived — and the trade is
/// accepted because the arrival date is confirmable: marking the salary
/// received re-anchors the cycle on the day it actually came (spec 5.4).
@immutable
class IncomeWindow {
  const IncomeWindow({
    required this.windowStart,
    required this.windowEnd,
    required this.anchorDate,
  });

  /// Earliest the money might arrive.
  final CalendarDate windowStart;

  /// Latest it might arrive. Always a working day.
  final CalendarDate windowEnd;

  /// What every calculation uses. The window's last working day, unless that
  /// would fall in the following month — then the first one, so a cycle stays
  /// in the month it belongs to.
  final CalendarDate anchorDate;

  /// True when the base date was not a working day, or the schedule spans
  /// several days. The UI hatches this span on the calendar.
  bool get isUncertain => windowStart != windowEnd;

  int get lengthInDays => windowStart.daysUntil(windowEnd) + 1;

  @override
  bool operator ==(Object other) =>
      other is IncomeWindow &&
      other.windowStart == windowStart &&
      other.windowEnd == windowEnd &&
      other.anchorDate == anchorDate;

  @override
  int get hashCode => Object.hash(windowStart, windowEnd, anchorDate);

  @override
  String toString() =>
      'IncomeWindow($windowStart..$windowEnd, anchor $anchorDate)';
}

/// Resolves a schedule's raw date, or raw span, into an [IncomeWindow].
///
/// A single [start] with no [end] is a precise schedule: if it lands on a
/// non-working day the window opens in both directions, to the working days
/// on either side of the gap. A schedule that is already a span keeps its own
/// [start] and only extends to the right, since the left edge was chosen by
/// the user rather than forced by the calendar (spec 4.7).
///
/// The anchor is the window's last working day while that stays inside the
/// month the schedule pointed at; otherwise the first one.
IncomeWindow resolveIncomeWindow({
  required CalendarDate start,
  required WorkingDayCalendar calendar,
  CalendarDate? end,
}) {
  if (end == null) {
    if (calendar.isWorkingDay(start)) {
      return IncomeWindow(
        windowStart: start,
        windowEnd: start,
        anchorDate: start,
      );
    }
    final CalendarDate before = calendar.workingDayOnOrBefore(start);
    final CalendarDate after = calendar.workingDayOnOrAfter(start);
    return IncomeWindow(
      windowStart: before,
      windowEnd: after,
      anchorDate: _anchorWithin(start, before: before, after: after),
    );
  }

  if (end.isBefore(start)) {
    throw ArgumentError.value(end, 'end', 'ends before $start');
  }
  final CalendarDate windowEnd = calendar.workingDayOnOrAfter(end);
  return IncomeWindow(
    windowStart: start,
    windowEnd: windowEnd,
    anchorDate: _anchorWithin(
      end,
      before: calendar.workingDayOnOrBefore(end),
      after: windowEnd,
    ),
  );
}

/// Forward, unless forward leaves the month [scheduled] named.
///
/// Only the month matters, not the count of days skipped: a Saturday the 31st
/// and a Saturday the 1st are the same distance from a working day and belong
/// to opposite cycles.
CalendarDate _anchorWithin(
  CalendarDate scheduled, {
  required CalendarDate before,
  required CalendarDate after,
}) {
  final bool sameMonth =
      after.year == scheduled.year && after.month == scheduled.month;
  return sameMonth ? after : before;
}
