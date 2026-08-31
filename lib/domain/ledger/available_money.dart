import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:sielto/domain/ledger/ledger_entry.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// What the ledger walk starts from, and which entries it may see.
///
/// The three modes disagree only about these two things; the walk itself is
/// identical (spec 4.9). Keeping the difference here is what stops each mode
/// from growing its own arithmetic.
@immutable
class LedgerContext {
  const LedgerContext({required this.available, required this.entries});

  final Decimal available;
  final List<LedgerEntry> entries;
}

/// Income-driven mode (spec 4.7).
///
/// `Free Cash = (Income_main + Inflow_secondary) - Sum(Payments_period)`,
/// where the secondary inflows are the non-anchor receipts whose date has
/// already come. Future incomes stay in [entries] and join at their own date.
///
/// Returns null for [LedgerContext.available] callers when the anchor amount is
/// unknown; see [isComputable].
@immutable
class IncomeDrivenContext {
  const IncomeDrivenContext({
    required this.anchorAmount,
    required this.arrivedSecondary,
    required this.entries,
  });

  /// Null when the anchor income has no amount — a floating salary. The
  /// dashboard then says so rather than showing a number it cannot compute
  /// (spec 4.7).
  final Decimal? anchorAmount;

  /// Non-anchor receipts already arrived in this period.
  final Decimal arrivedSecondary;

  final List<LedgerEntry> entries;

  bool get isComputable => anchorAmount != null;

  LedgerContext? toLedgerContext() {
    final Decimal? anchor = anchorAmount;
    if (anchor == null) return null;
    return LedgerContext(
      available: anchor + arrivedSecondary,
      entries: entries,
    );
  }
}

/// Flow mode (spec 4.6), including the double-count fix (plan G1).
///
/// `manual_balance` is a snapshot of real money at a moment in time, so it
/// already reflects every expense paid before that moment. The walk subtracts
/// all ledger expenses regardless of `is_paid`, which would charge those
/// twice — the user pays rent, updates the balance to reality, and the app
/// deducts rent again.
///
/// Rule: in Flow only, drop expenses that are both paid and due on or before
/// the day the balance was set. Everything else, including paid expenses due
/// after that day, still counts.
abstract final class FlowContext {
  static LedgerContext build({
    required Decimal manualBalance,
    required List<LedgerEntry> entries,
    CalendarDate? balanceSetOn,
  }) {
    final List<LedgerEntry> kept = balanceSetOn == null
        ? entries
        : entries
              .where((LedgerEntry e) => !_alreadyInBalance(e, balanceSetOn))
              .toList();
    return LedgerContext(available: manualBalance, entries: kept);
  }

  /// How many entries the rule removed. Surfaced in the balance tooltip so the
  /// exclusion is visible rather than mysterious (plan G1).
  static int excludedCount({
    required List<LedgerEntry> entries,
    CalendarDate? balanceSetOn,
  }) {
    if (balanceSetOn == null) return 0;
    return entries
        .where((LedgerEntry e) => _alreadyInBalance(e, balanceSetOn))
        .length;
  }

  static bool _alreadyInBalance(LedgerEntry entry, CalendarDate balanceSetOn) =>
      entry.isExpense && entry.isPaid && !entry.date.isAfter(balanceSetOn);
}

/// Budget mode (spec 4.8).
///
/// The fund is `budget_target` plus every contribution. Both the target and
/// the deadline are optional and independent: with no target there is nothing
/// to measure against, so no cutoff is drawn and the mode is simply a list of
/// dated expenses.
@immutable
class BudgetContext {
  const BudgetContext({
    required this.budgetTarget,
    required this.contributions,
    required this.entries,
    this.deadlineDate,
    this.deadlineIsHard = false,
  });

  /// Null when no fund was set.
  final Decimal? budgetTarget;

  /// Receipts recorded against the fund.
  final Decimal contributions;

  final List<LedgerEntry> entries;
  final CalendarDate? deadlineDate;
  final bool deadlineIsHard;

  bool get hasFund => budgetTarget != null;

  LedgerContext? toLedgerContext() {
    final Decimal? target = budgetTarget;
    if (target == null) return null;
    return LedgerContext(available: target + contributions, entries: entries);
  }

  /// Entries past a hard deadline that was later pulled backwards. They are
  /// neither deleted nor blocked — they are dimmed and left out of the fit
  /// calculation until the deadline moves again or the entry is rescheduled
  /// (spec 4.8).
  ///
  /// Only a hard deadline marks anything. A soft one is a marker and affects
  /// neither input nor arithmetic, so a record dated after it is an ordinary
  /// record.
  List<LedgerEntry> get beyondDeadline {
    final CalendarDate? deadline = deadlineDate;
    if (deadline == null || !deadlineIsHard) return const <LedgerEntry>[];
    return entries.where((LedgerEntry e) => e.date.isAfter(deadline)).toList();
  }

  /// Whether a new entry on [date] may be saved. A soft deadline is a marker
  /// and never blocks input.
  bool acceptsEntryOn(CalendarDate date) {
    final CalendarDate? deadline = deadlineDate;
    if (deadline == null || !deadlineIsHard) return true;
    return !date.isAfter(deadline);
  }
}
