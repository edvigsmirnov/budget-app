import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/dashboard/dashboard_page.dart';
import 'package:sielto/features/dashboard/dashboard_parts.dart';
import 'package:sielto/features/dashboard/projection_chart.dart';
import 'package:sielto/features/incomes/income_form_page.dart';
import 'package:sielto/features/overdue/overdue.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The dashboard of a Flow Space (spec 4.6).
///
/// Flow has one open context and no periods, so the question it answers is
/// "how far does the money reach", and the projection under the figure is that
/// answer drawn out day by day.
class FlowDashboardBody extends ConsumerWidget {
  const FlowDashboardBody({required this.space, super.key});

  final Space space;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FlowLedger> ledger = ref.watch(flowLedgerProvider);
    return ledger.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) =>
          EmptyState(message: tr('common.loadFailed')),
      data: (FlowLedger data) => _Body(space: space, ledger: data),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.space, required this.ledger});

  final Space space;
  final FlowLedger ledger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String locale = context.locale.toString();
    final MoneyFormat money = MoneyFormat(
      locale: locale,
      currencyCode: space.currencyCode,
    );
    final DateLabels dates = DateLabels(locale);
    final DailyProjection projection = projectDays(
      available: ledger.available,
      entries: ledger.entries,
      from: ledger.today,
    );

    return ListView(
      padding: const EdgeInsets.all(SageSpace.gutter),
      children: <Widget>[
        MainFigure(
          label: tr('dashboard.freeMoney'),
          amount: ledger.freeCash,
          coverage: ledger.coverage,
          money: money,
          overspend: ledger.cascade.all.finalBalance,
          lastCoveredDay: ledger.lastCoveredDay,
          dates: dates,
          today: ledger.today,
          // The date the money runs out means nothing without the rate it was
          // computed at (spec 4.6).
          subtitle: tr(
            'dashboard.atAverageSpend',
            namedArgs: <String, String>{
              'amount': money.format(projection.averageSpendPerDay),
            },
          ),
          onTap: () => editBalance(context, ref, space: space, money: money),
        ),
        const SizedBox(height: SageSpace.md),
        // What is already late, before the projection of what is ahead.
        OverdueChip(
          money: money,
          margin: const EdgeInsets.only(bottom: SageSpace.md),
        ),
        ProjectionCard(
          projection: projection,
          money: money,
          dates: dates,
          today: ledger.today,
        ),
        const SizedBox(height: SageSpace.md),
        Row(
          children: <Widget>[
            Expanded(
              child: _FigureTile(
                value: money.format(ledger.available),
                label: tr('dashboard.currentMoney'),
                // When the figure was last true, so a stale balance shows as
                // stale (spec 4.6). It belongs on the figure rather than in a
                // block of its own underneath, which said the same number
                // twice in a row.
                caption: _balanceCaption(space, ledger, dates),
                // The balance is Flow's one hand-entered number, so the tile
                // showing it is also where it is edited.
                onTap: () =>
                    editBalance(context, ref, space: space, money: money),
              ),
            ),
            const SizedBox(width: SageSpace.sm),
            Expanded(
              child: _FigureTile(
                value: money.format(projection.averageSpendPerDay),
                label: tr('dashboard.perDay'),
              ),
            ),
          ],
        ),
        const SizedBox(height: SageSpace.md),
        NearestIncomeCard(
          income: ledger.nearestIncome,
          today: ledger.today,
          money: money,
          onTap: ledger.nearestIncome == null
              ? null
              : () =>
                    openIncomeForm(context, incomeId: ledger.nearestIncome!.id),
        ),
        const SizedBox(height: SageSpace.md),
        // No cascade here. Spec 4.6 mentions one, but Flow's question is how
        // far the money reaches and the answer is already the date above and
        // the Feed's cutoff line; splitting the same walk into mandatory and
        // everything adds a second reading of it and no new fact. It stays in
        // income-driven mode, where the cycle's base remainder is a figure of
        // its own.
        TotalsCard(
          planned: ledger.totalPlanned,
          paid: ledger.totalPaid,
          remaining: ledger.totalRemaining,
          money: money,
        ),
      ],
    );
  }
}

/// When the hand-entered balance was last true, and how many records the walk
/// left out (spec 4.6).
String? _balanceCaption(Space space, FlowLedger ledger, DateLabels dates) {
  final DateTime? setAt = space.manualBalanceUpdatedAt;
  return <String>[
    if (setAt != null)
      tr(
        'dashboard.balanceSetOn',
        namedArgs: <String, String>{
          'date': dates.short(CalendarDate.fromDateTime(setAt.toUtc())),
        },
      ),
    if (ledger.excludedCount > 0)
      plural('balance.excludedFromWalker', ledger.excludedCount),
  ].join(' · ').ifEmptyNull();
}

extension on String {
  String? ifEmptyNull() => isEmpty ? null : this;
}

/// One figure on a card, amount over label (design section 4.6).
///
/// The inverse of the label-first blocks elsewhere: these two sit under the
/// projection as its readings, so the number leads and the word explains it.
class _FigureTile extends StatelessWidget {
  const _FigureTile({
    required this.value,
    required this.label,
    this.caption,
    this.onTap,
  });

  final String value;
  final String label;

  /// A third line, for what qualifies the figure rather than names it.
  final String? caption;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SageCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SageSpace.sm,
        vertical: SageSpace.md,
      ),
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: context.sage.inkLabel),
          ),
          if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: context.sage.inkLabel),
            ),
        ],
      ),
    );
  }
}

/// Free money, or null once the money stops covering everything.
Decimal? flowFreeCash(FlowLedger ledger) => ledger.freeCash;
