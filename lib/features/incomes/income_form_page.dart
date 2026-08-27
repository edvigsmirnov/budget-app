import 'package:budget_app/app/providers.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/format/date_format.dart';
import 'package:budget_app/core/format/money_format.dart';
import 'package:budget_app/core/format/money_input.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/domain/value/calendar_date.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the income form. Flow has no schedules — a regular income with a
/// recurrence rule is M4 — so this covers one-off receipts (spec 5.4).
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

  CalendarDate? _date;
  bool _isReceived = false;
  Income? _existing;
  bool _loaded = false;

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
    super.dispose();
  }

  Future<void> _load() async {
    final String? id = widget.incomeId;
    if (id != null) {
      final Repositories repos = ref.read(repositoriesProvider);
      final List<Income> rows = await repos.incomes.inSpace(
        ref.read(currentSpaceProvider)!.id,
      );
      final Income? row = rows.where((Income i) => i.id == id).firstOrNull;
      if (row != null) {
        _existing = row;
        _title.text = row.title;
        _amount.text = row.amount?.toString() ?? '';
        _notes.text = row.notes ?? '';
        _date = row.expectedDate;
        _isReceived = row.isPaid;
      }
    }
    _date ??= widget.initialDate ?? ref.read(spaceClockProvider).today();
    if (mounted) setState(() => _loaded = true);
  }

  /// Null is a legitimate answer here: an expected inflow whose figure is not
  /// known yet stays honest rather than inventing a number (spec 4.7).
  Decimal? get _parsedAmount {
    final Decimal? value = parseMoney(_amount.text);
    if (value == null || value <= Decimal.zero) return null;
    return value;
  }

  /// An income can be saved without an amount, but not marked received without
  /// one (spec 4.5).
  bool get _isValid =>
      _title.text.trim().isNotEmpty &&
      (!_isReceived || _parsedAmount != null) &&
      (_amount.text.trim().isEmpty || _parsedAmount != null);

  Future<void> _save() async {
    final CalendarDate? date = _date;
    if (date == null) return;
    final Repositories repos = ref.read(repositoriesProvider);
    final String? notes = _notes.text.trim().isEmpty
        ? null
        : _notes.text.trim();
    final Income? existing = _existing;

    if (existing == null) {
      await repos.incomes.create(
        spaceId: ref.read(currentSpaceProvider)!.id,
        title: _title.text,
        expectedDate: date,
        amount: _parsedAmount,
        notes: notes,
        isPaid: _isReceived,
      );
    } else {
      await repos.incomes.update(
        existing.id,
        title: Value<String>(_title.text),
        amount: Value<Decimal?>(_parsedAmount),
        expectedDate: Value<CalendarDate>(date),
        notes: Value<String?>(notes),
        isPaid: Value<bool>(_isReceived),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final Income? existing = _existing;
    if (existing == null) return;
    await ref.read(repositoriesProvider).incomes.softDelete(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final CalendarDate current = _date ?? ref.read(spaceClockProvider).today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current.toUtcMidnight(),
      firstDate: DateTime.utc(current.year - 10),
      lastDate: DateTime.utc(current.year + 15),
    );
    if (picked != null) {
      setState(() => _date = CalendarDate.fromDateTime(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Space space = ref.space;
    final String locale = context.locale.toString();
    final MoneyFormat money = MoneyFormat(
      locale: locale,
      currencyCode: space.currencyCode,
    );

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(
        title: Text(_existing == null ? tr('income.add') : tr('income.edit')),
        actions: <Widget>[
          if (_existing != null)
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
            const SizedBox(height: SageSpace.lg),
            LabelledField(
              label: tr('income.fieldDate'),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(SageRadius.input),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.sage.card,
                    borderRadius: BorderRadius.circular(SageRadius.input),
                    border: Border.all(color: context.sage.border),
                  ),
                  child: Text(
                    DateLabels(locale).dayMonth(_date!),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SageSpace.lg),
            LabelledField(
              label: tr('income.fieldNotes'),
              child: TextField(
                controller: _notes,
                maxLines: 3,
                maxLength: 5000,
              ),
            ),
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
              onChanged: (bool value) => setState(() => _isReceived = value),
            ),
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
