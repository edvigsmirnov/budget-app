import 'package:budget_app/domain/schedule/income_schedule.dart';
import 'package:budget_app/domain/schedule/income_window.dart';
import 'package:budget_app/domain/schedule/working_days.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:meta/meta.dart';

/// One anchor income's schedule, as the materializer needs it.
@immutable
class AnchorSchedule {
  const AnchorSchedule({required this.ruleId, required this.schedule});

  final String ruleId;
  final IncomeSchedule schedule;
}

/// A computed period boundary, before it becomes a `budget_periods` row.
@immutable
class MaterializedPeriod {
  const MaterializedPeriod({
    required this.startDate,
    required this.endDate,
    required this.anchorDate,
    required this.windowStart,
    required this.windowEnd,
    required this.ruleIds,
  });

  final CalendarDate startDate;

  /// Inclusive, and one day before the next anchor. Null only for the last
  /// period computed, whose successor is beyond the horizon.
  final CalendarDate? endDate;

  final CalendarDate anchorDate;
  final CalendarDate windowStart;
  final CalendarDate windowEnd;

  /// Every anchor rule that resolved to this date. More than one means their
  /// anchors coincided and the periods merged.
  final List<String> ruleIds;

  bool get isMerged => ruleIds.length > 1;

  /// Inclusive on both ends, so a one-day period has length 1.
  int? get lengthInDays =>
      endDate == null ? null : startDate.daysUntil(endDate!) + 1;

  @override
  String toString() =>
      'MaterializedPeriod($startDate..${endDate ?? '-'}, '
      'anchor $anchorDate, rules $ruleIds)';
}

/// Turns anchor schedules into period boundaries (spec 4.7).
///
/// The convention is `[anchor, next anchor - 1]`, inclusive at both ends. A
/// payment due on the next anchor's date belongs to the *next* period: the
/// money has arrived that day, which agrees with the latest-working-day rule
/// used to pick the anchor in the first place.
abstract final class PeriodMaterializer {
  /// How far ahead periods are computed. Two periods before the edge, the app
  /// extends by another six, so paging forward never hits an unexplained wall
  /// (spec 4.7).
  static const int horizonPeriods = 6;

  /// Periods covering [from] and the next [count] anchors.
  ///
  /// Anchors landing on the same date merge into one period rather than
  /// producing a zero-length one: both incomes then belong to the same cycle
  /// and their amounts add. That is what makes the "minimum length is one day"
  /// invariant hold by construction.
  static List<MaterializedPeriod> materialize({
    required List<AnchorSchedule> anchors,
    required CalendarDate from,
    required WorkingDayCalendar calendar,
    int count = horizonPeriods,
  }) {
    if (anchors.isEmpty) return const <MaterializedPeriod>[];

    // One extra anchor beyond the horizon, so the last period gets a real end.
    final List<_Anchor> resolved = _anchorsFrom(
      anchors: anchors,
      from: from,
      calendar: calendar,
      needed: count + 1,
    );
    if (resolved.isEmpty) return const <MaterializedPeriod>[];

    final List<MaterializedPeriod> periods = <MaterializedPeriod>[];
    for (int i = 0; i < resolved.length && periods.length < count; i++) {
      final _Anchor current = resolved[i];
      final _Anchor? next = i + 1 < resolved.length ? resolved[i + 1] : null;
      periods.add(
        MaterializedPeriod(
          startDate: current.date,
          endDate: next?.date.addDays(-1),
          anchorDate: current.date,
          windowStart: current.windowStart,
          windowEnd: current.windowEnd,
          ruleIds: current.ruleIds,
        ),
      );
    }
    return periods;
  }

  /// True when only [remaining] periods are left ahead of today — the point
  /// at which the next batch is materialised (spec 4.7).
  static bool needsExtension(
    List<MaterializedPeriod> periods,
    CalendarDate today, {
    int threshold = 2,
  }) {
    final int ahead = periods
        .where((MaterializedPeriod p) => !p.startDate.isBefore(today))
        .length;
    return ahead <= threshold;
  }

  /// Resolves each schedule month by month, merges coincident anchors and
  /// returns them in date order.
  static List<_Anchor> _anchorsFrom({
    required List<AnchorSchedule> anchors,
    required CalendarDate from,
    required WorkingDayCalendar calendar,
    required int needed,
  }) {
    final Map<String, _Anchor> byDate = <String, _Anchor>{};

    // Start a month early: a schedule late in the previous month can resolve
    // forward into the window, and the period containing `from` starts before
    // it.
    int year = from.year;
    int month = from.month - 1;
    if (month == 0) {
      month = 12;
      year -= 1;
    }

    // Bounded so a schedule that somehow never lands ahead of `from` cannot
    // spin. Each pass covers one month.
    const int maxMonths = 120;
    for (int i = 0; i < maxMonths && byDate.length < needed + 2; i++) {
      for (final AnchorSchedule anchor in anchors) {
        final IncomeWindow window = anchor.schedule.resolveFor(
          year,
          month,
          calendar: calendar,
        );
        final String key = window.anchorDate.toIso();
        final _Anchor? existing = byDate[key];
        if (existing == null) {
          byDate[key] = _Anchor(
            date: window.anchorDate,
            windowStart: window.windowStart,
            windowEnd: window.windowEnd,
            ruleIds: <String>[anchor.ruleId],
          );
        } else {
          // Coincident anchors merge into one period (spec 4.7).
          existing.ruleIds.add(anchor.ruleId);
          if (window.windowStart.isBefore(existing.windowStart)) {
            byDate[key] = existing.withWindowStart(window.windowStart);
          }
        }
      }
      month++;
      if (month == 13) {
        month = 1;
        year++;
      }
    }

    final List<_Anchor> sorted = byDate.values.toList()
      ..sort((_Anchor a, _Anchor b) => a.date.compareTo(b.date));

    // The period containing `from` starts at the last anchor on or before it.
    final int startIndex = sorted.lastIndexWhere(
      (_Anchor a) => !a.date.isAfter(from),
    );
    return sorted.sublist(startIndex < 0 ? 0 : startIndex);
  }
}

class _Anchor {
  _Anchor({
    required this.date,
    required this.windowStart,
    required this.windowEnd,
    required this.ruleIds,
  });

  final CalendarDate date;
  final CalendarDate windowStart;
  final CalendarDate windowEnd;
  final List<String> ruleIds;

  _Anchor withWindowStart(CalendarDate start) => _Anchor(
    date: date,
    windowStart: start,
    windowEnd: windowEnd,
    ruleIds: ruleIds,
  );
}
