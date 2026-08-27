import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/ledger/available_money.dart';
import 'package:sielto/domain/ledger/ledger_entry.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// Every live payment of the current Space.
final StreamProvider<List<Payment>> spacePaymentsProvider =
    StreamProvider<List<Payment>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const Stream<List<Payment>>.empty();
      return ref.watch(repositoriesProvider).payments.watchInSpace(space.id);
    });

final StreamProvider<List<Income>> spaceIncomesProvider =
    StreamProvider<List<Income>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const Stream<List<Income>>.empty();
      return ref.watch(repositoriesProvider).incomes.watchInSpace(space.id);
    });

final StreamProvider<List<Category>> spaceCategoriesProvider =
    StreamProvider<List<Category>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const Stream<List<Category>>.empty();
      return ref.watch(repositoriesProvider).categories.watchInSpace(space.id);
    });

/// Categories by id, including soft-deleted ones: a payment keeps showing the
/// category it was filed under even after that category is removed (spec 7).
final StreamProvider<Map<String, Category>> categoryIndexProvider =
    StreamProvider<Map<String, Category>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const Stream<Map<String, Category>>.empty();
      return ref
          .watch(repositoriesProvider)
          .categories
          .watchAllEverInSpace(space.id)
          .map(
            (List<Category> rows) => <String, Category>{
              for (final Category c in rows) c.id: c,
            },
          );
    });

LedgerEntry paymentEntry(Payment p) => LedgerEntry(
  id: p.id,
  date: p.dueDate,
  amount: p.amount,
  isIncome: false,
  sortOrder: p.sortOrder,
  expenseType: p.expenseType,
  isPaid: p.isPaid,
  title: p.title,
);

/// An income with no amount yet — a floating salary — contributes nothing to
/// the walk until the figure is known (spec 4.7).
LedgerEntry? incomeEntry(Income i) {
  final Decimal? amount = i.amount;
  if (amount == null) return null;
  return LedgerEntry(
    id: i.id,
    date: i.expectedDate,
    amount: amount,
    isIncome: true,
    sortOrder: i.sortOrder,
    isPaid: i.isPaid,
    title: i.title,
  );
}

/// The Flow-mode figures every screen of a Flow Space reads.
///
/// One computation, shared: the Dashboard's main figure, the Feed's header
/// numbers and the cutoff line in the list are all views of this (spec 4.9).
@immutable
class FlowLedger {
  const FlowLedger({
    required this.available,
    required this.cascade,
    required this.entries,
    required this.excludedCount,
    required this.today,
    required this.totalPlanned,
    required this.totalPaid,
    required this.nearestIncome,
  });

  /// Money on hand: the manual balance plus everything received since it was
  /// set.
  final Decimal available;

  final LedgerCascade cascade;

  /// What the walk actually saw, after the double-count rule.
  final List<LedgerEntry> entries;

  /// How many rows that rule removed. Shown under the balance so the exclusion
  /// is visible rather than mysterious (plan G1).
  final int excludedCount;

  final CalendarDate today;

  /// Every planned expense in the context, paid or not.
  final Decimal totalPlanned;
  final Decimal totalPaid;

  /// The next inflow that has not arrived yet, or null.
  final Income? nearestIncome;

  Decimal get totalRemaining => totalPlanned - totalPaid;

  Coverage get coverage => cascade.coverage;

  /// Free money once everything planned is covered; null when it is not.
  Decimal? get freeCash => cascade.all.freeCash;

  /// After the mandatory expenses alone. The floor to stay above (spec 4.4).
  Decimal? get baseRemainder => cascade.mandatory.freeCash;

  /// The last day the money reaches — the day before the first expense that
  /// does not fit. Null while everything is covered.
  CalendarDate? get lastCoveredDay {
    final CalendarDate? cutoff = cascade.all.cutoffDate;
    return cutoff?.addDays(-1);
  }

  /// Coverage per entry id, for the cutoff line in the Feed.
  Map<String, bool> get coverageByEntry => <String, bool>{
    for (final LedgerStep step in cascade.all.steps)
      step.entry.id: step.isCovered,
  };
}

/// Builds [FlowLedger] from the Space row and its records.
///
/// Which inflows are already inside `manual_balance` is decided by the same
/// date test as the expenses (plan G1): a receipt dated on or before the
/// snapshot is part of it, one dated after is added on top. Unreceived incomes
/// stay in the ledger and join at their own date, never before it (spec 4.6).
FlowLedger buildFlowLedger({
  required Space space,
  required List<Payment> payments,
  required List<Income> incomes,
  required CalendarDate today,
}) {
  final CalendarDate? balanceSetOn = space.manualBalanceUpdatedAt == null
      ? null
      : CalendarDate.fromDateTime(space.manualBalanceUpdatedAt!.toUtc());
  final Decimal manualBalance = space.manualBalance ?? Decimal.zero;

  Decimal receivedSinceSnapshot = Decimal.zero;
  final List<LedgerEntry> entries = <LedgerEntry>[];

  for (final Payment p in payments) {
    entries.add(paymentEntry(p));
  }

  for (final Income i in incomes) {
    final LedgerEntry? entry = incomeEntry(i);
    if (entry == null) continue;
    if (!i.isPaid) {
      entries.add(entry);
      continue;
    }
    final bool insideSnapshot =
        balanceSetOn != null && !entry.date.isAfter(balanceSetOn);
    if (!insideSnapshot) receivedSinceSnapshot += entry.amount;
  }

  final LedgerContext context = FlowContext.build(
    manualBalance: manualBalance + receivedSinceSnapshot,
    entries: entries,
    balanceSetOn: balanceSetOn,
  );

  Decimal planned = Decimal.zero;
  Decimal paid = Decimal.zero;
  for (final Payment p in payments) {
    planned += p.amount;
    if (p.isPaid) paid += p.amount;
  }

  Income? nearest;
  for (final Income i in incomes) {
    if (i.isPaid || i.expectedDate.isBefore(today)) continue;
    if (nearest == null || i.expectedDate.isBefore(nearest.expectedDate)) {
      nearest = i;
    }
  }

  return FlowLedger(
    available: context.available,
    cascade: LedgerWalker.cascade(
      available: context.available,
      entries: context.entries,
    ),
    entries: context.entries,
    excludedCount: FlowContext.excludedCount(
      entries: entries,
      balanceSetOn: balanceSetOn,
    ),
    today: today,
    totalPlanned: planned,
    totalPaid: paid,
    nearestIncome: nearest,
  );
}

/// The ledger as it would stand if a draft were saved (spec 6.1).
///
/// Runs entirely in memory: the form recomputes this on every keystroke and
/// the database is not touched until Save. [replacingId] takes the record
/// being edited out first, so the preview measures the change rather than a
/// duplicate.
///
/// [available] and [entries] come from whichever context the Space computes
/// in — Flow's open walk or one income cycle — rather than from `FlowLedger`,
/// which would put every future salary into an income-driven preview.
LedgerRun previewRun({
  required Decimal available,
  required List<LedgerEntry> entries,
  required List<LedgerEntry> draft,
  String? replacingId,
}) => LedgerWalker.walk(
  available: available,
  entries: <LedgerEntry>[
    for (final LedgerEntry e in entries)
      if (e.id != replacingId) e,
    ...draft,
  ],
);

/// The live figures for the current Space. Recomputed whenever a record, the
/// balance or the Space itself changes (spec 4.9).
final Provider<AsyncValue<FlowLedger>> flowLedgerProvider =
    Provider<AsyncValue<FlowLedger>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const AsyncValue<FlowLedger>.loading();

      final AsyncValue<List<Payment>> payments = ref.watch(
        spacePaymentsProvider,
      );
      final AsyncValue<List<Income>> incomes = ref.watch(spaceIncomesProvider);

      final Object? error = payments.error ?? incomes.error;
      if (error != null) {
        return AsyncValue<FlowLedger>.error(
          error,
          payments.stackTrace ?? incomes.stackTrace ?? StackTrace.current,
        );
      }

      final List<Payment>? paymentRows = payments.value;
      final List<Income>? incomeRows = incomes.value;
      if (paymentRows == null || incomeRows == null) {
        return const AsyncValue<FlowLedger>.loading();
      }

      return AsyncValue<FlowLedger>.data(
        buildFlowLedger(
          space: space,
          payments: paymentRows,
          incomes: incomeRows,
          today: ref.watch(spaceClockProvider).today(),
        ),
      );
    });
