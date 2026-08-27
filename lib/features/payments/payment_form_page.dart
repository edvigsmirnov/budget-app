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
import 'package:sielto/core/ui/dialogs.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/ledger/ledger_entry.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/payments/category_picker.dart';
import 'package:sielto/features/payments/recurrence.dart';
import 'package:sielto/features/payments/series_scope_dialog.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// Opens the payment form. With no [paymentId] it is a new record.
Future<void> openPaymentForm(
  BuildContext context, {
  String? paymentId,
  CalendarDate? date,
  PaymentDraft? draft,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (BuildContext _) =>
        PaymentFormPage(paymentId: paymentId, initialDate: date, draft: draft),
  ),
);

/// A prefilled but unsaved record, from "duplicate before/after" (spec 6.5).
@immutable
class PaymentDraft {
  const PaymentDraft({
    required this.title,
    required this.amount,
    required this.date,
    required this.expenseType,
    this.categoryId,
    this.notes,
  });

  /// Copies a record onto a new date. `group_recurring_id` and `is_paid` are
  /// deliberately not carried over: a duplicate is a record of its own, and
  /// inheriting the series would let a later "all future" edit reach it.
  factory PaymentDraft.from(Payment payment, CalendarDate date) => PaymentDraft(
    title: payment.title,
    amount: payment.amount,
    date: date,
    expenseType: payment.expenseType,
    categoryId: payment.categoryId,
    notes: payment.notes,
  );

  final String title;
  final Decimal amount;
  final CalendarDate date;
  final ExpenseType expenseType;
  final String? categoryId;
  final String? notes;
}

class PaymentFormPage extends ConsumerStatefulWidget {
  const PaymentFormPage({
    this.paymentId,
    this.initialDate,
    this.draft,
    super.key,
  });

  final String? paymentId;
  final CalendarDate? initialDate;
  final PaymentDraft? draft;

  @override
  ConsumerState<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends ConsumerState<PaymentFormPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  CalendarDate? _date;
  ExpenseType _type = ExpenseType.variable;
  String? _categoryId;
  bool _isPaid = false;
  bool _isRecurring = false;
  RecurrenceInterval _interval = RecurrenceInterval.monthly;

  /// Null means open-ended, which fills the 24-month horizon (spec 6.3).
  int? _occurrences = 12;

  Payment? _existing;
  bool _loaded = false;
  bool _saving = false;

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
    final PaymentDraft? draft = widget.draft;
    final String? id = widget.paymentId;

    if (id != null) {
      final Payment? row = await ref
          .read(repositoriesProvider)
          .payments
          .byId(id);
      if (row != null) {
        _existing = row;
        _title.text = row.title;
        _amount.text = row.amount.toString();
        _notes.text = row.notes ?? '';
        _date = row.dueDate;
        _type = row.expenseType;
        _categoryId = row.categoryId;
        _isPaid = row.isPaid;
      }
    } else if (draft != null) {
      _title.text = draft.title;
      _amount.text = draft.amount.toString();
      _notes.text = draft.notes ?? '';
      _date = draft.date;
      _type = draft.expenseType;
      _categoryId = draft.categoryId;
    }

    _date ??= widget.initialDate ?? ref.read(spaceClockProvider).today();
    if (mounted) setState(() => _loaded = true);
  }

  Decimal? get _parsedAmount {
    final Decimal? value = parseMoney(_amount.text);
    if (value == null || value < Decimal.zero) return null;
    return value;
  }

  /// Title after trim and a non-negative amount (spec 6.7). Zero passes: a
  /// zero-amount record is a dated to-do, which Budget mode uses.
  bool get _isValid =>
      _title.text.trim().isNotEmpty && _parsedAmount != null && !_saving;

  /// The date range the form accepts without comment (spec 6.7). Outside it
  /// the field warns; it does not block, because old entries are sometimes
  /// deliberate.
  bool get _dateLooksOdd {
    final CalendarDate? date = _date;
    if (date == null) return false;
    final CalendarDate today = ref.read(spaceClockProvider).today();
    return date.isBefore(today.addMonths(-12 * 5)) ||
        date.isAfter(today.addMonths(12 * 10));
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

  Future<void> _save() async {
    final Decimal? amount = _parsedAmount;
    final CalendarDate? date = _date;
    if (amount == null || date == null) return;

    setState(() => _saving = true);
    try {
      final Repositories repos = ref.read(repositoriesProvider);
      final Space space = ref.read(currentSpaceProvider)!;
      final String? notes = _notes.text.trim().isEmpty
          ? null
          : _notes.text.trim();
      final Payment? existing = _existing;

      if (existing == null) {
        if (_isRecurring) {
          await repos.payments.createSeries(
            spaceId: space.id,
            title: _title.text,
            amount: amount,
            dates: recurrenceDates(
              start: date,
              interval: _interval,
              count: _occurrences,
            ),
            expenseType: _type,
            categoryId: _categoryId,
            notes: notes,
          );
        } else {
          await repos.payments.create(
            spaceId: space.id,
            title: _title.text,
            amount: amount,
            dueDate: date,
            expenseType: _type,
            categoryId: _categoryId,
            notes: notes,
            isPaid: _isPaid,
          );
        }
      } else {
        final SeriesScope scope = await _resolveScope(existing);
        switch (scope) {
          case SeriesScope.thisOne:
            await repos.payments.update(
              existing.id,
              title: Value<String>(_title.text),
              amount: Value<Decimal>(amount),
              dueDate: Value<CalendarDate>(date),
              expenseType: Value<ExpenseType>(_type),
              categoryId: Value<String?>(_categoryId),
              notes: Value<String?>(notes),
              isPaid: Value<bool>(_isPaid),
            );
          case SeriesScope.allFuture:
            // The date is not written across a series: each occurrence keeps
            // its own day (spec 6.3).
            await repos.payments.updateSeriesFrom(
              existing.groupRecurringId!,
              existing.dueDate,
              title: Value<String>(_title.text),
              amount: Value<Decimal>(amount),
              expenseType: Value<ExpenseType>(_type),
              categoryId: Value<String?>(_categoryId),
              notes: Value<String?>(notes),
            );
          case SeriesScope.wholeSeries:
            await repos.payments.updateWholeSeries(
              existing.groupRecurringId!,
              title: Value<String>(_title.text),
              amount: Value<Decimal>(amount),
              expenseType: Value<ExpenseType>(_type),
              categoryId: Value<String?>(_categoryId),
              notes: Value<String?>(notes),
            );
          case SeriesScope.cancelled:
            return;
        }
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// A record outside a series always edits itself; one inside asks first
  /// (spec 6.3).
  Future<SeriesScope> _resolveScope(Payment payment) async {
    if (payment.groupRecurringId == null) return SeriesScope.thisOne;
    if (!mounted) return SeriesScope.cancelled;
    return askSeriesScope(context);
  }

  Future<void> _delete() async {
    final Payment? existing = _existing;
    if (existing == null) return;
    if (existing.expenseType == ExpenseType.mandatory &&
        !await confirmMandatory(context)) {
      return;
    }
    await ref.read(repositoriesProvider).payments.softDelete(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Space space = ref.space;
    final SageColors sage = context.sage;
    final String locale = context.locale.toString();
    final MoneyFormat money = MoneyFormat(
      locale: locale,
      currencyCode: space.currencyCode,
    );

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: sage.surface,
      appBar: AppBar(
        title: Text(_existing == null ? tr('payment.add') : tr('payment.edit')),
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
        child: Column(
          children: <Widget>[
            _LivePreview(
              amount: _parsedAmount,
              date: _date,
              replacingId: _existing?.id,
              isRecurring: _isRecurring && _existing == null,
              occurrences: _occurrences,
              interval: _interval,
              money: money,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SageSpace.formGutter),
                children: <Widget>[
                  LabelledField(
                    label: tr('payment.fieldTitle'),
                    child: TextField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: SageSpace.lg),
                  LabelledField(
                    label: tr('payment.fieldAmount'),
                    child: TextField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]')),
                      ],
                      decoration: InputDecoration(suffixText: money.symbol),
                    ),
                  ),
                  const SizedBox(height: SageSpace.lg),
                  LabelledField(
                    label: tr('payment.fieldDate'),
                    child: _DateField(
                      date: _date!,
                      labels: DateLabels(locale),
                      onTap: _pickDate,
                      warn: _dateLooksOdd,
                    ),
                  ),
                  if (_dateLooksOdd)
                    Padding(
                      padding: const EdgeInsets.only(top: SageSpace.xs),
                      child: Text(
                        tr('payment.dateOutOfRange'),
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: sage.warning),
                      ),
                    ),
                  const SizedBox(height: SageSpace.lg),
                  LabelledField(
                    label: tr('payment.fieldCategory'),
                    child: CategoryPickerField(
                      selectedId: _categoryId,
                      onChanged: (Category? category) => setState(() {
                        _categoryId = category?.id;
                        // The category supplies the default, never overrides a
                        // choice already made on the record (spec 6.2).
                        if (category != null) _type = category.expenseType;
                      }),
                    ),
                  ),
                  const SizedBox(height: SageSpace.lg),
                  LabelledField(
                    label: tr('payment.fieldType'),
                    child: SegmentedChoice<ExpenseType>(
                      values: ExpenseType.values,
                      selected: _type,
                      labelOf: (ExpenseType t) => tr('expenseType.${t.name}'),
                      onChanged: (ExpenseType t) => setState(() => _type = t),
                    ),
                  ),
                  if (_existing == null) ...<Widget>[
                    const SizedBox(height: SageSpace.lg),
                    _RecurrenceFields(
                      isRecurring: _isRecurring,
                      interval: _interval,
                      occurrences: _occurrences,
                      onRecurringChanged: (bool value) =>
                          setState(() => _isRecurring = value),
                      onIntervalChanged: (RecurrenceInterval value) =>
                          setState(() => _interval = value),
                      onOccurrencesChanged: (int? value) =>
                          setState(() => _occurrences = value),
                    ),
                  ],
                  const SizedBox(height: SageSpace.lg),
                  LabelledField(
                    label: tr('payment.fieldNotes'),
                    child: TextField(
                      controller: _notes,
                      maxLines: 3,
                      maxLength: 5000,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: _isPaid,
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr('payment.markPaid')),
                    onChanged: (bool value) => setState(() => _isPaid = value),
                  ),
                  const SizedBox(height: SageSpace.lg),
                  FilledButton(
                    onPressed: _isValid ? _save : null,
                    child: Text(tr('common.save')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Live Preview strip (spec 6.1).
///
/// It recomputes on every keystroke and stays in memory: nothing is written
/// until Save. A preview that would go negative turns red immediately, which
/// is the whole point of showing it before the record exists.
class _LivePreview extends ConsumerWidget {
  const _LivePreview({
    required this.amount,
    required this.date,
    required this.replacingId,
    required this.isRecurring,
    required this.occurrences,
    required this.interval,
    required this.money,
  });

  final Decimal? amount;
  final CalendarDate? date;
  final String? replacingId;
  final bool isRecurring;
  final int? occurrences;
  final RecurrenceInterval interval;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final FlowLedger? base = ref.watch(flowLedgerProvider).value;
    if (base == null) return const SizedBox.shrink();

    final Decimal? draftAmount = amount;
    final CalendarDate? draftDate = date;

    final List<LedgerEntry> draft = <LedgerEntry>[
      if (draftAmount != null && draftDate != null)
        for (final CalendarDate d
            in isRecurring
                ? recurrenceDates(
                    start: draftDate,
                    interval: interval,
                    count: occurrences,
                  )
                : <CalendarDate>[draftDate])
          LedgerEntry(
            id: 'draft:${d.toIso()}',
            date: d,
            amount: draftAmount,
            isIncome: false,
            // Sits last within its day: a preview must not reorder what is
            // already there.
            sortOrder: 1 << 30,
          ),
    ];

    final LedgerRun before = LedgerWalker.walk(
      available: base.available,
      entries: <LedgerEntry>[
        for (final LedgerEntry e in base.entries)
          if (e.id != replacingId) e,
      ],
    );
    final LedgerRun after = previewRun(
      base: base,
      draft: draft,
      replacingId: replacingId,
    );

    final Decimal? beforeFree = before.freeCash;
    final Decimal? afterFree = after.freeCash;
    final Color afterColor = afterFree == null ? sage.danger : sage.ink;

    return Container(
      width: double.infinity,
      color: sage.canvas,
      padding: const EdgeInsets.symmetric(
        horizontal: SageSpace.formGutter,
        vertical: SageSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tr('dashboard.freeMoney'), style: text.labelSmall),
          const SizedBox(height: SageSpace.xs),
          Row(
            children: <Widget>[
              Text(
                beforeFree == null
                    ? tr('dashboard.notCovered')
                    : money.format(beforeFree),
                style: text.titleSmall?.copyWith(color: sage.inkSecondary),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SageSpace.sm),
                child: Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: sage.inkLabel,
                ),
              ),
              Text(
                afterFree == null
                    ? tr('dashboard.notCovered')
                    : money.format(afterFree),
                style: text.titleSmall?.copyWith(color: afterColor),
              ),
            ],
          ),
          if (isRecurring && draft.length > 1) ...<Widget>[
            const SizedBox(height: SageSpace.xs),
            Text(
              tr(
                'payment.recurringPreview',
                namedArgs: <String, String>{
                  'now': money.format(draftAmount!),
                  'total': money.format(
                    draftAmount * Decimal.fromInt(draft.length),
                  ),
                  'count': '${draft.length}',
                },
              ),
              style: text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.labels,
    required this.onTap,
    required this.warn,
  });

  final CalendarDate date;
  final DateLabels labels;
  final VoidCallback onTap;
  final bool warn;

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
          border: Border.all(color: warn ? sage.warning : sage.border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                labels.dayMonth(date),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 16, color: sage.inkLabel),
          ],
        ),
      ),
    );
  }
}

/// One-off or repeating, and for how long (spec 6.3).
class _RecurrenceFields extends StatelessWidget {
  const _RecurrenceFields({
    required this.isRecurring,
    required this.interval,
    required this.occurrences,
    required this.onRecurringChanged,
    required this.onIntervalChanged,
    required this.onOccurrencesChanged,
  });

  final bool isRecurring;
  final RecurrenceInterval interval;
  final int? occurrences;
  final ValueChanged<bool> onRecurringChanged;
  final ValueChanged<RecurrenceInterval> onIntervalChanged;
  final ValueChanged<int?> onOccurrencesChanged;

  /// Null is "indefinitely", which materialises the 24-month horizon.
  static const List<int?> _choices = <int?>[3, 6, 12, 24, null];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SegmentedChoice<bool>(
        values: const <bool>[false, true],
        selected: isRecurring,
        labelOf: (bool value) =>
            value ? tr('payment.recurring') : tr('payment.oneOff'),
        onChanged: onRecurringChanged,
      ),
      if (isRecurring) ...<Widget>[
        const SizedBox(height: SageSpace.md),
        SegmentedChoice<RecurrenceInterval>(
          values: RecurrenceInterval.values,
          selected: interval,
          labelOf: (RecurrenceInterval value) => tr('recurrence.${value.name}'),
          onChanged: onIntervalChanged,
        ),
        const SizedBox(height: SageSpace.md),
        Wrap(
          spacing: SageSpace.sm,
          children: <Widget>[
            for (final int? choice in _choices)
              ChoiceChip(
                selected: occurrences == choice,
                label: Text(
                  choice == null
                      ? tr('recurrence.indefinitely')
                      : plural('recurrence.times', choice),
                ),
                onSelected: (bool _) => onOccurrencesChanged(choice),
              ),
          ],
        ),
      ],
    ],
  );
}
