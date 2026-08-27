import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/crypto/database_key.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/synced_repository.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sqlite3/sqlite3.dart';

/// A concrete repository, only so the base class rules can be exercised.
class _PaymentRepository extends SyncedRepository<$PaymentsTable, Payment> {
  _PaymentRepository({
    required super.db,
    required super.clock,
    required super.userId,
  });

  @override
  TableInfo<$PaymentsTable, Payment> get table => db.payments;
}

void main() {
  late Directory dir;

  setUpAll(SpaceClock.initialize);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('budget_db_');
  });

  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows holds the file until every handle closes.
    }
  });

  Future<AppDatabase> open(DatabaseKey key) async {
    final AppDatabase db = AppDatabase(
      openEncryptedDatabase(directory: dir, key: key),
    );
    await db.customSelect('SELECT 1').get();
    return db;
  }

  test('the database file is encrypted on disk', () async {
    final DatabaseKey key = DatabaseKey.generate();
    final AppDatabase db = await open(key);
    await _seed(db, title: 'Rent for the flat');
    await db.close();

    final File file = File('${dir.path}/sielto.sqlite');
    final List<int> bytes = file.readAsBytesSync();
    expect(
      String.fromCharCodes(bytes.take(16)),
      isNot(startsWith('SQLite format 3')),
    );
    expect(String.fromCharCodes(bytes), isNot(contains('Rent for the flat')));
  });

  test('a third-party client cannot read it', () async {
    final AppDatabase db = await open(DatabaseKey.generate());
    await _seed(db);
    await db.close();

    final Database raw = sqlite3.open('${dir.path}/sielto.sqlite');
    addTearDown(raw.close);
    expect(
      () => raw.select('SELECT * FROM payments'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('the same key reopens the data', () async {
    final DatabaseKey key = DatabaseKey.generate();
    final AppDatabase first = await open(key);
    await _seed(first, title: 'Internet');
    await first.close();

    final AppDatabase second = await open(key);
    addTearDown(second.close);
    final List<Payment> rows = await second.select(second.payments).get();
    expect(rows.single.title, 'Internet');
  });

  group('repository rules', () {
    late AppDatabase db;
    late _PaymentRepository repo;

    setUp(() async {
      db = inMemoryDatabase();
      await _seedSpace(db);
      repo = _PaymentRepository(
        db: db,
        clock: SpaceClock(
          timezone: 'Europe/Berlin',
          now: () => DateTime.utc(2026, 3, 10, 12),
        ),
        userId: 'user-1',
      );
    });

    tearDown(() => db.close());

    test('reads exclude soft-deleted rows', () async {
      await _seed(db, id: 'p1');
      await _seed(db, id: 'p2');
      await repo.softDelete('p2');

      final List<Payment> alive = await repo.selectAlive().get();
      expect(alive.map((Payment p) => p.id), <String>['p1']);

      // The row is still there, so the delete can propagate.
      final List<Payment> all = await db.select(db.payments).get();
      expect(all, hasLength(2));
    });

    test('a soft delete stamps the edit and marks it pending', () async {
      await _seed(db, id: 'p1');
      await repo.softDelete('p1');

      final Payment row = await (db.select(
        db.payments,
      )..where(($PaymentsTable t) => t.id.equals('p1'))).getSingle();
      expect(row.isDeleted, isTrue);
      expect(row.syncStatus, SyncStatus.pending);
      expect(row.lastModifiedBy, 'user-1');
      expect(row.clientEditedAt, DateTime.utc(2026, 3, 10, 12));
    });

    test('restore is the exact undo', () async {
      await _seed(db, id: 'p1');
      await repo.softDelete('p1');
      await repo.restore('p1');

      expect(await repo.selectAlive().get(), hasLength(1));
    });

    test('space scoping and the delete filter compose', () async {
      await _seedSpace(db, id: 's2');
      await _seed(db, id: 'p1');
      await _seed(db, id: 'p2', spaceId: 's2');
      await repo.softDelete('p1');

      expect(await repo.selectAliveInSpace('s1').get(), isEmpty);
      expect(await repo.selectAliveInSpace('s2').get(), hasLength(1));
    });

    test('ids are unique across repeated generation', () {
      final Set<String> ids = <String>{
        for (int i = 0; i < 1000; i++) SyncedRepository.newId(),
      };
      expect(ids, hasLength(1000));
    });
  });

  test('a 10k-row Space opens in under 200 ms', () async {
    // The M1 exit criterion. Bulk insert first, then measure.
    final DatabaseKey key = DatabaseKey.generate();
    final AppDatabase db = await open(key);
    await _seedSpace(db);

    await db.batch((Batch b) {
      b.insertAll(db.payments, <PaymentsCompanion>[
        for (int i = 0; i < 10000; i++)
          PaymentsCompanion.insert(
            id: 'p$i',
            spaceId: 's1',
            title: 'Payment $i',
            amount: Decimal.fromInt(i % 500 + 1),
            dueDate: const CalendarDate(2026, 1, 1).addDays(i % 400),
            expenseType: i.isEven
                ? ExpenseType.mandatory
                : ExpenseType.variable,
            createdAt: DateTime.utc(2026, 1, 1),
            clientEditedAt: DateTime.utc(2026, 1, 1),
          ),
      ]);
    });
    await db.close();

    // The exit criterion is that the Space opens: decrypt the header, run the
    // migration check, be ready to query.
    final Stopwatch openWatch = Stopwatch()..start();
    final AppDatabase reopened = await open(key);
    openWatch.stop();
    addTearDown(reopened.close);

    // Not the criterion, and not what any screen does — the Feed pages by day.
    // Measured as an upper bound: if reading every row stays this cheap, no
    // realistic query is a problem.
    final Stopwatch readWatch = Stopwatch()..start();
    final List<Payment> rows =
        await (reopened.select(reopened.payments)
              ..where(($PaymentsTable t) => t.isDeleted.equals(false))
              ..orderBy(<OrderClauseGenerator<$PaymentsTable>>[
                ($PaymentsTable t) => OrderingTerm(expression: t.dueDate),
                ($PaymentsTable t) => OrderingTerm(expression: t.sortOrder),
                ($PaymentsTable t) => OrderingTerm(expression: t.id),
              ]))
            .get();
    readWatch.stop();

    expect(rows, hasLength(10000));
    expect(
      openWatch.elapsedMilliseconds,
      lessThan(200),
      reason:
          'opening a 10k-row Space took ${openWatch.elapsedMilliseconds} ms',
    );
    // Deliberately loose. This is a smoke bound against an order-of-magnitude
    // regression — a dropped index, per-row decryption — not a budget: the
    // work is ~140 ms on a dev machine and around 4x that on a shared CI
    // runner, so a tight bound measures the runner rather than the code. The
    // open time above is the number that matters, and it has room to spare.
    expect(
      readWatch.elapsedMilliseconds,
      lessThan(2000),
      reason:
          'reading all 10k rows took ${readWatch.elapsedMilliseconds} ms; '
          'well above what any screen asks for',
    );
  });
}

Future<void> _seedSpace(AppDatabase db, {String id = 's1'}) => db
    .into(db.spaces)
    .insert(
      SpacesCompanion.insert(
        id: id,
        title: 'Household',
        spaceType: SpaceType.family,
        budgetMode: BudgetMode.flow,
        ownerId: 'user-1',
        storageMode: StorageMode.local,
        timezone: 'Europe/Berlin',
        currencyCode: 'EUR',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );

Future<void> _seed(
  AppDatabase db, {
  String id = 'p1',
  String spaceId = 's1',
  String title = 'Rent',
}) async {
  final List<Space> spaces = await db.select(db.spaces).get();
  if (spaces.isEmpty) await _seedSpace(db);
  await db
      .into(db.payments)
      .insert(
        PaymentsCompanion.insert(
          id: id,
          spaceId: spaceId,
          title: title,
          amount: Decimal.fromInt(1200),
          dueDate: const CalendarDate(2026, 3, 1),
          expenseType: ExpenseType.mandatory,
          createdAt: DateTime.utc(2026, 1, 1),
          clientEditedAt: DateTime.utc(2026, 1, 1),
        ),
      );
}
