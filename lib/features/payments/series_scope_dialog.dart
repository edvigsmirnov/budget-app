import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// How far an edit to one occurrence of a repeating payment reaches
/// (spec 6.3).
enum SeriesScope {
  /// This occurrence only — the common case of a single month differing.
  thisOne,

  /// This one and every later occurrence, leaving paid rows alone.
  allFuture,

  /// Every occurrence, past included, again leaving paid rows alone.
  wholeSeries,

  cancelled,
}

/// Asked whenever a record that belongs to a series is saved.
Future<SeriesScope> askSeriesScope(BuildContext context) =>
    _askScope(context, title: tr('series.title'), body: tr('series.body'));

/// Asked before removing a repeating payment.
///
/// Only two answers: the whole thing, or everything from this occurrence on.
/// "This one only" is the app bar's delete, and offering it twice under
/// different words is how a user ends up deleting the wrong thing.
Future<SeriesScope> askSeriesDeleteScope(BuildContext context) => _askScope(
  context,
  title: tr('series.deleteTitle'),
  body: tr('series.deleteBody'),
  scopes: const <SeriesScope>[SeriesScope.allFuture, SeriesScope.wholeSeries],
  isDestructive: true,
);

Future<SeriesScope> _askScope(
  BuildContext context, {
  required String title,
  required String body,
  List<SeriesScope> scopes = const <SeriesScope>[
    SeriesScope.thisOne,
    SeriesScope.allFuture,
    SeriesScope.wholeSeries,
  ],
  bool isDestructive = false,
}) async {
  final SeriesScope? answer = await showDialog<SeriesScope>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: context.sage.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SageRadius.card),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      content: Text(body, style: Theme.of(context).textTheme.bodyMedium),
      actions: <Widget>[
        for (final SeriesScope scope in scopes)
          TextButton(
            onPressed: () => Navigator.of(context).pop(scope),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: context.sage.danger)
                : null,
            child: Text(tr('series.${scope.name}')),
          ),
      ],
    ),
  );
  return answer ?? SeriesScope.cancelled;
}
