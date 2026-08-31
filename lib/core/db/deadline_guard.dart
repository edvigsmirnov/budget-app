import 'package:drift/drift.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

/// Raised when a record would be dated past a hard deadline (spec 4.8).
class BeyondHardDeadline implements Exception {
  const BeyondHardDeadline(this.deadline);

  final CalendarDate deadline;

  @override
  String toString() => 'BeyondHardDeadline: $deadline';
}

/// Refuses records dated after a Budget Space's hard deadline.
///
/// Here rather than in the form for the same reason the freeze guard is: the
/// rule is about what the tables may contain, and a check only a screen makes
/// is bypassed by every other path to the same table.
///
/// A soft deadline refuses nothing — it is a marker, and the spec is explicit
/// that it must not affect input. Nor does moving a hard deadline backwards
/// delete or block what is already there: those records are marked beyond the
/// deadline and left alone until it moves again (spec 4.8).
class DeadlineGuard {
  const DeadlineGuard({required this.db});

  final AppDatabase db;

  /// Throws [BeyondHardDeadline] when [date] falls after a hard deadline.
  Future<void> refuseIfBeyondDeadline(String spaceId, CalendarDate date) async {
    final BudgetPeriod? period =
        await (db.select(db.budgetPeriods)..where(
              ($BudgetPeriodsTable t) =>
                  t.spaceId.equals(spaceId) &
                  t.periodType.equalsValue(PeriodType.continuous) &
                  t.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (period == null || !period.deadlineIsHard) return;

    final CalendarDate? deadline = period.deadlineDate;
    if (deadline == null || !date.isAfter(deadline)) return;
    throw BeyondHardDeadline(deadline);
  }
}
