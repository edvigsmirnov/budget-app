import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/dashboard/dashboard_parts.dart';
import 'package:sielto/features/dashboard/period_selector.dart';
import 'package:sielto/features/incomes/income_form_page.dart';
import 'package:sielto/features/incomes/income_rules_page.dart';
import 'package:sielto/features/space/period_ledger.dart';

/// The dashboard of a Regular-income Space (spec 4.7).
///
/// Three states, and the two that are not the happy one are the point: a Space
/// with no anchor income yet is a valid, permanent state rather than an error,
/// and an anchor whose amount is unknown gets an honest "cannot compute this"
/// instead of a fabricated figure.
class PeriodDashboardBody extends ConsumerWidget {
  const PeriodDashboardBody({required this.space, super.key});

  final Space space;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<IncomeRecurrenceRule> rules =
        ref.watch(incomeRulesProvider).value ?? const <IncomeRecurrenceRule>[];
    final bool hasAnchor = rules.any((IncomeRecurrenceRule r) => r.isAnchor);

    if (!hasAnchor) return const _NoAnchorState();

    final AsyncValue<PeriodLedger> ledger = ref.watch(periodLedgerProvider);
    return ledger.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) =>
          EmptyState(message: tr('common.loadFailed')),
      data: (PeriodLedger data) => _PeriodBody(space: space, ledger: data),
    );
  }
}

/// A Space with no regular income yet.
///
/// Not an error and not a blocked screen: the Feed and Calendar keep working,
/// and the hint about the other two modes suggests without pushing (spec 4.7).
class _NoAnchorState extends StatelessWidget {
  const _NoAnchorState();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SageSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.savings_outlined,
              size: 40,
              color: context.sage.inkLabel,
            ),
            const SizedBox(height: SageSpace.lg),
            Text(
              tr('period.noAnchorTitle'),
              textAlign: TextAlign.center,
              style: text.titleSmall,
            ),
            const SizedBox(height: SageSpace.sm),
            Text(
              tr('period.noAnchorBody'),
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
            const SizedBox(height: SageSpace.lg),
            FilledButton(
              onPressed: () => openIncomeForm(context),
              child: Text(tr('income.add')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodBody extends ConsumerWidget {
  const _PeriodBody({required this.space, required this.ledger});

  final Space space;
  final PeriodLedger ledger;

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
        const PeriodSelector(),
        const SizedBox(height: SageSpace.sm),
        if (!ledger.isComputable)
          _FloatingAnchorCard(ledger: ledger, money: money)
        else ...<Widget>[
          MainFigureCard(
            label: tr('dashboard.freeMoney'),
            amount: ledger.freeCash,
            coverage: ledger.coverage,
            money: money,
            overspend: ledger.cascade!.all.finalBalance,
            lastCoveredDay: ledger.lastCoveredDay,
            dates: dates,
            today: ledger.today,
          ),
          const SizedBox(height: SageSpace.md),
          CascadeCard(
            baseRemainder: ledger.baseRemainder,
            netFree: ledger.freeCash,
            baseCoverage: ledger.cascade!.mandatory.coverage,
            netCoverage: ledger.cascade!.all.coverage,
            money: money,
          ),
        ],
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

/// An anchor income whose amount is not known yet (spec 4.7).
///
/// The expense side is fully computed and shown; the remainder is not, and the
/// screen says which rather than printing a number that would be wrong.
class _FloatingAnchorCard extends StatelessWidget {
  const _FloatingAnchorCard({required this.ledger, required this.money});

  final PeriodLedger ledger;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Income? income = ledger.nearestIncome;

    return SageCard(
      padding: const EdgeInsets.all(SageSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('period.amountUnknownTitle'), style: text.titleSmall),
          const SizedBox(height: SageSpace.sm),
          Text(tr('period.amountUnknownBody'), style: text.bodySmall),
          const SizedBox(height: SageSpace.md),
          const Hairline(),
          const SizedBox(height: SageSpace.md),
          Row(
            children: <Widget>[
              Expanded(
                child: StatColumn(
                  label: tr('dashboard.planned'),
                  value: money.format(ledger.totalPlanned),
                ),
              ),
              if (income != null)
                TextButton(
                  onPressed: () => openIncomeForm(context, incomeId: income.id),
                  child: Text(tr('period.setAmount')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Free money for the period, or the day the money runs out.
Decimal? freeCashOf(PeriodLedger ledger) => ledger.freeCash;
