import 'package:budget_app/core/db/converters.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:drift/drift.dart';

/// Local schema, mirroring the Postgres definitions in the spec.
///
/// Two rules hold everywhere, from v1, while the app is still fully offline
/// (plan section 2, invariants 2 and 3):
///   - every syncable table carries the five sync columns, so turning a Space
///     cloud-side is a mode change and not a migration;
///   - primary keys are UUIDv4 generated on the device, never autoincrement,
///     so two offline devices cannot mint the same id.
///
/// Changes to synced tables are additive forever (spec 10.6): add nullable
/// columns, never rename or drop.

/// The five columns every syncable table carries (spec 10.2).
mixin SyncColumns on Table {
  /// Soft delete. Every read filters on this; see `SyncedRepository`.
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant<bool>(false))();

  TextColumn get syncStatus => textEnum<SyncStatus>()
      .named('sync_status')
      .withDefault(const Constant<String>('none'))();

  /// Author of the last edit, for conflict toasts (spec 10.4).
  TextColumn get lastModifiedBy =>
      text().named('last_modified_by').nullable()();

  /// Device clock at the moment of the edit, and the basis for LWW. Doubles as
  /// the local 'last modified'; there is no separate updated_at.
  DateTimeColumn get clientEditedAt => dateTime().named('client_edited_at')();

  /// Set by a Supabase trigger on receipt. Null until a row has been uploaded.
  DateTimeColumn get serverReceivedAt =>
      dateTime().named('server_received_at').nullable()();
}

/// A Space. `budgetMode` has no update path anywhere in the app by design
/// (spec 3.1) — it is an architectural guarantee, not a UX convention.
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get spaceType => textEnum<SpaceType>().named('space_type')();
  TextColumn get budgetMode => textEnum<BudgetMode>().named('budget_mode')();
  TextColumn get ownerId => text().named('owner_id')();

  /// Named storage_mode, not sync_status, to keep it distinct from the
  /// per-row sync state (spec 3.1).
  TextColumn get storageMode => textEnum<StorageMode>().named('storage_mode')();

  /// Overrides the global default when resolving holidays (spec 5.1.1).
  TextColumn get countryCode => text().named('country_code').nullable()();

  /// One 'today' for every member, regardless of where they are
  /// (plan section 2, invariant 7).
  TextColumn get timezone => text()();

  /// Frozen after the first record (spec 9.2).
  TextColumn get currencyCode => text().named('currency_code')();

  /// 0 disables invites. Null is reserved for 'no limit' and is written by a
  /// separate UPDATE rather than stored as 0 (spec 3.4).
  IntColumn get maxMembers => integer()
      .named('max_members')
      .nullable()
      .withDefault(const Constant<int>(0))();

  /// Read-only local archive. Never uploaded.
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant<bool>(false))();

  /// Flow's 'money I have now' (spec 4.6). Budget uses budget_target instead.
  TextColumn get manualBalance =>
      text().named('manual_balance').nullable().map(const DecimalConverter())();

  DateTimeColumn get manualBalanceUpdatedAt =>
      dateTime().named('manual_balance_updated_at').nullable()();

  /// Raised only with creator consent (spec 10.6, plan G6).
  IntColumn get minSchemaVersion => integer()
      .named('min_schema_version')
      .withDefault(const Constant<int>(1))();

  TextColumn get feedOrderMode => textEnum<FeedOrderMode>()
      .named('feed_order_mode')
      .withDefault(const Constant<String>('grouped'))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (length(trim(title)) > 0)',
    'CHECK (manual_balance IS NULL OR CAST(manual_balance AS REAL) >= 0)',
    'CHECK (max_members IS NULL OR max_members >= 0)',
  ];
}

/// Membership only. Public nickname lives in [UserProfiles], private notes in
/// [MemberLocalLabels] (spec 6.6).
class SpaceMembers extends Table {
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();
  TextColumn get userId => text().named('user_id')();
  DateTimeColumn get joinedAt => dateTime().named('joined_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{spaceId, userId};
}

/// Private per-viewer notes about another member. Syncs between the viewer's
/// own devices and is invisible to everyone else, including the Space creator
/// (spec 3.2).
class MemberLocalLabels extends Table with SyncColumns {
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();
  TextColumn get viewerUserId => text().named('viewer_user_id')();
  TextColumn get targetUserId => text().named('target_user_id')();
  TextColumn get localName => text().named('local_name').nullable()();
  TextColumn get localRole => text().named('local_role').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    spaceId,
    viewerUserId,
    targetUserId,
  };
}

/// Public nickname, shared with everyone in a common Space. Written locally at
/// onboarding and uploaded lazily on the first cloud Space (spec 3.2).
class UserProfiles extends Table with SyncColumns {
  TextColumn get userId => text().named('user_id')();
  TextColumn get nickname => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{userId};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (length(trim(nickname)) > 0)',
  ];
}

/// User-defined, never built in. The title freezes once a visible payment
/// binds to it; colour, icon and default type stay editable (spec 7).
class Categories extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();
  TextColumn get title => text()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();

  /// Default for new payments only. Existing rows keep their own value.
  TextColumn get expenseType => textEnum<ExpenseType>()
      .named('expense_type')
      .withDefault(const Constant<String>('variable'))();

  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant<int>(0))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (length(trim(title)) > 0)',
  ];
}

/// Period boundaries — the single source of truth for all three modes
/// (spec 4.7). Flow and Budget each hold exactly one `continuous` row with a
/// null end_date, which is why freezing never applies to them.
class BudgetPeriods extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();
  TextColumn get periodType => textEnum<PeriodType>().named('period_type')();

  TextColumn get startDate =>
      text().named('start_date').map(const CalendarDateConverter())();

  /// Null for `continuous`: the context never closes.
  TextColumn get endDate =>
      text().named('end_date').nullable().map(const CalendarDateConverter())();

  /// Anchor income uncertainty window (spec 5.1.1). Null for `continuous`.
  TextColumn get windowStart => text()
      .named('window_start')
      .nullable()
      .map(const CalendarDateConverter())();

  TextColumn get windowEnd => text()
      .named('window_end')
      .nullable()
      .map(const CalendarDateConverter())();

  /// resolveIncomeWindow's result, stored rather than recomputed per render.
  TextColumn get anchorDate => text()
      .named('anchor_date')
      .nullable()
      .map(const CalendarDateConverter())();

  /// The window was computed without holiday data and may still narrow.
  BoolColumn get holidayDataIncomplete => boolean()
      .named('holiday_data_incomplete')
      .withDefault(const Constant<bool>(false))();

  /// Budget mode's event date (spec 4.8). Null elsewhere.
  TextColumn get deadlineDate => text()
      .named('deadline_date')
      .nullable()
      .map(const CalendarDateConverter())();

  BoolColumn get deadlineIsHard => boolean()
      .named('deadline_is_hard')
      .withDefault(const Constant<bool>(false))();

  TextColumn get budgetTarget =>
      text().named('budget_target').nullable().map(const DecimalConverter())();

  /// Temporary unfreeze of a closed period (spec 5.5).
  DateTimeColumn get unfrozenUntil =>
      dateTime().named('unfrozen_until').nullable()();

  TextColumn get unfreezeReason => text().named('unfreeze_reason').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    // Minimum period length is one day; degenerate periods merge instead
    // (spec 4.7, 'Convention for period boundaries').
    'CHECK (end_date IS NULL OR end_date >= start_date)',
    'CHECK (window_end IS NULL OR window_start IS NULL OR window_end >= window_start)',
    'CHECK (budget_target IS NULL OR CAST(budget_target AS REAL) >= 0)',
  ];
}

/// Repetition rule for regular incomes. One-off incomes do not use it at all
/// (spec 5.2).
class IncomeRecurrenceRules extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();
  TextColumn get title => text()();

  /// Null when the amount floats (spec 4.7, floating salary).
  TextColumn get amount => text().nullable().map(const DecimalConverter())();

  /// Only meaningful in income_driven Spaces; the form hides it elsewhere.
  BoolColumn get isAnchor =>
      boolean().named('is_anchor').withDefault(const Constant<bool>(false))();

  TextColumn get scheduleType =>
      textEnum<ScheduleType>().named('schedule_type')();

  /// fixed_date
  IntColumn get fixedDay => integer().named('fixed_day').nullable()();

  /// weekday_rule
  TextColumn get weekdayOrdinal =>
      textEnum<WeekdayOrdinal>().named('weekday_ordinal').nullable()();
  TextColumn get weekdayDay =>
      textEnum<Weekday>().named('weekday_day').nullable()();

  /// date_range
  IntColumn get dateRangeStart =>
      integer().named('date_range_start').nullable()();
  IntColumn get dateRangeEnd => integer().named('date_range_end').nullable()();

  /// boundary_days
  TextColumn get boundaryAnchor =>
      textEnum<BoundaryAnchor>().named('boundary_anchor').nullable()();
  IntColumn get boundaryCount => integer().named('boundary_count').nullable()();

  /// Holiday calendar for this rule, overriding the Space country.
  TextColumn get countryCode => text().named('country_code').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (length(trim(title)) > 0)',
    'CHECK (amount IS NULL OR CAST(amount AS REAL) > 0)',
    'CHECK (fixed_day IS NULL OR (fixed_day BETWEEN 1 AND 31))',
    'CHECK (date_range_start IS NULL OR (date_range_start BETWEEN 1 AND 31))',
    'CHECK (date_range_end IS NULL OR (date_range_end BETWEEN 1 AND 31))',
    'CHECK (boundary_count IS NULL OR boundary_count > 0)',
    // Each schedule type carries its own fields and no others.
    "CHECK (schedule_type <> 'fixedDate' OR fixed_day IS NOT NULL)",
    "CHECK (schedule_type <> 'weekdayRule' OR (weekday_ordinal IS NOT NULL AND weekday_day IS NOT NULL))",
    "CHECK (schedule_type <> 'dateRange' OR (date_range_start IS NOT NULL AND date_range_end IS NOT NULL))",
    "CHECK (schedule_type <> 'boundaryDays' OR (boundary_anchor IS NOT NULL AND boundary_count IS NOT NULL))",
  ];
}

/// One expected or received inflow. Regular incomes are materialised here from
/// their rule, so each occurrence has its own is_paid, note and edits
/// (spec 5.2).
class Incomes extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();

  /// Null marks a one-off receipt.
  TextColumn get recurrenceRuleId => text()
      .named('recurrence_rule_id')
      .nullable()
      .references(IncomeRecurrenceRules, #id)();

  TextColumn get title => text()();
  TextColumn get amount => text().nullable().map(const DecimalConverter())();

  /// The anchor date from resolveIncomeWindow for regular incomes; the date
  /// the user picked for one-offs.
  TextColumn get expectedDate =>
      text().named('expected_date').map(const CalendarDateConverter())();

  /// When the money actually arrived, if it differed. Affects neither the
  /// period assignment nor the schedule (spec 5.4).
  TextColumn get actualDate => text()
      .named('actual_date')
      .nullable()
      .map(const CalendarDateConverter())();

  TextColumn get budgetPeriodId => text()
      .named('budget_period_id')
      .nullable()
      .references(BudgetPeriods, #id)();

  /// Manual order within the day in the Feed. Sparse, gap 1024, and
  /// deliberately not unique — the constraint would break on a feed-mode
  /// switch (plan G2). Ties break on id.
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant<int>(0))();

  /// Expected versus received.
  BoolColumn get isPaid =>
      boolean().named('is_paid').withDefault(const Constant<bool>(false))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (length(trim(title)) > 0)',
    'CHECK (amount IS NULL OR CAST(amount AS REAL) > 0)',
  ];
}

/// An expense. Always has a date — 'a payment always has a date' is an
/// invariant of the whole model (spec 6).
class Payments extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get spaceId => text().named('space_id').references(Spaces, #id)();

  TextColumn get budgetPeriodId => text()
      .named('budget_period_id')
      .nullable()
      .references(BudgetPeriods, #id)();

  /// `manual` pins the row to its period against recalculation (spec 5.3).
  TextColumn get periodAssignment => textEnum<PeriodAssignment>()
      .named('period_assignment')
      .withDefault(const Constant<String>('auto'))();

  TextColumn get categoryId =>
      text().named('category_id').nullable().references(Categories, #id)();

  /// Ties one occurrence to its repeating series (spec 6.3).
  TextColumn get groupRecurringId =>
      text().named('group_recurring_id').nullable()();

  TextColumn get title => text()();
  TextColumn get amount => text().map(const DecimalConverter())();

  TextColumn get dueDate =>
      text().named('due_date').map(const CalendarDateConverter())();

  TextColumn get expenseType => textEnum<ExpenseType>().named('expense_type')();

  /// See [Incomes.sortOrder] — sparse, not unique (plan G2).
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant<int>(0))();

  BoolColumn get isPaid =>
      boolean().named('is_paid').withDefault(const Constant<bool>(false))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (length(trim(title)) > 0)',
    // Zero is allowed: Budget mode uses a zero-amount payment as a to-do with
    // a deadline (spec 4.8, 6.7). Negative never is — the sign comes from the
    // record type, not the number.
    'CHECK (CAST(amount AS REAL) >= 0)',
  ];
}

/// Public holidays per country and year (spec 5.1.1). Device-local cache, not
/// Space data, so it carries no sync columns.
class HolidayCache extends Table {
  TextColumn get id => text()();
  TextColumn get countryCode => text().named('country_code')();
  IntColumn get year => integer()();

  /// JSON array of `YYYY-MM-DD`.
  TextColumn get holidayDates => text().named('holiday_dates')();

  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{countryCode, year},
  ];
}

/// Non-working days the user added by hand (spec 5.1.2). Stored per app, not
/// per Space, and applied to every Space using the same country.
class CustomNonWorkingDays extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().map(const CalendarDateConverter())();
  TextColumn get title => text().nullable()();

  /// Null applies the day to every country.
  TextColumn get countryCode => text().named('country_code').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{date, countryCode},
  ];
}
