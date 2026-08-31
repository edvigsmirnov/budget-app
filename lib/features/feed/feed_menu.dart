import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/feed/feed_model.dart';
import 'package:sielto/features/incomes/income_form_page.dart';
import 'package:sielto/features/payments/payment_form_page.dart';
import 'package:sielto/features/settings/holidays_page.dart';

enum _QuickAdd { payment, income, nonWorkingDay }

/// The FAB menu (spec 6.5).
///
/// A bubble beside the button rather than a sheet over the list: three short
/// items do not need half the screen, and the menu stays attached to the thing
/// that opened it.
///
/// The third item marks a non-working day. It is here as well as in Settings
/// because that is where the user already is when they notice a day is wrong
/// (spec 5.1.2, entry point 3).
Future<void> showQuickAddMenu(
  BuildContext context,
  WidgetRef ref, {
  required CalendarDate today,
  required GlobalKey anchorKey,
}) async {
  final _QuickAdd? choice = await showMenu<_QuickAdd>(
    context: context,
    position: _anchorOn(context, anchorKey),
    color: context.sage.card,
    // Material's default is a half-second grow from the top of the screen. The
    // menu belongs to the button under it, so it opens from there and it opens
    // at the speed the rest of the app moves at.
    popUpAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 140),
      reverseDuration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SageRadius.card),
    ),
    items: <PopupMenuEntry<_QuickAdd>>[
      PopupMenuItem<_QuickAdd>(
        value: _QuickAdd.payment,
        child: _MenuLine(
          icon: Icons.remove_circle_outline,
          label: tr('payment.add'),
        ),
      ),
      PopupMenuItem<_QuickAdd>(
        value: _QuickAdd.income,
        child: _MenuLine(
          icon: Icons.add_circle_outline,
          // Same record, different meaning: in Budget mode money arriving is
          // not income for a period, it is a payment into the fund (spec 4.8).
          label: ref.space.budgetMode == BudgetMode.budget
              ? tr('budget.topUp')
              : tr('income.add'),
        ),
      ),
      PopupMenuItem<_QuickAdd>(
        value: _QuickAdd.nonWorkingDay,
        child: _MenuLine(
          icon: Icons.event_busy_outlined,
          label: tr('holidays.markDay'),
        ),
      ),
    ],
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _QuickAdd.payment:
      await openPaymentForm(context, date: today);
    case _QuickAdd.income:
      await openIncomeForm(context, date: today);
    case _QuickAdd.nonWorkingDay:
      await markNonWorkingDay(context, ref, initial: today);
  }
}

/// The rectangle a popup opens from: the strip just above the anchor, in
/// overlay coordinates.
///
/// Anchoring on the button's own bounds let Material choose to grow downwards
/// off the bottom of the screen and then correct itself. Naming the space above
/// the button as the target means it only ever grows up, out of the button.
RelativeRect _anchorOn(BuildContext context, GlobalKey anchorKey) {
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final RenderBox? box =
      anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return RelativeRect.fill;

  final Offset topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final Offset bottomRight = box.localToGlobal(
    box.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  return RelativeRect.fromLTRB(
    topLeft.dx,
    0,
    overlay.size.width - bottomRight.dx,
    overlay.size.height - topLeft.dy + SageSpace.sm,
  );
}

/// One row of a popup menu: a glyph and a label, the same pairing the sheets
/// use so the two menus read alike.
class _MenuLine extends StatelessWidget {
  const _MenuLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Icon(icon, size: 20, color: context.sage.inkSecondary),
      const SizedBox(width: SageSpace.md),
      Text(label, style: Theme.of(context).textTheme.bodyLarge),
    ],
  );
}

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
