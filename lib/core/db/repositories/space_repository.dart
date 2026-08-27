import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/synced_repository.dart';
import 'package:budget_app/core/time/space_clock.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Raised when the currency is changed after the Space already holds a record.
/// Re-denominating existing figures would silently rewrite what they mean
/// (spec 9.2).
class CurrencyFrozen implements Exception {
  const CurrencyFrozen(this.spaceId);

  final String spaceId;

  @override
  String toString() => 'CurrencyFrozen: $spaceId';
}

/// Spaces are device-scoped rows, not synced records — they carry no sync
/// columns — so this does not extend [SyncedRepository]. Archiving is local
/// and never uploaded (spec 3.1).
class SpaceRepository {
  SpaceRepository({required this.db, required this.clock});

  final AppDatabase db;
  final SpaceClock clock;

  Future<List<Space>> all() => _selectAll().get();

  /// The same list as [all], re-emitted whenever the table changes. The UI
  /// reads this rather than re-querying after every write.
  Stream<List<Space>> watchAll() => _selectAll().watch();

  Future<Space?> byId(String id) => _selectById(id).getSingleOrNull();

  Stream<Space?> watchById(String id) => _selectById(id).watchSingleOrNull();

  SimpleSelectStatement<$SpacesTable, Space> _selectAll() =>
      db.select(db.spaces)
        ..where(($SpacesTable t) => t.isArchived.equals(false))
        ..orderBy(<OrderClauseGenerator<$SpacesTable>>[
          ($SpacesTable t) => OrderingTerm(expression: t.createdAt),
        ]);

  SimpleSelectStatement<$SpacesTable, Space> _selectById(String id) =>
      db.select(db.spaces)..where(($SpacesTable t) => t.id.equals(id));

  Future<Space> create({
    required String title,
    required SpaceType spaceType,
    required BudgetMode budgetMode,
    required String ownerId,
    required String timezone,
    required String currencyCode,
    StorageMode storageMode = StorageMode.local,
    String? countryCode,
  }) {
    if (!SpaceClock.isKnownTimezone(timezone)) {
      throw ArgumentError.value(timezone, 'timezone', 'unknown IANA zone');
    }
    return db
        .into(db.spaces)
        .insertReturning(
          SpacesCompanion.insert(
            id: SyncedRepository.newId(),
            title: title.trim(),
            spaceType: spaceType,
            // No update path exists for budgetMode anywhere, by design
            // (spec 3.1).
            budgetMode: budgetMode,
            ownerId: ownerId,
            storageMode: storageMode,
            timezone: timezone,
            currencyCode: currencyCode,
            countryCode: Value<String?>(countryCode),
            createdAt: clock.nowUtc(),
          ),
        );
  }

  /// Cosmetic, so it is editable forever and needs no confirmation
  /// (spec 3.4).
  Future<int> setTitle(String spaceId, String title) =>
      (db.update(db.spaces)..where(($SpacesTable t) => t.id.equals(spaceId)))
          .write(SpacesCompanion(title: Value<String>(title.trim())));

  /// Changes which "today" every date comparison in this Space resolves
  /// against (spec 9.2). Rejected for an unknown zone rather than silently
  /// storing a name nothing can look up.
  Future<int> setTimezone(String spaceId, String timezone) {
    if (!SpaceClock.isKnownTimezone(timezone)) {
      throw ArgumentError.value(timezone, 'timezone', 'unknown IANA zone');
    }
    return (db.update(db.spaces)
          ..where(($SpacesTable t) => t.id.equals(spaceId)))
        .write(SpacesCompanion(timezone: Value<String>(timezone)));
  }

  /// True until the Space holds its first payment or income. "First record"
  /// means any non-deleted payment or income (plan G9).
  Future<bool> canChangeCurrency(String spaceId) async {
    final Payment? payment =
        await (db.select(db.payments)
              ..where(
                ($PaymentsTable t) =>
                    t.spaceId.equals(spaceId) & t.isDeleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    if (payment != null) return false;

    final Income? income =
        await (db.select(db.incomes)
              ..where(
                ($IncomesTable t) =>
                    t.spaceId.equals(spaceId) & t.isDeleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    return income == null;
  }

  Future<int> setCurrency(String spaceId, String currencyCode) async {
    if (!await canChangeCurrency(spaceId)) throw CurrencyFrozen(spaceId);
    return (db.update(db.spaces)
          ..where(($SpacesTable t) => t.id.equals(spaceId)))
        .write(SpacesCompanion(currencyCode: Value<String>(currencyCode)));
  }

  /// Flow's live snapshot of real money. The timestamp matters as much as the
  /// figure: the walker excludes expenses already paid on or before it
  /// (plan G1).
  Future<int> setManualBalance(String spaceId, Decimal balance) =>
      (db.update(
        db.spaces,
      )..where(($SpacesTable t) => t.id.equals(spaceId))).write(
        SpacesCompanion(
          manualBalance: Value<Decimal?>(balance),
          manualBalanceUpdatedAt: Value<DateTime?>(clock.nowUtc()),
        ),
      );

  Future<int> setArchived(String spaceId, {required bool isArchived}) =>
      (db.update(db.spaces)..where(($SpacesTable t) => t.id.equals(spaceId)))
          .write(SpacesCompanion(isArchived: Value<bool>(isArchived)));

  Future<int> setFeedOrderMode(String spaceId, FeedOrderMode mode) =>
      (db.update(db.spaces)..where(($SpacesTable t) => t.id.equals(spaceId)))
          .write(SpacesCompanion(feedOrderMode: Value<FeedOrderMode>(mode)));

  /// A clock bound to this Space's timezone. Every "today" in the app for this
  /// Space comes from here (plan section 2, invariant 7).
  SpaceClock clockFor(Space space) => SpaceClock(timezone: space.timezone);
}
