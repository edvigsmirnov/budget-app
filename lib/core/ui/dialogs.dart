import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// A yes/no confirmation (spec, Sage section 17).
///
/// Returns false when dismissed, so a tap outside is always the safe answer.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool isDestructive = false,
}) async {
  final bool? answer = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final SageColors sage = context.sage;
      return AlertDialog(
        backgroundColor: sage.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SageRadius.card),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        content: Text(body, style: Theme.of(context).textTheme.bodyMedium),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? sage.danger : sage.accentStrong,
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return answer ?? false;
}

/// The guard on mandatory payments (spec 6.2). Variable payments skip it: they
/// are meant to be moved and dropped freely.
Future<bool> confirmMandatory(BuildContext context) => confirmDialog(
  context,
  title: tr('payment.mandatoryConfirmTitle'),
  body: tr('payment.mandatoryConfirmBody'),
  confirmLabel: tr('common.continue'),
);

/// The undo window after a soft delete (spec 7).
///
/// The delete has already happened when this appears — the snackbar only
/// offers a short window to reverse it, and leaving the screen early simply
/// ends that window.
void showUndoSnackbar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: tr('common.undo'), onPressed: onUndo),
      ),
    );
}
