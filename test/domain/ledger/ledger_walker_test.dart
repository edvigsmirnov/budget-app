import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/domain/ledger/ledger_entry.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

LedgerEntry expense(
  String id,
  String date,
  String amount, {
  ExpenseType type = ExpenseType.mandatory,
  int sortOrder = 0,
  bool isPaid = false,
}) => LedgerEntry(
  id: id,
  date: d(date),
  amount: m(amount),
  isIncome: false,
  expenseType: type,
  sortOrder: sortOrder,
  isPaid: isPaid,
  title: id,
);

LedgerEntry income(String id, String date, String amount) => LedgerEntry(
  id: id,
  date: d(date),
  amount: m(amount),
  isIncome: true,
  title: id,
);

void main() {
  group('running balance', () {
    test('everything covered leaves free cash and no cutoff', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('1000'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-01', '600'),
          expense('internet', '2026-03-05', '40'),
        ],
      );
      expect(run.hasCutoff, isFalse);
      expect(run.finalBalance, m('360'));
      expect(run.freeCash, m('360'));
      expect(run.coverage, Coverage.covered);
    });

    test('landing exactly on zero is covered, not short', () {
      // This is the orange dot: paid in full, nothing spare (spec 4.9).
      final LedgerRun run = LedgerWalker.walk(
        available: m('640'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-01', '600'),
          expense('internet', '2026-03-05', '40'),
        ],
      );
      expect(run.hasCutoff, isFalse);
      expect(run.finalBalance, Decimal.zero);
      expect(run.coverage, Coverage.exact);
    });

    test('the cutoff is the first expense that does not fit', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('650'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-01', '600'),
          expense('internet', '2026-03-05', '40'),
          expense('gym', '2026-03-07', '30'),
        ],
      );
      expect(run.cutoffEntryId, 'gym');
      expect(run.cutoffDate, d('2026-03-07'));
      expect(run.coverage, Coverage.short);
      expect(run.freeCash, isNull);
      // The balance keeps going so the overspend total stays visible.
      expect(run.finalBalance, m('-20'));
    });

    test('everything after the cutoff is uncovered too', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('100'),
        entries: <LedgerEntry>[
          expense('a', '2026-03-01', '60'),
          expense('b', '2026-03-02', '60'),
          expense('c', '2026-03-03', '10'),
        ],
      );
      // 'c' would fit on its own, but the money ran out before it.
      expect(run.uncovered.map((LedgerEntry e) => e.id), <String>['b', 'c']);
    });

    test('an empty ledger is covered with the full amount left', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('500'),
        entries: const <LedgerEntry>[],
      );
      expect(run.finalBalance, m('500'));
      expect(run.coverage, Coverage.covered);
    });

    test('no money and no entries is exact, not short', () {
      final LedgerRun run = LedgerWalker.walk(
        available: Decimal.zero,
        entries: const <LedgerEntry>[],
      );
      expect(run.coverage, Coverage.exact);
    });
  });

  group('where the money ends', () {
    test('an expense paid to the last unit takes the line below it', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('500'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-05', '200'),
          expense('card', '2026-03-10', '300'),
        ],
      );
      // Everything fits, so there is no cutoff — but there is nothing left
      // after the 10th either, and the Feed says so under that row.
      expect(run.cutoffEntryId, isNull);
      expect(run.moneyEndsAt, (entryId: 'card', below: true));
      expect(run.lastCoveredDay, d('2026-03-10'));
    });

    test('an expense that does not fit takes the line above it', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('500'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-05', '200'),
          expense('card', '2026-03-10', '400'),
        ],
      );
      expect(run.moneyEndsAt, (entryId: 'card', below: false));
      expect(run.lastCoveredDay, d('2026-03-09'));
    });

    test('the first of the two wins, so only one line is ever drawn', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('500'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-05', '500'),
          expense('card', '2026-03-10', '100'),
        ],
      );
      expect(run.exhaustedEntryId, 'rent');
      expect(run.cutoffEntryId, 'card');
      expect(run.moneyEndsAt, (entryId: 'rent', below: true));
    });

    test('money left over draws no line at all', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('500'),
        entries: <LedgerEntry>[expense('rent', '2026-03-05', '200')],
      );
      expect(run.moneyEndsAt, isNull);
      expect(run.lastCoveredDay, isNull);
    });

    test('an income that lands on zero is not an ending', () {
      // Only an expense empties the balance; an income arriving at zero is
      // money coming in, not running out.
      final LedgerRun run = LedgerWalker.walk(
        available: m('-100'),
        entries: <LedgerEntry>[income('salary', '2026-03-05', '100')],
      );
      expect(run.exhaustedEntryId, isNull);
    });
  });

  group('the coverage verdict needs data', () {
    test('no money and nothing planned has no verdict', () {
      final LedgerCascade cascade = LedgerWalker.cascade(
        available: Decimal.zero,
        entries: const <LedgerEntry>[],
      );
      expect(cascade.hasData, isFalse);
      expect(cascade.coverage, isNull);
    });

    test('nothing planned but money on hand does', () {
      final LedgerCascade cascade = LedgerWalker.cascade(
        available: m('500'),
        entries: const <LedgerEntry>[],
      );
      expect(cascade.coverage, Coverage.covered);
    });

    test('no money but something planned does', () {
      final LedgerCascade cascade = LedgerWalker.cascade(
        available: Decimal.zero,
        entries: <LedgerEntry>[expense('rent', '2026-03-05', '200')],
      );
      expect(cascade.coverage, Coverage.short);
    });
  });

  group('future income joins only on its own date', () {
    test('money that arrives too late does not prevent a cutoff', () {
      // The rule that makes this more than a SUM: totals balance on paper
      // (100 + 900 - 500 - 400 = 100) but the money is not there in time.
      final LedgerRun run = LedgerWalker.walk(
        available: m('100'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-05', '500'),
          income('salary', '2026-03-26', '900'),
          expense('card', '2026-03-28', '400'),
        ],
      );
      expect(run.cutoffEntryId, 'rent');
      expect(run.cutoffDate, d('2026-03-05'));
      expect(run.coverage, Coverage.short);
    });

    test('money that arrives in time carries the balance forward', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('600'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-05', '500'),
          income('salary', '2026-03-26', '900'),
          expense('card', '2026-03-28', '400'),
        ],
      );
      expect(run.hasCutoff, isFalse);
      expect(run.finalBalance, m('600'));
    });

    test('income on the same day as an expense is available that day', () {
      // Ordering incomes first within a date avoids inventing a cutoff that
      // never happens in reality.
      final LedgerRun run = LedgerWalker.walk(
        available: Decimal.zero,
        entries: <LedgerEntry>[
          expense('rent', '2026-03-26', '500'),
          income('salary', '2026-03-26', '900'),
        ],
      );
      expect(run.hasCutoff, isFalse);
      expect(run.finalBalance, m('400'));
    });
  });

  group('order within a day', () {
    test('sort_order decides which expense falls past the cutoff', () {
      // Feed position is not cosmetic: it sets the coverage priority when the
      // day's money runs out (spec 4.9).
      final LedgerRun run = LedgerWalker.walk(
        available: m('100'),
        entries: <LedgerEntry>[
          expense('gym', '2026-03-01', '80', sortOrder: 2048),
          expense('rent', '2026-03-01', '80', sortOrder: 0),
        ],
      );
      expect(run.cutoffEntryId, 'gym');
    });

    test('reordering changes which one survives', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('100'),
        entries: <LedgerEntry>[
          expense('gym', '2026-03-01', '80', sortOrder: 0),
          expense('rent', '2026-03-01', '80', sortOrder: 2048),
        ],
      );
      expect(run.cutoffEntryId, 'rent');
    });

    test('a tied sort_order still orders deterministically', () {
      // sort_order carries no uniqueness constraint by design (plan G2).
      List<String> idsFor(List<LedgerEntry> entries) => LedgerWalker.walk(
        available: m('1000'),
        entries: entries,
      ).steps.map((LedgerStep s) => s.entry.id).toList();

      final List<LedgerEntry> entries = <LedgerEntry>[
        expense('b', '2026-03-01', '10'),
        expense('a', '2026-03-01', '10'),
      ];
      expect(idsFor(entries), <String>['a', 'b']);
      expect(idsFor(entries.reversed.toList()), <String>['a', 'b']);
    });

    test('input order never affects the result', () {
      final List<LedgerEntry> entries = <LedgerEntry>[
        income('salary', '2026-03-26', '900'),
        expense('rent', '2026-03-05', '500'),
        expense('card', '2026-03-28', '400'),
      ];
      final LedgerRun forward = LedgerWalker.walk(
        available: m('600'),
        entries: entries,
      );
      final LedgerRun reversed = LedgerWalker.walk(
        available: m('600'),
        entries: entries.reversed.toList(),
      );
      expect(reversed.finalBalance, forward.finalBalance);
      expect(reversed.cutoffEntryId, forward.cutoffEntryId);
    });
  });

  group('mandatory / variable cascade', () {
    test('two answers from one mechanism', () {
      final List<LedgerEntry> entries = <LedgerEntry>[
        expense('rent', '2026-03-01', '600'),
        expense('groceries', '2026-03-03', '200', type: ExpenseType.variable),
      ];
      final LedgerCascade c = LedgerWalker.cascade(
        available: m('1000'),
        entries: entries,
      );
      expect(c.mandatory.finalBalance, m('400'));
      expect(c.all.finalBalance, m('200'));
    });

    test('mandatory can be covered while the full picture is not', () {
      final LedgerCascade c = LedgerWalker.cascade(
        available: m('700'),
        entries: <LedgerEntry>[
          expense('rent', '2026-03-01', '600'),
          expense('clothes', '2026-03-03', '200', type: ExpenseType.variable),
        ],
      );
      expect(c.mandatory.coverage, Coverage.covered);
      expect(c.all.coverage, Coverage.short);
      // The dot follows the full picture.
      expect(c.coverage, Coverage.short);
    });

    test('incomes take part in both passes', () {
      final LedgerCascade c = LedgerWalker.cascade(
        available: Decimal.zero,
        entries: <LedgerEntry>[
          income('salary', '2026-03-01', '1000'),
          expense('rent', '2026-03-02', '600'),
          expense('fun', '2026-03-03', '100', type: ExpenseType.variable),
        ],
      );
      expect(c.mandatory.finalBalance, m('400'));
      expect(c.all.finalBalance, m('300'));
    });
  });

  group('decimal exactness', () {
    test('the classic float case stays exact', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('0.3'),
        entries: <LedgerEntry>[
          expense('a', '2026-03-01', '0.1'),
          expense('b', '2026-03-02', '0.2'),
        ],
      );
      expect(run.finalBalance, Decimal.zero);
      expect(run.coverage, Coverage.exact);
    });

    test('a fraction of a unit short is still short', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('0.29'),
        entries: <LedgerEntry>[
          expense('a', '2026-03-01', '0.1'),
          expense('b', '2026-03-02', '0.2'),
        ],
      );
      expect(run.cutoffEntryId, 'b');
      expect(run.finalBalance, m('-0.01'));
    });

    test('many small amounts do not drift', () {
      final LedgerRun run = LedgerWalker.walk(
        available: m('10'),
        entries: <LedgerEntry>[
          for (int i = 0; i < 100; i++) expense('e$i', '2026-03-01', '0.1'),
        ],
      );
      expect(run.finalBalance, Decimal.zero);
      expect(run.hasCutoff, isFalse);
    });
  });

  group('zero-amount entries', () {
    test('a zero expense never causes a cutoff', () {
      // Budget mode uses these as dated to-dos (spec 4.8).
      final LedgerRun run = LedgerWalker.walk(
        available: Decimal.zero,
        entries: <LedgerEntry>[expense('book flights', '2026-03-01', '0')],
      );
      expect(run.hasCutoff, isFalse);
      expect(run.coverage, Coverage.exact);
    });
  });
}
