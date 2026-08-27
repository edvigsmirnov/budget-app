import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/holiday_repository.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

/// The two device-local tables behind the working-day calendar (spec 5.1.1,
/// 5.1.2). Neither carries sync columns, so neither ever leaves the device.
void main() {
  late AppDatabase db;
  late HolidayRepository holidays;
  late CustomNonWorkingDayRepository customDays;

  SpaceClock.initialize();
  final SpaceClock clock = SpaceClock(
    timezone: 'UTC',
    now: () => DateTime.utc(2026, 3, 10, 12),
  );

  setUp(() {
    db = inMemoryDatabase();
    holidays = HolidayRepository(db: db, clock: clock);
    customDays = CustomNonWorkingDayRepository(db: db, clock: clock);
  });

  tearDown(() => db.close());

  group('holiday cache', () {
    test('stores and reads a year back', () async {
      await holidays.store('de', 2026, <CalendarDate>[
        d('2026-01-01'),
        d('2026-05-01'),
      ]);
      // Written lower case, read upper: the code is normalised on both sides.
      expect(await holidays.cached('DE', 2026), <CalendarDate>[
        d('2026-01-01'),
        d('2026-05-01'),
      ]);
    });

    test('nothing cached and nothing to cache are different answers', () async {
      await holidays.store('DE', 2026, const <CalendarDate>[]);
      expect(await holidays.cached('DE', 2026), isEmpty);
      expect(await holidays.cached('DE', 2027), isNull);
    });

    test('a refetch replaces the year in place', () async {
      await holidays.store('DE', 2026, <CalendarDate>[d('2026-01-01')]);
      await holidays.store('DE', 2026, <CalendarDate>[
        d('2026-01-01'),
        d('2026-12-25'),
      ]);
      expect((await holidays.cached('DE', 2026))!.length, 2);
      expect(await holidays.allFor('DE'), hasLength(2));
    });

    test('allFor merges every cached year', () async {
      await holidays.store('DE', 2026, <CalendarDate>[d('2026-01-01')]);
      await holidays.store('DE', 2027, <CalendarDate>[d('2027-01-01')]);
      await holidays.store('FR', 2026, <CalendarDate>[d('2026-07-14')]);
      expect(await holidays.allFor('DE'), <CalendarDate>{
        d('2026-01-01'),
        d('2027-01-01'),
      });
    });
  });

  group('custom non-working days', () {
    test('marking the same day twice is not an error', () async {
      final CustomNonWorkingDay first = await customDays.add(
        date: d('2026-03-12'),
        title: 'Company day',
        countryCode: 'DE',
      );
      final CustomNonWorkingDay again = await customDays.add(
        date: d('2026-03-12'),
        countryCode: 'DE',
      );
      expect(again.id, first.id);
      expect(await customDays.all(), hasLength(1));
    });

    test('the same date for two countries is two rows', () async {
      await customDays.add(date: d('2026-03-12'), countryCode: 'DE');
      await customDays.add(date: d('2026-03-12'), countryCode: 'FR');
      expect(await customDays.all(), hasLength(2));
    });

    test('a day with no country applies to every country', () async {
      await customDays.add(date: d('2026-03-12'));
      expect(await customDays.forCountry('DE'), hasLength(1));
      expect(await customDays.forCountry(null), hasLength(1));
    });

    test("a country's day is invisible to another", () async {
      await customDays.add(date: d('2026-03-12'), countryCode: 'FR');
      expect(await customDays.forCountry('DE'), isEmpty);
      // With no country set, only the everywhere-days apply.
      expect(await customDays.forCountry(null), isEmpty);
    });

    test('an empty title is stored as none', () async {
      final CustomNonWorkingDay day = await customDays.add(
        date: d('2026-03-12'),
        title: '   ',
      );
      expect(day.title, isNull);
    });

    test('removing is a hard delete', () async {
      final CustomNonWorkingDay day = await customDays.add(
        date: d('2026-03-12'),
      );
      await customDays.remove(day.id);
      expect(await customDays.all(), isEmpty);
    });
  });
}
