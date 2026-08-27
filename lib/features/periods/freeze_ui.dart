import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/freeze_guard.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/period/freeze.dart';
import 'package:sielto/features/periods/freeze_providers.dart';

/// Runs a write that a frozen period may refuse, and reports the refusal.
///
/// The screens disable what they can, but the guard is the authority and a
/// period can freeze while a form is open. Catching it here turns the last
/// case into a message instead of a crash.
Future<bool> guardFreeze(
  BuildContext context,
  Future<void> Function() write,
) async {
  try {
    await write();
    return true;
  } on PeriodFrozen {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(tr('freeze.refused'))));
    }
    return false;
  }
}

/// The state of the period a screen is showing (spec 5.5).
///
/// Nothing while it is open, a warning two days before it closes, and a
/// standing notice once it has. The warning is the point of the rule: a wrong
/// figure is still correctable while it shows.
class FreezeBanner extends ConsumerWidget {
  const FreezeBanner({required this.period, super.key});

  final BudgetPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FreezeLookup lookup = ref.watch(freezeLookupProvider);
    final FreezeState state = lookup.stateOf(period);
    if (state == FreezeState.open) return const SizedBox.shrink();

    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final bool frozen = state == FreezeState.frozen;
    final Color ink = frozen ? sage.inkSecondary : sage.warning;

    // Only the Space creator may reopen a closed period (spec 5.5, level 3).
    final Space? space = ref.watch(currentSpaceProvider);
    final bool isOwner =
        space != null && space.ownerId == ref.watch(userIdProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: SageSpace.md),
      child: SageCard(
        color: frozen ? sage.card : sage.warningTint,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              frozen ? Icons.lock_outline : Icons.schedule,
              size: 18,
              color: ink,
            ),
            const SizedBox(width: SageSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    frozen ? tr('freeze.frozenTitle') : tr('freeze.soonTitle'),
                    style: text.labelLarge?.copyWith(color: ink),
                  ),
                  const SizedBox(height: SageSpace.xs),
                  Text(
                    frozen
                        ? tr('freeze.frozenBody')
                        : plural(
                            'freeze.soonBody',
                            lookup.daysUntilFreeze(period),
                          ),
                    style: text.bodySmall,
                  ),
                  if (frozen && isOwner) ...<Widget>[
                    const SizedBox(height: SageSpace.xs),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => _unfreeze(context, ref),
                        child: Text(tr('freeze.unfreeze')),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unfreeze(BuildContext context, WidgetRef ref) async {
    final String? reason = await askUnfreezeReason(context);
    if (reason == null) return;

    final Repositories repos = ref.read(repositoriesProvider);
    const FreezeEvaluator evaluator = FreezeEvaluator();
    await repos.periods.unfreeze(
      period.id,
      evaluator.unfreezeExpiry(ref.read(spaceClockProvider).nowUtc()),
      reason,
    );
  }
}

/// The reason a period was reopened, which the spec requires and stores
/// (spec 5.5). Returns null when the dialog is dismissed.
Future<String?> askUnfreezeReason(BuildContext context) async {
  final TextEditingController reason = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _UnfreezeDialog(controller: reason),
    );
  } finally {
    reason.dispose();
  }
}

class _UnfreezeDialog extends StatefulWidget {
  const _UnfreezeDialog({required this.controller});

  final TextEditingController controller;

  @override
  State<_UnfreezeDialog> createState() => _UnfreezeDialogState();
}

class _UnfreezeDialogState extends State<_UnfreezeDialog> {
  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final String reason = widget.controller.text.trim();

    return AlertDialog(
      backgroundColor: sage.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SageRadius.card),
      ),
      title: Text(
        tr('freeze.unfreezeTitle'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tr('freeze.unfreezeBody'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: SageSpace.md),
          TextField(
            controller: widget.controller,
            autofocus: true,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: tr('freeze.reasonHint')),
            onChanged: (String _) => setState(() {}),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('common.cancel')),
        ),
        TextButton(
          // A reason is required, not optional: the record of why a closed
          // period was reopened is the whole safeguard (spec 5.5).
          onPressed: reason.isEmpty
              ? null
              : () => Navigator.of(context).pop(reason),
          child: Text(tr('freeze.unfreeze')),
        ),
      ],
    );
  }
}

/// The read-only notice a form shows in place of its protected fields.
class FreezeNotice extends StatelessWidget {
  const FreezeNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return Padding(
      padding: const EdgeInsets.only(bottom: SageSpace.md),
      child: SageCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.lock_outline, size: 18, color: sage.inkLabel),
            const SizedBox(width: SageSpace.sm),
            Expanded(
              child: Text(
                tr('freeze.formNotice'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
