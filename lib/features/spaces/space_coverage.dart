import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/space/period_ledger.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The coverage dot for every Space, so the switcher shows each one's state
/// without opening it (spec 4.4).
///
/// One walk per Space. That is affordable because Spaces are few — a person
/// keeps a household, a trip and a freelance ledger, not hundreds — and each
/// walk is linear in the records it sees.
///
/// A Space whose figure is uncomputable (a floating salary with no amount yet)
/// is absent from the map rather than guessed at: no dot is the honest answer.
final FutureProvider<Map<String, Coverage>> spaceCoverageProvider =
    FutureProvider<Map<String, Coverage>>((Ref ref) async {
      final List<Space> spaces =
          ref.watch(spaceListProvider).value ?? const <Space>[];
      final Repositories repos = ref.watch(repositoriesProvider);

      // Re-run when the records change, not only when the Space list does.
      ref.watch(spacePaymentsProvider);
      ref.watch(spaceIncomesProvider);

      final Map<String, Coverage> result = <String, Coverage>{};
      for (final Space space in spaces) {
        final Coverage? coverage = await _coverageOf(repos, space);
        if (coverage != null) result[space.id] = coverage;
      }
      return result;
    });

Future<Coverage?> _coverageOf(Repositories repos, Space space) async {
  final CalendarDate today = repos.spaces.clockFor(space).today();
  final List<Payment> payments = await repos.payments.inSpace(space.id);
  final List<Income> incomes = await repos.incomes.inSpace(space.id);

  if (space.budgetMode != BudgetMode.incomeDriven) {
    return buildFlowLedger(
      space: space,
      payments: payments,
      incomes: incomes,
      today: today,
    ).coverage;
  }

  final List<BudgetPeriod> periods = await repos.periods.incomeDrivenIn(
    space.id,
  );
  final BudgetPeriod? current = periods
      .where(
        (BudgetPeriod p) =>
            !p.startDate.isAfter(today) &&
            (p.endDate == null || !p.endDate!.isBefore(today)),
      )
      .firstOrNull;
  // No period yet means no anchor income yet, which is a valid state with
  // nothing to report (spec 4.7).
  if (current == null) return null;

  final List<IncomeRecurrenceRule> rules = await repos.incomeRules.inSpace(
    space.id,
  );
  return buildPeriodLedger(
    period: current,
    payments: payments,
    incomes: incomes,
    anchorRuleIds: <String>{
      for (final IncomeRecurrenceRule r in rules)
        if (r.isAnchor) r.id,
    },
    today: today,
  ).coverage;
}
