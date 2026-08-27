import 'package:meta/meta.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/feed/feed_model.dart';

/// What a drag in the Feed turned out to mean.
sealed class ReorderOutcome {
  const ReorderOutcome();
}

/// A new order within the same day. Carries the whole day so the caller
/// renumbers it in one pass instead of hunting for a gap between neighbours.
@immutable
class ReorderWithinDay extends ReorderOutcome {
  const ReorderWithinDay(this.orderedIds);

  final List<String> orderedIds;
}

/// Dragged past the day boundary. The date picker opens prefilled with
/// [suggestedDate] and nothing is written until it is confirmed (spec 4.5).
@immutable
class ReorderToOtherDay extends ReorderOutcome {
  const ReorderToOtherDay(this.recordId, this.suggestedDate);

  final String recordId;
  final CalendarDate suggestedDate;
}

/// Snapback. In `grouped` mode a row cannot leave its type block (spec 4.5).
class ReorderRejected extends ReorderOutcome {
  const ReorderRejected();
}

/// Resolves a drag into one of the three outcomes.
///
/// [insertAt] is the index the row lands on once it has been lifted out —
/// what `onReorderItem` reports, already corrected for the removal.
ReorderOutcome resolveReorder({
  required List<FeedItem> items,
  required int oldIndex,
  required int insertAt,
  required FeedOrderMode orderMode,
}) {
  final FeedItem dragged = items[oldIndex];
  if (dragged is! FeedRow) return const ReorderRejected();
  final FeedRecord record = dragged.record;

  final List<FeedItem> without = List<FeedItem>.of(items)..removeAt(oldIndex);

  final FeedRow? previous = _nearestRow(without, insertAt - 1, step: -1);
  final FeedRow? next = _nearestRow(without, insertAt, step: 1);
  final CalendarDate? dropDay = _dayAt(without, insertAt);

  if (dropDay == null || dropDay != record.date) {
    return ReorderToOtherDay(
      record.id,
      _suggestDate(
        previous: previous?.record.date,
        next: next?.record.date,
        fallback: dropDay ?? record.date,
      ),
    );
  }

  if (orderMode == FeedOrderMode.grouped &&
      !_fitsItsGroup(record, previous: previous, next: next)) {
    return const ReorderRejected();
  }

  final List<String> ordered = <String>[];
  for (final FeedItem item in without) {
    if (item is FeedRow && item.record.date == record.date) {
      ordered.add(item.record.id);
    }
  }
  final int position = _positionWithinDay(without, insertAt, record.date);
  ordered.insert(position, record.id);
  return ReorderWithinDay(ordered);
}

/// The day a drop position belongs to. Null inside the overdue section, which
/// spans several dates and so names no single day — a drop there is treated
/// like any other cross-day move and opens the picker.
CalendarDate? _dayAt(List<FeedItem> items, int insertAt) {
  for (int i = insertAt - 1; i >= 0; i--) {
    final FeedItem item = items[i];
    if (item is FeedHeader) return item.isOverdue ? null : item.date;
  }
  return null;
}

FeedRow? _nearestRow(List<FeedItem> items, int from, {required int step}) {
  for (int i = from; i >= 0 && i < items.length; i += step) {
    final FeedItem item = items[i];
    if (item is FeedRow) return item;
    if (item is FeedHeader) return null;
  }
  return null;
}

/// Prefill for the date picker (spec 4.5): the neighbouring day when the drop
/// clearly belongs to one, and the later of the two when it sits between them.
CalendarDate _suggestDate({
  required CalendarDate? previous,
  required CalendarDate? next,
  required CalendarDate fallback,
}) {
  if (previous != null && next != null) {
    return previous.isAfter(next) ? previous : next;
  }
  return previous ?? next ?? fallback;
}

/// Incomes above mandatory payments above variable ones. A row may sit between
/// two blocks, but never inside the wrong one.
bool _fitsItsGroup(
  FeedRecord record, {
  required FeedRow? previous,
  required FeedRow? next,
}) {
  final int rank = _rank(record);
  if (previous != null &&
      previous.record.date == record.date &&
      _rank(previous.record) > rank) {
    return false;
  }
  if (next != null &&
      next.record.date == record.date &&
      _rank(next.record) < rank) {
    return false;
  }
  return true;
}

int _rank(FeedRecord r) {
  if (r.isIncome) return 0;
  return r.isMandatory ? 1 : 2;
}

int _positionWithinDay(List<FeedItem> items, int insertAt, CalendarDate day) {
  int position = 0;
  for (int i = 0; i < insertAt && i < items.length; i++) {
    final FeedItem item = items[i];
    if (item is FeedRow && item.record.date == day) position++;
  }
  return position;
}
