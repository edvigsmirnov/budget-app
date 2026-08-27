import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// How far a change to one occurrence's amount reaches (spec 5.4).
///
/// Deliberately two options rather than the payments' three: an income series
/// is driven by a rule with one amount, so "this occurrence" and "the salary
/// from now on" are the only distinctions that mean anything.
enum IncomeScope {
  /// A one-off deviation — a different bonus this month — leaving the rule
  /// alone.
  thisOne,

  /// The salary changed: the rule and every unreceived occurrence follow.
  allFuture,

  cancelled,
}

Future<IncomeScope> askIncomeScope(BuildContext context) async {
  final IncomeScope? answer = await showDialog<IncomeScope>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: context.sage.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SageRadius.card),
      ),
      title: Text(
        tr('incomeScope.title'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        tr('incomeScope.body'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(IncomeScope.cancelled),
          child: Text(tr('common.cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(IncomeScope.thisOne),
          child: Text(tr('incomeScope.thisOne')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(IncomeScope.allFuture),
          child: Text(tr('incomeScope.allFuture')),
        ),
      ],
    ),
  );
  return answer ?? IncomeScope.cancelled;
}
