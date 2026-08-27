import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/synced_repository.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// The device-local holiday cache (spec 5.1.1).
///
/// No sync columns and no Space id: this is reference data about a country,
/// not a user's records, so it never leaves the device and never uploads.
/// Rows are kept indefinitely — a few kilobytes a year, and the last known
/// list is what keeps the app working offline when the year turns.
class HolidayRepository {
  HolidayRepository({required this.db, required this.clock});

  final AppDatabase db;
  final SpaceClock clock;

  /// The cached dates for one country and year, or null when nothing is
  /// cached. Null and empty are different answers: a country with no public
  /// holidays at all is a valid cached result.
  Future<List<CalendarDate>?> cached(String countryCode, int year) async {
    final HolidayCacheData? row = await _row(countryCode, year);
    if (row == null) return null;
    return _decode(row.holidayDates);
  }

  Future<bool> has(String countryCode, int year) async =>
      await _row(countryCode, year) != null;

  /// Writes or replaces one country-year. The unique key is `(country, year)`,
  /// so a refetch updates in place rather than accumulating rows.
  Future<void> store(
    String countryCode,
    int year,
    List<CalendarDate> dates,
  ) async {
    final String code = countryCode.toUpperCase();
    final String encoded = jsonEncode(<String>[
      for (final CalendarDate d in dates) d.toIso(),
    ]);
    final HolidayCacheData? existing = await _row(code, year);

    if (existing == null) {
      await db
          .into(db.holidayCache)
          .insert(
            HolidayCacheCompanion.insert(
              id: SyncedRepository.newId(),
              countryCode: code,
              year: year,
              holidayDates: encoded,
              fetchedAt: clock.nowUtc(),
            ),
          );
      return;
    }

    await (db.update(
      db.holidayCache,
    )..where(($HolidayCacheTable t) => t.id.equals(existing.id))).write(
      HolidayCacheCompanion(
        holidayDates: Value<String>(encoded),
        fetchedAt: Value<DateTime>(clock.nowUtc()),
      ),
    );
  }

  /// Every cached year for one country, merged. Used to build the calendar a
  /// materialisation run walks against.
  Future<Set<CalendarDate>> allFor(String countryCode) async {
    final List<HolidayCacheData> rows =
        await (db.select(db.holidayCache)..where(
              ($HolidayCacheTable t) =>
                  t.countryCode.equals(countryCode.toUpperCase()),
            ))
            .get();
    return <CalendarDate>{
      for (final HolidayCacheData row in rows) ..._decode(row.holidayDates),
    };
  }

  Future<HolidayCacheData?> _row(String countryCode, int year) =>
      (db.select(db.holidayCache)..where(
            ($HolidayCacheTable t) =>
                t.countryCode.equals(countryCode.toUpperCase()) &
                t.year.equals(year),
          ))
          .getSingleOrNull();

  /// A malformed row reads as empty rather than throwing. The cache is a
  /// convenience, and a corrupt entry must not take the app down with it.
  List<CalendarDate> _decode(String raw) {
    final Object? parsed = jsonDecode(raw);
    if (parsed is! List<dynamic>) return const <CalendarDate>[];
    return <CalendarDate>[
      for (final Object? d in parsed)
        if (d is String) CalendarDate.parse(d),
    ];
  }
}

/// The non-working days the user added by hand (spec 5.1.2).
///
/// Stored per app rather than per Space, and applied to every Space using the
/// same country — a company holiday is a fact about the person, not about one
/// of their ledgers.
class CustomNonWorkingDayRepository {
  CustomNonWorkingDayRepository({required this.db, required this.clock});

  final AppDatabase db;
  final SpaceClock clock;

  /// The days that apply to [countryCode], newest date first.
  ///
  /// A row with no country applies everywhere, which is why it is included
  /// whatever [countryCode] is — including when the user has set none.
  Future<List<CustomNonWorkingDay>> forCountry(String? countryCode) async {
    final List<CustomNonWorkingDay> rows = await all();
    return rows
        .where(
          (CustomNonWorkingDay d) =>
              d.countryCode == null ||
              (countryCode != null &&
                  d.countryCode!.toUpperCase() == countryCode.toUpperCase()),
        )
        .toList();
  }

  Future<List<CustomNonWorkingDay>> all() =>
      (db.select(db.customNonWorkingDays)
            ..orderBy(<OrderClauseGenerator<$CustomNonWorkingDaysTable>>[
              ($CustomNonWorkingDaysTable t) =>
                  OrderingTerm(expression: t.date),
            ]))
          .get();

  Stream<List<CustomNonWorkingDay>> watchAll() =>
      (db.select(db.customNonWorkingDays)
            ..orderBy(<OrderClauseGenerator<$CustomNonWorkingDaysTable>>[
              ($CustomNonWorkingDaysTable t) =>
                  OrderingTerm(expression: t.date),
            ]))
          .watch();

  /// Adds a day, or returns the existing one for that date and country. The
  /// table's unique key is `(date, country)`, so marking the same day twice is
  /// not an error.
  Future<CustomNonWorkingDay> add({
    required CalendarDate date,
    String? title,
    String? countryCode,
  }) async {
    final String? code = countryCode?.toUpperCase();
    final CustomNonWorkingDay? existing = await _on(date, code);
    if (existing != null) return existing;

    return db
        .into(db.customNonWorkingDays)
        .insertReturning(
          CustomNonWorkingDaysCompanion.insert(
            id: SyncedRepository.newId(),
            date: date,
            title: Value<String?>(title?.trim().isEmpty ?? true ? null : title),
            countryCode: Value<String?>(code),
            createdAt: clock.nowUtc(),
          ),
        );
  }

  /// A hard delete, not a soft one: the table carries no sync columns and
  /// nothing references a marked day.
  Future<int> remove(String id) => (db.delete(
    db.customNonWorkingDays,
  )..where(($CustomNonWorkingDaysTable t) => t.id.equals(id))).go();

  Future<CustomNonWorkingDay?> _on(CalendarDate date, String? countryCode) =>
      (db.select(db.customNonWorkingDays)..where(
            ($CustomNonWorkingDaysTable t) => countryCode == null
                ? t.date.equals(date.toIso()) & t.countryCode.isNull()
                : t.date.equals(date.toIso()) &
                      t.countryCode.equals(countryCode),
          ))
          .getSingleOrNull();
}
