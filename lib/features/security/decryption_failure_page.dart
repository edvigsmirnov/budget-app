import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shown when the database file is present but its key is not.
///
/// The alternative would be a crash or an endless spinner over unreadable
/// data; this states plainly what happened and offers the three ways out
/// (spec 2.2). Only "Start over" works in M1 — the other two need the Recovery
/// Key and the backup container, which arrive in M7.
class DecryptionFailurePage extends StatelessWidget {
  const DecryptionFailurePage({required this.onStartOver, super.key});

  final Future<void> Function() onStartOver;

  Future<void> _confirm(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('decryption.confirmTitle'.tr()),
        content: Text('decryption.confirmBody'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('decryption.confirmAction'.tr()),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await onStartOver();
  }

  @override
  Widget build(BuildContext context) {
    final SageColors c = context.sage;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SageSpace.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: SageSpace.md,
                children: <Widget>[
                  Icon(Icons.lock_outline, size: 44, color: c.inkSecondary),
                  const SizedBox(height: SageSpace.xs),
                  Text(
                    'decryption.title'.tr(),
                    style: text.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'decryption.body'.tr(),
                    style: text.bodyMedium?.copyWith(color: c.inkSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SageSpace.md),

                  // Both land in M7. Shown disabled rather than hidden: the
                  // recovery path is the point of the envelope scheme, and a
                  // user who has a Recovery Key should see it is coming.
                  _Unavailable(label: 'decryption.enterRecoveryKey'.tr()),
                  _Unavailable(label: 'decryption.restoreFromBackup'.tr()),

                  const SizedBox(height: SageSpace.sm),
                  OutlinedButton(
                    onPressed: () => _confirm(context),
                    style: OutlinedButton.styleFrom(foregroundColor: c.danger),
                    child: Text('decryption.startOver'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final SageColors c = context.sage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton(onPressed: null, child: Text(label)),
        Padding(
          padding: const EdgeInsets.only(top: SageSpace.xs),
          child: Text(
            'decryption.notYetAvailable'.tr(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: c.inkLabel),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
