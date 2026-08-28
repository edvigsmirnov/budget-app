import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/ledger/ledger_entry.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/incomes/income_rules_page.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The figures for one income cycle (spec 4.7).
///
/// The mechanism is the same chronological walk every mode uses. What differs
/// is only where it starts and what it may see: it starts from the anchor
/// income, which lands on the first day of the period by construction, and it
/// sees that period's payments plus its non-anchor incomes.
///
/// Two consequences worth stating, because both are easy to get wrong:
///
/// - **A non-anchor income joins on its own date, not before.** The walk
///   reaches it when it reaches its day, exactly as the cutoff rule requires
///   (spec 4.9, rule 3). Nothing is spendable in advance of arriving.
/// - **`is_paid` changes no figure here.** It records what happened; the
///   forecast is about dates. Gating the arithmetic on it would mean future
///   income never counted at all, since nothing can be marked received before
///   it arrives.
@immutable
class PeriodLedger {
  const PeriodLedger({
    required this.period,
    required this.anchorAmount,
    required this.cascade,
    required this.entries,
    required this.today,
    required this.totalPlanned,
    required this.totalPaid,
    required this.nearestIncome,
    required this.unknownIncomeCount,
    required this.hasIncome,
    required this.hasUnpaidExpense,
  });

  final BudgetPeriod period;

  /// The period's anchor income. Null when the salary floats and no figure has
  /// been given yet — the dashboard then says so instead of inventing one
  /// (spec 4.7).
  final Decimal? anchorAmount;

  /// Null exactly when [anchorAmount] is: with no starting sum there is
  /// nothing to walk.
  final LedgerCascade? cascade;

  final List<LedgerEntry> entries;
  final CalendarDate today;

  /// Every payment in the period, paid or not.
  final Decimal totalPlanned;
  final Decimal totalPaid;

  /// The next inflow of this period that has not arrived yet.
  final Income? nearestIncome;

  /// Incomes in the period whose amount is unknown, so they contribute
  /// nothing. Reported rather than silently ignored (spec 4.7).
  final int unknownIncomeCount;

  /// Whether any income at all is recorded against this cycle.
  final bool hasIncome;

  /// Whether anything in it is still owed.
  final bool hasUnpaidExpense;

  bool get isComputable => cascade != null;

  /// Whether the walk's verdict says anything about this cycle.
  ///
  /// A cycle with no income and nothing outstanding is not overspent: the
  /// money already moved, and there was no figure it was meant to come out of.
  /// The remainder is still arithmetic and still shown — it is simply not
  /// judged, so no dot, no cutoff and no date the money runs out on.
  bool get isJudged => hasIncome || hasUnpaidExpense;

  Decimal get totalRemaining => totalPlanned - totalPaid;

  Coverage? get coverage => isJudged ? cascade?.coverage : null;

  /// Money left once everything planned is covered; null when it is not, or
  /// when the anchor amount is unknown. An unjudged cycle reports the plain
  /// remainder instead, which is a fact rather than a forecast.
  Decimal? get freeCash =>
      isJudged ? cascade?.all.freeCash : cascade?.all.finalBalance;

  /// After the mandatory payments alone (spec 4.4).
  Decimal? get baseRemainder =>
      isJudged ? cascade?.mandatory.freeCash : cascade?.mandatory.finalBalance;

  /// After the mandatory payments alone, as a verdict.
  Coverage? get baseCoverage => isJudged ? cascade?.mandatory.coverage : null;

  /// The last day the money reaches, when it does not reach the whole period.
  CalendarDate? get lastCoveredDay => isJudged ? cascade?.lastCoveredDay : null;

  /// Where this cycle's money runs out, for the line in the Feed.
  ({String entryId, bool below})? get moneyEndsAt =>
      isJudged ? cascade?.moneyEndsAt : null;

  Map<String, bool> get coverageByEntry => !isJudged
      ? const <String, bool>{}
      : <String, bool>{
          for (final LedgerStep step
              in cascade?.all.steps ?? const <LedgerStep>[])
            step.entry.id: step.isCovered,
        };
}

/// Builds the figures for one period from its records.
PeriodLedger buildPeriodLedger({
  required BudgetPeriod period,
  required List<Payment> payments,
  required List<Income> incomes,
  required Set<String> anchorRuleIds,
  required CalendarDate today,
}) {
  bool isAnchor(Income i) =>
      i.recurrenceRuleId != null && anchorRuleIds.contains(i.recurrenceRuleId);

  // Bound to this period, or bound nowhere and dated inside it. The second
  // case is every record between being written and the next recompute placing
  // it: without it the Feed lists a payment the figures above it ignore.
  final CalendarDate? end = period.endDate;
  bool inPeriod(String? boundTo, CalendarDate date) {
    if (boundTo != null) return boundTo == period.id;
    return !period.startDate.isAfter(date) &&
        (end == null || !end.isBefore(date));
  }

  final List<Payment> ofPeriod = payments
      .where((Payment p) => inPeriod(p.budgetPeriodId, p.dueDate))
      .toList();

  // The anchor is the exception, and deliberately strict: it is not a record
  // inside the period, it is the record the period was built around. Counting
  // an unbound one by date lets a materialisation still in flight — or a
  // schedule that puts two occurrences near one boundary — add a second and
  // third salary to the base the whole cycle is measured from.
  final List<Income> inflows = incomes
      .where(
        (Income i) => isAnchor(i)
            ? i.budgetPeriodId == period.id
            : inPeriod(i.budgetPeriodId, i.expectedDate),
      )
      .toList();

  // Anchors that resolved to the same date merged into this one period, so
  // their amounts add (spec 4.7).
  //
  // Two ways to end up without a figure, and they are not the same answer:
  //
  // - **No anchor income at all** is zero. Nothing is coming, and zero is what
  //   that is worth; the cycle computes normally from it, and the expenses
  //   below show as uncovered because they are.
  // - **An anchor with no amount** is unknown. Money is coming and its size is
  //   not known yet, so any figure would be invented — a floating salary makes
  //   the cycle uncomputable, and that is not zero (spec 4.7).
  Decimal anchorTotal = Decimal.zero;
  bool anchorKnown = false;
  bool anchorUnknown = false;
  for (final Income i in inflows.where(isAnchor)) {
    final Decimal? amount = i.amount;
    if (amount == null) {
      anchorUnknown = true;
      continue;
    }
    anchorTotal += amount;
    anchorKnown = true;
  }
  final Decimal? anchorAmount = (anchorUnknown && !anchorKnown)
      ? null
      : anchorTotal;

  int unknown = 0;
  final List<LedgerEntry> entries = <LedgerEntry>[
    for (final Payment p in ofPeriod) paymentEntry(p),
  ];
  for (final Income i in inflows) {
    if (isAnchor(i)) continue;
    final LedgerEntry? entry = incomeEntry(i);
    if (entry == null) {
      unknown++;
      continue;
    }
    entries.add(entry);
  }

  Decimal planned = Decimal.zero;
  Decimal paid = Decimal.zero;
  for (final Payment p in ofPeriod) {
    planned += p.amount;
    if (p.isPaid) paid += p.amount;
  }

  Income? nearest;
  for (final Income i in inflows) {
    if (i.isPaid || i.expectedDate.isBefore(today)) continue;
    if (nearest == null || i.expectedDate.isBefore(nearest.expectedDate)) {
      nearest = i;
    }
  }

  return PeriodLedger(
    period: period,
    anchorAmount: anchorAmount,
    cascade: anchorAmount == null
        ? null
        : LedgerWalker.cascade(available: anchorAmount, entries: entries),
    entries: entries,
    today: today,
    totalPlanned: planned,
    totalPaid: paid,
    nearestIncome: nearest,
    unknownIncomeCount: unknown + (anchorUnknown && anchorKnown ? 1 : 0),
    hasIncome: inflows.isNotEmpty,
    hasUnpaidExpense: ofPeriod.any((Payment p) => !p.isPaid),
  );
}

/// The period the three screens are showing (spec 4.3).
///
/// One selection shared across Dashboard, Feed and Calendar: paging forward on
/// one and switching to another shows the same cycle, not today's.
class SelectedPeriodController extends Notifier<String?> {
  @override
  String? build() {
    // Following the Space resets the choice, which is what should happen.
    ref.watch(currentSpaceProvider);
    return null;
  }

  void select(String? periodId) => state = periodId;
}

final NotifierProvider<SelectedPeriodController, String?>
selectedPeriodIdProvider = NotifierProvider<SelectedPeriodController, String?>(
  SelectedPeriodController.new,
);

/// The income cycles of the open Space, oldest first.
final Provider<List<BudgetPeriod>> incomePeriodsProvider =
    Provider<List<BudgetPeriod>>((Ref ref) {
      final List<BudgetPeriod> all =
          ref.watch(spacePeriodsProvider).value ?? const <BudgetPeriod>[];
      return all
          .where((BudgetPeriod p) => p.periodType == PeriodType.incomeDriven)
          .toList();
    });

/// The selected period, defaulting to the one containing today.
final Provider<BudgetPeriod?> selectedPeriodProvider = Provider<BudgetPeriod?>((
  Ref ref,
) {
  final List<BudgetPeriod> periods = ref.watch(incomePeriodsProvider);
  if (periods.isEmpty) return null;

  final String? chosen = ref.watch(selectedPeriodIdProvider);
  for (final BudgetPeriod p in periods) {
    if (p.id == chosen) return p;
  }

  final CalendarDate today = ref.watch(spaceClockProvider).today();
  for (final BudgetPeriod p in periods) {
    if (p.startDate.isAfter(today)) continue;
    final CalendarDate? end = p.endDate;
    if (end == null || !end.isBefore(today)) return p;
  }
  return periods.first;
});

/// Every cycle's figures, oldest first.
///
/// Deliberately blind to which period is selected: the Feed draws each cycle's
/// own coverage and its own cutoff line, so scrolling from one into the next
/// must not recompute — or redraw — the list under the finger.
final Provider<AsyncValue<List<PeriodLedger>>> periodLedgersProvider =
    Provider<AsyncValue<List<PeriodLedger>>>((Ref ref) {
      // Periods have to exist before they can be shown.
      ref.watch(periodRefreshProvider);

      final AsyncValue<List<Payment>> payments = ref.watch(
        spacePaymentsProvider,
      );
      final AsyncValue<List<Income>> incomes = ref.watch(spaceIncomesProvider);
      final AsyncValue<List<IncomeRecurrenceRule>> rules = ref.watch(
        incomeRulesProvider,
      );

      final Object? error = payments.error ?? incomes.error ?? rules.error;
      if (error != null) {
        return AsyncValue<List<PeriodLedger>>.error(error, StackTrace.current);
      }

      final List<Payment>? paymentRows = payments.value;
      final List<Income>? incomeRows = incomes.value;
      final List<IncomeRecurrenceRule>? ruleRows = rules.value;
      if (paymentRows == null || incomeRows == null || ruleRows == null) {
        return const AsyncValue<List<PeriodLedger>>.loading();
      }

      final Set<String> anchors = <String>{
        for (final IncomeRecurrenceRule r in ruleRows)
          if (r.isAnchor) r.id,
      };
      final CalendarDate today = ref.watch(spaceClockProvider).today();

      return AsyncValue<List<PeriodLedger>>.data(<PeriodLedger>[
        for (final BudgetPeriod period in ref.watch(incomePeriodsProvider))
          buildPeriodLedger(
            period: period,
            payments: paymentRows,
            incomes: incomeRows,
            anchorRuleIds: anchors,
            today: today,
          ),
      ]);
    });

/// The figures for the selected period, picked out of the set above.
final Provider<AsyncValue<PeriodLedger>> periodLedgerProvider =
    Provider<AsyncValue<PeriodLedger>>((Ref ref) {
      final BudgetPeriod? period = ref.watch(selectedPeriodProvider);
      if (period == null) return const AsyncValue<PeriodLedger>.loading();

      final AsyncValue<List<PeriodLedger>> all = ref.watch(
        periodLedgersProvider,
      );
      final Object? error = all.error;
      if (error != null) {
        return AsyncValue<PeriodLedger>.error(error, StackTrace.current);
      }
      final List<PeriodLedger>? ledgers = all.value;
      if (ledgers == null) return const AsyncValue<PeriodLedger>.loading();

      for (final PeriodLedger ledger in ledgers) {
        if (ledger.period.id == period.id) {
          return AsyncValue<PeriodLedger>.data(ledger);
        }
      }
      return const AsyncValue<PeriodLedger>.loading();
    });
