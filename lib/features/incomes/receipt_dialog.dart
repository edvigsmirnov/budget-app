import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/incomes/income_form_page.dart' show DateField;

/// Confirms when an income actually arrived (spec 5.4).
///
/// The expected date is a forecast; this is the fact. They are usually the
/// same, so the dialog opens with the expected date filled in and one tap
/// accepts it — the correction is there for the day the salary comes early.
///
/// Returns null when the dialog is dismissed, which leaves the record unmarked.
Future<CalendarDate?> askReceiptDate(
  BuildContext context, {
  required CalendarDate expected,
}) => showDialog<CalendarDate>(
  context: context,
  builder: (BuildContext context) => _ReceiptDialog(expected: expected),
);

class _ReceiptDialog extends StatefulWidget {
  const _ReceiptDialog({required this.expected});

  final CalendarDate expected;

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  late CalendarDate _actual = widget.expected;

  Future<void> _pick() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _actual.toUtcMidnight(),
      firstDate: DateTime.utc(_actual.year - 2),
      lastDate: DateTime.utc(_actual.year + 2),
    );
    if (picked != null) {
      setState(() => _actual = CalendarDate.fromDateTime(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final DateLabels dates = DateLabels(context.locale.toString());

    return AlertDialog(
      backgroundColor: sage.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SageRadius.card),
      ),
      title: Text(
        tr('income.markReceived'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tr('income.fieldActualDate'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SageSpace.sm),
          DateField(label: dates.dayMonth(_actual), onTap: _pick),
          if (_actual != widget.expected) ...<Widget>[
            const SizedBox(height: SageSpace.sm),
            Text(
              tr('income.actualDateNote'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('common.cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_actual),
          child: Text(tr('common.save')),
        ),
      ],
    );
  }
}
