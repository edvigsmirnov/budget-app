import 'package:budget_app/app/providers.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/repositories/payment_repository.dart';
import 'package:budget_app/core/format/date_format.dart';
import 'package:budget_app/core/format/money_format.dart';
import 'package:budget_app/core/settings/local_settings.dart';
import 'package:budget_app/core/settings/settings_providers.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/ui/dialogs.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:budget_app/features/feed/feed_menu.dart';
import 'package:budget_app/features/feed/feed_model.dart';
import 'package:budget_app/features/feed/feed_reorder.dart';
import 'package:budget_app/features/feed/feed_row.dart';
import 'package:budget_app/features/feed/feed_window.dart';
import 'package:budget_app/features/incomes/income_form_page.dart';
import 'package:budget_app/features/payments/payment_form_page.dart';
import 'package:budget_app/features/shell/app_header.dart';
import 'package:budget_app/features/space/space_ledger.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _FeedPageState extends ConsumerState<FeedPage> {
  final ScrollController _scroll = ScrollController();

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

  /// Widens the visible window as the user reaches either end (spec 4.5).
  void _extendOnEdge() {
    if (!_scroll.hasClients) return;
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
    final AsyncValue<FlowLedger> ledger = ref.watch(flowLedgerProvider);
    final AsyncValue<List<Payment>> payments = ref.watch(spacePaymentsProvider);
    final AsyncValue<List<Income>> incomes = ref.watch(spaceIncomesProvider);
    final AsyncValue<Map<String, Category>> categories = ref.watch(
      categoryIndexProvider,
    );
    final FeedDensity density = ref.watch(feedDensityProvider);
    final String locale = context.locale.toString();
    final MoneyFormat money = MoneyFormat(
      locale: locale,
      currencyCode: space.currencyCode,
    );

    final FlowLedger? flow = ledger.value;
    final List<Payment>? paymentRows = payments.value;
    final List<Income>? incomeRows = incomes.value;

    if (flow == null || paymentRows == null || incomeRows == null) {
      return Scaffold(
        backgroundColor: context.sage.surface,
        appBar: AppHeader(title: tr('nav.feed')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final FeedWindow window = ref.watch(feedWindowProvider);
    final List<FeedRecord> visible = <FeedRecord>[
      for (final Payment p in paymentRows)
        if (window.contains(p.dueDate)) FeedRecord.fromPayment(p),
      for (final Income i in incomeRows)
        if (window.contains(i.expectedDate)) FeedRecord.fromIncome(i),
    ];

    final List<FeedItem> items = buildFeedItems(
      records: visible,
      today: flow.today,
      orderMode: space.feedOrderMode,
      coverage: flow.coverageByEntry,
      cutoffEntryId: flow.cascade.all.cutoffEntryId,
    );

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppHeader(
        title: tr('nav.feed'),
        bottom: _FeedTotals(ledger: flow, money: money),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showQuickAddMenu(context, ref, today: flow.today),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? EmptyState(
              message: tr('feed.empty'),
              action: FilledButton(
                onPressed: () => openPaymentForm(context, date: flow.today),
                child: Text(tr('payment.add')),
              ),
            )
          : ReorderableListView.builder(
              scrollController: _scroll,
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) => _buildItem(
                context,
                items[index],
                index: index,
                density: density,
                money: money,
                locale: locale,
                today: flow.today,
                categories: categories.value ?? const <String, Category>{},
              ),
              onReorderItem: (int oldIndex, int newIndex) => _onReorder(
                items: items,
                oldIndex: oldIndex,
                insertAt: newIndex,
                orderMode: space.feedOrderMode,
              ),
            ),
    );
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
          onLongPress: () =>
              showRecordMenu(context, ref, record: record, today: today),
          dragHandle: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 18,
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

    if (record.isIncome) {
      if (next && record.amount == null) {
        // An amount is required before a receipt can be confirmed, or the
        // period's figures would stay uncomputable (spec 4.5).
        if (mounted) {
          openIncomeForm(context, incomeId: record.id, date: record.date);
        }
        return;
      }
      await repos.incomes.update(record.id, isPaid: Value<bool>(next));
      return;
    }
    await repos.payments.setPaid(record.id, isPaid: next);
  }

  Future<void> _delete(FeedRecord record) async {
    if (record.isMandatory && !await confirmMandatory(context)) return;
    final Repositories repos = ref.read(repositoriesProvider);

    if (record.isIncome) {
      await repos.incomes.softDelete(record.id);
    } else {
      await repos.payments.softDelete(record.id);
    }

    if (!mounted) return;
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
        if (row.record.isIncome) {
          await repos.incomes.update(
            id,
            expectedDate: Value<CalendarDate>(date),
          );
        } else {
          await repos.payments.update(id, dueDate: Value<CalendarDate>(date));
        }
    }
  }
}

/// Income and Free money for the current context, above the list (spec 4.5).
class _FeedTotals extends StatelessWidget implements PreferredSizeWidget {
  const _FeedTotals({required this.ledger, required this.money});

  final FlowLedger ledger;
  final MoneyFormat money;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final Decimal? free = ledger.freeCash;
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
            child: _TotalBlock(
              label: tr('feed.currentMoney'),
              value: ledger.available,
              money: money,
            ),
          ),
          Expanded(
            child: free == null
                ? StatColumn(
                    label: tr('dashboard.freeMoney'),
                    value: tr('dashboard.notCovered'),
                    valueColor: context.sage.danger,
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
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
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
