/// Enumerated columns, stored as text.
///
/// Text rather than ordinals: the sync contract is additive forever
/// (plan section 4, M1; spec 10.6), and a renumbered ordinal would silently
/// reinterpret existing rows on an older client. Names are the wire format —
/// add cases, never rename or remove them.
library;

/// How a Space computes periods. Set once at creation, never updated.
enum BudgetMode { incomeDriven, budget, flow }

/// Where a Space lives. Not the per-row sync state — see [SyncStatus].
enum StorageMode { local, cloud }

/// Deliberately cosmetic; drives nothing in the engine.
enum SpaceType { personal, family, trip, project, custom }

/// Row order within a day in the Feed.
enum FeedOrderMode { grouped, free }

enum ExpenseType { mandatory, variable }

/// Whether a payment's period was resolved automatically or pinned by hand.
enum PeriodAssignment { auto, manual }

enum SyncStatus { none, pending, synced }

/// `continuous` is the single open row Flow and Budget share; `incomeDriven`
/// is one row per income cycle.
enum PeriodType { continuous, incomeDriven }

enum ScheduleType { fixedDate, weekdayRule, dateRange, boundaryDays }

/// No `fifth`: every month has four of each weekday and a last one, so the
/// enum guarantees a schedule always resolves (spec 4.7).
enum WeekdayOrdinal { first, second, third, fourth, last }

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// Which end of the month `boundary_days` counts from.
enum BoundaryAnchor { start, end }
