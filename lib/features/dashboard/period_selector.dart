import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/format/date_format.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/space/period_ledger.dart';

/// "← Previous period / Next period →" with the cycle's dates between them
/// (spec 4.7).
///
/// It only moves between periods that exist: back through history, and forward
/// exactly as far as the schedule is known. There is no arbitrary range — a
/// period is always one whole cycle between two anchor incomes.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BudgetPeriod> periods = ref.watch(incomePeriodsProvider);
    final BudgetPeriod? current = ref.watch(selectedPeriodProvider);
    if (current == null || periods.isEmpty) return const SizedBox.shrink();

    final int index = periods.indexWhere(
      (BudgetPeriod p) => p.id == current.id,
    );
    final BudgetPeriod? previous = index > 0 ? periods[index - 1] : null;
    final BudgetPeriod? next = index >= 0 && index < periods.length - 1
        ? periods[index + 1]
        : null;

    final DateLabels dates = DateLabels(context.locale.toString());
    final CalendarDate today = ref.watch(spaceClockProviderForLabel);

    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: tr('period.previous'),
          onPressed: previous == null
              ? null
              : () => ref
                    .read(selectedPeriodIdProvider.notifier)
                    .select(previous.id),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      _label(current, dates),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  // The window was computed without that year's holidays and
                  // can still narrow. Unobtrusive on purpose: the figures are
                  // usable, just conservative (spec 5.1.1).
                  if (current.holidayDataIncomplete) ...<Widget>[
                    const SizedBox(width: SageSpace.xs),
                    Tooltip(
                      message: tr('holidays.incomplete'),
                      child: Icon(
                        Icons.cloud_off_outlined,
                        size: 16,
                        color: context.sage.inkLabel,
                      ),
                    ),
                  ],
                ],
              ),
              if (_isCurrent(current, today))
                Text(
                  tr('period.current'),
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: context.sage.accentStrong),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: tr('period.next'),
          onPressed: next == null
              ? null
              : () =>
                    ref.read(selectedPeriodIdProvider.notifier).select(next.id),
        ),
      ],
    );
  }

  String _label(BudgetPeriod period, DateLabels dates) {
    final CalendarDate? end = period.endDate;
    if (end == null) return dates.dayMonth(period.startDate);
    return '${dates.dayMonth(period.startDate)} — ${dates.dayMonth(end)}';
  }

  bool _isCurrent(BudgetPeriod period, CalendarDate today) {
    if (period.startDate.isAfter(today)) return false;
    final CalendarDate? end = period.endDate;
    return end == null || !end.isBefore(today);
  }
}

/// Today in the Space's timezone, as a plain value for labelling.
final Provider<CalendarDate> spaceClockProviderForLabel =
    Provider<CalendarDate>((Ref ref) => ref.watch(spaceClockProvider).today());
