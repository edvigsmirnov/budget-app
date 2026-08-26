import 'package:budget_app/domain/ledger/ledger_entry.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

/// The dashboard's coloured dot (spec 4.9).
enum Coverage {
  /// Everything is covered and money is left over.
  covered,

  /// Covered to the last unit. Nothing spare.
  exact,

  /// Something falls past the cutoff, or the balance ends negative.
  short,
}

/// One entry, with the balance after it was applied.
@immutable
class LedgerStep {
  const LedgerStep({
    required this.entry,
    required this.balanceAfter,
    required this.isCovered,
  });

  final LedgerEntry entry;

  /// Running balance once this entry was applied. Keeps going negative past
  /// the cutoff so the overspend total stays visible.
  final Decimal balanceAfter;

  /// False for this entry and every expense after it.
  final bool isCovered;
}

/// What the walk found.
@immutable
class LedgerRun {
  const LedgerRun({
    required this.available,
    required this.steps,
    required this.finalBalance,
    required this.cutoffEntryId,
    required this.cutoffDate,
    required this.coverage,
  });

  /// The sum the walk started from.
  final Decimal available;

  final List<LedgerStep> steps;

  /// Balance after every entry. Negative means overspend.
  final Decimal finalBalance;

  /// The first expense that could not be paid, or null when everything fits.
  final String? cutoffEntryId;

  /// The date of that expense. "Money lasts until ..." is the day before.
  final CalendarDate? cutoffDate;

  final Coverage coverage;

  bool get hasCutoff => cutoffEntryId != null;

  /// Money left when everything is covered; null once there is a cutoff,
  /// because "free money" is not a meaningful figure then.
  Decimal? get freeCash => hasCutoff ? null : finalBalance;

  /// Entries that fell past the cutoff.
  List<LedgerEntry> get uncovered => steps
      .where((LedgerStep s) => !s.isCovered)
      .map((LedgerStep s) => s.entry)
      .toList();
}

/// Chronological running balance over the ledger (spec 4.9).
///
/// The rule that makes this more than a `SUM`: a future income joins the
/// available money **only on its own date**. If the money on hand cannot reach
/// the next income, the cutoff falls before it — even though the totals would
/// balance on paper. A single aggregate cannot express that, and cannot say
/// where the balance first crossed zero.
///
/// Linear in the number of entries, over a list already filtered to the
/// context (`is_deleted = false`, the right date range).
abstract final class LedgerWalker {
  static LedgerRun walk({
    required Decimal available,
    required List<LedgerEntry> entries,
  }) {
    final List<LedgerEntry> ordered = List<LedgerEntry>.of(entries)
      ..sort(compareLedgerEntries);

    Decimal balance = available;
    String? cutoffEntryId;
    CalendarDate? cutoffDate;
    final List<LedgerStep> steps = <LedgerStep>[];

    for (final LedgerEntry entry in ordered) {
      if (entry.isIncome) {
        balance += entry.amount;
        steps.add(
          LedgerStep(
            entry: entry,
            balanceAfter: balance,
            // An income is never "uncovered"; it is money arriving.
            isCovered: true,
          ),
        );
        continue;
      }

      final Decimal after = balance - entry.amount;
      // Strictly negative. Landing exactly on zero paid the expense in full,
      // which is covered — that case is what makes the dot orange, not red.
      final bool covered = cutoffEntryId == null && after >= Decimal.zero;
      if (!covered && cutoffEntryId == null) {
        cutoffEntryId = entry.id;
        cutoffDate = entry.date;
      }

      balance = after;
      steps.add(
        LedgerStep(entry: entry, balanceAfter: balance, isCovered: covered),
      );
    }

    return LedgerRun(
      available: available,
      steps: steps,
      finalBalance: balance,
      cutoffEntryId: cutoffEntryId,
      cutoffDate: cutoffDate,
      coverage: _coverage(
        hasCutoff: cutoffEntryId != null,
        finalBalance: balance,
      ),
    );
  }

  /// Runs the walk twice: mandatory expenses alone, then everything.
  ///
  /// Same mechanism, two answers — what is left after the bills that must be
  /// paid, and what is left after everything planned (spec 4.9, 6.2). Incomes
  /// take part in both, since the money arrives either way.
  static LedgerCascade cascade({
    required Decimal available,
    required List<LedgerEntry> entries,
  }) {
    final List<LedgerEntry> mandatoryOnly = entries
        .where((LedgerEntry e) => e.isIncome || e.isMandatory)
        .toList();
    return LedgerCascade(
      mandatory: walk(available: available, entries: mandatoryOnly),
      all: walk(available: available, entries: entries),
    );
  }

  static Coverage _coverage({
    required bool hasCutoff,
    required Decimal finalBalance,
  }) {
    if (hasCutoff || finalBalance < Decimal.zero) return Coverage.short;
    if (finalBalance == Decimal.zero) return Coverage.exact;
    return Coverage.covered;
  }
}

/// The mandatory-then-everything pair the dashboard shows together.
@immutable
class LedgerCascade {
  const LedgerCascade({required this.mandatory, required this.all});

  /// Mandatory expenses only: the base remainder.
  final LedgerRun mandatory;

  /// Mandatory and variable: the net free money.
  final LedgerRun all;

  /// The dot follows the full picture, not the mandatory-only pass.
  Coverage get coverage => all.coverage;
}
