import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/schedule/income_schedule.dart';
import 'package:sielto/domain/value/enums.dart';

/// The schedule fields, as the form holds them before saving.
///
/// One object carrying every type's fields rather than a sealed hierarchy:
/// the user switches type back and forth while filling the form, and keeping
/// the other types' answers means switching back does not lose them.
@immutable
class ScheduleDraft {
  const ScheduleDraft({
    this.type = ScheduleType.fixedDate,
    this.fixedDay = 1,
    this.ordinal = WeekdayOrdinal.first,
    this.weekday = Weekday.monday,
    this.rangeStart = 23,
    this.rangeEnd = 25,
    this.boundaryAnchor = BoundaryAnchor.start,
    this.boundaryCount = 3,
  });

  final ScheduleType type;
  final int fixedDay;
  final WeekdayOrdinal ordinal;
  final Weekday weekday;
  final int rangeStart;
  final int rangeEnd;
  final BoundaryAnchor boundaryAnchor;
  final int boundaryCount;

  ScheduleDraft copyWith({
    ScheduleType? type,
    int? fixedDay,
    WeekdayOrdinal? ordinal,
    Weekday? weekday,
    int? rangeStart,
    int? rangeEnd,
    BoundaryAnchor? boundaryAnchor,
    int? boundaryCount,
  }) => ScheduleDraft(
    type: type ?? this.type,
    fixedDay: fixedDay ?? this.fixedDay,
    ordinal: ordinal ?? this.ordinal,
    weekday: weekday ?? this.weekday,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
    boundaryAnchor: boundaryAnchor ?? this.boundaryAnchor,
    boundaryCount: boundaryCount ?? this.boundaryCount,
  );

  /// A range must not end before it starts; everything else is constrained by
  /// its control.
  bool get isValid => type != ScheduleType.dateRange || rangeEnd >= rangeStart;

  /// Compared by value, because the answer decides whether a rule edit re-dates
  /// the occurrences already on the calendar. By identity every save would look
  /// like a schedule change and drop rows that had per-month corrections on
  /// them (spec 5.4).
  ///
  /// Only the fields the chosen [type] actually uses count: the editor keeps
  /// the others at whatever they were last set to, and a stale `fixedDay`
  /// behind a weekday rule is not a difference.
  @override
  bool operator ==(Object other) {
    if (other is! ScheduleDraft || other.type != type) return false;
    return switch (type) {
      ScheduleType.fixedDate => other.fixedDay == fixedDay,
      ScheduleType.weekdayRule =>
        other.ordinal == ordinal && other.weekday == weekday,
      ScheduleType.dateRange =>
        other.rangeStart == rangeStart && other.rangeEnd == rangeEnd,
      ScheduleType.boundaryDays =>
        other.boundaryAnchor == boundaryAnchor &&
            other.boundaryCount == boundaryCount,
    };
  }

  @override
  int get hashCode => switch (type) {
    ScheduleType.fixedDate => Object.hash(type, fixedDay),
    ScheduleType.weekdayRule => Object.hash(type, ordinal, weekday),
    ScheduleType.dateRange => Object.hash(type, rangeStart, rangeEnd),
    ScheduleType.boundaryDays => Object.hash(
      type,
      boundaryAnchor,
      boundaryCount,
    ),
  };
}

/// Picks one of the four schedule shapes and its fields (spec 5.1).
class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final ScheduleDraft draft;
  final ValueChanged<ScheduleDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FieldLabel(tr('schedule.type')),
        // Four chips in a two-by-two block rather than four stacked cards
        // (design section 5.1): the four are alternatives of equal weight, and
        // a vertical list of explanations buries the fields underneath them.
        for (int row = 0; row < 2; row++) ...<Widget>[
          Row(
            children: <Widget>[
              for (int col = 0; col < 2; col++) ...<Widget>[
                if (col == 1) const SizedBox(width: SageSpace.sm),
                Expanded(
                  child: _TypeChip(
                    type: ScheduleType.values[row * 2 + col],
                    selected: draft.type == ScheduleType.values[row * 2 + col],
                    onTap: () => onChanged(
                      draft.copyWith(type: ScheduleType.values[row * 2 + col]),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SageSpace.sm),
        ],
        const SizedBox(height: SageSpace.xs),
        // The chosen shape explained where it was chosen, one line instead of
        // four competing for the same attention.
        Text(
          tr('schedule.${draft.type.name}.hint'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: SageSpace.md),
        _fieldsFor(context),
        const SizedBox(height: SageSpace.md),
        const UncertaintyNote(),
      ],
    );
  }

  Widget _fieldsFor(BuildContext context) => switch (draft.type) {
    ScheduleType.fixedDate => _FixedDateFields(
      draft: draft,
      onChanged: onChanged,
    ),
    ScheduleType.weekdayRule => _WeekdayFields(
      draft: draft,
      onChanged: onChanged,
    ),
    ScheduleType.dateRange => _RangeFields(draft: draft, onChanged: onChanged),
    ScheduleType.boundaryDays => _BoundaryFields(
      draft: draft,
      onChanged: onChanged,
    ),
  };
}

/// One of the four schedule shapes, as a chip.
class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ScheduleType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SageRadius.button),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? sage.accentTint : sage.card,
          borderRadius: BorderRadius.circular(SageRadius.button),
          border: Border.all(
            color: selected ? sage.accentStrong : sage.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          tr('schedule.${type.name}.name'),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? sage.accentStrong : sage.inkSecondary,
          ),
        ),
      ),
    );
  }
}

/// What happens when a computed date lands on a weekend or a holiday.
///
/// Stated on the form rather than discovered later on the calendar: the rule
/// decides which cycle a salary opens, and it is not one a reader would guess
/// (spec 5.1.1).
class UncertaintyNote extends StatelessWidget {
  const UncertaintyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SageSpace.md),
      decoration: BoxDecoration(
        color: sage.accentTint,
        borderRadius: BorderRadius.circular(SageRadius.button),
      ),
      child: Text(
        tr('schedule.uncertaintyNote'),
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: sage.inkSecondary),
      ),
    );
  }
}

/// "The 26th of every month."
class _FixedDateFields extends StatelessWidget {
  const _FixedDateFields({required this.draft, required this.onChanged});

  final ScheduleDraft draft;
  final ValueChanged<ScheduleDraft> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      LabelledField(
        label: tr('schedule.dayOfMonth'),
        child: _DayPicker(
          value: draft.fixedDay,
          onChanged: (int day) => onChanged(draft.copyWith(fixedDay: day)),
        ),
      ),
      // The clamping rule, said where the choice is made rather than after it
      // surprises someone in February (spec 5.1).
      if (draft.fixedDay >= 29)
        Padding(
          padding: const EdgeInsets.only(top: SageSpace.xs),
          child: Text(
            tr('schedule.shortMonthHint'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
    ],
  );
}

/// "The last Friday."
class _WeekdayFields extends StatelessWidget {
  const _WeekdayFields({required this.draft, required this.onChanged});

  final ScheduleDraft draft;
  final ValueChanged<ScheduleDraft> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: LabelledField(
          label: tr('schedule.ordinal'),
          child: DropdownButtonFormField<WeekdayOrdinal>(
            initialValue: draft.ordinal,
            items: <DropdownMenuItem<WeekdayOrdinal>>[
              for (final WeekdayOrdinal o in WeekdayOrdinal.values)
                DropdownMenuItem<WeekdayOrdinal>(
                  value: o,
                  child: Text(tr('ordinal.${o.name}')),
                ),
            ],
            onChanged: (WeekdayOrdinal? o) =>
                onChanged(draft.copyWith(ordinal: o)),
          ),
        ),
      ),
      const SizedBox(width: SageSpace.md),
      Expanded(
        child: LabelledField(
          label: tr('schedule.weekday'),
          child: DropdownButtonFormField<Weekday>(
            initialValue: draft.weekday,
            items: <DropdownMenuItem<Weekday>>[
              for (final Weekday w in Weekday.values)
                DropdownMenuItem<Weekday>(
                  value: w,
                  child: Text(tr('weekday.${w.name}')),
                ),
            ],
            onChanged: (Weekday? w) => onChanged(draft.copyWith(weekday: w)),
          ),
        ),
      ),
    ],
  );
}

/// "Between the 23rd and the 25th."
class _RangeFields extends StatelessWidget {
  const _RangeFields({required this.draft, required this.onChanged});

  final ScheduleDraft draft;
  final ValueChanged<ScheduleDraft> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: LabelledField(
              label: tr('schedule.rangeStart'),
              child: _DayPicker(
                value: draft.rangeStart,
                onChanged: (int day) =>
                    onChanged(draft.copyWith(rangeStart: day)),
              ),
            ),
          ),
          const SizedBox(width: SageSpace.md),
          Expanded(
            child: LabelledField(
              label: tr('schedule.rangeEnd'),
              child: _DayPicker(
                value: draft.rangeEnd,
                onChanged: (int day) =>
                    onChanged(draft.copyWith(rangeEnd: day)),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: SageSpace.xs),
      Text(
        draft.isValid
            ? tr('schedule.latestDayRule')
            : tr('schedule.rangeInverted'),
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: draft.isValid ? null : context.sage.danger),
      ),
    ],
  );
}

/// "The first three days of the month."
class _BoundaryFields extends StatelessWidget {
  const _BoundaryFields({required this.draft, required this.onChanged});

  final ScheduleDraft draft;
  final ValueChanged<ScheduleDraft> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      LabelledField(
        label: tr('schedule.boundaryEnd'),
        child: SegmentedChoice<BoundaryAnchor>(
          values: BoundaryAnchor.values,
          selected: draft.boundaryAnchor,
          labelOf: (BoundaryAnchor a) => tr('boundary.${a.name}'),
          onChanged: (BoundaryAnchor a) =>
              onChanged(draft.copyWith(boundaryAnchor: a)),
        ),
      ),
      const SizedBox(height: SageSpace.md),
      LabelledField(
        label: tr('schedule.boundaryCount'),
        child: _Stepper(
          value: draft.boundaryCount,
          min: 1,
          // Past a fortnight, "the first N days" stops describing anything and
          // the user wants a fixed date instead (spec 5.1).
          max: BoundaryDaysSchedule.maxCount,
          onChanged: (int n) => onChanged(draft.copyWith(boundaryCount: n)),
        ),
      ),
      const SizedBox(height: SageSpace.xs),
      Text(
        tr('schedule.latestDayRule'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

/// A day of the month, 1 to 31.
class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: value,
    items: <DropdownMenuItem<int>>[
      for (int day = 1; day <= 31; day++)
        DropdownMenuItem<int>(value: day, child: Text('$day')),
    ],
    onChanged: (int? day) => day == null ? null : onChanged(day),
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return Container(
      decoration: BoxDecoration(
        color: sage.card,
        borderRadius: BorderRadius.circular(SageRadius.input),
        border: Border.all(color: sage.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: Theme.of(context).textTheme.titleSmall),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
