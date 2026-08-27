import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/dashboard/balance_sheet.dart';
import 'package:sielto/features/shell/app_header.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// Aggregated figures for the current context — no individual records
/// (spec 4.4). Flow has one continuous context, so there are no period arrows.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Space space = ref.space;
    final AsyncValue<FlowLedger> ledger = ref.watch(flowLedgerProvider);

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppHeader(title: space.title),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) =>
            EmptyState(message: tr('common.loadFailed')),
        data: (FlowLedger data) => _DashboardBody(space: space, ledger: data),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.space, required this.ledger});

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

    return ListView(
      padding: const EdgeInsets.all(SageSpace.gutter),
      children: <Widget>[
        _MainFigure(space: space, ledger: ledger, money: money, dates: dates),
        const SizedBox(height: SageSpace.md),
        _CascadeCard(ledger: ledger, money: money),
        const SizedBox(height: SageSpace.md),
        _TotalsCard(ledger: ledger, money: money),
        const SizedBox(height: SageSpace.md),
        _NearestIncomeCard(ledger: ledger, money: money, dates: dates),
      ],
    );
  }
}

/// The hero figure and the balance it is computed from (spec 4.6).
///
/// While everything is covered this is Free Money. Once it is not, the useful
/// answer is a date rather than a number — how far the money reaches.
class _MainFigure extends ConsumerWidget {
  const _MainFigure({
    required this.space,
    required this.ledger,
    required this.money,
    required this.dates,
  });

  final Space space;
  final FlowLedger ledger;
  final MoneyFormat money;
  final DateLabels dates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final Decimal? free = ledger.freeCash;
    final CalendarDate? lastDay = ledger.lastCoveredDay;

    return SageCard(
      padding: const EdgeInsets.all(SageSpace.lg),
      onTap: () => showBalanceSheet(context, ref, space: space, money: money),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                free != null
                    ? tr('dashboard.freeMoney')
                    : tr('dashboard.lasts'),
                style: text.labelSmall,
              ),
              const SizedBox(width: SageSpace.sm),
              CoverageDot(ledger.coverage),
            ],
          ),
          const SizedBox(height: SageSpace.sm),
          Text(
            free != null
                ? money.format(free)
                : (lastDay == null
                      ? money.format(ledger.cascade.all.finalBalance)
                      : dates.dayMonth(lastDay, reference: ledger.today)),
            style: text.displaySmall?.copyWith(
              color: free == null ? sage.danger : sage.ink,
            ),
          ),
          if (free == null) ...<Widget>[
            const SizedBox(height: SageSpace.xs),
            Text(
              tr(
                'dashboard.overspend',
                namedArgs: <String, String>{
                  'amount': money.format(-ledger.cascade.all.finalBalance),
                },
              ),
              style: text.bodySmall?.copyWith(color: sage.danger),
            ),
          ],
          const SizedBox(height: SageSpace.md),
          const Hairline(),
          const SizedBox(height: SageSpace.md),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(tr('dashboard.currentMoney'), style: text.labelSmall),
                    const SizedBox(height: SageSpace.xs),
                    Text(
                      money.format(ledger.available),
                      style: text.titleSmall,
                    ),
                    if (space.manualBalanceUpdatedAt != null)
                      Text(
                        tr(
                          'dashboard.balanceSetOn',
                          namedArgs: <String, String>{
                            'date': dates.short(
                              CalendarDate.fromDateTime(
                                space.manualBalanceUpdatedAt!.toUtc(),
                              ),
                            ),
                          },
                        ),
                        style: text.bodySmall,
                      ),
                    if (ledger.excludedCount > 0)
                      Text(
                        plural(
                          'balance.excludedFromWalker',
                          ledger.excludedCount,
                        ),
                        style: text.bodySmall,
                      ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 18, color: sage.inkLabel),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mandatory first, then everything: two answers from one walk (spec 4.4).
class _CascadeCard extends StatelessWidget {
  const _CascadeCard({required this.ledger, required this.money});

  final FlowLedger ledger;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Decimal? base = ledger.baseRemainder;
    final Decimal? net = ledger.freeCash;

    return SageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('dashboard.cascade'), style: text.titleSmall),
          const SizedBox(height: SageSpace.md),
          _CascadeRow(
            label: tr('dashboard.baseRemainder'),
            hint: tr('dashboard.baseRemainderHint'),
            value: base == null
                ? tr('dashboard.notCovered')
                : money.format(base),
            coverage: ledger.cascade.mandatory.coverage,
          ),
          const SizedBox(height: SageSpace.md),
          _CascadeRow(
            label: tr('dashboard.netFree'),
            hint: tr('dashboard.netFreeHint'),
            value: net == null ? tr('dashboard.notCovered') : money.format(net),
            coverage: ledger.cascade.all.coverage,
          ),
        ],
      ),
    );
  }
}

class _CascadeRow extends StatelessWidget {
  const _CascadeRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.coverage,
  });

  final String label;
  final String hint;
  final String value;
  final Coverage coverage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: text.bodyLarge),
              Text(hint, style: text.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: SageSpace.md),
        Text(
          value,
          style: text.titleSmall?.copyWith(
            color: CoverageDot.colorOf(context, coverage),
          ),
        ),
      ],
    );
  }
}

/// Planned, paid, still to pay (spec 4.4).
class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.ledger, required this.money});

  final FlowLedger ledger;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) => SageCard(
    child: Row(
      children: <Widget>[
        Expanded(
          child: StatColumn(
            label: tr('dashboard.planned'),
            value: money.format(ledger.totalPlanned),
          ),
        ),
        Expanded(
          child: StatColumn(
            label: tr('dashboard.paid'),
            value: money.format(ledger.totalPaid),
          ),
        ),
        Expanded(
          child: StatColumn(
            label: tr('dashboard.leftToPay'),
            value: money.format(ledger.totalRemaining),
          ),
        ),
      ],
    ),
  );
}

/// "In 5 days — Salary: 2 400 €" (spec 4.4). In Flow this is the next inflow
/// the user has entered; there is no schedule behind it until M4.
class _NearestIncomeCard extends StatelessWidget {
  const _NearestIncomeCard({
    required this.ledger,
    required this.money,
    required this.dates,
  });

  final FlowLedger ledger;
  final MoneyFormat money;
  final DateLabels dates;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Income? income = ledger.nearestIncome;

    if (income == null) {
      return SageCard(
        child: Text(tr('dashboard.noUpcomingIncome'), style: text.bodyMedium),
      );
    }

    final int days = ledger.today.daysUntil(income.expectedDate);
    final Decimal? amount = income.amount;

    return SageCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.south_west, size: 18, color: context.sage.accentStrong),
          const SizedBox(width: SageSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  days == 0
                      ? tr('dashboard.incomeToday')
                      : plural('dashboard.incomeInDays', days),
                  style: text.labelSmall,
                ),
                const SizedBox(height: SageSpace.xs),
                Text(income.title, style: text.bodyLarge),
              ],
            ),
          ),
          Text(
            amount == null ? tr('income.amountUnknown') : money.format(amount),
            style: text.titleSmall?.copyWith(
              color: amount == null
                  ? context.sage.inkLabel
                  : context.sage.accentStrong,
            ),
          ),
        ],
      ),
    );
  }
}
