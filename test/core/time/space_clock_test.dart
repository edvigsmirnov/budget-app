import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';

void main() {
  setUpAll(SpaceClock.initialize);

  SpaceClock at(String timezone, DateTime instant) =>
      SpaceClock(timezone: timezone, now: () => instant);

  test('today follows the Space timezone, not the device', () {
    // 23:30 UTC is already tomorrow in Berlin (UTC+1 in March) and still
    // early evening in New York.
    final DateTime instant = DateTime.utc(2026, 3, 10, 23, 30);

    expect(
      at('Europe/Berlin', instant).today(),
      const CalendarDate(2026, 3, 11),
    );
    expect(
      at('America/New_York', instant).today(),
      const CalendarDate(2026, 3, 10),
    );
  });

  test('two members in different places share one Space date', () {
    // The clock is the Space's, so a Berlin member and a New York member
    // reading the same Space agree on which day it is.
    final DateTime instant = DateTime.utc(2026, 3, 10, 23, 30);
    final SpaceClock berlinSpace = at('Europe/Berlin', instant);
    final SpaceClock sameSpaceOtherDevice = SpaceClock(
      timezone: 'Europe/Berlin',
      now: () => instant.add(const Duration(milliseconds: 1)),
    );
    expect(sameSpaceOtherDevice.today(), berlinSpace.today());
  });

  test('a day range is half-open and covers exactly one day', () {
    final SpaceClock clock = at('Europe/Berlin', DateTime.utc(2026, 6, 1));
    const CalendarDate day = CalendarDate(2026, 6, 15);

    final DateTime start = clock.startOfDayUtc(day);
    final DateTime end = clock.endOfDayUtc(day);

    expect(clock.dateOf(start), day);
    expect(clock.dateOf(end), const CalendarDate(2026, 6, 16));
    expect(clock.dateOf(end.subtract(const Duration(microseconds: 1))), day);
  });

  test('a spring-forward day is 23 hours, not 24', () {
    // Berlin loses an hour on 2026-03-29. Adding 24h to midnight would land
    // on the wrong instant; the range is built from dates instead.
    final SpaceClock clock = at('Europe/Berlin', DateTime.utc(2026, 3, 1));
    const CalendarDate dst = CalendarDate(2026, 3, 29);

    final Duration length = clock
        .endOfDayUtc(dst)
        .difference(clock.startOfDayUtc(dst));
    expect(length, const Duration(hours: 23));
  });

  test('an autumn-back day is 25 hours', () {
    final SpaceClock clock = at('Europe/Berlin', DateTime.utc(2026, 10, 1));
    const CalendarDate dst = CalendarDate(2026, 10, 25);

    final Duration length = clock
        .endOfDayUtc(dst)
        .difference(clock.startOfDayUtc(dst));
    expect(length, const Duration(hours: 25));
  });

  test('nowUtc is untouched by the Space timezone', () {
    final DateTime instant = DateTime.utc(2026, 3, 10, 22, 30);
    expect(at('Asia/Tokyo', instant).nowUtc(), instant);
  });

  test('unknown timezones are detectable before use', () {
    expect(SpaceClock.isKnownTimezone('Europe/Berlin'), isTrue);
    expect(SpaceClock.isKnownTimezone('Mars/Olympus'), isFalse);
  });
}
