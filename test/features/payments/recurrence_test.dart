import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/features/payments/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

List<String> isoOf(List<CalendarDate> dates) =>
    dates.map((CalendarDate d) => d.toIso()).toList();

void main() {
  group('monthly', () {
    test('a fixed count produces exactly that many rows', () {
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2026-03-10'),
        interval: RecurrenceInterval.monthly,
        count: 12,
      );
      expect(dates, hasLength(12));
      expect(dates.first, d('2026-03-10'));
      expect(dates.last, d('2027-02-10'));
    });

    test('the 31st clamps into short months without drifting', () {
      // The bug this guards: stepping from the clamped date instead of the
      // original walks the series backwards a day at a time.
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2026-01-31'),
        interval: RecurrenceInterval.monthly,
        count: 4,
      );
      expect(isoOf(dates), <String>[
        '2026-01-31',
        '2026-02-28',
        '2026-03-31',
        '2026-04-30',
      ]);
    });

    test('a leap February takes the 29th', () {
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2028-01-31'),
        interval: RecurrenceInterval.monthly,
        count: 2,
      );
      expect(dates.last, d('2028-02-29'));
    });

    test('a year boundary is crossed cleanly', () {
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2026-11-15'),
        interval: RecurrenceInterval.monthly,
        count: 3,
      );
      expect(isoOf(dates), <String>['2026-11-15', '2026-12-15', '2027-01-15']);
    });
  });

  group('weekly', () {
    test('steps seven days at a time', () {
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2026-03-05'),
        interval: RecurrenceInterval.weekly,
        count: 3,
      );
      expect(isoOf(dates), <String>['2026-03-05', '2026-03-12', '2026-03-19']);
    });
  });

  group('open-ended', () {
    test('fills the horizon rather than running forever', () {
      // "Indefinitely" is the one case where no explicit limit would grow the
      // database without bound (spec 6.3).
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2026-03-10'),
        interval: RecurrenceInterval.monthly,
      );
      expect(dates, hasLength(recurrenceHorizonMonths + 1));
      expect(dates.last, d('2028-03-10'));
    });

    test('a weekly open-ended series stops at the same horizon', () {
      final List<CalendarDate> dates = recurrenceDates(
        start: d('2026-03-10'),
        interval: RecurrenceInterval.weekly,
      );
      expect(dates.last.isAfter(d('2028-03-10')), isFalse);
      expect(dates.last.isAfter(d('2028-03-03')), isTrue);
    });
  });

  test('a single occurrence is the start date alone', () {
    expect(
      recurrenceDates(
        start: d('2026-03-10'),
        interval: RecurrenceInterval.monthly,
        count: 1,
      ),
      <CalendarDate>[d('2026-03-10')],
    );
  });
}
