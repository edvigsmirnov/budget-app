import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/format/money_input.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/space/budget_ledger.dart';

/// The fund's planned figure (spec 4.8).
///
/// Optional, and clearable: emptying the field puts the Space back to tracking
/// spend with nothing to fit into, which is a way to use the mode rather than
/// an unfinished state.
Future<void> editBudgetFund(
  BuildContext context,
  WidgetRef ref, {
  required BudgetLedger ledger,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (BuildContext _) => _FundSheet(ledger: ledger),
);

class _FundSheet extends ConsumerStatefulWidget {
  const _FundSheet({required this.ledger});

  final BudgetLedger ledger;

  @override
  ConsumerState<_FundSheet> createState() => _FundSheetState();
}

class _FundSheetState extends ConsumerState<_FundSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.ledger.target?.toString() ?? '',
  );

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// Null for an empty field, which is the clear; the outer flag says which of
  /// the two an empty parse means.
  bool get _isValid {
    if (_amount.text.trim().isEmpty) return true;
    final Decimal? value = parseMoney(_amount.text);
    return value != null && value >= Decimal.zero;
  }

  Future<void> _save() async {
    if (!_isValid) return;
    final Decimal? value = _amount.text.trim().isEmpty
        ? null
        : parseMoney(_amount.text);
    await ref
        .read(repositoriesProvider)
        .periods
        .setBudgetTarget(widget.ledger.period.id, value);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final MoneyFormat money = MoneyFormat(
      locale: context.locale.toString(),
      currencyCode: ref.space.currencyCode,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: SageSpace.formGutter,
        right: SageSpace.formGutter,
        top: SageSpace.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SageSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('budget.fundSheetTitle'), style: text.titleMedium),
          const SizedBox(height: SageSpace.sm),
          Text(tr('budget.fundSheetBody'), style: text.bodyMedium),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('budget.target'),
            child: TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
              ],
              decoration: InputDecoration(
                suffixText: money.symbol,
                hintText: tr('budget.targetHint'),
              ),
              onSubmitted: (String _) => _save(),
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          FilledButton(
            onPressed: _isValid ? _save : null,
            child: Text(tr('common.save')),
          ),
        ],
      ),
    );
  }
}

/// The event date and whether it binds (spec 4.8).
Future<void> editBudgetDeadline(
  BuildContext context,
  WidgetRef ref, {
  required BudgetLedger ledger,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (BuildContext _) => _DeadlineSheet(ledger: ledger),
);

class _DeadlineSheet extends ConsumerStatefulWidget {
  const _DeadlineSheet({required this.ledger});

  final BudgetLedger ledger;

  @override
  ConsumerState<_DeadlineSheet> createState() => _DeadlineSheetState();
}

class _DeadlineSheetState extends ConsumerState<_DeadlineSheet> {
  late CalendarDate? _date = widget.ledger.deadline;
  late bool _isHard = widget.ledger.deadlineIsHard;

  Future<void> _pick() async {
    final CalendarDate start = _date ?? widget.ledger.today;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: start.toUtcMidnight(),
      firstDate: DateTime.utc(start.year - 5),
      lastDate: DateTime.utc(start.year + 10),
    );
    if (picked == null) return;
    setState(() => _date = CalendarDate.fromDateTime(picked));
  }

  Future<void> _save() async {
    await ref
        .read(repositoriesProvider)
        .periods
        .setDeadline(widget.ledger.period.id, date: _date, isHard: _isHard);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final DateLabels dates = DateLabels(context.locale.toString());

    return Padding(
      padding: EdgeInsets.only(
        left: SageSpace.formGutter,
        right: SageSpace.formGutter,
        top: SageSpace.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SageSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('budget.deadlineSheetTitle'), style: text.titleMedium),
          const SizedBox(height: SageSpace.sm),
          Text(tr('budget.deadlineSheetBody'), style: text.bodyMedium),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('budget.deadline'),
            child: InkWell(
              onTap: _pick,
              borderRadius: BorderRadius.circular(SageRadius.button),
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _date == null
                            ? tr('budget.noDeadline')
                            : dates.short(_date!),
                        style: text.bodyLarge?.copyWith(
                          color: _date == null ? sage.inkLabel : sage.ink,
                        ),
                      ),
                    ),
                    if (_date != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: tr('common.clear'),
                        onPressed: () => setState(() {
                          _date = null;
                          _isHard = false;
                        }),
                      ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: sage.inkLabel,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: SageSpace.md),
          // A soft deadline is a marker and never blocks input; a hard one
          // refuses records dated after it (spec 4.8).
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isHard,
            onChanged: _date == null
                ? null
                : (bool value) => setState(() => _isHard = value),
            title: Text(tr('budget.hardDeadline'), style: text.bodyLarge),
            subtitle: Text(
              tr('budget.hardDeadlineHint'),
              style: text.bodySmall,
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          FilledButton(onPressed: _save, child: Text(tr('common.save'))),
        ],
      ),
    );
  }
}
