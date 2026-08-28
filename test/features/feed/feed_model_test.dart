import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/feed/feed_model.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);

FeedRecord expense(
  String id,
  String date, {
  bool isPaid = false,
  ExpenseType type = ExpenseType.mandatory,
  int sortOrder = 0,
}) => FeedRecord(
  id: id,
  date: d(date),
  title: id,
  amount: Decimal.fromInt(100),
  isIncome: false,
  isPaid: isPaid,
  sortOrder: sortOrder,
  expenseType: type,
);

FeedRecord income(String id, String date, {int sortOrder = 0}) => FeedRecord(
  id: id,
  date: d(date),
  title: id,
  amount: Decimal.fromInt(900),
  isIncome: true,
  isPaid: false,
  sortOrder: sortOrder,
);

List<String> keysOf(List<FeedItem> items) =>
    items.map((FeedItem i) => i.key).toList();

void main() {
  final CalendarDate today = d('2026-03-10');

  group('late records stay on their own day', () {
    // The Feed is strictly chronological. A missed payment is marked, not
    // moved: lifting it out separated it from the date that explains it.
    test('an unpaid past expense keeps its place in the list', () {
      final List<FeedItem> items = buildFeedItems(
        records: <FeedRecord>[
          expense('later', '2026-03-20'),
          expense('missed', '2026-03-01'),
        ],
        orderMode: FeedOrderMode.grouped,
      );
      expect(keysOf(items), <String>[
        'header:2026-03-01',
        'row:missed',
        'header:2026-03-20',
        'row:later',
      ]);
    });

    test('a missed and a settled payment share one day heading', () {
      final List<FeedItem> items = buildFeedItems(
        records: <FeedRecord>[
          expense('missed', '2026-03-01', sortOrder: 0),
          expense('rent', '2026-03-01', isPaid: true, sortOrder: 1024),
        ],
        orderMode: FeedOrderMode.free,
      );
      expect(keysOf(items), <String>[
        'header:2026-03-01',
        'row:missed',
        'row:rent',
      ]);
    });

    test('a record still knows it is overdue', () {
      expect(expense('missed', '2026-03-01').isOverdue(today), isTrue);
      expect(expense('due', '2026-03-10').isOverdue(today), isFalse);
      // No money was missed; nothing is owed to anyone.
      expect(income('salary', '2026-03-01').isOverdue(today), isFalse);
    });
  });

  group('order within a day', () {
    final List<FeedRecord> day = <FeedRecord>[
      expense('gym', '2026-03-15', type: ExpenseType.variable, sortOrder: 0),
      expense('rent', '2026-03-15', sortOrder: 2048),
      income('salary', '2026-03-15', sortOrder: 4096),
    ];

    test('grouped puts incomes, then mandatory, then variable', () {
      final List<FeedItem> items = buildFeedItems(
        records: day,
        orderMode: FeedOrderMode.grouped,
      );
      expect(keysOf(items), <String>[
        'header:2026-03-15',
        'row:salary',
        'row:rent',
        'row:gym',
      ]);
    });

    test('free follows sort_order alone', () {
      final List<FeedItem> items = buildFeedItems(
        records: day,
        orderMode: FeedOrderMode.free,
      );
      expect(keysOf(items), <String>[
        'header:2026-03-15',
        'row:gym',
        'row:rent',
        'row:salary',
      ]);
    });

    test('a tied sort_order still orders deterministically', () {
      // sort_order carries no uniqueness constraint by design (plan G2).
      final List<FeedRecord> tied = <FeedRecord>[
        expense('b', '2026-03-15'),
        expense('a', '2026-03-15'),
      ];
      expect(
        keysOf(buildFeedItems(records: tied, orderMode: FeedOrderMode.free)),
        <String>['header:2026-03-15', 'row:a', 'row:b'],
      );
      expect(
        keysOf(
          buildFeedItems(
            records: tied.reversed.toList(),
            orderMode: FeedOrderMode.free,
          ),
        ),
        <String>['header:2026-03-15', 'row:a', 'row:b'],
      );
    });
  });

  group('cutoff line', () {
    test('is drawn immediately above the entry that does not fit', () {
      final List<FeedItem> items = buildFeedItems(
        records: <FeedRecord>[
          expense('covered', '2026-03-15', sortOrder: 0),
          expense('short', '2026-03-15', sortOrder: 1024),
        ],
        orderMode: FeedOrderMode.free,
        coverage: <String, bool>{'covered': true, 'short': false},
        moneyEndsAt: <String, bool>{'short': false},
      );
      expect(keysOf(items), <String>[
        'header:2026-03-15',
        'row:covered',
        'cutoff:short',
        'row:short',
      ]);
    });

    test('is drawn below the entry the money paid to the last unit', () {
      final List<FeedItem> items = buildFeedItems(
        records: <FeedRecord>[
          expense('last', '2026-03-15', sortOrder: 0),
          expense('after', '2026-03-15', sortOrder: 1024),
        ],
        orderMode: FeedOrderMode.free,
        moneyEndsAt: <String, bool>{'last': true},
      );
      expect(keysOf(items), <String>[
        'header:2026-03-15',
        'row:last',
        'cutoff:last',
        'row:after',
      ]);
    });

    test('no cutoff id means no line', () {
      final List<FeedItem> items = buildFeedItems(
        records: <FeedRecord>[expense('a', '2026-03-15')],
        orderMode: FeedOrderMode.free,
      );
      expect(items.whereType<FeedCutoff>(), isEmpty);
    });
  });

  test('days appear in chronological order', () {
    final List<FeedItem> items = buildFeedItems(
      records: <FeedRecord>[
        expense('c', '2026-04-01'),
        expense('a', '2026-03-12'),
        expense('b', '2026-03-20'),
      ],
      orderMode: FeedOrderMode.free,
    );
    expect(
      items.whereType<FeedHeader>().map((FeedHeader h) => h.date.toIso()),
      <String>['2026-03-12', '2026-03-20', '2026-04-01'],
    );
  });

  test('an empty ledger produces no items at all', () {
    expect(
      buildFeedItems(
        records: const <FeedRecord>[],
        orderMode: FeedOrderMode.grouped,
      ),
      isEmpty,
    );
  });
}
