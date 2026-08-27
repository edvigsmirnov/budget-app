import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/payment_repository.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/settings/local_settings.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/dialogs.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/dashboard/period_selector.dart';
import 'package:sielto/features/feed/feed_menu.dart';
import 'package:sielto/features/feed/feed_model.dart';
import 'package:sielto/features/feed/feed_reorder.dart';
import 'package:sielto/features/feed/feed_row.dart';
import 'package:sielto/features/feed/feed_window.dart';
import 'package:sielto/features/incomes/income_form_page.dart';
import 'package:sielto/features/payments/payment_form_page.dart';
import 'package:sielto/features/periods/freeze_providers.dart';
import 'package:sielto/features/periods/freeze_ui.dart';
import 'package:sielto/features/shell/app_header.dart';
import 'package:sielto/features/space/period_ledger.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The chronological list of payments and incomes (spec 4.5).
///
/// The Dashboard answers "how much"; this screen answers "what exactly, and
/// when". Both read the same walk, so the figures above the list are the same
/// numbers the Dashboard shows, not a second calculation.
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

/// Fixed extents, so the scroll offset can be mapped onto the list without
/// measuring every child.
const double _headerExtent = 40;
const double _cutoffExtent = 34;

class _FeedPageState extends ConsumerState<FeedPage> {
  final ScrollController _scroll = ScrollController();

  /// The flattened list as last built, for the scroll listener and the arrows.
  List<FeedItem> _items = const <FeedItem>[];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_extendOnEdge);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_extendOnEdge)
      ..dispose();
    super.dispose();
  }

  /// Widens the visible window as the user reaches either end (spec 4.5), and
  /// keeps the period the figures describe in step with where the list is.
  void _extendOnEdge() {
    if (!_scroll.hasClients) return;
    _syncPeriodToScroll(_items);
    final ScrollPosition position = _scroll.position;
    const double margin = 400;
    if (position.pixels <= position.minScrollExtent + margin) {
      ref.read(feedWindowProvider.notifier).extendBackwards();
    } else if (position.pixels >= position.maxScrollExtent - margin) {
      ref.read(feedWindowProvider.notifier).extendForwards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Space space = ref.space;
    final AsyncValue<Map<String, Category>> categories = ref.watch(
      categoryIndexProvider,
    );
    final FeedDensity density = ref.watch(feedDensityProvider);
    final String locale = context.locale.toString();
    final MoneyFormat money = MoneyFormat(
      locale: locale,
      currencyCode: space.currencyCode,
    );

    final _FeedSource? source = _source(space);
    if (source == null) {
      return Scaffold(
        backgroundColor: context.sage.surface,
        appBar: AppHeader(title: tr('nav.feed')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _items = buildFeedItems(
      records: source.records,
      today: source.today,
      orderMode: space.feedOrderMode,
      coverage: source.coverage,
      cutoffEntryId: source.cutoffEntryId,
    );
    final List<FeedItem> items = _items;

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppHeader(
        title: tr('nav.feed'),
        bottom: _FeedTotals(source: source, money: money),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickAddMenu(context, ref, today: source.today),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          // The same selection the Dashboard shows, so paging on one screen
          // moves the other (spec 4.3).
          if (source.byPeriod)
            PeriodSelector(
              onJump: (BudgetPeriod p) => _scrollToPeriod(p, items),
            ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    message: tr('feed.empty'),
                    action: FilledButton(
                      onPressed: () =>
                          openPaymentForm(context, date: source.today),
                      child: Text(tr('payment.add')),
                    ),
                  )
                : ReorderableListView.builder(
                    scrollController: _scroll,
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildItem(
                          context,
                          items[index],
                          index: index,
                          density: density,
                          money: money,
                          locale: locale,
                          today: source.today,
                          categories:
                              categories.value ?? const <String, Category>{},
                          freeze: ref.watch(freezeLookupProvider),
                        ),
                    onReorderItem: (int oldIndex, int newIndex) => _onReorder(
                      items: items,
                      oldIndex: oldIndex,
                      insertAt: newIndex,
                      orderMode: space.feedOrderMode,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// What the list draws, and the two figures above it.
  ///
  /// One continuous list in every mode: the Feed scrolls into the past and the
  /// future and is deliberately not clipped to a period (spec 4.5). What the
  /// period decides is the two numbers above it — and which period that is
  /// comes from where the list is scrolled to, so moving through the records
  /// moves the figures with them.
  _FeedSource? _source(Space space) {
    final List<Payment>? payments = ref.watch(spacePaymentsProvider).value;
    final List<Income>? incomes = ref.watch(spaceIncomesProvider).value;
    if (payments == null || incomes == null) return null;

    final FeedWindow window = ref.watch(feedWindowProvider);
    final List<FeedRecord> records = <FeedRecord>[
      for (final Payment p in payments)
        if (window.contains(p.dueDate)) FeedRecord.fromPayment(p),
      for (final Income i in incomes)
        if (window.contains(i.expectedDate)) FeedRecord.fromIncome(i),
    ];

    if (space.budgetMode == BudgetMode.incomeDriven) {
      // Before the first regular income there are no cycles at all, which is a
      // valid permanent state: the list still shows, with no figures over it
      // (spec 4.7).
      final PeriodLedger? ledger = ref.watch(periodLedgerProvider).value;
      if (ref.watch(selectedPeriodProvider) == null || ledger == null) {
        return _FeedSource(
          records: records,
          today: ref.watch(spaceClockProvider).today(),
          coverage: const <String, bool>{},
          cutoffEntryId: null,
          available: null,
          freeCash: null,
          byPeriod: false,
        );
      }

      return _FeedSource(
        records: records,
        today: ledger.today,
        // The colouring belongs to the cycle the figures describe; records
        // outside it are drawn plainly rather than in another cycle's colours.
        coverage: ledger.coverageByEntry,
        cutoffEntryId: ledger.cascade?.all.cutoffEntryId,
        available: ledger.anchorAmount,
        freeCash: ledger.freeCash,
        byPeriod: true,
      );
    }

    final FlowLedger? flow = ref.watch(flowLedgerProvider).value;
    if (flow == null) return null;
    return _FeedSource(
      records: records,
      today: flow.today,
      coverage: flow.coverageByEntry,
      cutoffEntryId: flow.cascade.all.cutoffEntryId,
      available: flow.available,
      freeCash: flow.freeCash,
      byPeriod: false,
    );
  }

  /// Follows the list: the period the top visible day belongs to becomes the
  /// selected one, so the figures above and the Dashboard both track the
  /// scroll instead of a separate control.
  void _syncPeriodToScroll(List<FeedItem> items) {
    final List<BudgetPeriod> periods = ref.read(incomePeriodsProvider);
    if (periods.isEmpty || !_scroll.hasClients) return;

    final CalendarDate? top = _topVisibleDate(items);
    if (top == null) return;

    for (final BudgetPeriod p in periods) {
      final CalendarDate? end = p.endDate;
      if (p.startDate.isAfter(top)) continue;
      if (end != null && end.isBefore(top)) continue;
      if (ref.read(selectedPeriodIdProvider) != p.id) {
        ref.read(selectedPeriodIdProvider.notifier).select(p.id);
      }
      return;
    }
  }

  /// The date of the first row at or below the top of the viewport.
  ///
  /// Rows are a fixed extent per density and headers a fixed height, so the
  /// offset maps onto the flattened list arithmetically rather than by asking
  /// every child where it is.
  CalendarDate? _topVisibleDate(List<FeedItem> items) {
    final double offset = _scroll.position.pixels;
    final double rowHeight = rowHeightFor(ref.read(feedDensityProvider));

    double y = 0;
    CalendarDate? lastHeader;
    for (final FeedItem item in items) {
      final double h = switch (item) {
        FeedHeader() => _headerExtent,
        FeedCutoff() => _cutoffExtent,
        FeedRow() => rowHeight,
      };
      if (item is FeedHeader && item.date != null) lastHeader = item.date;
      if (y + h > offset) return lastHeader ?? _firstDateOf(items);
      y += h;
    }
    return lastHeader;
  }

  CalendarDate? _firstDateOf(List<FeedItem> items) {
    for (final FeedItem item in items) {
      if (item is FeedHeader && item.date != null) return item.date;
    }
    return null;
  }

  /// Scrolls the list to where a period begins.
  ///
  /// The arrows move the list rather than filtering it: the Feed stays one
  /// continuous run of records, and the buttons are a way to travel it.
  void _scrollToPeriod(BudgetPeriod period, List<FeedItem> items) {
    final double rowHeight = rowHeightFor(ref.read(feedDensityProvider));
    double y = 0;
    for (final FeedItem item in items) {
      if (item is FeedHeader &&
          item.date != null &&
          !item.date!.isBefore(period.startDate)) {
        _scroll.animateTo(
          y.clamp(
            _scroll.position.minScrollExtent,
            _scroll.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
        return;
      }
      y += switch (item) {
        FeedHeader() => _headerExtent,
        FeedCutoff() => _cutoffExtent,
        FeedRow() => rowHeight,
      };
    }
  }

  Widget _buildItem(
    BuildContext context,
    FeedItem item, {
    required int index,
    required FeedDensity density,
    required MoneyFormat money,
    required String locale,
    required CalendarDate today,
    required Map<String, Category> categories,
    required FreezeLookup freeze,
  }) {
    switch (item) {
      case FeedHeader():
        return _DayHeader(
          key: ValueKey<String>(item.key),
          header: item,
          today: today,
          dates: DateLabels(locale),
        );
      case FeedCutoff():
        return _CutoffLine(key: ValueKey<String>(item.key), item: item);
      case FeedRow():
        final FeedRecord record = item.record;
        return FeedRowTile(
          key: ValueKey<String>(item.key),
          record: record,
          isCovered: item.isCovered,
          density: density,
          money: money,
          category: record.categoryId == null
              ? null
              : categories[record.categoryId],
          onTap: () => _edit(record),
          onTogglePaid: () => _togglePaid(record),
          onDelete: () => _delete(record),
          isFrozen: freeze.isFrozen(record.budgetPeriodId),
          onLongPress: () =>
              showRecordMenu(context, ref, record: record, today: today),
          dragHandle: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: context.sage.inkLabel,
            ),
          ),
        );
    }
  }

  void _edit(FeedRecord record) {
    if (record.isIncome) {
      openIncomeForm(context, incomeId: record.id, date: record.date);
      return;
    }
    openPaymentForm(context, paymentId: record.id, date: record.date);
  }

  /// Marking something paid never asks; clearing the mark on a mandatory
  /// payment does (spec 4.5).
  Future<void> _togglePaid(FeedRecord record) async {
    final Repositories repos = ref.read(repositoriesProvider);
    final bool next = !record.isPaid;

    if (!next && record.isMandatory && !await confirmMandatory(context)) {
      return;
    }
    if (!mounted) return;

    if (record.isIncome) {
      if (next && record.amount == null) {
        // An amount is required before a receipt can be confirmed, or the
        // period's figures would stay uncomputable (spec 4.5).
        if (mounted) {
          openIncomeForm(context, incomeId: record.id, date: record.date);
        }
        return;
      }
      await guardFreeze(
        context,
        () => repos.incomes.update(record.id, isPaid: Value<bool>(next)),
      );
      return;
    }
    await guardFreeze(
      context,
      () => repos.payments.setPaid(record.id, isPaid: next),
    );
  }

  Future<void> _delete(FeedRecord record) async {
    if (record.isMandatory && !await confirmMandatory(context)) return;
    if (!mounted) return;
    final Repositories repos = ref.read(repositoriesProvider);

    final bool deleted = await guardFreeze(
      context,
      () => record.isIncome
          ? repos.incomes.softDelete(record.id)
          : repos.payments.softDelete(record.id),
    );
    ref.invalidate(periodRefreshProvider);
    if (!deleted || !mounted) return;
    showUndoSnackbar(
      context,
      message: tr(
        'feed.deleted',
        namedArgs: <String, String>{'title': record.title},
      ),
      onUndo: () async {
        if (record.isIncome) {
          await repos.incomes.restore(record.id);
        } else {
          await repos.payments.restore(record.id);
        }
      },
    );
  }

  Future<void> _onReorder({
    required List<FeedItem> items,
    required int oldIndex,
    required int insertAt,
    required FeedOrderMode orderMode,
  }) async {
    final ReorderOutcome outcome = resolveReorder(
      items: items,
      oldIndex: oldIndex,
      insertAt: insertAt,
      orderMode: orderMode,
    );
    final Repositories repos = ref.read(repositoriesProvider);

    switch (outcome) {
      case ReorderRejected():
        // Snapback: the list rebuilds from the unchanged query.
        return;

      case ReorderWithinDay(orderedIds: final List<String> ids):
        final Map<String, FeedRecord> byId = <String, FeedRecord>{
          for (final FeedItem item in items)
            if (item is FeedRow) item.record.id: item.record,
        };
        for (int i = 0; i < ids.length; i++) {
          final FeedRecord? record = byId[ids[i]];
          if (record == null) continue;
          final int order = i * PaymentRepository.sortOrderGap;
          if (record.sortOrder == order) continue;
          if (record.isIncome) {
            await repos.incomes.setSortOrder(record.id, order);
          } else {
            await repos.payments.update(
              record.id,
              sortOrder: Value<int>(order),
            );
          }
        }

      case ReorderToOtherDay(
        recordId: final String id,
        suggestedDate: final CalendarDate suggested,
      ):
        // The picker opens prefilled and writes nothing until confirmed
        // (spec 4.5).
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: suggested.toUtcMidnight(),
          firstDate: DateTime.utc(suggested.year - 5),
          lastDate: DateTime.utc(suggested.year + 10),
        );
        if (picked == null) return;
        final CalendarDate date = CalendarDate.fromDateTime(picked);
        final FeedRow? row = items
            .whereType<FeedRow>()
            .where((FeedRow r) => r.record.id == id)
            .firstOrNull;
        if (row == null) return;
        if (!mounted) return;
        await guardFreeze(
          context,
          () => row.record.isIncome
              ? repos.incomes.update(
                  id,
                  expectedDate: Value<CalendarDate>(date),
                )
              : repos.payments.update(id, dueDate: Value<CalendarDate>(date)),
        );
        // The new date may belong to another period.
        ref.invalidate(periodRefreshProvider);
    }
  }
}

/// What the Feed draws, whichever mode produced it.
///
/// The two modes disagree about which records belong on screen and about what
/// the starting sum is, and about nothing else; collapsing that disagreement
/// here keeps one list, one reorder path and one row widget.
@immutable
class _FeedSource {
  const _FeedSource({
    required this.records,
    required this.today,
    required this.coverage,
    required this.cutoffEntryId,
    required this.available,
    required this.freeCash,
    required this.byPeriod,
  });

  final List<FeedRecord> records;
  final CalendarDate today;
  final Map<String, bool> coverage;

  /// The row the money runs out on, or null when it covers everything.
  final String? cutoffEntryId;

  /// The sum the walk started from. Null when it is not known — an anchor
  /// income with no amount yet (spec 4.7).
  final Decimal? available;

  /// Null when the plan is not covered, or when [available] is unknown.
  final Decimal? freeCash;

  final bool byPeriod;
}

/// Income and Free money for the current context, above the list (spec 4.5).
class _FeedTotals extends StatelessWidget implements PreferredSizeWidget {
  const _FeedTotals({required this.source, required this.money});

  final _FeedSource source;
  final MoneyFormat money;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final Decimal? available = source.available;
    final Decimal? free = source.freeCash;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SageSpace.gutter,
        0,
        SageSpace.gutter,
        SageSpace.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: available == null
                ? StatColumn(
                    label: source.byPeriod
                        ? tr('feed.income')
                        : tr('feed.currentMoney'),
                    value: tr('income.amountUnknown'),
                  )
                : _TotalBlock(
                    label: source.byPeriod
                        ? tr('feed.income')
                        : tr('feed.currentMoney'),
                    value: available,
                    money: money,
                  ),
          ),
          Expanded(
            child: free == null
                ? StatColumn(
                    label: tr('dashboard.freeMoney'),
                    // Not covered and not computable are different answers,
                    // and only one of them is red.
                    value: available == null
                        ? tr('income.amountUnknown')
                        : tr('dashboard.notCovered'),
                    valueColor: available == null ? null : context.sage.danger,
                  )
                : _TotalBlock(
                    label: tr('dashboard.freeMoney'),
                    value: free,
                    money: money,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TotalBlock extends StatelessWidget {
  const _TotalBlock({
    required this.label,
    required this.value,
    required this.money,
  });

  final String label;
  final Decimal value;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: SageSpace.xs),
      AnimatedMoney(value: value, format: money.format),
    ],
  );
}

/// A date, or the Overdue banner that stays at the top until its rows are
/// marked paid (spec 4.5).
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.header,
    required this.today,
    required this.dates,
    super.key,
  });

  final FeedHeader header;
  final CalendarDate today;
  final DateLabels dates;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;

    if (header.isOverdue) {
      return Container(
        width: double.infinity,
        color: sage.dangerTint,
        padding: const EdgeInsets.symmetric(
          horizontal: SageSpace.gutter,
          vertical: SageSpace.sm,
        ),
        child: Text(
          tr('payment.overdue').toUpperCase(),
          style: text.labelSmall?.copyWith(color: sage.danger),
        ),
      );
    }

    final CalendarDate date = header.date!;
    final bool isToday = date == today;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SageSpace.gutter,
        SageSpace.md,
        SageSpace.gutter,
        SageSpace.xs,
      ),
      child: Row(
        children: <Widget>[
          Text(
            isToday ? tr('feed.today') : dates.dayMonth(date, reference: today),
            style: text.labelSmall?.copyWith(
              color: isToday ? sage.accentStrong : sage.inkLabel,
            ),
          ),
          const SizedBox(width: SageSpace.sm),
          Text(dates.weekday(date), style: text.labelSmall),
          const SizedBox(width: SageSpace.sm),
          const Expanded(child: Hairline()),
        ],
      ),
    );
  }
}

/// The line where the money runs out (spec 4.9).
class _CutoffLine extends StatelessWidget {
  const _CutoffLine({required this.item, super.key});

  final FeedCutoff item;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SageSpace.gutter,
        vertical: SageSpace.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Container(height: 1, color: sage.danger)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SageSpace.sm),
            child: Text(
              tr('feed.cutoff'),
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: sage.danger),
            ),
          ),
          Expanded(child: Container(height: 1, color: sage.danger)),
        ],
      ),
    );
  }
}
