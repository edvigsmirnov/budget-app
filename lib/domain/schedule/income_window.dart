import 'package:meta/meta.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// When an income might land, and the one date the maths uses.
///
/// Payday practice differs by country and employer — some pay before a
/// weekend, some after — so the app does not pick a direction. It shows the
/// span as uncertain and computes against the latest working day in it
/// (spec 5.1.1). That is the conservative choice: a payment is never planned
/// against money that has not arrived.
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

  /// What every calculation uses. Always equal to [windowEnd].
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
/// Either way the anchor is the window's last working day.
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
      anchorDate: after,
    );
  }

  if (end.isBefore(start)) {
    throw ArgumentError.value(end, 'end', 'ends before $start');
  }
  final CalendarDate windowEnd = calendar.workingDayOnOrAfter(end);
  return IncomeWindow(
    windowStart: start,
    windowEnd: windowEnd,
    anchorDate: windowEnd,
  );
}
