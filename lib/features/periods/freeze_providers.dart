import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/period/freeze.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// The freeze state of every period of the open Space, resolved from rows the
/// screens already hold (spec 5.5).
///
/// The repositories refuse a frozen write on their own; this exists so a
/// screen can say so before the user tries. Both go through the same
/// [FreezeEvaluator], so there is one rule and two readers of it, not two
/// rules.
@immutable
class FreezeLookup {
  const FreezeLookup({
    required this.periods,
    required this.today,
    required this.nowUtc,
    this.evaluator = const FreezeEvaluator(),
  });

  /// The Space's periods by id.
  final Map<String, BudgetPeriod> periods;
  final CalendarDate today;
  final DateTime nowUtc;
  final FreezeEvaluator evaluator;

  /// [FreezeState.open] for a record bound to nothing, and for the continuous
  /// period Flow and Budget use: neither has an end, so neither ever freezes.
  FreezeState of(String? periodId) {
    final BudgetPeriod? period = periodId == null ? null : periods[periodId];
    if (period == null) return FreezeState.open;
    return stateOf(period);
  }

  FreezeState stateOf(BudgetPeriod period) => evaluator.evaluate(
    endDate: period.endDate,
    today: today,
    nowUtc: nowUtc,
    unfrozenUntil: period.unfrozenUntil,
  );

  bool isFrozen(String? periodId) => of(periodId) == FreezeState.frozen;

  /// Days until [period] freezes, for the warning that precedes it. Negative
  /// once it already has.
  int daysUntilFreeze(BudgetPeriod period) {
    final CalendarDate? end = period.endDate;
    if (end == null) return 1 << 30;
    return today.daysUntil(end.addDays(evaluator.freezeAfterDays));
  }
}

final Provider<FreezeLookup> freezeLookupProvider = Provider<FreezeLookup>((
  Ref ref,
) {
  final SpaceClock clock = ref.watch(spaceClockProvider);
  return FreezeLookup(
    periods: <String, BudgetPeriod>{
      for (final BudgetPeriod p
          in ref.watch(spacePeriodsProvider).value ?? const <BudgetPeriod>[])
        p.id: p,
    },
    today: clock.today(),
    nowUtc: clock.nowUtc(),
  );
});
