import 'package:budget_app/domain/ledger/available_money.dart';
import 'package:budget_app/domain/ledger/ledger_entry.dart';
import 'package:budget_app/domain/ledger/ledger_walker.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarDate d(String iso) => CalendarDate.parse(iso);
Decimal m(String v) => Decimal.parse(v);

LedgerEntry expense(
  String id,
  String date,
  String amount, {
  bool isPaid = false,
  ExpenseType type = ExpenseType.mandatory,
}) => LedgerEntry(
  id: id,
  date: d(date),
  amount: m(amount),
  isIncome: false,
  expenseType: type,
  isPaid: isPaid,
  title: id,
);

void main() {
  group('income-driven', () {
    test('available is the anchor plus arrived secondary inflows', () {
      final IncomeDrivenContext ctx = IncomeDrivenContext(
        anchorAmount: null,
        arrivedSecondary: Decimal.zero,
        entries: <LedgerEntry>[],
      );
      expect(ctx.isComputable, isFalse);
      expect(ctx.toLedgerContext(), isNull);
    });

    test('a floating salary leaves the figure uncomputable, not wrong', () {
      // The dashboard says the amount is unknown rather than inventing one
      // (spec 4.7).
      final IncomeDrivenContext ctx = IncomeDrivenContext(
        anchorAmount: null,
        arrivedSecondary: m('200'),
        entries: <LedgerEntry>[expense('rent', '2026-03-01', '600')],
      );
      expect(ctx.toLedgerContext(), isNull);
    });

    test('secondary inflows add once the anchor is known', () {
      final IncomeDrivenContext ctx = IncomeDrivenContext(
        anchorAmount: m('3000'),
        arrivedSecondary: m('200'),
        entries: <LedgerEntry>[expense('rent', '2026-03-01', '600')],
      );
      final LedgerContext ledger = ctx.toLedgerContext()!;
      expect(ledger.available, m('3200'));

      final LedgerRun run = LedgerWalker.walk(
        available: ledger.available,
        entries: ledger.entries,
      );
      expect(run.finalBalance, m('2600'));
    });
  });

  group('flow, and the double-count rule', () {
    // manual_balance is a snapshot of real money, so it already reflects
    // everything paid before it was set (plan G1).
    final List<LedgerEntry> entries = <LedgerEntry>[
      expense('rent', '2026-03-01', '600', isPaid: true),
      expense('internet', '2026-03-05', '40', isPaid: true),
      expense('groceries', '2026-03-20', '200'),
    ];

    test('paid expenses on or before the balance date are dropped', () {
      final LedgerContext ctx = FlowContext.build(
        manualBalance: m('1000'),
        entries: entries,
        balanceSetOn: d('2026-03-10'),
      );
      expect(ctx.entries.map((LedgerEntry e) => e.id), <String>['groceries']);

      final LedgerRun run = LedgerWalker.walk(
        available: ctx.available,
        entries: ctx.entries,
      );
      // Without the rule this would read 160: rent and internet charged twice.
      expect(run.finalBalance, m('800'));
    });

    test('a paid expense due after the balance date still counts', () {
      final LedgerContext ctx = FlowContext.build(
        manualBalance: m('1000'),
        entries: <LedgerEntry>[
          expense('prepaid', '2026-03-20', '150', isPaid: true),
        ],
        balanceSetOn: d('2026-03-10'),
      );
      expect(ctx.entries, hasLength(1));
    });

    test('an unpaid expense before the balance date still counts', () {
      // Overdue but unpaid: the money has not left the account.
      final LedgerContext ctx = FlowContext.build(
        manualBalance: m('1000'),
        entries: <LedgerEntry>[expense('overdue', '2026-03-01', '150')],
        balanceSetOn: d('2026-03-10'),
      );
      expect(ctx.entries, hasLength(1));
    });

    test('an expense due exactly on the balance date is dropped', () {
      // The boundary is inclusive: the balance was set after paying it.
      final LedgerContext ctx = FlowContext.build(
        manualBalance: m('1000'),
        entries: <LedgerEntry>[
          expense('sameDay', '2026-03-10', '150', isPaid: true),
        ],
        balanceSetOn: d('2026-03-10'),
      );
      expect(ctx.entries, isEmpty);
    });

    test('with no balance date nothing is dropped', () {
      final LedgerContext ctx = FlowContext.build(
        manualBalance: m('1000'),
        entries: entries,
      );
      expect(ctx.entries, hasLength(3));
    });

    test('the excluded count is reportable', () {
      // Shown in the balance tooltip so the exclusion is visible (plan G1).
      expect(
        FlowContext.excludedCount(
          entries: entries,
          balanceSetOn: d('2026-03-10'),
        ),
        2,
      );
      expect(FlowContext.excludedCount(entries: entries), 0);
    });

    test('incomes are never dropped', () {
      final List<LedgerEntry> withIncome = <LedgerEntry>[
        LedgerEntry(
          id: 'salary',
          date: d('2026-03-01'),
          amount: m('900'),
          isIncome: true,
          isPaid: true,
        ),
      ];
      final LedgerContext ctx = FlowContext.build(
        manualBalance: m('100'),
        entries: withIncome,
        balanceSetOn: d('2026-03-10'),
      );
      expect(ctx.entries, hasLength(1));
    });
  });

  group('budget', () {
    test('the fund is the target plus contributions', () {
      final BudgetContext ctx = BudgetContext(
        budgetTarget: m('2000'),
        contributions: m('500'),
        entries: <LedgerEntry>[expense('flights', '2026-06-01', '800')],
      );
      expect(ctx.toLedgerContext()!.available, m('2500'));
    });

    test('with no fund there is nothing to measure against', () {
      // Pure expense tracking; no cutoff is drawn (spec 4.8).
      final BudgetContext ctx = BudgetContext(
        budgetTarget: null,
        contributions: Decimal.zero,
        entries: <LedgerEntry>[expense('flights', '2026-06-01', '800')],
      );
      expect(ctx.hasFund, isFalse);
      expect(ctx.toLedgerContext(), isNull);
    });

    test('a hard deadline refuses later entries', () {
      final BudgetContext ctx = BudgetContext(
        budgetTarget: m('2000'),
        contributions: Decimal.zero,
        entries: const <LedgerEntry>[],
        deadlineDate: d('2026-08-15'),
        deadlineIsHard: true,
      );
      expect(ctx.acceptsEntryOn(d('2026-08-15')), isTrue);
      expect(ctx.acceptsEntryOn(d('2026-08-16')), isFalse);
    });

    test('a soft deadline never blocks input', () {
      final BudgetContext ctx = BudgetContext(
        budgetTarget: m('2000'),
        contributions: Decimal.zero,
        entries: const <LedgerEntry>[],
        deadlineDate: d('2026-08-15'),
      );
      expect(ctx.acceptsEntryOn(d('2026-12-31')), isTrue);
    });

    test('pulling a deadline back marks entries, never deletes them', () {
      // Moving the deadline backwards must not lose data (spec 4.8).
      final BudgetContext ctx = BudgetContext(
        budgetTarget: m('2000'),
        contributions: Decimal.zero,
        entries: <LedgerEntry>[
          expense('hotel', '2026-08-10', '400'),
          expense('souvenirs', '2026-08-20', '100'),
        ],
        deadlineDate: d('2026-08-15'),
        deadlineIsHard: true,
      );
      expect(ctx.entries, hasLength(2));
      expect(ctx.beyondDeadline.map((LedgerEntry e) => e.id), <String>[
        'souvenirs',
      ]);
    });

    test('a zero-amount entry is a dated to-do', () {
      final BudgetContext ctx = BudgetContext(
        budgetTarget: m('100'),
        contributions: Decimal.zero,
        entries: <LedgerEntry>[expense('renew passport', '2026-06-01', '0')],
      );
      final LedgerContext ledger = ctx.toLedgerContext()!;
      final LedgerRun run = LedgerWalker.walk(
        available: ledger.available,
        entries: ledger.entries,
      );
      expect(run.finalBalance, m('100'));
      expect(run.coverage, Coverage.covered);
    });
  });
}
