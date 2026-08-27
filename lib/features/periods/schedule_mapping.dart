import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/domain/schedule/income_schedule.dart';
import 'package:budget_app/domain/value/enums.dart';

/// Turns a stored recurrence rule into the schedule the M2 engine understands.
///
/// The table keeps one nullable column per schedule field and a CHECK
/// constraint per type, so a well-formed row always has the fields its type
/// needs. This still returns null rather than throwing on a malformed one: a
/// bad row should cost the user one income, not the whole screen.
IncomeSchedule? scheduleOf(IncomeRecurrenceRule rule) {
  switch (rule.scheduleType) {
    case ScheduleType.fixedDate:
      final int? day = rule.fixedDay;
      return day == null ? null : FixedDateSchedule(day);

    case ScheduleType.weekdayRule:
      final WeekdayOrdinal? ordinal = rule.weekdayOrdinal;
      final Weekday? weekday = rule.weekdayDay;
      if (ordinal == null || weekday == null) return null;
      return WeekdayRuleSchedule(ordinal, weekday);

    case ScheduleType.dateRange:
      final int? start = rule.dateRangeStart;
      final int? end = rule.dateRangeEnd;
      if (start == null || end == null || end < start) return null;
      return DateRangeSchedule(start, end);

    case ScheduleType.boundaryDays:
      final BoundaryAnchor? anchor = rule.boundaryAnchor;
      final int? count = rule.boundaryCount;
      if (anchor == null || count == null) return null;
      if (count < 1 || count > BoundaryDaysSchedule.maxCount) return null;
      return BoundaryDaysSchedule(anchor, count);
  }
}

/// A one-line description of the rule, for a list row.
///
/// Deliberately built from the stored fields rather than the schedule object:
/// the string has to survive a rule whose fields [scheduleOf] would reject.
String scheduleSummaryKey(IncomeRecurrenceRule rule) =>
    'schedule.${rule.scheduleType.name}.summary';
