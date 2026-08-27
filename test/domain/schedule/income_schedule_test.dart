import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/domain/schedule/income_schedule.dart';
import 'package:sielto/domain/schedule/income_window.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

void main() {
  final WorkingDayCalendar weekends = WorkingDayCalendar.weekendsOnly();

  group('month length', () {
    test('covers every month shape, leap years included', () {
      const List<(int, int, int)> cases = <(int, int, int)>[
        (2026, 1, 31),
        (2026, 2, 28),
        (2028, 2, 29), // leap
        (2100, 2, 28), // not a leap year: divisible by 100, not by 400
        (2000, 2, 29), // leap: divisible by 400
        (2026, 4, 30),
        (2026, 12, 31),
      ];
      for (final (int year, int month, int length) in cases) {
        expect(
          IncomeSchedule.daysInMonth(year, month),
          length,
          reason: '$year-$month',
        );
      }
    });
  });

  group('FixedDateSchedule', () {
    test('lands on the chosen day', () {
      const FixedDateSchedule s = FixedDateSchedule(26);
      expect(s.baseRangeFor(2026, 3).start, d('2026-03-26'));
    });

    test('short months clamp to their last day', () {
      // 31 becomes 28, 29 or 30 rather than spilling into the next month.
      const FixedDateSchedule s = FixedDateSchedule(31);
      expect(s.baseRangeFor(2026, 2).start, d('2026-02-28'));
      expect(s.baseRangeFor(2028, 2).start, d('2028-02-29'));
      expect(s.baseRangeFor(2026, 4).start, d('2026-04-30'));
      expect(s.baseRangeFor(2026, 5).start, d('2026-05-31'));
    });

    test('clamping happens before working days are considered', () {
      // 2026-02-28 is a Saturday: clamp first, then open the window. The
      // window still reaches Monday, but the anchor stays in February.
      const FixedDateSchedule s = FixedDateSchedule(31);
      final IncomeWindow w = s.resolveFor(2026, 2, calendar: weekends);
      expect(w.windowStart, d('2026-02-27'));
      expect(w.windowEnd, d('2026-03-02'));
      expect(w.anchorDate, d('2026-02-27'));
    });

    test('a day outside 1..31 is refused', () {
      expect(
        () => const FixedDateSchedule(0).baseRangeFor(2026, 1),
        throwsArgumentError,
      );
      expect(
        () => const FixedDateSchedule(32).baseRangeFor(2026, 1),
        throwsArgumentError,
      );
    });
  });

  group('WeekdayRuleSchedule', () {
    test('finds the nth weekday', () {
      // March 2026 starts on a Sunday, so Mondays are the 2nd, 9th, 16th, 23rd
      // and 30th.
      const List<(WeekdayOrdinal, String)> cases = <(WeekdayOrdinal, String)>[
        (WeekdayOrdinal.first, '2026-03-02'),
        (WeekdayOrdinal.second, '2026-03-09'),
        (WeekdayOrdinal.third, '2026-03-16'),
        (WeekdayOrdinal.fourth, '2026-03-23'),
        (WeekdayOrdinal.last, '2026-03-30'),
      ];
      for (final (WeekdayOrdinal ordinal, String iso) in cases) {
        expect(
          WeekdayRuleSchedule(
            ordinal,
            Weekday.monday,
          ).baseRangeFor(2026, 3).start,
          d(iso),
          reason: '$ordinal Monday',
        );
      }
    });

    test('last is the fifth when there is one, the fourth otherwise', () {
      // The reason no fifth option exists: it would sometimes be missing.
      expect(
        const WeekdayRuleSchedule(
          WeekdayOrdinal.last,
          Weekday.monday,
        ).baseRangeFor(2026, 3).start,
        d('2026-03-30'),
      );
      expect(
        const WeekdayRuleSchedule(
          WeekdayOrdinal.last,
          Weekday.monday,
        ).baseRangeFor(2026, 2).start,
        d('2026-02-23'),
      );
    });

    test('every ordinal and weekday resolves in every month of a year', () {
      // The invariant the enum protects: a schedule can never be skipped.
      for (int month = 1; month <= 12; month++) {
        for (final WeekdayOrdinal ordinal in WeekdayOrdinal.values) {
          for (final Weekday weekday in Weekday.values) {
            final CalendarDate date = WeekdayRuleSchedule(
              ordinal,
              weekday,
            ).baseRangeFor(2026, month).start;
            expect(date.month, month);
            expect(date.weekday, weekday.index + 1);
          }
        }
      }
    });

    test('a February with exactly four of a weekday still resolves', () {
      // 2026-02 is 28 days starting on a Sunday: exactly four of each.
      expect(
        const WeekdayRuleSchedule(
          WeekdayOrdinal.fourth,
          Weekday.sunday,
        ).baseRangeFor(2026, 2).start,
        d('2026-02-22'),
      );
    });
  });

  group('DateRangeSchedule', () {
    test('expands to the span, anchored at its end', () {
      const DateRangeSchedule s = DateRangeSchedule(23, 25);
      final ({CalendarDate? end, CalendarDate start}) r = s.baseRangeFor(
        2026,
        3,
      );
      expect(r.start, d('2026-03-23'));
      expect(r.end, d('2026-03-25'));
    });

    test('clamps to a short month', () {
      const DateRangeSchedule s = DateRangeSchedule(28, 31);
      final ({CalendarDate? end, CalendarDate start}) r = s.baseRangeFor(
        2026,
        2,
      );
      expect(r.start, d('2026-02-28'));
      expect(r.end, d('2026-02-28'));
    });

    test('the anchor is the latest day of the span within its month', () {
      const DateRangeSchedule s = DateRangeSchedule(28, 31);
      final IncomeWindow w = s.resolveFor(2026, 5, calendar: weekends);
      // 2026-05-31 is a Sunday, so the span extends to Monday 1 June — but
      // May's salary anchors May's cycle, on the Friday before.
      expect(w.windowStart, d('2026-05-28'));
      expect(w.windowEnd, d('2026-06-01'));
      expect(w.anchorDate, d('2026-05-29'));
    });

    test('a backwards range is refused', () {
      expect(
        () => const DateRangeSchedule(25, 23).baseRangeFor(2026, 3),
        throwsArgumentError,
      );
    });
  });

  group('BoundaryDaysSchedule', () {
    test('first N days', () {
      const BoundaryDaysSchedule s = BoundaryDaysSchedule(
        BoundaryAnchor.start,
        3,
      );
      final ({CalendarDate? end, CalendarDate start}) r = s.baseRangeFor(
        2026,
        3,
      );
      expect(r.start, d('2026-03-01'));
      expect(r.end, d('2026-03-03'));
    });

    test('last N days follow the real month length', () {
      const BoundaryDaysSchedule s = BoundaryDaysSchedule(
        BoundaryAnchor.end,
        3,
      );
      expect(s.baseRangeFor(2026, 2).start, d('2026-02-26'));
      expect(s.baseRangeFor(2026, 2).end, d('2026-02-28'));
      expect(s.baseRangeFor(2028, 2).start, d('2028-02-27'));
      expect(s.baseRangeFor(2028, 2).end, d('2028-02-29'));
      expect(s.baseRangeFor(2026, 3).start, d('2026-03-29'));
      expect(s.baseRangeFor(2026, 3).end, d('2026-03-31'));
    });

    test('the count is capped at 15', () {
      // Past that, "the first N days" stops describing anything (spec 5.1).
      expect(
        () => const BoundaryDaysSchedule(
          BoundaryAnchor.start,
          16,
        ).baseRangeFor(2026, 1),
        throwsArgumentError,
      );
      expect(
        () => const BoundaryDaysSchedule(
          BoundaryAnchor.start,
          0,
        ).baseRangeFor(2026, 1),
        throwsArgumentError,
      );
    });

    test('a single day is a valid boundary range', () {
      const BoundaryDaysSchedule s = BoundaryDaysSchedule(
        BoundaryAnchor.end,
        1,
      );
      final ({CalendarDate? end, CalendarDate start}) r = s.baseRangeFor(
        2026,
        4,
      );
      expect(r.start, d('2026-04-30'));
      expect(r.end, d('2026-04-30'));
    });
  });
}
