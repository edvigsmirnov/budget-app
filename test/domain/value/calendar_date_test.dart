import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and renders ISO days', () {
    expect(CalendarDate.parse('2026-03-09').toIso(), '2026-03-09');
    expect(const CalendarDate(2026, 3, 9).toIso(), '2026-03-09');
  });

  test('rejects anything carrying a time', () {
    // A value with a time has already lost the distinction this type keeps.
    expect(
      () => CalendarDate.parse('2026-03-09T00:00:00Z'),
      throwsFormatException,
    );
    expect(() => CalendarDate.parse('2026-3-9'), throwsFormatException);
    expect(() => CalendarDate.parse(''), throwsFormatException);
  });

  test('ISO text sorts the same way the dates do', () {
    final List<CalendarDate> dates = <CalendarDate>[
      const CalendarDate(2026, 10, 2),
      const CalendarDate(2026, 2, 10),
      const CalendarDate(2025, 12, 31),
    ]..sort();
    expect(dates.map((CalendarDate d) => d.toIso()).toList(), <String>[
      '2025-12-31',
      '2026-02-10',
      '2026-10-02',
    ]);
  });

  test('from normalises overflow the way DateTime does', () {
    expect(CalendarDate.from(2026, 2, 30), const CalendarDate(2026, 3, 2));
    expect(CalendarDate.from(2026, 13, 1), const CalendarDate(2027, 1, 1));
  });

  test('day arithmetic crosses months and years', () {
    expect(
      const CalendarDate(2026, 1, 31).addDays(1),
      const CalendarDate(2026, 2, 1),
    );
    expect(
      const CalendarDate(2026, 12, 31).addDays(1),
      const CalendarDate(2027, 1, 1),
    );
    expect(
      const CalendarDate(2026, 3, 1).addDays(-1),
      const CalendarDate(2026, 2, 28),
    );
  });

  test('day arithmetic ignores DST', () {
    // Berlin's clocks move on 2026-03-29, but a calendar day is a calendar
    // day; UTC midnight anchors the arithmetic.
    expect(
      const CalendarDate(2026, 3, 28).addDays(1),
      const CalendarDate(2026, 3, 29),
    );
    expect(
      const CalendarDate(
        2026,
        3,
        28,
      ).daysUntil(const CalendarDate(2026, 3, 30)),
      2,
    );
  });

  test('leap days exist and are counted', () {
    expect(CalendarDate.from(2028, 2, 29).toIso(), '2028-02-29');
    expect(
      const CalendarDate(2028, 2, 28).addDays(1),
      const CalendarDate(2028, 2, 29),
    );
    expect(
      const CalendarDate(2026, 2, 28).addDays(1),
      const CalendarDate(2026, 3, 1),
    );
  });

  test('daysUntil is signed', () {
    const CalendarDate a = CalendarDate(2026, 3, 1);
    const CalendarDate b = CalendarDate(2026, 3, 15);
    expect(a.daysUntil(b), 14);
    expect(b.daysUntil(a), -14);
    expect(a.daysUntil(a), 0);
  });

  test('weekday matches DateTime', () {
    // 2026-03-09 is a Monday.
    expect(const CalendarDate(2026, 3, 9).weekday, DateTime.monday);
    expect(const CalendarDate(2026, 3, 15).weekday, DateTime.sunday);
  });

  test('equality is by value', () {
    expect(const CalendarDate(2026, 3, 9), const CalendarDate(2026, 3, 9));
    expect(
      const CalendarDate(2026, 3, 9).hashCode,
      const CalendarDate(2026, 3, 9).hashCode,
    );
    expect(<CalendarDate>{
      const CalendarDate(2026, 3, 9),
      CalendarDate.parse('2026-03-09'),
    }, hasLength(1));
  });

  test('comparisons read in the obvious direction', () {
    const CalendarDate early = CalendarDate(2026, 3, 1);
    const CalendarDate late = CalendarDate(2026, 3, 2);
    expect(early.isBefore(late), isTrue);
    expect(late.isAfter(early), isTrue);
    expect(early.isBefore(early), isFalse);
  });
}
