import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/synced_repository.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Period boundaries. The single source of truth for all three modes
/// (spec 4.7); the materialisation logic that fills it arrives in M2.
class BudgetPeriodRepository
    extends SyncedRepository<$BudgetPeriodsTable, BudgetPeriod> {
  BudgetPeriodRepository({
    required super.db,
    required super.clock,
    required super.userId,
  });

  @override
  TableInfo<$BudgetPeriodsTable, BudgetPeriod> get table => db.budgetPeriods;

  Future<List<BudgetPeriod>> inSpace(String spaceId) =>
      (selectAliveInSpace(spaceId)
            ..orderBy(<OrderClauseGenerator<$BudgetPeriodsTable>>[
              ($BudgetPeriodsTable t) => OrderingTerm(expression: t.startDate),
            ]))
          .get();

  /// The open row Flow and Budget share. Exactly one per Space, and it never
  /// closes — which is why freezing does not reach those modes (spec 4.7).
  Future<BudgetPeriod?> continuousFor(String spaceId) =>
      (selectAliveInSpace(spaceId)..where(
            ($BudgetPeriodsTable t) =>
                t.periodType.equalsValue(PeriodType.continuous),
          ))
          .getSingleOrNull();

  /// Creates the continuous row if the Space has none. Idempotent, so it is
  /// safe to call on every space open (plan G8).
  Future<BudgetPeriod> ensureContinuous({
    required String spaceId,
    required CalendarDate startDate,
    Decimal? budgetTarget,
    CalendarDate? deadlineDate,
    bool deadlineIsHard = false,
  }) async {
    final BudgetPeriod? existing = await continuousFor(spaceId);
    if (existing != null) return existing;

    final ({String author, DateTime editedAt}) s = stamp();
    return db
        .into(db.budgetPeriods)
        .insertReturning(
          BudgetPeriodsCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            periodType: PeriodType.continuous,
            startDate: startDate,
            // Null end_date: the context is open and has no end.
            budgetTarget: Value<Decimal?>(budgetTarget),
            deadlineDate: Value<CalendarDate?>(deadlineDate),
            deadlineIsHard: Value<bool>(deadlineIsHard),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
        );
  }

  /// An income-driven cycle. Boundaries are inclusive on both ends:
  /// `[anchor, next anchor - 1]` (spec 4.7).
  Future<BudgetPeriod> createIncomeDriven({
    required String spaceId,
    required CalendarDate startDate,
    required CalendarDate endDate,
    required CalendarDate anchorDate,
    CalendarDate? windowStart,
    CalendarDate? windowEnd,
    bool holidayDataIncomplete = false,
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return db
        .into(db.budgetPeriods)
        .insertReturning(
          BudgetPeriodsCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            periodType: PeriodType.incomeDriven,
            startDate: startDate,
            endDate: Value<CalendarDate?>(endDate),
            anchorDate: Value<CalendarDate?>(anchorDate),
            windowStart: Value<CalendarDate?>(windowStart),
            windowEnd: Value<CalendarDate?>(windowEnd),
            holidayDataIncomplete: Value<bool>(holidayDataIncomplete),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
        );
  }

  /// The income-driven cycles of a Space, oldest first.
  Future<List<BudgetPeriod>> incomeDrivenIn(String spaceId) async {
    final List<BudgetPeriod> all = await inSpace(spaceId);
    return all
        .where((BudgetPeriod p) => p.periodType == PeriodType.incomeDriven)
        .toList();
  }

  Stream<List<BudgetPeriod>> watchInSpace(String spaceId) =>
      (selectAliveInSpace(spaceId)
            ..orderBy(<OrderClauseGenerator<$BudgetPeriodsTable>>[
              ($BudgetPeriodsTable t) => OrderingTerm(expression: t.startDate),
            ]))
          .watch();

  /// Moves an existing period's boundaries without replacing the row.
  ///
  /// In place, and that is the point: a payment pinned to a period by hand
  /// holds the period as an object, so "I filed this under the September
  /// salary" stays true even when that salary shifts by two days (spec 5.3).
  Future<int> updateBoundaries(
    String periodId, {
    required CalendarDate startDate,
    required CalendarDate? endDate,
    required CalendarDate anchorDate,
    required CalendarDate windowStart,
    required CalendarDate windowEnd,
    bool holidayDataIncomplete = false,
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.budgetPeriods,
    )..where(($BudgetPeriodsTable t) => t.id.equals(periodId))).write(
      BudgetPeriodsCompanion(
        startDate: Value<CalendarDate>(startDate),
        endDate: Value<CalendarDate?>(endDate),
        anchorDate: Value<CalendarDate?>(anchorDate),
        windowStart: Value<CalendarDate?>(windowStart),
        windowEnd: Value<CalendarDate?>(windowEnd),
        holidayDataIncomplete: Value<bool>(holidayDataIncomplete),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// The period a date falls in. A `continuous` row has no end and always
  /// matches once it has started.
  Future<BudgetPeriod?> containing(String spaceId, CalendarDate date) async {
    final List<BudgetPeriod> periods = await inSpace(spaceId);
    for (final BudgetPeriod p in periods) {
      if (p.startDate.isAfter(date)) continue;
      final CalendarDate? end = p.endDate;
      if (end == null || !end.isBefore(date)) return p;
    }
    return null;
  }

  /// Temporary unfreeze of a closed period (spec 5.5).
  Future<int> unfreeze(String periodId, DateTime until, String reason) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.budgetPeriods,
    )..where(($BudgetPeriodsTable t) => t.id.equals(periodId))).write(
      BudgetPeriodsCompanion(
        unfrozenUntil: Value<DateTime?>(until),
        unfreezeReason: Value<String?>(reason),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }
}
