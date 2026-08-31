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
import 'package:sielto/features/dashboard/budget_settings.dart';
import 'package:sielto/features/dashboard/dashboard_parts.dart';
import 'package:sielto/features/overdue/overdue.dart';
import 'package:sielto/features/space/budget_ledger.dart';

/// The dashboard of a Budget Space (spec 4.8).
///
/// The question is "does this fit", and both halves of it are optional. With a
/// fund the hero figure is what is left of it; without one there is nothing to
/// fit into, so the screen reports what has been spent and says so plainly
/// rather than inventing a limit.
class BudgetDashboardBody extends ConsumerWidget {
  const BudgetDashboardBody({required this.space, super.key});

  final Space space;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BudgetLedger> ledger = ref.watch(budgetLedgerProvider);
    return ledger.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace _) =>
          EmptyState(message: tr('common.loadFailed')),
      data: (BudgetLedger data) => _Body(space: space, ledger: data),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.space, required this.ledger});

  final Space space;
  final BudgetLedger ledger;

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
        if (ledger.hasFund)
          MainFigure(
            label: tr('budget.remaining'),
            amount: ledger.remaining,
            coverage: ledger.coverage,
            money: money,
            overspend: ledger.cascade!.all.finalBalance,
            lastCoveredDay: ledger.lastCoveredDay,
            dates: dates,
            today: ledger.today,
            subtitle: tr(
              'budget.ofFund',
              namedArgs: <String, String>{
                'amount': money.format(ledger.available),
              },
            ),
            onTap: () => editBudgetFund(context, ref, ledger: ledger),
          )
        else
          _NoFundFigure(ledger: ledger, money: money),
        const SizedBox(height: SageSpace.md),
        OverdueChip(
          money: money,
          margin: const EdgeInsets.only(bottom: SageSpace.md),
        ),
        _DeadlineCard(ledger: ledger, dates: dates),
        const SizedBox(height: SageSpace.md),
        _FundCard(ledger: ledger, money: money),
        const SizedBox(height: SageSpace.md),
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

/// No fund was set, so there is nothing to fit into (spec 4.8).
///
/// What is spent is still a real figure and leads the screen; the invitation to
/// set a target sits under it rather than in place of it, because tracking
/// spend with no limit is a valid way to use the mode, not a half-finished
/// setup.
class _NoFundFigure extends ConsumerWidget {
  const _NoFundFigure({required this.ledger, required this.money});

  final BudgetLedger ledger;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: SageSpace.md),
          child: Column(
            children: <Widget>[
              Text(
                tr('budget.spent'),
                style: text.bodyMedium?.copyWith(color: context.sage.inkLabel),
              ),
              const SizedBox(height: SageSpace.xs),
              Text(money.format(ledger.totalPaid), style: text.displaySmall),
            ],
          ),
        ),
        DashedButton(
          label: tr('budget.setFund'),
          onTap: () => editBudgetFund(context, ref, ledger: ledger),
        ),
      ],
    );
  }
}

/// The event date and how far off it is (spec 4.8).
class _DeadlineCard extends ConsumerWidget {
  const _DeadlineCard({required this.ledger, required this.dates});

  final BudgetLedger ledger;
  final DateLabels dates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final CalendarDate? deadline = ledger.deadline;

    if (deadline == null) {
      return DashedButton(
        label: tr('budget.setDeadline'),
        onTap: () => editBudgetDeadline(context, ref, ledger: ledger),
      );
    }

    final int days = ledger.daysToDeadline!;
    return SageCard(
      onTap: () => editBudgetDeadline(context, ref, ledger: ledger),
      child: Row(
        children: <Widget>[
          Icon(
            ledger.deadlineIsHard ? Icons.lock_clock : Icons.event_outlined,
            size: 20,
            color: sage.inkLabel,
          ),
          const SizedBox(width: SageSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dates.dayMonth(deadline, reference: ledger.today),
                  style: text.bodyLarge,
                ),
                Text(
                  // Past, today, or a countdown — the three things a date can
                  // be when you are working towards it.
                  days < 0
                      ? plural('budget.daysAgo', -days)
                      : (days == 0
                            ? tr('budget.deadlineToday')
                            : plural('budget.daysLeft', days)),
                  style: text.bodySmall?.copyWith(
                    color: days < 0 ? sage.danger : sage.inkLabel,
                  ),
                ),
              ],
            ),
          ),
          if (ledger.deadlineIsHard)
            Text(
              tr('budget.hard'),
              style: text.labelSmall?.copyWith(color: sage.inkLabel),
            ),
          const SizedBox(width: SageSpace.sm),
          Icon(Icons.chevron_right, size: 18, color: sage.inkLabel),
        ],
      ),
    );
  }
}

/// What the fund is made of: the planned figure and what has been paid in.
class _FundCard extends ConsumerWidget {
  const _FundCard({required this.ledger, required this.money});

  final BudgetLedger ledger;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ledger.hasFund && ledger.contributions == Decimal.zero) {
      return const SizedBox.shrink();
    }
    return SageCard(
      onTap: () => editBudgetFund(context, ref, ledger: ledger),
      child: Column(
        children: <Widget>[
          StatRow(
            label: tr('budget.target'),
            value: ledger.target == null
                ? tr('budget.noTarget')
                : money.format(ledger.target!),
          ),
          const SizedBox(height: SageSpace.sm),
          StatRow(
            label: tr('budget.contributions'),
            value: money.format(ledger.contributions),
          ),
          const SizedBox(height: SageSpace.sm),
          const Hairline(),
          const SizedBox(height: SageSpace.sm),
          StatRow(
            label: tr('budget.fund'),
            value: money.format(ledger.available),
            emphasised: true,
          ),
        ],
      ),
    );
  }
}
