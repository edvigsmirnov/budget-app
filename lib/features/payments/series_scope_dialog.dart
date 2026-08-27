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
Future<SeriesScope> askSeriesScope(BuildContext context) async {
  final SeriesScope? answer = await showDialog<SeriesScope>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: context.sage.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SageRadius.card),
      ),
      title: Text(
        tr('series.title'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        tr('series.body'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
        for (final SeriesScope scope in <SeriesScope>[
          SeriesScope.thisOne,
          SeriesScope.allFuture,
          SeriesScope.wholeSeries,
        ])
          TextButton(
            onPressed: () => Navigator.of(context).pop(scope),
            child: Text(tr('series.${scope.name}')),
          ),
      ],
    ),
  );
  return answer ?? SeriesScope.cancelled;
}
