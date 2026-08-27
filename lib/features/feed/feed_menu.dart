import 'package:budget_app/app/providers.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:budget_app/features/feed/feed_model.dart';
import 'package:budget_app/features/incomes/income_form_page.dart';
import 'package:budget_app/features/payments/payment_form_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The FAB menu (spec 6.5).
///
/// "Mark a non-working day" is the third item in the spec; it belongs to the
/// holiday work in M4 and is absent here rather than shown inert.
Future<void> showQuickAddMenu(
  BuildContext context,
  WidgetRef ref, {
  required CalendarDate today,
}) => showModalBottomSheet<void>(
  context: context,
  builder: (BuildContext sheetContext) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.remove_circle_outline),
          title: Text(tr('payment.add')),
          onTap: () {
            Navigator.of(sheetContext).pop();
            openPaymentForm(context, date: today);
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: Text(tr('income.add')),
          onTap: () {
            Navigator.of(sheetContext).pop();
            openIncomeForm(context, date: today);
          },
        ),
      ],
    ),
  ),
);

/// The long-press menu on an existing row (spec 6.5).
///
/// All four items only prefill a date — none of them reorders anything. The
/// list stays chronological, and position within a day is changed by dragging.
Future<void> showRecordMenu(
  BuildContext context,
  WidgetRef ref, {
  required FeedRecord record,
  required CalendarDate today,
}) => showModalBottomSheet<void>(
  context: context,
  builder: (BuildContext sheetContext) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SageSpace.gutter,
            SageSpace.md,
            SageSpace.gutter,
            SageSpace.sm,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              record.title,
              style: Theme.of(sheetContext).textTheme.titleSmall,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.arrow_upward),
          title: Text(tr('feed.addBefore')),
          onTap: () {
            Navigator.of(sheetContext).pop();
            _addOn(context, record, record.date.addDays(-1));
          },
        ),
        ListTile(
          leading: const Icon(Icons.arrow_downward),
          title: Text(tr('feed.addAfter')),
          onTap: () {
            Navigator.of(sheetContext).pop();
            _addOn(context, record, record.date.addDays(1));
          },
        ),
        if (!record.isIncome) ...<Widget>[
          ListTile(
            leading: const Icon(Icons.content_copy_outlined),
            title: Text(tr('feed.duplicateBefore')),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _duplicate(context, ref, record, record.date.addDays(-1));
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: Text(tr('feed.duplicateAfter')),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _duplicate(context, ref, record, record.date.addDays(1));
            },
          ),
        ],
      ],
    ),
  ),
);

/// An empty form on the neighbouring day. Only the date is carried over
/// (spec 6.5).
void _addOn(BuildContext context, FeedRecord record, CalendarDate date) {
  if (record.isIncome) {
    openIncomeForm(context, date: date);
    return;
  }
  openPaymentForm(context, date: date);
}

/// A full copy on the neighbouring day, opened unsaved so the one field that
/// differs — usually the amount — can be corrected before it exists.
Future<void> _duplicate(
  BuildContext context,
  WidgetRef ref,
  FeedRecord record,
  CalendarDate date,
) async {
  final Payment? source = await ref
      .read(repositoriesProvider)
      .payments
      .byId(record.id);
  if (source == null || !context.mounted) return;
  await openPaymentForm(
    context,
    date: date,
    draft: PaymentDraft.from(source, date),
  );
}
