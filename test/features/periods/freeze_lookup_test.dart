import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/period/freeze.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/periods/freeze_providers.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

/// What the screens read to decide what to disable (spec 5.5).
///
/// The repositories refuse a frozen write on their own; these pin that the
/// display answer agrees with the enforcement one, and that the two states
/// which are not "frozen" are distinguished.
void main() {
  late AppDatabase db;
  late Repositories repos;
  late Space space;

  SpaceClock.initialize();
  final DateTime now = DateTime.utc(2026, 3, 10, 12);
  final SpaceClock clock = SpaceClock(timezone: 'UTC', now: () => now);
  final CalendarDate today = d('2026-03-10');

  setUp(() async {
    db = inMemoryDatabase();
    repos = Repositories(db: db, clock: clock, userId: 'tester');
    space = await repos.spaces.create(
      title: 'Family',
      spaceType: SpaceType.family,
      budgetMode: BudgetMode.incomeDriven,
      ownerId: 'tester',
      timezone: 'UTC',
      currencyCode: 'EUR',
    );
  });

  tearDown(() => db.close());

  Future<FreezeLookup> lookup() async => FreezeLookup(
    periods: <String, BudgetPeriod>{
      for (final BudgetPeriod p in await repos.periods.inSpace(space.id))
        p.id: p,
    },
    today: today,
    nowUtc: now,
  );

  Future<BudgetPeriod> endingOn(String iso) => repos.periods.createIncomeDriven(
    spaceId: space.id,
    startDate: d(iso).addMonths(-1),
    endDate: d(iso),
    anchorDate: d(iso).addMonths(-1),
  );

  test('an open period is open', () async {
    final BudgetPeriod period = await endingOn('2026-03-31');
    expect((await lookup()).of(period.id), FreezeState.open);
  });

  test('a period past its deadline is frozen', () async {
    // Ended 2026-02-20, so it froze on 2026-03-06 — four days ago.
    final BudgetPeriod period = await endingOn('2026-02-20');
    expect((await lookup()).isFrozen(period.id), isTrue);
  });

  test('the two days before the deadline warn', () async {
    // Ends 2026-02-25, so it freezes on 2026-03-11 — tomorrow.
    final BudgetPeriod period = await endingOn('2026-02-25');
    final FreezeLookup state = await lookup();
    expect(state.of(period.id), FreezeState.closingSoon);
    expect(state.daysUntilFreeze(period), 1);
  });

  test('an unfreeze reopens the period until it lapses', () async {
    final BudgetPeriod period = await endingOn('2026-02-20');
    await repos.periods.unfreeze(
      period.id,
      now.add(const Duration(hours: 48)),
      'corrected the rent',
    );
    expect((await lookup()).of(period.id), FreezeState.open);
  });

  test('a lapsed unfreeze freezes again', () async {
    final BudgetPeriod period = await endingOn('2026-02-20');
    await repos.periods.unfreeze(
      period.id,
      now.subtract(const Duration(minutes: 1)),
      'corrected the rent',
    );
    expect((await lookup()).isFrozen(period.id), isTrue);
  });

  test('the continuous period never freezes', () async {
    // No end date, so there is nothing for the deadline to count from. Flow
    // and Budget live here (spec 4.7).
    final BudgetPeriod period = await repos.periods.ensureContinuous(
      spaceId: space.id,
      startDate: d('2020-01-01'),
    );
    expect((await lookup()).of(period.id), FreezeState.open);
  });

  test('a record bound to no period is open', () async {
    expect((await lookup()).of(null), FreezeState.open);
  });

  test('a record bound to a period that no longer exists is open', () async {
    // A dangling id is not a reason to lock a row out of editing.
    expect((await lookup()).of('gone'), FreezeState.open);
  });
}
