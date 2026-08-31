import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/dashboard/balance_sheet.dart';
import 'package:sielto/features/dashboard/budget_dashboard.dart';
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
              BudgetMode.budget => BudgetDashboardBody(space: space),
            },
          ),
        ],
      ),
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
