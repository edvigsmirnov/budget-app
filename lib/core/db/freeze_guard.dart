import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/period/freeze.dart';

/// Raised when a write would change a protected field of a record whose period
/// has frozen (spec 5.5).
class PeriodFrozen implements Exception {
  const PeriodFrozen(this.periodId);

  final String periodId;

  @override
  String toString() => 'PeriodFrozen: $periodId';
}

/// Refuses edits to closed history.
///
/// The check lives here rather than in a screen because that is the point of
/// the rule: a period freezes so the totals stop moving, and a guarantee that
/// only a widget enforces can be routed around by any other path to the same
/// table (spec 5.5, level 2).
///
/// What stays editable in a frozen period is as deliberate as what does not:
/// the category of a payment, because reclassifying does not change the fact
/// of it, and notes, because they may only be appended.
class FreezeGuard {
  const FreezeGuard({
    required this.db,
    required this.clock,
    this.evaluator = const FreezeEvaluator(),
  });

  final AppDatabase db;

  /// The injected wall clock. Re-zoned per Space rather than replaced, so no
  /// path here reads the system time (plan section 2, invariant 7).
  final SpaceClock clock;

  final FreezeEvaluator evaluator;

  /// Throws [PeriodFrozen] when [periodId] is closed to edits.
  ///
  /// "Today" is resolved in the Space's own timezone, not the device's: two
  /// members in different countries have to agree on which day it is, or they
  /// would disagree about whether a period has frozen (spec 5.5).
  Future<void> refuseIfFrozen(String? periodId) async {
    if (periodId == null) return;

    final BudgetPeriod? period =
        await (db.select(db.budgetPeriods)
              ..where(($BudgetPeriodsTable t) => t.id.equals(periodId)))
            .getSingleOrNull();
    // A continuous period has no end, so it never freezes — a consequence of
    // Flow and Budget being open-ended, not an exemption (spec 4.7).
    if (period == null || period.endDate == null) return;

    final Space? space =
        await (db.select(db.spaces)
              ..where(($SpacesTable t) => t.id.equals(period.spaceId)))
            .getSingleOrNull();
    if (space == null) return;

    final SpaceClock spaceClock = clock.inZone(space.timezone);
    final bool frozen = evaluator.isFrozen(
      endDate: period.endDate,
      today: spaceClock.today(),
      nowUtc: spaceClock.nowUtc(),
      unfrozenUntil: period.unfrozenUntil,
    );
    if (frozen) throw PeriodFrozen(periodId);
  }

  /// The state to show, for a screen that wants to warn rather than refuse.
  Future<FreezeState> stateOf(String? periodId) async {
    if (periodId == null) return FreezeState.open;

    final BudgetPeriod? period =
        await (db.select(db.budgetPeriods)
              ..where(($BudgetPeriodsTable t) => t.id.equals(periodId)))
            .getSingleOrNull();
    if (period == null || period.endDate == null) return FreezeState.open;

    final Space? space =
        await (db.select(db.spaces)
              ..where(($SpacesTable t) => t.id.equals(period.spaceId)))
            .getSingleOrNull();
    if (space == null) return FreezeState.open;

    final SpaceClock spaceClock = clock.inZone(space.timezone);
    return evaluator.evaluate(
      endDate: period.endDate,
      today: spaceClock.today(),
      nowUtc: spaceClock.nowUtc(),
      unfrozenUntil: period.unfrozenUntil,
    );
  }
}
