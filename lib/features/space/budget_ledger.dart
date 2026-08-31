import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/ledger/available_money.dart';
import 'package:sielto/domain/ledger/ledger_entry.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The figures for a Budget Space (spec 4.8).
///
/// The same chronological walk as everywhere else; only the starting sum
/// differs — here it is the fund: the planned target plus every top-up paid
/// into it.
///
/// Both limits are optional and independent. With no fund there is nothing to
/// measure a fit against, so the screen reports what has been spent and draws
/// no cutoff; with no deadline the list simply has no end.
@immutable
class BudgetLedger {
  const BudgetLedger({
    required this.period,
    required this.target,
    required this.contributions,
    required this.cascade,
    required this.entries,
    required this.beyondDeadline,
    required this.today,
    required this.totalPlanned,
    required this.totalPaid,
  });

  /// The Space's one continuous row, which carries the fund and the deadline.
  final BudgetPeriod period;

  /// The planned figure. Null when no fund was set.
  final Decimal? target;

  /// Everything paid into the fund so far.
  final Decimal contributions;

  /// Null exactly when there is no fund: with no starting sum there is nothing
  /// to walk.
  final LedgerCascade? cascade;

  /// The expenses the walk saw — those inside the deadline.
  final List<LedgerEntry> entries;

  /// Ids of records left outside by a deadline that moved backwards. Drawn
  /// dimmed and left out of the reckoning, never deleted (spec 4.8).
  final Set<String> beyondDeadline;

  final CalendarDate today;

  /// Every expense inside the deadline, paid or not.
  final Decimal totalPlanned;
  final Decimal totalPaid;

  CalendarDate? get deadline => period.deadlineDate;

  bool get deadlineIsHard => period.deadlineIsHard;

  bool get hasFund => target != null;

  /// The fund: what was planned plus what has been paid in.
  Decimal get available => (target ?? Decimal.zero) + contributions;

  Decimal get totalRemaining => totalPlanned - totalPaid;

  /// What is left of the fund once everything planned is taken off. Null when
  /// the plan does not fit, and when there is no fund to measure against.
  Decimal? get remaining => cascade?.all.freeCash;

  Coverage? get coverage => cascade?.coverage;

  CalendarDate? get lastCoveredDay => cascade?.lastCoveredDay;

  /// Days left until the event, or null when there is no date to count to.
  /// Negative once it has passed.
  int? get daysToDeadline =>
      deadline == null ? null : today.daysUntil(deadline!);

  Map<String, bool> get coverageByEntry => <String, bool>{
    for (final LedgerStep step in cascade?.all.steps ?? const <LedgerStep>[])
      step.entry.id: step.isCovered,
  };

  Map<String, bool> get moneyEndsAt {
    final ({String entryId, bool below})? end = cascade?.moneyEndsAt;
    return <String, bool>{if (end != null) end.entryId: end.below};
  }
}

/// Builds [BudgetLedger] from the continuous period and the Space's records.
///
/// A top-up is an ordinary income row read differently: in Budget mode money
/// arriving is not a period's income, it is a payment into the fund, so every
/// receipt joins the starting sum rather than the walk (spec 4.8).
BudgetLedger buildBudgetLedger({
  required BudgetPeriod period,
  required List<Payment> payments,
  required List<Income> incomes,
  required CalendarDate today,
}) {
  Decimal contributions = Decimal.zero;
  for (final Income i in incomes) {
    contributions += i.amount ?? Decimal.zero;
  }

  final List<LedgerEntry> all = <LedgerEntry>[
    for (final Payment p in payments) paymentEntry(p),
  ];

  final BudgetContext context = BudgetContext(
    budgetTarget: period.budgetTarget,
    contributions: contributions,
    entries: all,
    deadlineDate: period.deadlineDate,
    deadlineIsHard: period.deadlineIsHard,
  );
  final Set<String> beyond = <String>{
    for (final LedgerEntry e in context.beyondDeadline) e.id,
  };
  final List<LedgerEntry> inside = <LedgerEntry>[
    for (final LedgerEntry e in all)
      if (!beyond.contains(e.id)) e,
  ];

  Decimal planned = Decimal.zero;
  Decimal paid = Decimal.zero;
  for (final Payment p in payments) {
    if (beyond.contains(p.id)) continue;
    planned += p.amount;
    if (p.isPaid) paid += p.amount;
  }

  final Decimal? target = period.budgetTarget;
  return BudgetLedger(
    period: period,
    target: target,
    contributions: contributions,
    cascade: target == null
        ? null
        : LedgerWalker.cascade(
            available: target + contributions,
            entries: inside,
          ),
    entries: inside,
    beyondDeadline: beyond,
    today: today,
    totalPlanned: planned,
    totalPaid: paid,
  );
}

/// The Space's one continuous period, which Budget and Flow both hold.
final Provider<AsyncValue<BudgetPeriod?>> continuousPeriodProvider =
    Provider<AsyncValue<BudgetPeriod?>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const AsyncValue<BudgetPeriod?>.loading();
      return ref
          .watch(spacePeriodsProvider)
          .whenData(
            (List<BudgetPeriod> rows) => rows
                .where(
                  (BudgetPeriod p) => p.periodType == PeriodType.continuous,
                )
                .firstOrNull,
          );
    });

/// The live figures for a Budget Space.
final Provider<AsyncValue<BudgetLedger>>
budgetLedgerProvider = Provider<AsyncValue<BudgetLedger>>((Ref ref) {
  final AsyncValue<List<Payment>> payments = ref.watch(spacePaymentsProvider);
  final AsyncValue<List<Income>> incomes = ref.watch(spaceIncomesProvider);
  final AsyncValue<BudgetPeriod?> period = ref.watch(continuousPeriodProvider);

  final Object? error = payments.error ?? incomes.error ?? period.error;
  if (error != null) {
    return AsyncValue<BudgetLedger>.error(error, StackTrace.current);
  }

  final List<Payment>? paymentRows = payments.value;
  final List<Income>? incomeRows = incomes.value;
  final BudgetPeriod? row = period.value;
  if (paymentRows == null || incomeRows == null || row == null) {
    return const AsyncValue<BudgetLedger>.loading();
  }

  return AsyncValue<BudgetLedger>.data(
    buildBudgetLedger(
      period: row,
      payments: paymentRows,
      incomes: incomeRows,
      today: ref.watch(spaceClockProvider).today(),
    ),
  );
});
