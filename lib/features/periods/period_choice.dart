import 'package:meta/meta.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

/// Which period a payment is filed under (spec 5.3).
///
/// [byDate] is the default and follows the due date: when the anchor income
/// moves, the payment moves with it. The other two are a choice the user made,
/// and a recompute leaves them alone — "I filed this under the September
/// salary" stays true even when that salary shifts.
enum PeriodChoice { byDate, current, next }

/// The period a date falls in, and the one after it.
@immutable
class PeriodPair {
  const PeriodPair({required this.current, required this.next});

  /// Null when no cycle covers the date — before the first anchor, or past the
  /// last one the schedule reaches.
  final BudgetPeriod? current;

  final BudgetPeriod? next;

  /// Nothing to choose between: the control is not shown.
  bool get isEmpty => current == null && next == null;

  BudgetPeriod? forChoice(PeriodChoice choice) => switch (choice) {
    PeriodChoice.byDate || PeriodChoice.current => current,
    PeriodChoice.next => next,
  };
}

/// Locates [date] among the income-driven cycles of a Space.
///
/// [periods] is expected oldest first, which is what `incomeDrivenIn` and
/// `incomePeriodsProvider` both return.
PeriodPair periodsAround(List<BudgetPeriod> periods, CalendarDate date) {
  for (int i = 0; i < periods.length; i++) {
    final BudgetPeriod p = periods[i];
    if (p.periodType != PeriodType.incomeDriven) continue;
    if (p.startDate.isAfter(date)) continue;
    final CalendarDate? end = p.endDate;
    if (end != null && end.isBefore(date)) continue;
    return PeriodPair(
      current: p,
      next: i + 1 < periods.length ? periods[i + 1] : null,
    );
  }
  return const PeriodPair(current: null, next: null);
}

/// Whether [date] sits inside a boundary nobody can be sure of yet.
///
/// A cycle opens when its anchor income arrives, and where that date fell on a
/// weekend the arrival is a span rather than a day (spec 5.1.1). A payment
/// dated inside that span could honestly belong to either cycle — which is the
/// only situation where asking the user is worth anything. Everywhere else the
/// date answers on its own, and a control offering a choice that has already
/// been made is just another thing to read.
bool periodIsAmbiguousOn(List<BudgetPeriod> periods, CalendarDate date) {
  for (final BudgetPeriod p in periods) {
    if (p.periodType != PeriodType.incomeDriven) continue;
    final CalendarDate? from = p.windowStart;
    final CalendarDate? to = p.windowEnd;
    // A window of one day resolved to a certainty; there is nothing to ask.
    if (from == null || to == null || from == to) continue;
    if (!from.isAfter(date) && !to.isBefore(date)) return true;
  }
  return false;
}

/// What the form should show for an existing payment.
///
/// A pin to something that is neither the containing period nor the one after
/// it reads as [PeriodChoice.byDate]: the control offers two targets, and
/// claiming one of them for a third period would be a lie.
PeriodChoice choiceOf(Payment payment, PeriodPair pair) {
  if (payment.periodAssignment != PeriodAssignment.manual) {
    return PeriodChoice.byDate;
  }
  if (payment.budgetPeriodId == pair.next?.id) return PeriodChoice.next;
  if (payment.budgetPeriodId == pair.current?.id) return PeriodChoice.current;
  return PeriodChoice.byDate;
}
