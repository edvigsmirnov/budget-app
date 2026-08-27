import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/holiday_repository.dart';
import 'package:sielto/core/holidays/holiday_source.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/periods/holiday_service.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

/// A bundle that answers from a map instead of the asset directory, so the
/// tests pin the resolution order rather than the shipped data.
class _FakeBundle extends HolidayBundle {
  const _FakeBundle(this.data);

  final Map<String, Map<int, List<CalendarDate>>> data;

  @override
  Future<List<CalendarDate>?> datesFor(String countryCode, int year) async =>
      data[countryCode.toUpperCase()]?[year];
}

class _FakeApi extends NagerHolidayApi {
  _FakeApi(this.data);

  final Map<String, Map<int, List<CalendarDate>>> data;
  int calls = 0;

  @override
  Future<List<CalendarDate>?> fetch(String countryCode, int year) async {
    calls++;
    return data[countryCode.toUpperCase()]?[year];
  }
}

/// Where the working-day calendar comes from (spec 5.1.1).
///
/// The order is the whole point: cache, then the shipped data, then the
/// network — last because it is the only source that can fail and the only one
/// that needs permission.
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

  HolidayService serviceWith({
    Map<String, Map<int, List<CalendarDate>>> bundle =
        const <String, Map<int, List<CalendarDate>>>{},
    NagerHolidayApi? api,
  }) => HolidayService(
    holidays: holidays,
    customDays: customDays,
    bundle: _FakeBundle(bundle),
    api: api ?? _FakeApi(const <String, Map<int, List<CalendarDate>>>{}),
  );

  group('sources', () {
    test('the cache is used and nothing else is consulted', () async {
      await holidays.store('DE', 2026, <CalendarDate>[d('2026-01-01')]);
      final _FakeApi api = _FakeApi(<String, Map<int, List<CalendarDate>>>{
        'DE': <int, List<CalendarDate>>{
          2026: <CalendarDate>[d('2026-12-25')],
        },
      });

      final ResolvedCalendar resolved = await serviceWith(api: api)
          .resolve(countryCode: 'DE', years: <int>{2026}, mayFetch: true);

      expect(api.calls, 0);
      expect(resolved.isComplete, isTrue);
      expect(resolved.calendar.isNonWorkingDay(d('2026-01-01')), isTrue);
    });

    test('the shipped data fills a year and is cached', () async {
      final _FakeApi api = _FakeApi(
        const <String, Map<int, List<CalendarDate>>>{},
      );
      final ResolvedCalendar resolved = await serviceWith(
        bundle: <String, Map<int, List<CalendarDate>>>{
          'DE': <int, List<CalendarDate>>{
            2026: <CalendarDate>[d('2026-05-01')],
          },
        },
        api: api,
      ).resolve(countryCode: 'DE', years: <int>{2026}, mayFetch: true);

      // Shipped data comes before the network, so nothing was requested.
      expect(api.calls, 0);
      expect(resolved.isComplete, isTrue);
      expect(await holidays.has('DE', 2026), isTrue);
    });

    test('the network fills a year the bundle does not cover', () async {
      final _FakeApi api = _FakeApi(<String, Map<int, List<CalendarDate>>>{
        'DE': <int, List<CalendarDate>>{
          2029: <CalendarDate>[d('2029-05-01')],
        },
      });

      final ResolvedCalendar resolved = await serviceWith(api: api)
          .resolve(countryCode: 'DE', years: <int>{2029}, mayFetch: true);

      expect(api.calls, 1);
      expect(resolved.isComplete, isTrue);
      expect(resolved.calendar.isNonWorkingDay(d('2029-05-01')), isTrue);
    });
  });

  group('when the data cannot be had', () {
    test('without consent the year is reported missing', () async {
      final _FakeApi api = _FakeApi(<String, Map<int, List<CalendarDate>>>{
        'DE': <int, List<CalendarDate>>{
          2029: <CalendarDate>[d('2029-05-01')],
        },
      });

      final ResolvedCalendar resolved = await serviceWith(api: api)
          .resolve(countryCode: 'DE', years: <int>{2029}, mayFetch: false);

      // Nothing was requested, and the caller is told the window is wide.
      expect(api.calls, 0);
      expect(resolved.missingYears, <int>{2029});
    });

    test('a failed request is reported, not thrown', () async {
      final ResolvedCalendar resolved = await serviceWith().resolve(
        countryCode: 'DE',
        years: <int>{2029},
        mayFetch: true,
      );
      expect(resolved.missingYears, <int>{2029});
      // The run continues on weekends alone: May Day, a Tuesday that year,
      // reads as an ordinary working day rather than stopping the walk.
      expect(resolved.calendar.isNonWorkingDay(d('2029-05-01')), isFalse);
    });
  });

  group('country priority', () {
    test('no country means no holidays and nothing missing', () async {
      await holidays.store('DE', 2026, <CalendarDate>[d('2026-01-01')]);

      final ResolvedCalendar resolved = await serviceWith().resolve(
        countryCode: null,
        years: <int>{2026},
        mayFetch: true,
      );

      // A New Year's Day that belongs to a country nobody selected.
      expect(resolved.calendar.isNonWorkingDay(d('2026-01-01')), isFalse);
      expect(resolved.missingYears, isEmpty);
    });

    test('weekends always count, country or not', () async {
      final ResolvedCalendar resolved = await serviceWith().resolve(
        countryCode: null,
        years: <int>{2026},
        mayFetch: false,
      );
      expect(resolved.calendar.isNonWorkingDay(d('2026-03-07')), isTrue);
    });
  });

  group('custom days', () {
    test('a day marked for the country joins the calendar', () async {
      await customDays.add(date: d('2026-03-12'), countryCode: 'DE');
      final ResolvedCalendar resolved = await serviceWith().resolve(
        countryCode: 'DE',
        years: <int>{},
        mayFetch: false,
      );
      expect(resolved.calendar.isNonWorkingDay(d('2026-03-12')), isTrue);
    });

    test('a day marked for no country applies everywhere', () async {
      await customDays.add(date: d('2026-03-12'));
      for (final String? country in <String?>['DE', 'FR', null]) {
        final ResolvedCalendar resolved = await serviceWith().resolve(
          countryCode: country,
          years: <int>{},
          mayFetch: false,
        );
        expect(resolved.calendar.isNonWorkingDay(d('2026-03-12')), isTrue);
      }
    });

    test("another country's day does not apply", () async {
      await customDays.add(date: d('2026-03-12'), countryCode: 'FR');
      final ResolvedCalendar resolved = await serviceWith().resolve(
        countryCode: 'DE',
        years: <int>{},
        mayFetch: false,
      );
      expect(resolved.calendar.isNonWorkingDay(d('2026-03-12')), isFalse);
    });
  });
}
