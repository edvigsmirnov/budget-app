import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/budget_period_repository.dart';
import 'package:sielto/core/db/repositories/category_repository.dart';
import 'package:sielto/core/db/repositories/holiday_repository.dart';
import 'package:sielto/core/db/repositories/income_repository.dart';
import 'package:sielto/core/db/repositories/payment_repository.dart';
import 'package:sielto/core/db/repositories/space_repository.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/time/space_clock.dart';
import 'package:sielto/domain/value/calendar_date.dart';
import 'package:sielto/features/periods/holiday_service.dart';
import 'package:sielto/features/periods/period_service.dart';

/// Set once the database is open, by the startup path in main.dart.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>(
  (Ref ref) => throw StateError('databaseProvider was not overridden'),
);

/// Every repository.
///
/// The clock here is UTC on purpose. Repositories ask it for one thing only —
/// `nowUtc`, the stamp on every write — and that instant is the same in every
/// zone. "Today" is a different question, belongs to a Space, and is answered
/// by [spaceClockProvider]; keeping the two apart is also what stops the
/// repository graph from depending on which Space is open.
class Repositories {
  Repositories({
    required this.db,
    required SpaceClock clock,
    required String userId,
  }) : spaces = SpaceRepository(db: db, clock: clock),
       payments = PaymentRepository(db: db, clock: clock, userId: userId),
       incomes = IncomeRepository(db: db, clock: clock, userId: userId),
       incomeRules = IncomeRuleRepository(db: db, clock: clock, userId: userId),
       periods = BudgetPeriodRepository(db: db, clock: clock, userId: userId),
       holidays = HolidayRepository(db: db, clock: clock),
       customDays = CustomNonWorkingDayRepository(db: db, clock: clock) {
    categories = CategoryRepository(
      db: db,
      clock: clock,
      userId: userId,
      payments: payments,
    );
  }

  final AppDatabase db;
  final SpaceRepository spaces;
  final PaymentRepository payments;
  final IncomeRepository incomes;
  final IncomeRuleRepository incomeRules;
  final BudgetPeriodRepository periods;

  /// Reference data about a country rather than a user's records, so neither
  /// of these carries sync columns (spec 5.1.1, 5.1.2).
  final HolidayRepository holidays;
  final CustomNonWorkingDayRepository customDays;

  late final CategoryRepository categories;
}

final Provider<Repositories> repositoriesProvider = Provider<Repositories>(
  (Ref ref) => Repositories(
    db: ref.watch(databaseProvider),
    clock: SpaceClock(timezone: 'UTC'),
    userId: ref.watch(userIdProvider),
  ),
);

/// Every Space on this device, live.
final StreamProvider<List<Space>> spaceListProvider =
    StreamProvider<List<Space>>(
      (Ref ref) => ref.watch(repositoriesProvider).spaces.watchAll(),
    );

/// Which Space to open. Persisted so a relaunch lands where the user left off.
class CurrentSpaceIdController extends Notifier<String?> {
  @override
  String? build() => ref.watch(localSettingsProvider).currentSpaceId;

  Future<void> select(String? spaceId) async {
    await ref.read(localSettingsProvider).setCurrentSpaceId(spaceId);
    state = spaceId;
  }
}

final NotifierProvider<CurrentSpaceIdController, String?>
currentSpaceIdProvider = NotifierProvider<CurrentSpaceIdController, String?>(
  CurrentSpaceIdController.new,
);

/// The stored selection resolved against the Spaces that actually exist. Falls
/// back to the first Space when the stored id is gone, and to null when there
/// are none — which is what sends the user to onboarding.
final Provider<AsyncValue<Space?>> resolvedSpaceProvider =
    Provider<AsyncValue<Space?>>((Ref ref) {
      final String? selected = ref.watch(currentSpaceIdProvider);
      return ref.watch(spaceListProvider).whenData((List<Space> spaces) {
        if (spaces.isEmpty) return null;
        for (final Space space in spaces) {
          if (space.id == selected) return space;
        }
        return spaces.first;
      });
    });

/// The Space the app is showing, or null before one exists.
///
/// Deliberately a root-level provider rather than something scoped per
/// subtree: a scoped override reaches only the widgets that read it directly,
/// while every provider derived from it would still resolve against the root —
/// and silently see no Space at all.
final Provider<Space?> currentSpaceProvider = Provider<Space?>(
  (Ref ref) => ref.watch(resolvedSpaceProvider).value,
);

/// One definition of "today" per Space (plan section 2, invariant 7). Falls
/// back to UTC before a Space exists.
final Provider<SpaceClock> spaceClockProvider = Provider<SpaceClock>((Ref ref) {
  final Space? space = ref.watch(currentSpaceProvider);
  return SpaceClock(timezone: space?.timezone ?? 'UTC');
});

final Provider<HolidayService> holidayServiceProvider =
    Provider<HolidayService>((Ref ref) {
      final Repositories repos = ref.watch(repositoriesProvider);
      return HolidayService(
        holidays: repos.holidays,
        customDays: repos.customDays,
      );
    });

/// The days the user marked by hand, live. App-level, not per Space
/// (spec 5.1.2).
final StreamProvider<List<CustomNonWorkingDay>> customNonWorkingDaysProvider =
    StreamProvider<List<CustomNonWorkingDay>>(
      (Ref ref) => ref.watch(repositoriesProvider).customDays.watchAll(),
    );

/// Which days count as non-working when an income date is resolved
/// (spec 5.1.1).
///
/// The country is the Space's own if it set one, otherwise the global default,
/// otherwise none — the spec's three priority levels, resolved here so the
/// engine below never has to know about settings.
final FutureProvider<ResolvedCalendar> resolvedCalendarProvider =
    FutureProvider<ResolvedCalendar>((Ref ref) async {
      final Space? space = ref.watch(currentSpaceProvider);
      final CalendarDate today = ref.watch(spaceClockProvider).today();

      // Through the controllers, not the store: a store read would not rebuild
      // this when the setting changes.
      final String? defaultCountry = ref.watch(defaultCountryProvider);
      final bool consented = ref.watch(holidayConsentProvider) ?? false;
      final bool offline = ref.watch(offlineModeProvider);

      // Marking a day non-working has to change the answer immediately.
      ref.watch(customNonWorkingDaysProvider);

      return ref
          .watch(holidayServiceProvider)
          .resolve(
            countryCode: space?.countryCode ?? defaultCountry,
            // The horizon, not the calendar year: a monthly cycle materialised
            // in July already reaches into January (spec 5.1.1).
            years: <int>{
              today.year,
              today.addMonths(PeriodService.incomeHorizonMonths).year,
            },
            mayFetch: !offline && consented,
          );
    });

/// Brings periods and future occurrences up to date for the open Space.
///
/// Watched by the screens that need periods, so opening a Space is what
/// triggers the recompute. It reads the Space row and the clock, and neither
/// changes when it writes — so this cannot feed itself.
final FutureProvider<PeriodRefresh> periodRefreshProvider =
    FutureProvider<PeriodRefresh>((Ref ref) async {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const PeriodRefresh();

      // The calendar decides where every anchor lands, so it is resolved
      // before anything is written, not alongside.
      final ResolvedCalendar resolved = await ref.watch(
        resolvedCalendarProvider.future,
      );
      return PeriodService(
        repos: ref.watch(repositoriesProvider),
        calendar: resolved.calendar,
        missingHolidayYears: resolved.missingYears,
      ).refresh(space, ref.watch(spaceClockProvider).today());
    });

/// Every period of the open Space, live.
final StreamProvider<List<BudgetPeriod>> spacePeriodsProvider =
    StreamProvider<List<BudgetPeriod>>((Ref ref) {
      final Space? space = ref.watch(currentSpaceProvider);
      if (space == null) return const Stream<List<BudgetPeriod>>.empty();
      return ref.watch(repositoriesProvider).periods.watchInSpace(space.id);
    });

/// The open Space. Throws where there is none, which is a routing mistake
/// rather than a state a screen has to handle.
extension CurrentSpaceX on WidgetRef {
  Space get space =>
      watch(currentSpaceProvider) ?? (throw StateError('no Space is open'));
}
