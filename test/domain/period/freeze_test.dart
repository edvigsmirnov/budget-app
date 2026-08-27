import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/domain/period/freeze.dart';
import 'package:sielto/domain/value/calendar_date.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

void main() {
  const FreezeEvaluator evaluator = FreezeEvaluator();
  final DateTime now = DateTime.utc(2026, 4, 10, 12);

  FreezeState stateOn(String today, {String? endDate, DateTime? unfrozen}) =>
      evaluator.evaluate(
        endDate: endDate == null ? null : d(endDate),
        today: d(today),
        nowUtc: now,
        unfrozenUntil: unfrozen,
      );

  group('the 14-day rule', () {
    // A period ending 2026-03-25 freezes once 2026-04-08 is behind us.
    const String end = '2026-03-25';

    test('open well before the deadline', () {
      expect(stateOn('2026-03-26', endDate: end), FreezeState.open);
      expect(stateOn('2026-04-05', endDate: end), FreezeState.open);
    });

    test('warns two days out', () {
      expect(stateOn('2026-04-06', endDate: end), FreezeState.closingSoon);
      expect(stateOn('2026-04-07', endDate: end), FreezeState.closingSoon);
      expect(stateOn('2026-04-08', endDate: end), FreezeState.closingSoon);
    });

    test('frozen the day after the deadline passes', () {
      expect(stateOn('2026-04-09', endDate: end), FreezeState.frozen);
      expect(stateOn('2026-06-01', endDate: end), FreezeState.frozen);
    });

    test('the boundary day itself is still editable', () {
      // The rule is `end_date + 14 < today`, so day 14 is not yet frozen.
      expect(
        evaluator.isFrozen(
          endDate: d(end),
          today: d('2026-04-08'),
          nowUtc: now,
        ),
        isFalse,
      );
      expect(
        evaluator.isFrozen(
          endDate: d(end),
          today: d('2026-04-09'),
          nowUtc: now,
        ),
        isTrue,
      );
    });
  });

  group('open contexts never freeze', () {
    test('a null end date stays open forever', () {
      // Flow and Budget have no end, so history stays editable. A consequence
      // of their open nature, not an exemption (spec 4.7).
      expect(stateOn('2030-01-01'), FreezeState.open);
      expect(
        evaluator.isFrozen(endDate: null, today: d('2030-01-01'), nowUtc: now),
        isFalse,
      );
    });
  });

  group('unfreeze override', () {
    const String end = '2026-03-25';

    test('a live override reopens a frozen period', () {
      expect(
        stateOn(
          '2026-05-01',
          endDate: end,
          unfrozen: DateTime.utc(2026, 4, 11),
        ),
        FreezeState.open,
      );
    });

    test('a lapsed override does not', () {
      expect(
        stateOn('2026-05-01', endDate: end, unfrozen: DateTime.utc(2026, 4, 9)),
        FreezeState.frozen,
      );
    });

    test('an override lasts 48 hours', () {
      expect(evaluator.unfreezeExpiry(now), DateTime.utc(2026, 4, 12, 12));
    });
  });

  group('appending notes', () {
    test('the first note is written plainly', () {
      expect(
        FreezeEvaluator.appendNote(null, 'Prepaid six months', d('2026-08-15')),
        '[added 2026-08-15]: Prepaid six months',
      );
    });

    test('an addition never touches the original text', () {
      // A frozen period allows additions, never edits (spec 5.5).
      const String existing = 'Prepaid six months';
      final String result = FreezeEvaluator.appendNote(
        existing,
        'Checked with the landlord',
        d('2026-10-02'),
      );
      expect(result, startsWith(existing));
      expect(result, contains('---'));
      expect(result, endsWith('[added 2026-10-02]: Checked with the landlord'));
    });

    test('a blank existing note is treated as none', () {
      expect(
        FreezeEvaluator.appendNote('   ', 'First', d('2026-08-15')),
        '[added 2026-08-15]: First',
      );
    });
  });
}
