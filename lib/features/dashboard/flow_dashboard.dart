import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/dashboard/dashboard_page.dart';
import 'package:sielto/features/dashboard/dashboard_parts.dart';
import 'package:sielto/features/dashboard/projection_chart.dart';
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
          onTap: () => editBalance(context, ref, space: space, money: money),
        ),
        const SizedBox(height: SageSpace.md),
        SageCard(
          onTap: () => editBalance(context, ref, space: space, money: money),
          child: BalanceFooter(
            space: space,
            available: ledger.available,
            excludedCount: ledger.excludedCount,
            money: money,
            dates: dates,
          ),
        ),
        const SizedBox(height: SageSpace.md),
        ProjectionCard(
          projection: projection,
          money: money,
          dates: dates,
          today: ledger.today,
        ),
        const SizedBox(height: SageSpace.md),
        CascadeCard(
          available: ledger.available,
          baseRemainder: ledger.baseRemainder,
          baseCoverage: ledger.cascade.mandatory.coverage,
          money: money,
        ),
        const SizedBox(height: SageSpace.md),
        TotalsCard(
          planned: ledger.totalPlanned,
          paid: ledger.totalPaid,
          remaining: ledger.totalRemaining,
          money: money,
        ),
        const SizedBox(height: SageSpace.md),
        NearestIncomeCard(
          income: ledger.nearestIncome,
          today: ledger.today,
          money: money,
        ),
      ],
    );
  }
}

/// Free money, or null once the money stops covering everything.
Decimal? flowFreeCash(FlowLedger ledger) => ledger.freeCash;
