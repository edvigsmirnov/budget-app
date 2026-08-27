import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/income_repository.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/dialogs.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/periods/schedule_mapping.dart';

/// The regular incomes of a Space and their schedules (spec 5.1, 5.2).
///
/// The anchor badge is not decoration: anchors are what period boundaries are
/// computed from. Removing the last one is refused by the repository, and this
/// screen reports that refusal rather than pre-empting it.
class IncomeRulesPage extends ConsumerWidget {
  const IncomeRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Space space = ref.space;
    final AsyncValue<List<IncomeRecurrenceRule>> rules = ref.watch(
      incomeRulesProvider,
    );
    final MoneyFormat money = MoneyFormat(
      locale: context.locale.toString(),
      currencyCode: space.currencyCode,
    );

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(title: Text(tr('income.regularTitle'))),
      body: switch (rules) {
        AsyncData<List<IncomeRecurrenceRule>>(
          value: final List<IncomeRecurrenceRule> rows,
        )
            when rows.isEmpty =>
          EmptyState(message: tr('income.noRegular')),
        AsyncData<List<IncomeRecurrenceRule>>(
          value: final List<IncomeRecurrenceRule> rows,
        ) =>
          ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (BuildContext _, int _) => const Hairline(),
            itemBuilder: (BuildContext context, int index) => _RuleTile(
              rule: rows[index],
              money: money,
              isIncomeDriven: space.budgetMode == BudgetMode.incomeDriven,
              onDelete: () => _delete(context, ref, space, rows[index]),
              onToggleAnchor: (bool anchor) =>
                  _setAnchor(context, ref, space, rows[index], anchor),
            ),
          ),
        AsyncError<List<IncomeRecurrenceRule>>() => EmptyState(
          message: tr('common.loadFailed'),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Space space,
    IncomeRecurrenceRule rule,
  ) async {
    final bool confirmed = await confirmDialog(
      context,
      title: tr('income.deleteRuleTitle'),
      body: tr(
        'income.deleteRuleBody',
        namedArgs: <String, String>{'title': rule.title},
      ),
      confirmLabel: tr('common.delete'),
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref
          .read(repositoriesProvider)
          .incomeRules
          .deleteRule(rule.id, mode: space.budgetMode);
      ref.invalidate(periodRefreshProvider);
    } on LastAnchorRequired {
      // The guarantee lives in the repository, so this screen only reports it
      // (spec 4.7).
      if (context.mounted) _sayAnchorRequired(context);
    }
  }

  Future<void> _setAnchor(
    BuildContext context,
    WidgetRef ref,
    Space space,
    IncomeRecurrenceRule rule,
    bool anchor,
  ) async {
    try {
      await ref
          .read(repositoriesProvider)
          .incomeRules
          .setAnchor(rule.id, isAnchor: anchor, mode: space.budgetMode);
      ref.invalidate(periodRefreshProvider);
    } on LastAnchorRequired {
      if (context.mounted) _sayAnchorRequired(context);
    }
  }

  void _sayAnchorRequired(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr('income.lastAnchorRequired'))));
  }
}

/// Live rules of the open Space.
final StreamProvider<List<IncomeRecurrenceRule>> incomeRulesProvider =
    StreamProvider<List<IncomeRecurrenceRule>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) {
        return const Stream<List<IncomeRecurrenceRule>>.empty();
      }
      return ref.watch(repositoriesProvider).incomeRules.watchInSpace(space.id);
    });

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.rule,
    required this.money,
    required this.isIncomeDriven,
    required this.onDelete,
    required this.onToggleAnchor,
  });

  final IncomeRecurrenceRule rule;
  final MoneyFormat money;
  final bool isIncomeDriven;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleAnchor;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return ListTile(
      title: Row(
        children: <Widget>[
          Flexible(child: Text(rule.title, overflow: TextOverflow.ellipsis)),
          if (isIncomeDriven && rule.isAnchor) ...<Widget>[
            const SizedBox(width: SageSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: sage.accentTint,
                borderRadius: BorderRadius.circular(SageRadius.pill),
              ),
              child: Text(
                tr('income.anchorBadge'),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: sage.accentStrong),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        <String>[
          scheduleSummary(rule),
          if (rule.amount != null)
            money.format(rule.amount!)
          else
            tr('income.amountUnknown'),
        ].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isIncomeDriven)
            IconButton(
              tooltip: rule.isAnchor
                  ? tr('income.makeAdditional')
                  : tr('income.makeAnchor'),
              icon: Icon(
                rule.isAnchor ? Icons.push_pin : Icons.push_pin_outlined,
                size: 18,
                color: rule.isAnchor ? sage.accentStrong : sage.inkLabel,
              ),
              onPressed: () => onToggleAnchor(!rule.isAnchor),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: tr('common.delete'),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
