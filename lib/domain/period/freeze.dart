import 'package:meta/meta.dart';
import 'package:sielto/domain/value/calendar_date.dart';

/// What may still be edited in a period (spec 5.5).
enum FreezeState {
  /// Everything is editable.
  open,

  /// Freezes within [FreezeEvaluator.warningDays] days. The dashboard warns,
  /// so a wrong figure can still be caught.
  closingSoon,

  /// Amount, date, paid status, type and deletion are read-only. The category
  /// of a payment and appended notes are still allowed.
  frozen,
}

/// Decides whether a period is frozen.
///
/// The flag is never stored. Computing it on demand removes the background job
/// that would otherwise have to stamp it, and removes the window in which a
/// stored flag and the real date disagree (spec 5.5).
///
/// "Today" always comes from the Space timezone. Two members in different
/// countries must not disagree about whether a period froze overnight.
@immutable
class FreezeEvaluator {
  const FreezeEvaluator({this.freezeAfterDays = 14, this.warningDays = 2});

  /// Days after a period ends before it freezes.
  final int freezeAfterDays;

  /// How long the warning shows before that.
  final int warningDays;

  /// [endDate] null means an open context — Flow and Budget. Those never
  /// freeze, and that is a consequence of having no end, not an exemption
  /// (spec 4.7).
  ///
  /// [unfrozenUntil] is the creator's 48-hour override; while it is in the
  /// future the period is open again.
  FreezeState evaluate({
    required CalendarDate? endDate,
    required CalendarDate today,
    required DateTime nowUtc,
    DateTime? unfrozenUntil,
  }) {
    if (endDate == null) return FreezeState.open;

    if (unfrozenUntil != null && nowUtc.isBefore(unfrozenUntil)) {
      return FreezeState.open;
    }

    final CalendarDate freezesOn = endDate.addDays(freezeAfterDays);
    // Frozen once the deadline is behind us; the SQL form is
    // `(end_date + 14 days) < today`.
    if (freezesOn.isBefore(today)) return FreezeState.frozen;

    if (!freezesOn.addDays(-warningDays).isAfter(today)) {
      return FreezeState.closingSoon;
    }
    return FreezeState.open;
  }

  bool isFrozen({
    required CalendarDate? endDate,
    required CalendarDate today,
    required DateTime nowUtc,
    DateTime? unfrozenUntil,
  }) =>
      evaluate(
        endDate: endDate,
        today: today,
        nowUtc: nowUtc,
        unfrozenUntil: unfrozenUntil,
      ) ==
      FreezeState.frozen;

  /// When an unfreeze started now would lapse.
  DateTime unfreezeExpiry(DateTime nowUtc) =>
      nowUtc.add(const Duration(hours: 48));

  /// Appends to a note without touching what is already there. A frozen period
  /// allows additions, never edits, so the original text stays as written
  /// (spec 5.5).
  static String appendNote(String? existing, String addition, CalendarDate on) {
    final String stamped = '[added ${on.toIso()}]: $addition';
    if (existing == null || existing.trim().isEmpty) return stamped;
    return '$existing\n---\n$stamped';
  }
}
