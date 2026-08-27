import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// Builds both [ThemeData] objects from the same [SageColors] token set, so
/// token-based widgets need no per-theme branching.
abstract final class SageTheme {
  static ThemeData get light => _build(SageColors.light, Brightness.light);

  static ThemeData get dark => _build(SageColors.dark, Brightness.dark);

  static ThemeData _build(SageColors c, Brightness brightness) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.accentStrong,
      onPrimary: c.accentOn,
      primaryContainer: c.accentTint,
      onPrimaryContainer: c.inkHeading,
      secondary: c.accent,
      onSecondary: c.accentOn,
      secondaryContainer: c.accentTintAlt,
      onSecondaryContainer: c.inkHeading,
      tertiary: c.sand,
      onTertiary: c.ink,
      error: c.danger,
      onError: c.accentOn,
      errorContainer: c.dangerTint,
      onErrorContainer: c.ink,
      surface: c.card,
      onSurface: c.ink,
      surfaceContainerLowest: c.canvas,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.card,
      surfaceContainerHigh: c.cardRaised,
      surfaceContainerHighest: c.cardRaised,
      onSurfaceVariant: c.inkSecondary,
      outline: c.border,
      outlineVariant: c.hairline,
    );

    // System font throughout; the ramp is weight and size, not typeface.
    // `fontFamily` stays null so each platform uses its own face.
    //
    // Sized for a real device, not for the design mock. The mock draws its
    // phone frames 300px wide against a 360-412dp screen, so its type is about
    // three quarters of what it should be — reading its px as dp made every
    // screen render small. The ramp below is the mock scaled by ~1.2, which
    // lands close to the Material defaults; keep it there when translating
    // anything else from the mock.
    final TextTheme text = TextTheme(
      // Dashboard hero figure.
      displaySmall: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
        color: c.ink,
      ),
      // Screen and section headings.
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: c.inkHeading,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: c.inkHeading,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: c.ink,
      ),
      // List rows, form values.
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: c.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.inkSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: c.inkSecondary,
      ),
      // Uppercase field labels: 600/10 with .04em tracking.
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: c.inkLabel,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.inkLabel,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surface,
      canvasColor: c.canvas,
      dividerColor: c.hairline,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[c],
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: c.card,
        // Rule 3: shadow on light, lighter ground on dark.
        elevation: brightness == Brightness.light ? 1 : 0,
        shadowColor: brightness == Brightness.light
            ? const Color(0x14000000)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SageRadius.card),
          side: brightness == Brightness.dark
              ? BorderSide(color: c.hairline)
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.inkHeading,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Rule 2: identical in both themes.
          backgroundColor: c.accent,
          foregroundColor: c.accentOn,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SageRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.accentStrong,
          textStyle: text.labelLarge,
          side: BorderSide(color: c.border),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SageRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentStrong,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: text.labelSmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SageRadius.input),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SageRadius.input),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SageRadius.input),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SageRadius.input),
          borderSide: BorderSide(color: c.danger),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.accentTintAlt,
        labelStyle: text.labelMedium,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SageRadius.pill),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SageRadius.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.cardRaised,
        contentTextStyle: text.bodyLarge,
        actionTextColor: c.accentStrong,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SageRadius.button),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accentTint,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(text.labelMedium),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SageSpace.gutter,
        ),
      ),
    );
  }
}
