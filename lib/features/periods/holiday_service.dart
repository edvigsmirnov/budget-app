import 'package:meta/meta.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/holiday_repository.dart';
import 'package:sielto/core/holidays/holiday_source.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// A calendar and whether it was built from complete data.
@immutable
class ResolvedCalendar {
  const ResolvedCalendar({
    required this.calendar,
    required this.missingYears,
    required this.countryCode,
  });

  final WorkingDayCalendar calendar;

  /// Years the country has no holiday data for. Non-empty means the windows
  /// this calendar produces may still narrow, which is what
  /// `holiday_data_incomplete` records (spec 5.1.1).
  final Set<int> missingYears;

  /// Null when no country applies. Weekends and custom days still do.
  final String? countryCode;

  bool get isComplete => missingYears.isEmpty;
}

/// Builds the working-day calendar from its three sources (spec 5.1.1).
///
/// Weekends always count. Public holidays count when a country is set, and
/// come from the cache first, the bundled data second and the network last —
/// last because it is the only one that can fail, and the only one that needs
/// permission.
///
/// A year that none of the three can supply is reported rather than hidden:
/// the window is computed from what is known and the period carries the flag,
/// so a later run can narrow it (spec 5.1.1).
class HolidayService {
  const HolidayService({
    required this.holidays,
    required this.customDays,
    this.bundle = const HolidayBundle(),
    this.api = const NagerHolidayApi(),
  });

  final HolidayRepository holidays;
  final CustomNonWorkingDayRepository customDays;
  final HolidayBundle bundle;
  final NagerHolidayApi api;

  /// [countryCode] null skips holidays entirely — the third priority level,
  /// where only weekends and the user's own days apply.
  ///
  /// [years] is the span the caller is about to materialise over, not the
  /// calendar year: a monthly cycle materialised in July already reaches into
  /// January, and the data has to be there by then rather than in December.
  ///
  /// [mayFetch] is the caller's decision, already combining the one-time
  /// consent with the global offline switch. This class never re-derives it.
  Future<ResolvedCalendar> resolve({
    required String? countryCode,
    required Set<int> years,
    required bool mayFetch,
  }) async {
    final Set<CalendarDate> custom = <CalendarDate>{
      for (final CustomNonWorkingDay d in await customDays.forCountry(
        countryCode,
      ))
        d.date,
    };

    if (countryCode == null) {
      return ResolvedCalendar(
        calendar: WorkingDayCalendar(customNonWorkingDays: custom),
        // No country means no holidays are expected, so nothing is missing.
        missingYears: const <int>{},
        countryCode: null,
      );
    }

    final Set<int> missing = <int>{};
    for (final int year in years) {
      if (await holidays.has(countryCode, year)) continue;

      final List<CalendarDate>? bundled = await bundle.datesFor(
        countryCode,
        year,
      );
      if (bundled != null) {
        await holidays.store(countryCode, year, bundled);
        continue;
      }

      if (!mayFetch) {
        missing.add(year);
        continue;
      }

      final List<CalendarDate>? fetched = await api.fetch(countryCode, year);
      if (fetched == null) {
        // Offline, or a country the source does not know. Either way the run
        // continues on what it has (spec 5.1.1).
        missing.add(year);
        continue;
      }
      await holidays.store(countryCode, year, fetched);
    }

    return ResolvedCalendar(
      calendar: WorkingDayCalendar(
        holidays: await holidays.allFor(countryCode),
        customNonWorkingDays: custom,
      ),
      missingYears: missing,
      countryCode: countryCode,
    );
  }
}
