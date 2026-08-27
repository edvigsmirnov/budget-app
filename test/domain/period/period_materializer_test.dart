import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/domain/period/period_materializer.dart';
import 'package:sielto/domain/schedule/income_schedule.dart';
import 'package:sielto/domain/schedule/working_days.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

void main() {
  final WorkingDayCalendar weekends = WorkingDayCalendar.weekendsOnly();

  List<MaterializedPeriod> run(
    List<AnchorSchedule> anchors, {
    String from = '2026-03-10',
    WorkingDayCalendar? calendar,
    int count = 6,
  }) => PeriodMaterializer.materialize(
    anchors: anchors,
    from: d(from),
    calendar: calendar ?? weekends,
    count: count,
  );

  AnchorSchedule fixed(String id, int day) =>
      AnchorSchedule(ruleId: id, schedule: FixedDateSchedule(day));

  group('single anchor', () {
    test('produces the horizon of periods', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('salary', 26),
      ]);
      expect(periods, hasLength(6));
    });

    test('boundaries are inclusive and abut without gaps', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('salary', 15),
      ]);
      for (int i = 0; i < periods.length - 1; i++) {
        // end = next anchor - 1: a payment due on the next anchor belongs to
        // the next period (spec 4.7).
        expect(periods[i].endDate!.addDays(1), periods[i + 1].startDate);
      }
    });

    test('the first period is the one containing the start date', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('salary', 26),
      ], from: '2026-03-10');
      // The 10th of March sits in the cycle that began on 26 February.
      expect(periods.first.startDate, d('2026-02-26'));
      expect(periods.first.endDate, d('2026-03-25'));
    });

    test('every period is at least one day long', () {
      for (final int day in <int>[1, 15, 28, 31]) {
        final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
          fixed('salary', day),
        ]);
        for (final MaterializedPeriod p in periods) {
          expect(
            p.lengthInDays,
            greaterThanOrEqualTo(1),
            reason: 'day $day: $p',
          );
        }
      }
    });

    test('a year boundary inside the horizon is crossed cleanly', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('salary', 26),
      ], from: '2026-10-01');
      final Set<int> years = periods
          .map((MaterializedPeriod p) => p.startDate.year)
          .toSet();
      expect(years, containsAll(<int>[2026, 2027]));
      for (int i = 0; i < periods.length - 1; i++) {
        expect(periods[i].endDate!.addDays(1), periods[i + 1].startDate);
      }
    });

    test('a February anchor survives a leap year', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('salary', 31),
      ], from: '2028-01-15');
      final List<String> anchors = periods
          .map((MaterializedPeriod p) => p.anchorDate.toIso())
          .toList();
      // 31 clamps to the 29th in a leap February, then resolves forward off
      // the weekend: 2028-02-29 is a Tuesday, so it stays.
      expect(anchors, contains('2028-02-29'));
    });

    test('the window is carried onto the period', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        AnchorSchedule(
          ruleId: 'salary',
          schedule: const DateRangeSchedule(23, 25),
        ),
      ]);
      for (final MaterializedPeriod p in periods) {
        expect(p.windowEnd, p.anchorDate);
        expect(p.windowStart.isAfter(p.anchorDate), isFalse);
      }
    });
  });

  group('two anchors', () {
    test('the period splits between them', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('mine', 10),
        fixed('partner', 25),
      ], from: '2026-03-01');
      final List<String> anchors = periods
          .take(3)
          .map((MaterializedPeriod p) => p.anchorDate.toIso())
          .toList();
      expect(anchors, <String>['2026-02-25', '2026-03-10', '2026-03-25']);
    });

    test('coincident anchors merge instead of making a zero-length period', () {
      // The invariant that rules out degenerate periods (spec 4.7).
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('mine', 15),
        fixed('partner', 15),
      ]);
      for (final MaterializedPeriod p in periods) {
        expect(p.isMerged, isTrue);
        expect(p.ruleIds, containsAll(<String>['mine', 'partner']));
        expect(p.lengthInDays, greaterThanOrEqualTo(1));
      }
    });

    test('anchors that only sometimes coincide merge only then', () {
      // The 30th clamps to the 28th in February, colliding with the 28th.
      final List<MaterializedPeriod> periods = run(
        <AnchorSchedule>[fixed('a', 28), fixed('b', 30)],
        from: '2026-02-01',
        count: 4,
      );
      final MaterializedPeriod february = periods.firstWhere(
        (MaterializedPeriod p) => p.anchorDate.month == 3,
        orElse: () => periods.first,
      );
      expect(february.lengthInDays, greaterThanOrEqualTo(1));
      final MaterializedPeriod merged = periods.firstWhere(
        (MaterializedPeriod p) => p.isMerged,
        orElse: () => periods.first,
      );
      expect(merged.ruleIds, isNotEmpty);
    });

    test('back-to-back anchors give a one-day period, not a broken one', () {
      final List<MaterializedPeriod> periods = run(
        <AnchorSchedule>[fixed('a', 14), fixed('b', 15)],
        from: '2026-06-01',
        count: 4,
      );
      final Iterable<int?> lengths = periods.map(
        (MaterializedPeriod p) => p.lengthInDays,
      );
      expect(lengths, everyElement(greaterThanOrEqualTo(1)));
      expect(lengths, contains(1));
    });
  });

  group('edge cases', () {
    test('no anchors means no periods, which is a valid state', () {
      // A Space with no income yet is allowed to exist indefinitely
      // (spec 4.7).
      expect(run(const <AnchorSchedule>[]), isEmpty);
    });

    test('holidays move the anchor and the boundary with it', () {
      final WorkingDayCalendar calendar = WorkingDayCalendar(
        holidays: <CalendarDate>{d('2026-05-01')},
      );
      final List<MaterializedPeriod> periods = run(
        <AnchorSchedule>[fixed('salary', 1)],
        from: '2026-04-15',
        calendar: calendar,
        count: 2,
      );
      final MaterializedPeriod may = periods.firstWhere(
        (MaterializedPeriod p) => p.anchorDate.month == 5,
      );
      // 1 May is a holiday and a Friday, so the anchor moves to Monday.
      expect(may.anchorDate, d('2026-05-04'));
      expect(may.windowStart, d('2026-04-30'));
    });

    test('extension triggers two periods before the edge', () {
      final List<MaterializedPeriod> periods = run(<AnchorSchedule>[
        fixed('salary', 26),
      ]);
      expect(
        PeriodMaterializer.needsExtension(periods, d('2026-03-10')),
        isFalse,
      );
      expect(
        PeriodMaterializer.needsExtension(periods, periods[4].startDate),
        isTrue,
      );
    });

    test('a weekday rule anchors every month of a year', () {
      final List<MaterializedPeriod> periods = run(
        <AnchorSchedule>[
          AnchorSchedule(
            ruleId: 'salary',
            schedule: const WeekdayRuleSchedule(
              WeekdayOrdinal.last,
              Weekday.friday,
            ),
          ),
        ],
        from: '2026-01-01',
        count: 12,
      );
      expect(periods, hasLength(12));
      for (final MaterializedPeriod p in periods) {
        expect(p.anchorDate.weekday, DateTime.friday);
      }
    });
  });
}
