import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/dashboard/balance_sheet.dart';
import 'package:sielto/features/dashboard/dashboard_parts.dart';
import 'package:sielto/features/dashboard/flow_dashboard.dart';
import 'package:sielto/features/dashboard/period_dashboard.dart';
import 'package:sielto/features/shell/app_header.dart';

/// Aggregated figures for the current context — no individual records
/// (spec 4.4).
///
/// The three modes disagree about what the available sum is and where the
/// period ends, and about nothing else; that disagreement is the whole of the
/// branch below.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Space space = ref.space;

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppHeader(title: space.title),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SageSpace.gutter,
              0,
              SageSpace.gutter,
              SageSpace.sm,
            ),
            child: ModeBadge(tr('mode.${space.budgetMode.name}.name')),
          ),
          Expanded(
            child: switch (space.budgetMode) {
              BudgetMode.flow => FlowDashboardBody(space: space),
              BudgetMode.incomeDriven => PeriodDashboardBody(space: space),
              // Budget mode is M5; until then its Spaces show the Flow view,
              // which at least computes honestly from what has been entered.
              BudgetMode.budget => FlowDashboardBody(space: space),
            },
          ),
        ],
      ),
    );
  }
}

/// The balance snapshot Flow puts under its main figure (spec 4.6).
class BalanceFooter extends ConsumerWidget {
  const BalanceFooter({
    required this.space,
    required this.available,
    required this.excludedCount,
    required this.money,
    required this.dates,
    super.key,
  });

  final Space space;
  final Decimal available;
  final int excludedCount;
  final MoneyFormat money;
  final DateLabels dates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final DateTime? setAt = space.manualBalanceUpdatedAt;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tr('dashboard.currentMoney'), style: text.labelSmall),
              const SizedBox(height: SageSpace.xs),
              Text(money.format(available), style: text.titleSmall),
              if (setAt != null)
                Text(
                  tr(
                    'dashboard.balanceSetOn',
                    namedArgs: <String, String>{
                      'date': dates.short(
                        CalendarDate.fromDateTime(setAt.toUtc()),
                      ),
                    },
                  ),
                  style: text.bodySmall,
                ),
              if (excludedCount > 0)
                Text(
                  plural('balance.excludedFromWalker', excludedCount),
                  style: text.bodySmall,
                ),
            ],
          ),
        ),
        Icon(Icons.edit_outlined, size: 20, color: sage.inkLabel),
      ],
    );
  }
}

/// Opens the "set current balance" sheet for [space].
Future<void> editBalance(
  BuildContext context,
  WidgetRef ref, {
  required Space space,
  required MoneyFormat money,
}) => showBalanceSheet(context, ref, space: space, money: money);
