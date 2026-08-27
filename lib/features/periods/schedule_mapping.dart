import 'package:easy_localization/easy_localization.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/schedule/income_schedule.dart';
import 'package:sielto/domain/value/enums.dart';

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
/// Built from the stored fields rather than from [scheduleOf], so it still
/// describes a rule whose fields that function would reject.
String scheduleSummary(IncomeRecurrenceRule rule) {
  switch (rule.scheduleType) {
    case ScheduleType.fixedDate:
      return tr(
        'schedule.fixedDate.summary',
        namedArgs: <String, String>{'day': '${rule.fixedDay ?? '?'}'},
      );

    case ScheduleType.weekdayRule:
      final WeekdayOrdinal? ordinal = rule.weekdayOrdinal;
      final Weekday? weekday = rule.weekdayDay;
      if (ordinal == null || weekday == null) return tr('schedule.incomplete');
      return tr(
        'schedule.weekdayRule.summary',
        namedArgs: <String, String>{
          'ordinal': tr('ordinal.${ordinal.name}'),
          'weekday': tr('weekday.${weekday.name}'),
        },
      );

    case ScheduleType.dateRange:
      return tr(
        'schedule.dateRange.summary',
        namedArgs: <String, String>{
          'start': '${rule.dateRangeStart ?? '?'}',
          'end': '${rule.dateRangeEnd ?? '?'}',
        },
      );

    case ScheduleType.boundaryDays:
      final BoundaryAnchor? anchor = rule.boundaryAnchor;
      if (anchor == null) return tr('schedule.incomplete');
      return tr(
        'schedule.boundaryDays.summary',
        namedArgs: <String, String>{
          'count': '${rule.boundaryCount ?? '?'}',
          'anchor': tr('boundary.${anchor.name}'),
        },
      );
  }
}
