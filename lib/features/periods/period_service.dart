import 'package:meta/meta.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/period/period_materializer.dart';
import 'package:sielto/domain/schedule/income_schedule.dart';
import 'package:sielto/domain/schedule/income_window.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/periods/schedule_mapping.dart';

/// What a refresh changed, for the caller to report.
@immutable
class PeriodRefresh {
  const PeriodRefresh({
    this.periodsCreated = 0,
    this.periodsUpdated = 0,
    this.incomesMaterialised = 0,
    this.reboundToAuto = 0,
  });

  final int periodsCreated;
  final int periodsUpdated;
  final int incomesMaterialised;

  /// Payments whose hand-picked period was merged away and which fell back to
  /// automatic binding. The UI says so once, rather than moving them silently
  /// (spec 5.3).
  final int reboundToAuto;

  bool get isEmpty =>
      periodsCreated == 0 &&
      periodsUpdated == 0 &&
      incomesMaterialised == 0 &&
      reboundToAuto == 0;
}

/// Keeps `budget_periods` and future `incomes` rows in step with the anchor
/// schedules of an income-driven Space (spec 4.7, 5.2).
///
/// Three rules shape everything here:
///
/// - **Closed periods are never recomputed.** A period closes when the next
///   anchor arrives, which is earlier than the freeze at `end_date + 14d`.
///   Once closed its boundaries are history (spec 5.4).
/// - **Open periods move in place.** The row keeps its id so a payment pinned
///   to it by hand still means what the user meant (spec 5.3).
/// - **Received rows are untouchable.** Neither a schedule change nor a
///   recompute may move an income already marked received (spec 5.4).
class PeriodService {
  PeriodService({
    required this.repos,
    required this.calendar,
    this.missingHolidayYears = const <int>{},
  });

  final Repositories repos;

  /// Weekends, public holidays and custom non-working days, already merged
  /// (spec 5.1.1). Resolving the three sources is the caller's job.
  final WorkingDayCalendar calendar;

  /// Years the holiday list could not be obtained for. A period anchored in
  /// one of them is written with `holiday_data_incomplete`, so the window can
  /// be narrowed later instead of silently standing as final (spec 5.1.1).
  final Set<int> missingHolidayYears;

  /// How many months of future occurrences each rule materialises.
  static const int incomeHorizonMonths = PeriodMaterializer.horizonPeriods;

  /// Recomputes everything derivable from the schedules.
  ///
  /// Safe to call on every Space open: with no anchors it does nothing, which
  /// is the valid permanent state of a Space that has no income yet
  /// (spec 4.7).
  Future<PeriodRefresh> refresh(Space space, CalendarDate today) async {
    if (space.budgetMode != BudgetMode.incomeDriven) {
      return const PeriodRefresh();
    }

    final List<IncomeRecurrenceRule> rules = await repos.incomeRules.inSpace(
      space.id,
    );
    final List<AnchorSchedule> anchors = <AnchorSchedule>[
      for (final IncomeRecurrenceRule rule in rules)
        if (rule.isAnchor)
          if (scheduleOf(rule) case final IncomeSchedule schedule)
            AnchorSchedule(ruleId: rule.id, schedule: schedule),
    ];
    if (anchors.isEmpty) return const PeriodRefresh();

    final List<MaterializedPeriod> computed = PeriodMaterializer.materialize(
      anchors: anchors,
      from: today,
      calendar: calendar,
    );

    final ({int created, int removed, int updated}) periods =
        await _syncPeriods(space: space, computed: computed, today: today);
    // Occurrences stop at the last known boundary, so every materialised row
    // has a period to belong to. The horizon moves them along together.
    final List<BudgetPeriod> boundaries = await repos.periods.incomeDrivenIn(
      space.id,
    );
    // The floor is the start of the cycle the user is in, not today. The
    // anchor of the current period has usually already arrived — a Space
    // created mid-month is the ordinary case — and without its row the period
    // it opens has no amount and reads as uncomputable (spec 4.7).
    final BudgetPeriod? current = boundaries
        .where(
          (BudgetPeriod p) =>
              !p.startDate.isAfter(today) &&
              (p.endDate == null || !p.endDate!.isBefore(today)),
        )
        .firstOrNull;

    final int materialised = await _materialiseIncomes(
      space: space,
      rules: rules,
      today: today,
      from: current?.startDate ?? today,
      horizonEnd: boundaries.isEmpty ? null : boundaries.last.endDate,
    );
    final int rebound = await _bindRecords(space);

    return PeriodRefresh(
      periodsCreated: periods.created,
      periodsUpdated: periods.updated,
      incomesMaterialised: materialised,
      reboundToAuto: rebound,
    );
  }

  /// Writes the computed boundaries over the open periods, in order.
  Future<({int created, int updated, int removed})> _syncPeriods({
    required Space space,
    required List<MaterializedPeriod> computed,
    required CalendarDate today,
  }) async {
    final List<BudgetPeriod> existing = await repos.periods.incomeDrivenIn(
      space.id,
    );

    // A period is closed once its end is behind us. Those are history and are
    // left exactly as they were.
    final List<BudgetPeriod> open =
        existing
            .where(
              (BudgetPeriod p) =>
                  p.endDate == null || !p.endDate!.isBefore(today),
            )
            .toList()
          ..sort(
            (BudgetPeriod a, BudgetPeriod b) =>
                a.startDate.compareTo(b.startDate),
          );

    int created = 0;
    int updated = 0;

    for (int i = 0; i < computed.length; i++) {
      final MaterializedPeriod period = computed[i];
      if (i < open.length) {
        await repos.periods.updateBoundaries(
          open[i].id,
          startDate: period.startDate,
          endDate: period.endDate,
          anchorDate: period.anchorDate,
          windowStart: period.windowStart,
          windowEnd: period.windowEnd,
          holidayDataIncomplete: _incomplete(period),
        );
        updated++;
      } else {
        await repos.periods.createIncomeDriven(
          spaceId: space.id,
          startDate: period.startDate,
          // The furthest period has no successor yet, so no end. It gets one
          // on the next refresh, when the horizon moves.
          endDate: period.endDate ?? period.startDate,
          anchorDate: period.anchorDate,
          windowStart: period.windowStart,
          windowEnd: period.windowEnd,
          holidayDataIncomplete: _incomplete(period),
        );
        created++;
      }
    }

    // Open rows past the end of the computed list no longer correspond to any
    // anchor — anchors merged, or a rule was removed.
    int removed = 0;
    for (int i = computed.length; i < open.length; i++) {
      await repos.periods.softDelete(open[i].id);
      removed++;
    }

    return (created: created, updated: updated, removed: removed);
  }

  /// Whether this period's window was computed without the holidays of the
  /// year it is anchored in.
  ///
  /// The window can only ever narrow when the data arrives — a holiday adds
  /// non-working days, never removes them — so the flag marks a window that is
  /// wide rather than one that is wrong (spec 5.1.1).
  bool _incomplete(MaterializedPeriod period) =>
      missingHolidayYears.contains(period.anchorDate.year);

  /// Fills in the future occurrences each rule is missing.
  ///
  /// Only gaps are filled: an occurrence that already exists keeps its own
  /// `is_paid`, note and any per-occurrence amount correction (spec 5.2).
  Future<int> _materialiseIncomes({
    required Space space,
    required List<IncomeRecurrenceRule> rules,
    required CalendarDate today,
    required CalendarDate from,
    required CalendarDate? horizonEnd,
  }) async {
    int written = 0;

    for (final IncomeRecurrenceRule rule in rules) {
      final IncomeSchedule? schedule = scheduleOf(rule);
      if (schedule == null) continue;

      final Set<String> already = await repos.incomes.materialisedDatesFor(
        rule.id,
      );

      int year = from.year;
      int month = from.month;
      for (int i = 0; i < incomeHorizonMonths; i++) {
        final IncomeWindow window = schedule.resolveFor(
          year,
          month,
          calendar: calendar,
        );
        final String iso = window.anchorDate.toIso();

        // History is not invented: an income the user never recorded did not
        // happen as far as the app knows. The floor is [from] rather than
        // today, so the current cycle's own anchor is written even though its
        // date has passed. Nor is anything past the last boundary, which would
        // have no period to belong to.
        final bool withinHorizon =
            horizonEnd == null || !window.anchorDate.isAfter(horizonEnd);
        if (withinHorizon &&
            !window.anchorDate.isBefore(from) &&
            !already.contains(iso)) {
          await repos.incomes.create(
            spaceId: space.id,
            title: rule.title,
            expectedDate: window.anchorDate,
            amount: rule.amount,
            recurrenceRuleId: rule.id,
          );
          already.add(iso);
          written++;
        }

        month++;
        if (month == 13) {
          month = 1;
          year++;
        }
      }
    }

    return written;
  }

  /// Binds every record to the period its date falls in.
  ///
  /// Returns how many hand-pinned payments lost their period and fell back to
  /// automatic binding.
  Future<int> _bindRecords(Space space) async {
    final List<BudgetPeriod> periods = await repos.periods.incomeDrivenIn(
      space.id,
    );
    if (periods.isEmpty) return 0;

    String? periodFor(CalendarDate date) {
      for (final BudgetPeriod p in periods) {
        if (p.startDate.isAfter(date)) continue;
        final CalendarDate? end = p.endDate;
        if (end == null || !end.isBefore(date)) return p.id;
      }
      return null;
    }

    for (final Payment payment in await repos.payments.autoAssignedIn(
      space.id,
    )) {
      final String? target = periodFor(payment.dueDate);
      if (target != payment.budgetPeriodId) {
        await repos.payments.setPeriod(payment.id, target);
      }
    }

    // A manual pin survives a recompute, because the row it points at moved
    // rather than being replaced. It only breaks when that row is gone.
    final Set<String> live = <String>{
      for (final BudgetPeriod p in periods) p.id,
    };
    int rebound = 0;
    for (final Payment payment in await repos.payments.manuallyAssignedIn(
      space.id,
    )) {
      final String? pinned = payment.budgetPeriodId;
      if (pinned != null && live.contains(pinned)) continue;
      await repos.payments.setPeriod(
        payment.id,
        periodFor(payment.dueDate),
        assignment: PeriodAssignment.auto,
      );
      rebound++;
    }

    for (final Income income in await repos.incomes.inSpace(space.id)) {
      final String? target = periodFor(income.expectedDate);
      if (target != income.budgetPeriodId) {
        await repos.incomes.setPeriod(income.id, target);
      }
    }

    return rebound;
  }
}
