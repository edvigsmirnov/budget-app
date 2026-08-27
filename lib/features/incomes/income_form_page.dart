import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/format/money_format.dart';
import 'package:sielto/core/format/money_input.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/period/freeze.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/incomes/income_scope_dialog.dart';
import 'package:sielto/features/incomes/schedule_editor.dart';
import 'package:sielto/features/periods/freeze_providers.dart';
import 'package:sielto/features/periods/freeze_ui.dart';

/// Opens the income form (spec 5.1, 5.4).
///
/// One form for both shapes, as the spec asks: the "make regular" switch is
/// what decides whether saving writes a single row or a recurrence rule that
/// materialises many.
Future<void> openIncomeForm(
  BuildContext context, {
  String? incomeId,
  CalendarDate? date,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (BuildContext _) =>
        IncomeFormPage(incomeId: incomeId, initialDate: date),
  ),
);

class IncomeFormPage extends ConsumerStatefulWidget {
  const IncomeFormPage({this.incomeId, this.initialDate, super.key});

  final String? incomeId;
  final CalendarDate? initialDate;

  @override
  ConsumerState<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends ConsumerState<IncomeFormPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  /// What a frozen occurrence's note gains. The existing text stays as it is.
  final TextEditingController _addedNote = TextEditingController();

  CalendarDate? _date;
  bool _isReceived = false;

  /// Filled in when the receipt is confirmed; defaults to the expected date
  /// but is the user's to correct (spec 5.4).
  CalendarDate? _actualDate;

  bool _isRegular = false;
  ScheduleDraft _schedule = const ScheduleDraft();

  /// Only meaningful in income_driven Spaces, and only once one anchor exists.
  bool _isAnchor = true;
  bool _anchorChoiceApplies = false;

  Income? _existing;
  bool _loaded = false;
  bool _saving = false;

  /// The state of the occurrence's period. Amount, both dates and the receipt
  /// flag are read-only once it has closed (spec 5.5).
  FreezeState _freeze = FreezeState.open;

  bool get _isFrozen => _freeze == FreezeState.frozen;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController c in <TextEditingController>[
      _title,
      _amount,
    ]) {
      c.addListener(() => setState(() {}));
    }
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    _addedNote.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final Space space = ref.read(currentSpaceProvider)!;
    final Repositories repos = ref.read(repositoriesProvider);
    final String? id = widget.incomeId;

    if (id != null) {
      final List<Income> rows = await repos.incomes.inSpace(space.id);
      final Income? row = rows.where((Income i) => i.id == id).firstOrNull;
      if (row != null) {
        _existing = row;
        _title.text = row.title;
        _amount.text = row.amount?.toString() ?? '';
        _notes.text = row.notes ?? '';
        _date = row.expectedDate;
        _isReceived = row.isPaid;
        _actualDate = row.actualDate ?? row.expectedDate;
        _freeze = ref.read(freezeLookupProvider).of(row.budgetPeriodId);
      }
    } else if (space.budgetMode == BudgetMode.incomeDriven) {
      // The first regular income of the Space becomes the anchor with no
      // question asked; from the second on the choice is real (spec 5.2).
      final List<IncomeRecurrenceRule> anchors = await repos.incomeRules
          .anchorsInSpace(space.id);
      _anchorChoiceApplies = anchors.isNotEmpty;
    }

    _date ??= widget.initialDate ?? ref.read(spaceClockProvider).today();
    if (mounted) setState(() => _loaded = true);
  }

  /// Null is a legitimate answer: an inflow whose figure is not known yet
  /// stays honest rather than inventing one (spec 4.7).
  Decimal? get _parsedAmount {
    final Decimal? value = parseMoney(_amount.text);
    if (value == null || value <= Decimal.zero) return null;
    return value;
  }

  bool get _amountFieldIsWellFormed =>
      _amount.text.trim().isEmpty || _parsedAmount != null;

  /// An income saves without an amount, but cannot be marked received without
  /// one — the period's figures would stay uncomputable (spec 4.7).
  bool get _isValid =>
      _title.text.trim().isNotEmpty &&
      _amountFieldIsWellFormed &&
      (!_isReceived || _parsedAmount != null) &&
      (!_isRegular || _schedule.isValid) &&
      !_saving;

  Future<void> _save() async {
    final CalendarDate? date = _date;
    if (date == null) return;
    setState(() => _saving = true);

    try {
      final Space space = ref.read(currentSpaceProvider)!;
      final Repositories repos = ref.read(repositoriesProvider);
      final String? notes = _notes.text.trim().isEmpty
          ? null
          : _notes.text.trim();
      final Income? existing = _existing;

      if (existing != null && _isFrozen) {
        await _saveFrozen(existing, repos);
      } else if (existing != null) {
        await _saveExisting(existing, repos, date, notes);
      } else if (_isRegular) {
        await _createRule(space, repos);
      } else {
        await repos.incomes.create(
          spaceId: space.id,
          title: _title.text,
          expectedDate: date,
          amount: _parsedAmount,
          notes: notes,
          isPaid: _isReceived,
        );
      }

      // Periods and future occurrences follow from the rules, so any change
      // here can move them.
      ref.invalidate(periodRefreshProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createRule(Space space, Repositories repos) async {
    final IncomeRecurrenceRule rule = await repos.incomeRules
        .createFirstAsAnchor(
          spaceId: space.id,
          mode: space.budgetMode,
          title: _title.text,
          amount: _parsedAmount,
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

    // createFirstAsAnchor anchors the first rule of the Space on its own; a
    // later one takes the role the user picked.
    if (_anchorChoiceApplies && _isAnchor) {
      await repos.incomeRules.setAnchor(
        rule.id,
        isAnchor: true,
        mode: space.budgetMode,
      );
    }
  }

  /// The two writes a closed period still allows (spec 5.5): the title, and a
  /// note appended below what is already there.
  Future<void> _saveFrozen(Income existing, Repositories repos) async {
    final String addition = _addedNote.text.trim();
    await repos.incomes.update(
      existing.id,
      title: Value<String>(_title.text),
      notes: addition.isEmpty
          ? const Value<String?>.absent()
          : Value<String?>(
              FreezeEvaluator.appendNote(
                existing.notes,
                addition,
                ref.read(spaceClockProvider).today(),
              ),
            ),
    );
  }

  /// Editing one materialised occurrence.
  ///
  /// When it belongs to a series, changing the amount asks how far the change
  /// reaches; the date and the note are always this occurrence alone
  /// (spec 5.4).
  Future<void> _saveExisting(
    Income existing,
    Repositories repos,
    CalendarDate date,
    String? notes,
  ) async {
    IncomeScope scope = IncomeScope.thisOne;
    final bool amountChanged = _parsedAmount != existing.amount;
    if (existing.recurrenceRuleId != null && amountChanged) {
      if (!mounted) return;
      scope = await askIncomeScope(context);
      if (scope == IncomeScope.cancelled) return;
    }

    await repos.incomes.update(
      existing.id,
      title: Value<String>(_title.text),
      amount: Value<Decimal?>(_parsedAmount),
      expectedDate: Value<CalendarDate>(date),
      notes: Value<String?>(notes),
      isPaid: Value<bool>(_isReceived),
      // Clearing the receipt clears the fact with it: the expected date stays,
      // the actual one no longer exists (spec 5.4).
      actualDate: Value<CalendarDate?>(_isReceived ? _actualDate : null),
    );

    if (scope == IncomeScope.allFuture) {
      await repos.incomeRules.setAmount(
        existing.recurrenceRuleId!,
        _parsedAmount,
      );
      await repos.incomes.updateFutureAmounts(
        existing.recurrenceRuleId!,
        _parsedAmount,
      );
    }
  }

  Future<void> _delete() async {
    final Income? existing = _existing;
    if (existing == null) return;
    await ref.read(repositoriesProvider).incomes.softDelete(existing.id);
    ref.invalidate(periodRefreshProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate({required bool actual}) async {
    final CalendarDate current =
        (actual ? _actualDate : _date) ?? ref.read(spaceClockProvider).today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current.toUtcMidnight(),
      firstDate: DateTime.utc(current.year - 10),
      lastDate: DateTime.utc(current.year + 15),
    );
    if (picked == null) return;
    setState(() {
      if (actual) {
        _actualDate = CalendarDate.fromDateTime(picked);
      } else {
        _date = CalendarDate.fromDateTime(picked);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Space space = ref.space;
    final String locale = context.locale.toString();
    final MoneyFormat money = MoneyFormat(
      locale: locale,
      currencyCode: space.currencyCode,
    );
    final DateLabels dates = DateLabels(locale);

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isOccurrence = _existing != null;
    final bool partOfSeries = _existing?.recurrenceRuleId != null;

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(
        title: Text(isOccurrence ? tr('income.edit') : tr('income.add')),
        actions: <Widget>[
          // Deleting is protected, so a closed period offers no delete rather
          // than one that refuses (spec 5.5).
          if (isOccurrence && !_isFrozen)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: tr('common.delete'),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SageSpace.formGutter),
          children: <Widget>[
            if (_isFrozen) const FreezeNotice(),
            if (partOfSeries)
              Padding(
                padding: const EdgeInsets.only(bottom: SageSpace.md),
                child: SageCard(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.repeat,
                        size: 18,
                        color: context.sage.inkLabel,
                      ),
                      const SizedBox(width: SageSpace.sm),
                      Expanded(
                        child: Text(
                          tr('income.partOfSeries'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                enabled: !_isFrozen,
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
            const SizedBox(height: SageSpace.lg),

            // A regular income has no single date: its dates come from the
            // schedule (spec 5.1, step 3).
            if (!_isRegular) ...<Widget>[
              LabelledField(
                label: tr('income.fieldDate'),
                child: DateField(
                  label: dates.dayMonth(_date!),
                  onTap: _isFrozen ? null : () => _pickDate(actual: false),
                ),
              ),
              const SizedBox(height: SageSpace.lg),
            ],

            if (!isOccurrence) ...<Widget>[
              SwitchListTile.adaptive(
                value: _isRegular,
                contentPadding: EdgeInsets.zero,
                title: Text(tr('income.makeRegular')),
                subtitle: Text(tr('income.makeRegularHint')),
                onChanged: (bool value) => setState(() => _isRegular = value),
              ),
              if (_isRegular) ...<Widget>[
                const SizedBox(height: SageSpace.md),
                ScheduleEditor(
                  draft: _schedule,
                  onChanged: (ScheduleDraft next) =>
                      setState(() => _schedule = next),
                ),
                // Anchoring decides period boundaries, so it means nothing
                // outside income_driven and the form does not offer it there
                // (spec 5.2).
                if (_anchorChoiceApplies &&
                    space.budgetMode == BudgetMode.incomeDriven) ...<Widget>[
                  const SizedBox(height: SageSpace.lg),
                  LabelledField(
                    label: tr('income.role'),
                    child: SegmentedChoice<bool>(
                      values: const <bool>[true, false],
                      selected: _isAnchor,
                      labelOf: (bool anchor) => anchor
                          ? tr('income.roleAnchor')
                          : tr('income.roleAdditional'),
                      onChanged: (bool anchor) =>
                          setState(() => _isAnchor = anchor),
                    ),
                  ),
                  const SizedBox(height: SageSpace.xs),
                  Text(
                    _isAnchor
                        ? tr('income.roleAnchorHint')
                        : tr('income.roleAdditionalHint'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
              const SizedBox(height: SageSpace.lg),
            ],

            if (_isFrozen)
              _AppendNoteField(
                existing: _existing?.notes,
                controller: _addedNote,
              )
            else
              LabelledField(
                label: tr('income.fieldNotes'),
                child: TextField(
                  controller: _notes,
                  maxLines: 3,
                  maxLength: 5000,
                ),
              ),

            if (!_isRegular) ...<Widget>[
              SwitchListTile.adaptive(
                value: _isReceived,
                contentPadding: EdgeInsets.zero,
                title: Text(tr('income.markReceived')),
                subtitle: _isReceived && _parsedAmount == null
                    ? Text(
                        tr('income.amountRequired'),
                        style: TextStyle(color: context.sage.danger),
                      )
                    : null,
                onChanged: _isFrozen
                    ? null
                    : (bool value) => setState(() {
                        _isReceived = value;
                        _actualDate ??= _date;
                      }),
              ),
              // The date the money actually arrived, which the expected date
              // is not for. It changes no calculation (spec 5.4).
              if (_isReceived) ...<Widget>[
                const SizedBox(height: SageSpace.sm),
                LabelledField(
                  label: tr('income.fieldActualDate'),
                  child: DateField(
                    label: dates.dayMonth(_actualDate ?? _date!),
                    onTap: _isFrozen ? null : () => _pickDate(actual: true),
                  ),
                ),
                if (_actualDate != null && _actualDate != _date)
                  Padding(
                    padding: const EdgeInsets.only(top: SageSpace.xs),
                    child: Text(
                      tr('income.actualDateNote'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
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

/// The note of an occurrence in a closed period: what is there, and a field
/// that adds to it (spec 5.5).
class _AppendNoteField extends StatelessWidget {
  const _AppendNoteField({required this.existing, required this.controller});

  final String? existing;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (existing != null && existing!.trim().isNotEmpty) ...<Widget>[
        LabelledField(
          label: tr('income.fieldNotes'),
          child: SageCard(
            child: Text(
              existing!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: SageSpace.lg),
      ],
      LabelledField(
        label: tr('freeze.addNote'),
        child: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 5000,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: tr('freeze.addNoteHint')),
        ),
      ),
    ],
  );
}

/// A tappable date, shown as a field. Shared with the receipt dialog.
class DateField extends StatelessWidget {
  const DateField({required this.label, required this.onTap, super.key});

  final String label;

  /// Null when the period is closed: the field reads, it does not open a
  /// picker (spec 5.5).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SageRadius.input),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: sage.card,
          borderRadius: BorderRadius.circular(SageRadius.input),
          border: Border.all(color: sage.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: sage.inkLabel),
          ],
        ),
      ),
    );
  }
}
