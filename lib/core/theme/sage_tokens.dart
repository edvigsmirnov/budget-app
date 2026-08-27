import 'package:flutter/material.dart';

/// Sage design tokens.
///
/// Light values come from the design canvas. Dark values are derived by role,
/// not inverted. See docs/IMPLEMENTATION_PLAN.md section 5.
///
/// Rules, enforced by test/core/theme/sage_theme_test.dart:
///   1. Roles swap, hues don't.
///   2. [accent], [accentOn] and [warningAccent] are identical in both themes.
///   3. Elevation: shadow on light, [cardRaised] on dark.
///   4. Dark grounds keep a green bias.
///   5. No colour literals outside this file. Use `context.sage.<token>`.
@immutable
class SageColors extends ThemeExtension<SageColors> {
  const SageColors({
    required this.canvas,
    required this.surface,
    required this.card,
    required this.cardRaised,
    required this.ink,
    required this.inkHeading,
    required this.inkSecondary,
    required this.inkLabel,
    required this.hairline,
    required this.border,
    required this.accent,
    required this.accentStrong,
    required this.accentFill,
    required this.accentOn,
    required this.accentTint,
    required this.accentTintAlt,
    required this.danger,
    required this.dangerTint,
    required this.warning,
    required this.warningAccent,
    required this.warningTint,
    required this.sand,
    required this.sandTint,
  });

  /// Outer canvas, sheet backdrop.
  final Color canvas;

  /// App background.
  final Color surface;

  /// Cards, inputs, rows.
  final Color card;

  /// Raised surface. Equals [card] on light, where shadow carries elevation.
  final Color cardRaised;

  /// Primary text.
  final Color ink;

  /// Section headings.
  final Color inkHeading;

  /// Secondary text.
  final Color inkSecondary;

  /// Field labels. Holds 4.5:1 at 10px in both themes.
  final Color inkLabel;

  /// Row dividers.
  final Color hairline;

  /// Input and segment borders.
  final Color border;

  /// Theme-invariant. Fill on light; fill and text on dark.
  final Color accent;

  /// Positive figures, primary action text. Green coverage dot.
  final Color accentStrong;

  /// Filled surface sitting behind accent text.
  ///
  /// It has **no theme-invariant foreground**: it is a light green on light
  /// and a dark green on dark, so it needs [accentOn] in one theme and
  /// [accentStrong] in the other. A widget that wants one fill and one
  /// foreground across both themes uses [accent] with [accentOn] instead —
  /// pairing this token with [accentOn] renders dark-on-dark.
  final Color accentFill;

  /// Theme-invariant. Foreground on a solid [accent] fill.
  final Color accentOn;

  /// Selected-card background.
  final Color accentTint;

  /// Icon chips, secondary tint.
  final Color accentTintAlt;

  /// Overspend, destructive actions. Red coverage dot.
  final Color danger;

  /// Overdue section background.
  final Color dangerTint;

  /// Warning text.
  final Color warning;

  /// Theme-invariant. Orange coverage dot: covered exactly, nothing spare.
  final Color warningAccent;

  /// Warning wash.
  final Color warningTint;

  /// Income-uncertainty band, neutral markers.
  final Color sand;

  /// Band fill.
  final Color sandTint;

  /// From the design canvas.
  static const SageColors light = SageColors(
    canvas: Color(0xFFEEF1EA),
    surface: Color(0xFFF5F7F1),
    card: Color(0xFFFFFFFF),
    cardRaised: Color(0xFFFFFFFF),
    ink: Color(0xFF2B2F28),
    inkHeading: Color(0xFF243226),
    // Raised from canvas .60/.50, which measured 3.69:1 and 3.0:1 against a
    // 4.5:1 AA bar. Ordering preserved: secondary darker than labels.
    inkSecondary: Color(0xC72B2F28), // ink @ .78 -> 6.20:1 on canvas
    inkLabel: Color(0xAC2B2F28), // ink @ .675 -> 4.55:1 on canvas
    hairline: Color(0x142B2F28), // ink @ .08
    border: Color(0x262B2F28), // ink @ .15
    accent: Color(0xFF8FB996),
    accentStrong: Color(0xFF4C7A52),
    accentFill: Color(0xFF8FB996),
    accentOn: Color(0xFF1E3921),
    accentTint: Color(0xFFEEF5EC),
    accentTintAlt: Color(0xFFE6ECDF),
    danger: Color(0xFFA34B3A),
    dangerTint: Color(0xFFF7E3DE),
    warning: Color(0xFFA35A1F),
    warningAccent: Color(0xFFE29A5C),
    warningTint: Color(0xFFF7EBDD),
    sand: Color(0xFFCBB98F),
    sandTint: Color(0xFFD8C9A8),
  );

  /// Derived by role. Not an inversion.
  static const SageColors dark = SageColors(
    canvas: Color(0xFF131813),
    surface: Color(0xFF171D18),
    card: Color(0xFF1E251F),
    cardRaised: Color(0xFF252D26),
    ink: Color(0xFFE3EAE0),
    inkHeading: Color(0xFFEEF3EC),
    inkSecondary: Color(0xFFA9B5A6),
    inkLabel: Color(0xFF8B9889),
    hairline: Color(0x17E3EAE0), // paper @ .09
    border: Color(0x29E3EAE0), // paper @ .16
    accent: Color(0xFF8FB996),
    accentStrong: Color(0xFFA8CFAD),
    accentFill: Color(0xFF2F5434),
    accentOn: Color(0xFF1E3921),
    accentTint: Color(0xFF26362A),
    accentTintAlt: Color(0xFF2B382C),
    danger: Color(0xFFDD9B8C),
    dangerTint: Color(0xFF33231E),
    warning: Color(0xFFDFA570),
    warningAccent: Color(0xFFE29A5C),
    warningTint: Color(0xFF322517),
    sand: Color(0xFFC4B189),
    sandTint: Color(0xFF2E2A1F),
  );

  @override
  SageColors copyWith({
    Color? canvas,
    Color? surface,
    Color? card,
    Color? cardRaised,
    Color? ink,
    Color? inkHeading,
    Color? inkSecondary,
    Color? inkLabel,
    Color? hairline,
    Color? border,
    Color? accent,
    Color? accentStrong,
    Color? accentFill,
    Color? accentOn,
    Color? accentTint,
    Color? accentTintAlt,
    Color? danger,
    Color? dangerTint,
    Color? warning,
    Color? warningAccent,
    Color? warningTint,
    Color? sand,
    Color? sandTint,
  }) {
    return SageColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardRaised: cardRaised ?? this.cardRaised,
      ink: ink ?? this.ink,
      inkHeading: inkHeading ?? this.inkHeading,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkLabel: inkLabel ?? this.inkLabel,
      hairline: hairline ?? this.hairline,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentFill: accentFill ?? this.accentFill,
      accentOn: accentOn ?? this.accentOn,
      accentTint: accentTint ?? this.accentTint,
      accentTintAlt: accentTintAlt ?? this.accentTintAlt,
      danger: danger ?? this.danger,
      dangerTint: dangerTint ?? this.dangerTint,
      warning: warning ?? this.warning,
      warningAccent: warningAccent ?? this.warningAccent,
      warningTint: warningTint ?? this.warningTint,
      sand: sand ?? this.sand,
      sandTint: sandTint ?? this.sandTint,
    );
  }

  @override
  SageColors lerp(ThemeExtension<SageColors>? other, double t) {
    if (other is! SageColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return SageColors(
      canvas: c(canvas, other.canvas),
      surface: c(surface, other.surface),
      card: c(card, other.card),
      cardRaised: c(cardRaised, other.cardRaised),
      ink: c(ink, other.ink),
      inkHeading: c(inkHeading, other.inkHeading),
      inkSecondary: c(inkSecondary, other.inkSecondary),
      inkLabel: c(inkLabel, other.inkLabel),
      hairline: c(hairline, other.hairline),
      border: c(border, other.border),
      accent: c(accent, other.accent),
      accentStrong: c(accentStrong, other.accentStrong),
      accentFill: c(accentFill, other.accentFill),
      accentOn: c(accentOn, other.accentOn),
      accentTint: c(accentTint, other.accentTint),
      accentTintAlt: c(accentTintAlt, other.accentTintAlt),
      danger: c(danger, other.danger),
      dangerTint: c(dangerTint, other.dangerTint),
      warning: c(warning, other.warning),
      warningAccent: c(warningAccent, other.warningAccent),
      warningTint: c(warningTint, other.warningTint),
      sand: c(sand, other.sand),
      sandTint: c(sandTint, other.sandTint),
    );
  }
}

/// Corner radii from the Sage design canvas.
abstract final class SageRadius {
  static const double card = 14;
  static const double input = 11;
  static const double button = 12;
  static const double chip = 9;
  static const double pill = 100;
  static const double sheet = 30;
}

/// Spacing rhythm from the Sage design canvas.
abstract final class SageSpace {
  /// Vertical padding on a list row, above its hairline.
  static const double row = 9;

  /// Horizontal content gutter.
  static const double gutter = 16;

  /// Horizontal gutter inside forms.
  static const double formGutter = 18;

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
}

/// Shorthand for `Theme.of(context).extension<SageColors>()!`.
extension SageColorsX on BuildContext {
  SageColors get sage => Theme.of(this).extension<SageColors>()!;
}
