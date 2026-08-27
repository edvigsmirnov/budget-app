import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/format/money_input.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/incomes/schedule_editor.dart';

/// Editing a regular income as a whole (spec 5.4).
///
/// The occurrence form edits one month; this edits the rule behind all of
/// them. The two are separate on purpose — "the salary was different in March"
/// and "my salary changed" are different statements, and only the second
/// should reach next year.
Future<void> openIncomeRuleForm(
  BuildContext context, {
  required IncomeRecurrenceRule rule,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (BuildContext _) => IncomeRuleFormPage(rule: rule),
  ),
);

class IncomeRuleFormPage extends ConsumerStatefulWidget {
  const IncomeRuleFormPage({required this.rule, super.key});

  final IncomeRecurrenceRule rule;

  @override
  ConsumerState<IncomeRuleFormPage> createState() => _IncomeRuleFormPageState();
}

class _IncomeRuleFormPageState extends ConsumerState<IncomeRuleFormPage> {
  late final TextEditingController _title = TextEditingController(
    text: widget.rule.title,
  );
  late final TextEditingController _amount = TextEditingController(
    text: widget.rule.amount?.toString() ?? '',
  );

  late ScheduleDraft _schedule = _draftOf(widget.rule);
  bool _saving = false;

  static ScheduleDraft _draftOf(IncomeRecurrenceRule rule) => ScheduleDraft(
    type: rule.scheduleType,
    fixedDay: rule.fixedDay ?? 1,
    ordinal: rule.weekdayOrdinal ?? WeekdayOrdinal.first,
    weekday: rule.weekdayDay ?? Weekday.monday,
    rangeStart: rule.dateRangeStart ?? 23,
    rangeEnd: rule.dateRangeEnd ?? 25,
    boundaryAnchor: rule.boundaryAnchor ?? BoundaryAnchor.start,
    boundaryCount: rule.boundaryCount ?? 3,
  );

  @override
  void initState() {
    super.initState();
    for (final TextEditingController c in <TextEditingController>[
      _title,
      _amount,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Decimal? get _parsedAmount {
    final Decimal? value = parseMoney(_amount.text);
    if (value == null || value <= Decimal.zero) return null;
    return value;
  }

  bool get _amountIsWellFormed =>
      _amount.text.trim().isEmpty || _parsedAmount != null;

  bool get _isValid =>
      _title.text.trim().isNotEmpty &&
      _amountIsWellFormed &&
      _schedule.isValid &&
      !_saving;

  /// Whether the dates this rule produces would change.
  bool get _scheduleChanged => _schedule != _draftOf(widget.rule);

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final Repositories repos = ref.read(repositoriesProvider);
      final Decimal? amount = _parsedAmount;

      await repos.incomeRules.updateRule(
        widget.rule.id,
        title: _title.text,
        amount: amount,
        scheduleType: _schedule.type,
        fixedDay: _schedule.type == ScheduleType.fixedDate
            ? _schedule.fixedDay
            : null,
        weekdayOrdinal: _schedule.type == ScheduleType.weekdayRule
            ? _schedule.ordinal
            : null,
        weekdayDay: _schedule.type == ScheduleType.weekdayRule
            ? _schedule.weekday
            : null,
        dateRangeStart: _schedule.type == ScheduleType.dateRange
            ? _schedule.rangeStart
            : null,
        dateRangeEnd: _schedule.type == ScheduleType.dateRange
            ? _schedule.rangeEnd
            : null,
        boundaryAnchor: _schedule.type == ScheduleType.boundaryDays
            ? _schedule.boundaryAnchor
            : null,
        boundaryCount: _schedule.type == ScheduleType.boundaryDays
            ? _schedule.boundaryCount
            : null,
      );

      // The amount reaches every occurrence that has not arrived yet. A month
      // already confirmed keeps the figure it was confirmed with (spec 5.4).
      await repos.incomes.updateFutureAmounts(widget.rule.id, amount);

      if (_scheduleChanged) {
        // New dates mean the old rows are on the wrong days. Dropping the
        // unreceived ones lets the next recompute lay them out again;
        // received ones are history and stay (spec 5.4).
        await repos.incomes.clearFutureOccurrences(
          widget.rule.id,
          ref.read(spaceClockProvider).today(),
        );
      }

      ref.invalidate(periodRefreshProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Space space = ref.space;
    final MoneyFormat money = MoneyFormat(
      locale: context.locale.toString(),
      currencyCode: space.currencyCode,
    );

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(title: Text(tr('income.editRule'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SageSpace.formGutter),
          children: <Widget>[
            LabelledField(
              label: tr('income.fieldTitle'),
              child: TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: SageSpace.lg),
            LabelledField(
              label: tr('income.fieldAmount'),
              child: TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
                ],
                decoration: InputDecoration(
                  suffixText: money.symbol,
                  hintText: tr('income.amountOptional'),
                ),
              ),
            ),
            const SizedBox(height: SageSpace.xs),
            Text(
              tr('income.ruleAmountHint'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: SageSpace.lg),
            ScheduleEditor(
              draft: _schedule,
              onChanged: (ScheduleDraft next) =>
                  setState(() => _schedule = next),
            ),
            if (_scheduleChanged) ...<Widget>[
              const SizedBox(height: SageSpace.sm),
              Text(
                tr('income.ruleScheduleHint'),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.sage.warning),
              ),
            ],
            const SizedBox(height: SageSpace.lg),
            FilledButton(
              onPressed: _isValid ? _save : null,
              child: Text(tr('common.save')),
            ),
          ],
        ),
      ),
    );
  }
}
