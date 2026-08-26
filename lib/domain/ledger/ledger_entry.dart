import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

/// One row on the ledger, whether it started life as a payment or an income.
///
/// The walker treats both the same way — a dated amount that moves the running
/// balance — so it needs one type, not two. Payments and incomes differ only
/// in [isIncome] and in which date column they came from (`due_date` versus
/// `expected_date`).
@immutable
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.sortOrder = 0,
    this.expenseType,
    this.isPaid = false,
    this.title = '',
  });

  final String id;
  final CalendarDate date;

  /// Always positive. Direction comes from [isIncome], never from the sign —
  /// the same rule the input validation enforces (spec 6.7).
  final Decimal amount;

  final bool isIncome;

  /// Manual position within the day. Not just cosmetic: when the day's money
  /// runs out, the rows below this order are the ones that fall past the
  /// cutoff (spec 4.9).
  final int sortOrder;

  /// Null for incomes; categories and the mandatory/variable split apply to
  /// payments only.
  final ExpenseType? expenseType;

  final bool isPaid;
  final String title;

  bool get isExpense => !isIncome;

  bool get isMandatory => expenseType == ExpenseType.mandatory;

  @override
  String toString() =>
      'LedgerEntry($date ${isIncome ? '+' : '-'}$amount $title)';
}

/// Orders entries the way the walker consumes them.
///
/// Date first, then incomes before expenses on the same day — money that
/// arrives today can be spent today, and putting the expense first would
/// invent a cutoff that never happens. Then the manual order, then id so the
/// result is stable across rebuilds; `sort_order` carries no uniqueness
/// constraint, by design (plan G2).
int compareLedgerEntries(LedgerEntry a, LedgerEntry b) {
  final int byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate;

  if (a.isIncome != b.isIncome) return a.isIncome ? -1 : 1;

  final int byOrder = a.sortOrder.compareTo(b.sortOrder);
  if (byOrder != 0) return byOrder;

  return a.id.compareTo(b.id);
}
