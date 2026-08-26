import 'package:budget_app/domain/schedule/income_window.dart';
import 'package:budget_app/domain/schedule/working_days.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

void main() {
  group('WorkingDayCalendar', () {
    test('weekends are not working days', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar.weekendsOnly();
      // 2026-03-14 is a Saturday, 2026-03-15 a Sunday.
      expect(calendar.isWorkingDay(d('2026-03-13')), isTrue);
      expect(calendar.isWorkingDay(d('2026-03-14')), isFalse);
      expect(calendar.isWorkingDay(d('2026-03-15')), isFalse);
      expect(calendar.isWorkingDay(d('2026-03-16')), isTrue);
    });

    test('holidays and custom days both count', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar(
        holidays: <CalendarDate>{d('2026-01-01')},
        customNonWorkingDays: <CalendarDate>{d('2026-01-02')},
      );
      expect(calendar.isWorkingDay(d('2026-01-01')), isFalse);
      expect(calendar.isWorkingDay(d('2026-01-02')), isFalse);
      expect(calendar.isWorkingDay(d('2026-01-05')), isTrue);
    });

    test('with no country only weekends apply', () {
      // A supported state, not a degraded one (spec 5.1.1).
      final WorkingDayCalendar calendar = WorkingDayCalendar.weekendsOnly();
      expect(calendar.isWorkingDay(d('2026-01-01')), isTrue);
    });

    test('search walks past a run of non-working days', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar(
        holidays: <CalendarDate>{d('2026-01-01'), d('2026-01-02')},
      );
      // Thu 1st and Fri 2nd are holidays, then the weekend.
      expect(calendar.workingDayOnOrAfter(d('2026-01-01')), d('2026-01-05'));
      expect(calendar.workingDayOnOrBefore(d('2026-01-01')), d('2025-12-31'));
    });

    test('an absurd holiday set fails loudly rather than hanging', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar(
        weekendDays: <int>{1, 2, 3, 4, 5, 6, 7},
      );
      expect(
        () => calendar.workingDayOnOrAfter(d('2026-01-01')),
        throwsStateError,
      );
    });
  });

  group('resolveIncomeWindow', () {
    final WorkingDayCalendar weekends = WorkingDayCalendar.weekendsOnly();

    test('a working day resolves to itself, with no uncertainty', () {
      final IncomeWindow w = resolveIncomeWindow(
        start: d('2026-03-26'),
        calendar: weekends,
      );
      expect(w.windowStart, d('2026-03-26'));
      expect(w.windowEnd, d('2026-03-26'));
      expect(w.anchorDate, d('2026-03-26'));
      expect(w.isUncertain, isFalse);
    });

    test('a Saturday opens Friday to Monday and anchors on Monday', () {
      // The spec's own example (5.1.1). Monday, not Friday: never plan a
      // payment against money that may not have arrived.
      final IncomeWindow w = resolveIncomeWindow(
        start: d('2026-03-14'),
        calendar: weekends,
      );
      expect(w.windowStart, d('2026-03-13'));
      expect(w.windowEnd, d('2026-03-16'));
      expect(w.anchorDate, d('2026-03-16'));
      expect(w.isUncertain, isTrue);
      expect(w.lengthInDays, 4);
    });

    test('a holiday next to a weekend widens the window', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar(
        holidays: <CalendarDate>{d('2026-04-03'), d('2026-04-06')},
      );
      // Good Friday and Easter Monday around the weekend.
      final IncomeWindow w = resolveIncomeWindow(
        start: d('2026-04-04'),
        calendar: calendar,
      );
      expect(w.windowStart, d('2026-04-02'));
      expect(w.anchorDate, d('2026-04-07'));
    });

    test('a range keeps its own start and only extends right', () {
      // The left edge was the user's choice, not the calendar's (spec 4.7).
      final IncomeWindow w = resolveIncomeWindow(
        start: d('2026-03-11'),
        end: d('2026-03-14'),
        calendar: weekends,
      );
      expect(w.windowStart, d('2026-03-11'));
      expect(w.windowEnd, d('2026-03-16'));
      expect(w.anchorDate, d('2026-03-16'));
    });

    test('a range ending on a working day is left alone', () {
      final IncomeWindow w = resolveIncomeWindow(
        start: d('2026-03-11'),
        end: d('2026-03-13'),
        calendar: weekends,
      );
      expect(w.windowEnd, d('2026-03-13'));
    });

    test('the anchor is always the window end', () {
      for (final String iso in <String>[
        '2026-01-01',
        '2026-02-28',
        '2026-03-14',
        '2026-12-25',
      ]) {
        final IncomeWindow w = resolveIncomeWindow(
          start: d(iso),
          calendar: weekends,
        );
        expect(w.anchorDate, w.windowEnd, reason: iso);
      }
    });

    test('a backwards range is refused', () {
      expect(
        () => resolveIncomeWindow(
          start: d('2026-03-14'),
          end: d('2026-03-11'),
          calendar: weekends,
        ),
        throwsArgumentError,
      );
    });

    test('a window crossing into the next year still resolves', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar(
        holidays: <CalendarDate>{d('2025-12-31'), d('2026-01-01')},
      );
      final IncomeWindow w = resolveIncomeWindow(
        start: d('2025-12-31'),
        calendar: calendar,
      );
      expect(w.windowStart, d('2025-12-30'));
      expect(w.anchorDate, d('2026-01-02'));
    });
  });
}
