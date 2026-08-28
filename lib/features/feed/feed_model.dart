import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';

/// One row of the Feed, whichever table it came from.
///
/// The Feed shows payments and incomes in one chronological list, so it needs
/// one row type. This is the display twin of `LedgerEntry`, which the walker
/// uses: this one keeps the fields a row draws (category, notes) and admits an
/// unknown amount, which the walker cannot.
@immutable
class FeedRecord {
  const FeedRecord({
    required this.id,
    required this.date,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.isPaid,
    required this.sortOrder,
    this.expenseType,
    this.categoryId,
    this.notes,
    this.groupRecurringId,
    this.budgetPeriodId,
  });

  factory FeedRecord.fromPayment(Payment p) => FeedRecord(
    id: p.id,
    date: p.dueDate,
    title: p.title,
    amount: p.amount,
    isIncome: false,
    isPaid: p.isPaid,
    sortOrder: p.sortOrder,
    expenseType: p.expenseType,
    categoryId: p.categoryId,
    notes: p.notes,
    groupRecurringId: p.groupRecurringId,
    budgetPeriodId: p.budgetPeriodId,
  );

  factory FeedRecord.fromIncome(Income i) => FeedRecord(
    id: i.id,
    date: i.expectedDate,
    title: i.title,
    // Null is a floating amount, not zero: the figure is unknown (spec 4.7).
    amount: i.amount,
    isIncome: true,
    isPaid: i.isPaid,
    sortOrder: i.sortOrder,
    notes: i.notes,
    budgetPeriodId: i.budgetPeriodId,
  );

  final String id;
  final CalendarDate date;
  final String title;
  final Decimal? amount;
  final bool isIncome;
  final bool isPaid;
  final int sortOrder;
  final ExpenseType? expenseType;
  final String? categoryId;
  final String? notes;
  final String? groupRecurringId;

  /// The period the row is bound to, which decides whether it is frozen
  /// (spec 5.5). Null until a recompute has placed it.
  final String? budgetPeriodId;

  /// The same record at another position in its day.
  ///
  /// Used to hold a just-dropped order locally while the write lands.
  FeedRecord withSortOrder(int order) => FeedRecord(
    id: id,
    date: date,
    title: title,
    amount: amount,
    isIncome: isIncome,
    isPaid: isPaid,
    sortOrder: order,
    expenseType: expenseType,
    categoryId: categoryId,
    notes: notes,
    groupRecurringId: groupRecurringId,
    budgetPeriodId: budgetPeriodId,
  );

  bool get isMandatory => expenseType == ExpenseType.mandatory;

  /// Overdue: due before today and still unpaid (spec 4.5). An unpaid income
  /// is late, not overdue — no money has been missed.
  bool isOverdue(CalendarDate today) =>
      !isIncome && !isPaid && date.isBefore(today);
}

/// The three groups a day splits into in `grouped` order mode (spec 4.5).
/// Incomes first, then mandatory payments, then variable ones.
int _groupRank(FeedRecord r) {
  if (r.isIncome) return 0;
  return r.isMandatory ? 1 : 2;
}

/// Row order within one day.
///
/// In `grouped` mode the type decides the block and `sort_order` the position
/// inside it; in `free` mode `sort_order` alone decides. Id breaks ties either
/// way, because `sort_order` carries no uniqueness constraint (plan G2).
int compareInDay(FeedRecord a, FeedRecord b, FeedOrderMode mode) {
  if (mode == FeedOrderMode.grouped) {
    final int byGroup = _groupRank(a).compareTo(_groupRank(b));
    if (byGroup != 0) return byGroup;
  }
  final int byOrder = a.sortOrder.compareTo(b.sortOrder);
  if (byOrder != 0) return byOrder;
  return a.id.compareTo(b.id);
}

/// An entry in the flattened list the Feed renders.
sealed class FeedItem {
  const FeedItem();

  /// Stable across rebuilds, which is what keeps reorder animations and
  /// dismiss gestures attached to the right row.
  String get key;
}

/// "Overdue", or a date.
class FeedHeader extends FeedItem {
  const FeedHeader.day(this.date, {this.inOverdue = false}) : isOverdue = false;
  const FeedHeader.overdue() : date = null, isOverdue = true, inOverdue = true;

  final CalendarDate? date;

  /// The band that opens the overdue section.
  final bool isOverdue;

  /// A day inside that section. The same date can head a second group further
  /// down — a day with both a missed payment and a settled one — so the key
  /// has to say which of the two this is.
  final bool inOverdue;

  @override
  String get key => isOverdue
      ? 'header:overdue'
      : 'header:${inOverdue ? 'overdue:' : ''}${date!.toIso()}';
}

class FeedRow extends FeedItem {
  const FeedRow(this.record, {required this.isCovered});

  final FeedRecord record;

  /// False for this row and every expense after it once the money runs out.
  final bool isCovered;

  @override
  String get key => 'row:${record.id}';
}

/// The line between what the money covers and what it does not (spec 4.9).
class FeedCutoff extends FeedItem {
  const FeedCutoff(this.date);

  final CalendarDate date;

  @override
  String get key => 'cutoff';
}

/// Flattens records into the list the Feed draws.
///
/// Overdue rows are lifted into their own section at the top and stay there
/// until they are marked paid (spec 4.5); everything else runs in date order.
List<FeedItem> buildFeedItems({
  required List<FeedRecord> records,
  required CalendarDate today,
  required FeedOrderMode orderMode,
  Map<String, bool> coverage = const <String, bool>{},
  ({String entryId, bool below})? moneyEndsAt,
}) {
  final List<FeedRecord> overdue = <FeedRecord>[];
  final Map<String, List<FeedRecord>> byDay = <String, List<FeedRecord>>{};

  for (final FeedRecord r in records) {
    if (r.isOverdue(today)) {
      overdue.add(r);
      continue;
    }
    byDay.putIfAbsent(r.date.toIso(), () => <FeedRecord>[]).add(r);
  }

  final List<FeedItem> items = <FeedItem>[];

  if (overdue.isNotEmpty) {
    overdue.sort((FeedRecord a, FeedRecord b) {
      final int byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : compareInDay(a, b, orderMode);
    });
    items.add(const FeedHeader.overdue());
    // Dated inside the section too. Lifted to the top, a missed payment
    // otherwise sits under no date at all and there is nothing to say how late
    // it is.
    CalendarDate? lastDay;
    for (final FeedRecord r in overdue) {
      if (r.date != lastDay) {
        items.add(FeedHeader.day(r.date, inOverdue: true));
        lastDay = r.date;
      }
      items.add(FeedRow(r, isCovered: coverage[r.id] ?? true));
    }
  }

  final List<String> days = byDay.keys.toList()..sort();
  for (final String day in days) {
    items.add(FeedHeader.day(CalendarDate.parse(day)));
    final List<FeedRecord> rows = byDay[day]!
      ..sort((FeedRecord a, FeedRecord b) => compareInDay(a, b, orderMode));
    for (final FeedRecord r in rows) {
      // Above the row when the money could not pay it, below when it paid it
      // and stopped there (spec 4.9, and the zero rule over it).
      final bool endsHere = moneyEndsAt?.entryId == r.id;
      if (endsHere && !moneyEndsAt!.below) items.add(FeedCutoff(r.date));
      items.add(FeedRow(r, isCovered: coverage[r.id] ?? true));
      if (endsHere && moneyEndsAt!.below) items.add(FeedCutoff(r.date));
    }
  }

  return items;
}
