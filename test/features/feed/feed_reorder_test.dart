import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/feed/feed_model.dart';
import 'package:sielto/features/feed/feed_reorder.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

FeedRecord expense(
  String id,
  String date, {
  ExpenseType type = ExpenseType.mandatory,
  int sortOrder = 0,
}) => FeedRecord(
  id: id,
  date: d(date),
  title: id,
  amount: Decimal.fromInt(100),
  isIncome: false,
  isPaid: false,
  sortOrder: sortOrder,
  expenseType: type,
);

List<FeedItem> feed(List<FeedRecord> records, FeedOrderMode mode) =>
    buildFeedItems(records: records, orderMode: mode);

void main() {
  group('within one day', () {
    final List<FeedRecord> day = <FeedRecord>[
      expense('a', '2026-03-15', sortOrder: 0),
      expense('b', '2026-03-15', sortOrder: 1024),
      expense('c', '2026-03-15', sortOrder: 2048),
    ];

    test('moving a row down reports the new order', () {
      final List<FeedItem> items = feed(day, FeedOrderMode.free);
      // [header, a, b, c]; lifting 'a' out leaves [header, b, c].
      final ReorderOutcome outcome = resolveReorder(
        items: items,
        oldIndex: 1,
        insertAt: 3,
        orderMode: FeedOrderMode.free,
      );
      expect(outcome, isA<ReorderWithinDay>());
      expect((outcome as ReorderWithinDay).orderedIds, <String>['b', 'c', 'a']);
    });

    test('moving a row up reports the new order', () {
      final List<FeedItem> items = feed(day, FeedOrderMode.free);
      final ReorderOutcome outcome = resolveReorder(
        items: items,
        oldIndex: 3,
        insertAt: 1,
        orderMode: FeedOrderMode.free,
      );
      expect((outcome as ReorderWithinDay).orderedIds, <String>['c', 'a', 'b']);
    });
  });

  group('grouped mode keeps a row inside its block', () {
    final List<FeedRecord> mixed = <FeedRecord>[
      expense('rent', '2026-03-15', sortOrder: 0),
      expense('loan', '2026-03-15', sortOrder: 1024),
      expense('gym', '2026-03-15', type: ExpenseType.variable, sortOrder: 2048),
    ];

    test('a variable row cannot jump above the mandatory block', () {
      final List<FeedItem> items = feed(mixed, FeedOrderMode.grouped);
      // [header, rent, loan, gym]; 'gym' to the top of the day.
      expect(
        resolveReorder(
          items: items,
          oldIndex: 3,
          insertAt: 1,
          orderMode: FeedOrderMode.grouped,
        ),
        isA<ReorderRejected>(),
      );
    });

    test('the same move is allowed in free mode', () {
      final List<FeedItem> items = feed(mixed, FeedOrderMode.free);
      expect(
        resolveReorder(
          items: items,
          oldIndex: 3,
          insertAt: 1,
          orderMode: FeedOrderMode.free,
        ),
        isA<ReorderWithinDay>(),
      );
    });

    test('reordering inside the mandatory block is allowed', () {
      final List<FeedItem> items = feed(mixed, FeedOrderMode.grouped);
      final ReorderOutcome outcome = resolveReorder(
        items: items,
        oldIndex: 2,
        insertAt: 1,
        orderMode: FeedOrderMode.grouped,
      );
      expect((outcome as ReorderWithinDay).orderedIds, <String>[
        'loan',
        'rent',
        'gym',
      ]);
    });
  });

  group('past the day boundary', () {
    final List<FeedRecord> twoDays = <FeedRecord>[
      expense('a', '2026-03-15'),
      expense('b', '2026-03-16'),
    ];

    test('a drop in the next day opens the picker on that day', () {
      final List<FeedItem> items = feed(twoDays, FeedOrderMode.free);
      // [h15, a, h16, b]; 'a' dropped below 'b'.
      final ReorderOutcome outcome = resolveReorder(
        items: items,
        oldIndex: 1,
        insertAt: 3,
        orderMode: FeedOrderMode.free,
      );
      expect(outcome, isA<ReorderToOtherDay>());
      final ReorderToOtherDay moved = outcome as ReorderToOtherDay;
      expect(moved.recordId, 'a');
      expect(moved.suggestedDate, d('2026-03-16'));
    });

    test('nothing is written until the picker is confirmed', () {
      // The outcome only carries a suggestion; applying it is the caller's
      // job (spec 4.5).
      final List<FeedItem> items = feed(twoDays, FeedOrderMode.free);
      final ReorderOutcome outcome = resolveReorder(
        items: items,
        oldIndex: 1,
        insertAt: 3,
        orderMode: FeedOrderMode.free,
      );
      expect(outcome, isNot(isA<ReorderWithinDay>()));
    });
  });

  test('dragging a header is refused', () {
    final List<FeedItem> items = feed(<FeedRecord>[
      expense('a', '2026-03-15'),
    ], FeedOrderMode.free);
    expect(
      resolveReorder(
        items: items,
        oldIndex: 0,
        insertAt: 1,
        orderMode: FeedOrderMode.free,
      ),
      isA<ReorderRejected>(),
    );
  });

  test('a drop above the first day heading asks for a date', () {
    // Nothing above the first heading names a day, so a drop there is treated
    // like any other cross-day drag: the picker opens, and nothing is written
    // unless it is confirmed.
    final List<FeedItem> items = buildFeedItems(
      records: <FeedRecord>[
        expense('early', '2026-02-01'),
        expense('later', '2026-03-20'),
      ],
      orderMode: FeedOrderMode.free,
    );
    // [h02-01, early, h03-20, later]; 'later' dropped above every heading.
    final ReorderOutcome outcome = resolveReorder(
      items: items,
      oldIndex: 3,
      insertAt: 0,
      orderMode: FeedOrderMode.free,
    );
    expect(outcome, isA<ReorderToOtherDay>());
    expect((outcome as ReorderToOtherDay).recordId, 'later');
  });
}
