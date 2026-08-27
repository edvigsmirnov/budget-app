import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/synced_repository.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Raised when the last anchor of an income_driven Space would be removed or
/// demoted.
///
/// The invariant: an income_driven Space that has at least one regular income
/// always has at least one anchor (spec 4.7). Enforced here rather than in a
/// screen, because the repository is the single point every mutation passes
/// through — a UI check can be routed around, this cannot.
class LastAnchorRequired implements Exception {
  const LastAnchorRequired(this.ruleId);

  final String ruleId;

  @override
  String toString() => 'LastAnchorRequired: $ruleId';
}

/// Repetition rules for regular incomes.
class IncomeRuleRepository
    extends
        SyncedRepository<$IncomeRecurrenceRulesTable, IncomeRecurrenceRule> {
  IncomeRuleRepository({
    required super.db,
    required super.clock,
    required super.userId,
  });

  @override
  TableInfo<$IncomeRecurrenceRulesTable, IncomeRecurrenceRule> get table =>
      db.incomeRecurrenceRules;

  Future<List<IncomeRecurrenceRule>> inSpace(String spaceId) =>
      selectAliveInSpace(spaceId).get();

  Future<List<IncomeRecurrenceRule>> anchorsInSpace(String spaceId) =>
      (selectAliveInSpace(spaceId)
            ..where(($IncomeRecurrenceRulesTable t) => t.isAnchor.equals(true)))
          .get();

  /// Creates a rule. The caller has already resolved which schedule fields
  /// apply; the CHECK constraints reject a mismatched set.
  Future<IncomeRecurrenceRule> create({
    required String spaceId,
    required String title,
    required ScheduleType scheduleType,
    Decimal? amount,
    bool isAnchor = false,
    int? fixedDay,
    WeekdayOrdinal? weekdayOrdinal,
    Weekday? weekdayDay,
    int? dateRangeStart,
    int? dateRangeEnd,
    BoundaryAnchor? boundaryAnchor,
    int? boundaryCount,
    String? countryCode,
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return db
        .into(db.incomeRecurrenceRules)
        .insertReturning(
          IncomeRecurrenceRulesCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            title: title.trim(),
            scheduleType: scheduleType,
            amount: Value<Decimal?>(amount),
            isAnchor: Value<bool>(isAnchor),
            fixedDay: Value<int?>(fixedDay),
            weekdayOrdinal: Value<WeekdayOrdinal?>(weekdayOrdinal),
            weekdayDay: Value<Weekday?>(weekdayDay),
            dateRangeStart: Value<int?>(dateRangeStart),
            dateRangeEnd: Value<int?>(dateRangeEnd),
            boundaryAnchor: Value<BoundaryAnchor?>(boundaryAnchor),
            boundaryCount: Value<int?>(boundaryCount),
            countryCode: Value<String?>(countryCode),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
        );
  }

  /// The first regular income of an income_driven Space becomes the anchor
  /// automatically (spec 5.2).
  Future<IncomeRecurrenceRule> createFirstAsAnchor({
    required String spaceId,
    required BudgetMode mode,
    required String title,
    required ScheduleType scheduleType,
    Decimal? amount,
    int? fixedDay,
    WeekdayOrdinal? weekdayOrdinal,
    Weekday? weekdayDay,
    int? dateRangeStart,
    int? dateRangeEnd,
    BoundaryAnchor? boundaryAnchor,
    int? boundaryCount,
    String? countryCode,
  }) async {
    // Anchoring is meaningless outside income_driven: Flow and Budget have no
    // period between incomes, so the flag stays false and no UI offers it.
    final bool anchor =
        mode == BudgetMode.incomeDriven &&
        (await anchorsInSpace(spaceId)).isEmpty;
    return create(
      spaceId: spaceId,
      title: title,
      scheduleType: scheduleType,
      amount: amount,
      isAnchor: anchor,
      fixedDay: fixedDay,
      weekdayOrdinal: weekdayOrdinal,
      weekdayDay: weekdayDay,
      dateRangeStart: dateRangeStart,
      dateRangeEnd: dateRangeEnd,
      boundaryAnchor: boundaryAnchor,
      boundaryCount: boundaryCount,
      countryCode: countryCode,
    );
  }

  /// Demoting the last anchor of an income_driven Space is refused.
  Future<int> setAnchor(
    String ruleId, {
    required bool isAnchor,
    required BudgetMode mode,
  }) async {
    if (!isAnchor) await _refuseIfLastAnchor(ruleId, mode);
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.incomeRecurrenceRules,
    )..where(($IncomeRecurrenceRulesTable t) => t.id.equals(ruleId))).write(
      IncomeRecurrenceRulesCompanion(
        isAnchor: Value<bool>(isAnchor),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// Deleting the last anchor is refused for the same reason as demoting it.
  Future<int> deleteRule(String ruleId, {required BudgetMode mode}) async {
    await _refuseIfLastAnchor(ruleId, mode);
    return softDelete(ruleId);
  }

  Future<void> _refuseIfLastAnchor(String ruleId, BudgetMode mode) async {
    if (mode != BudgetMode.incomeDriven) return;

    final IncomeRecurrenceRule? rule =
        await (selectAlive()
              ..where(($IncomeRecurrenceRulesTable t) => t.id.equals(ruleId)))
            .getSingleOrNull();
    if (rule == null || !rule.isAnchor) return;

    final List<IncomeRecurrenceRule> anchors = await anchorsInSpace(
      rule.spaceId,
    );
    if (anchors.length <= 1) throw LastAnchorRequired(ruleId);
  }
}

/// Materialised inflows: one row per expected or received income, regular and
/// one-off alike (spec 5.2).
class IncomeRepository extends SyncedRepository<$IncomesTable, Income> {
  IncomeRepository({
    required super.db,
    required super.clock,
    required super.userId,
  });

  @override
  TableInfo<$IncomesTable, Income> get table => db.incomes;

  Future<List<Income>> inSpace(String spaceId) => _selectInSpace(spaceId).get();

  Stream<List<Income>> watchInSpace(String spaceId) =>
      _selectInSpace(spaceId).watch();

  SimpleSelectStatement<$IncomesTable, Income> _selectInSpace(String spaceId) =>
      selectAliveInSpace(spaceId)
        ..orderBy(<OrderClauseGenerator<$IncomesTable>>[
          ($IncomesTable t) => OrderingTerm(expression: t.expectedDate),
          ($IncomesTable t) => OrderingTerm(expression: t.sortOrder),
          ($IncomesTable t) => OrderingTerm(expression: t.id),
        ]);

  Future<List<Income>> forRule(String ruleId) =>
      (selectAlive()
            ..where(($IncomesTable t) => t.recurrenceRuleId.equals(ruleId)))
          .get();

  Future<Income> create({
    required String spaceId,
    required String title,
    required CalendarDate expectedDate,
    Decimal? amount,
    String? recurrenceRuleId,
    String? budgetPeriodId,
    String? notes,
    bool isPaid = false,
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return db
        .into(db.incomes)
        .insertReturning(
          IncomesCompanion.insert(
            id: SyncedRepository.newId(),
            spaceId: spaceId,
            title: title.trim(),
            expectedDate: expectedDate,
            amount: Value<Decimal?>(amount),
            recurrenceRuleId: Value<String?>(recurrenceRuleId),
            budgetPeriodId: Value<String?>(budgetPeriodId),
            notes: Value<String?>(notes),
            isPaid: Value<bool>(isPaid),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: s.editedAt,
            createdAt: s.editedAt,
          ),
        );
  }

  Future<int> update(
    String id, {
    Value<String> title = const Value<String>.absent(),
    Value<Decimal?> amount = const Value<Decimal?>.absent(),
    Value<CalendarDate> expectedDate = const Value<CalendarDate>.absent(),
    Value<CalendarDate?> actualDate = const Value<CalendarDate?>.absent(),
    Value<String?> notes = const Value<String?>.absent(),
    Value<bool> isPaid = const Value<bool>.absent(),
  }) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.incomes,
    )..where(($IncomesTable t) => t.id.equals(id))).write(
      IncomesCompanion(
        title: title.present
            ? Value<String>(title.value.trim())
            : const Value<String>.absent(),
        amount: amount,
        expectedDate: expectedDate,
        actualDate: actualDate,
        notes: notes,
        isPaid: isPaid,
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// The occurrences already materialised for a rule, by expected date. Used
  /// to fill only the gaps rather than re-inserting the horizon each time.
  Future<Set<String>> materialisedDatesFor(String ruleId) async {
    final List<Income> rows = await forRule(ruleId);
    return <String>{for (final Income i in rows) i.expectedDate.toIso()};
  }

  Future<int> setPeriod(String id, String? periodId) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.incomes,
    )..where(($IncomesTable t) => t.id.equals(id))).write(
      IncomesCompanion(
        budgetPeriodId: Value<String?>(periodId),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// Rewrites the planned amount of every future occurrence of a rule.
  ///
  /// Received rows are skipped: money already in hand is a fact, and a change
  /// to what the salary will be from now on must not rewrite it (spec 5.4).
  Future<int> updateFutureAmounts(String ruleId, Decimal? amount) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(db.incomes)..where(
          ($IncomesTable t) =>
              t.recurrenceRuleId.equals(ruleId) &
              t.isPaid.equals(false) &
              t.isDeleted.equals(false),
        ))
        .write(
          IncomesCompanion(
            amount: Value<Decimal?>(amount),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: Value<DateTime>(s.editedAt),
          ),
        );
  }

  /// Drops unreceived future occurrences of a rule, so a schedule change can
  /// re-materialise them on the new dates. Received rows stay untouched.
  Future<int> clearFutureOccurrences(String ruleId, CalendarDate from) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(db.incomes)..where(
          ($IncomesTable t) =>
              t.recurrenceRuleId.equals(ruleId) &
              t.isPaid.equals(false) &
              t.isDeleted.equals(false) &
              t.expectedDate.isBiggerOrEqualValue(from.toIso()),
        ))
        .write(
          IncomesCompanion(
            isDeleted: const Value<bool>(true),
            syncStatus: const Value<SyncStatus>(SyncStatus.pending),
            lastModifiedBy: Value<String?>(s.author),
            clientEditedAt: Value<DateTime>(s.editedAt),
          ),
        );
  }

  /// Manual position within the day, set by a drag in the Feed.
  Future<int> setSortOrder(String id, int sortOrder) {
    final ({String author, DateTime editedAt}) s = stamp();
    return (db.update(
      db.incomes,
    )..where(($IncomesTable t) => t.id.equals(id))).write(
      IncomesCompanion(
        sortOrder: Value<int>(sortOrder),
        syncStatus: const Value<SyncStatus>(SyncStatus.pending),
        lastModifiedBy: Value<String?>(s.author),
        clientEditedAt: Value<DateTime>(s.editedAt),
      ),
    );
  }

  /// Confirms receipt. An amount is mandatory when the row has none: without
  /// it the period's Free Cash would stay uncomputable (spec 4.7).
  Future<int> markReceived(
    String id, {
    Decimal? amount,
    CalendarDate? actualDate,
  }) async {
    final Income? row =
        await (selectAlive()..where(($IncomesTable t) => t.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return 0;
    if (row.amount == null && amount == null) {
      throw ArgumentError.value(
        amount,
        'amount',
        'an income with no amount needs one to be marked received',
      );
    }
    return update(
      id,
      isPaid: const Value<bool>(true),
      amount: amount == null
          ? const Value<Decimal?>.absent()
          : Value<Decimal?>(amount),
      actualDate: actualDate == null
          ? const Value<CalendarDate?>.absent()
          : Value<CalendarDate?>(actualDate),
    );
  }
}
