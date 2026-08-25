import 'package:budget_app/core/theme/sage_theme.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sage_contrast.dart';

/// Asserts the design rules in docs/IMPLEMENTATION_PLAN.md section 5, so a
/// token edit that breaks one fails the build.
void main() {
  group('theme wiring', () {
    test('both themes expose the token set', () {
      expect(SageTheme.light.extension<SageColors>(), same(SageColors.light));
      expect(SageTheme.dark.extension<SageColors>(), same(SageColors.dark));
    });

    test('brightness matches the palette it was built from', () {
      expect(SageTheme.light.brightness, Brightness.light);
      expect(SageTheme.dark.brightness, Brightness.dark);
    });

    test('scaffold sits on the surface token, never a Material default', () {
      expect(SageTheme.light.scaffoldBackgroundColor, SageColors.light.surface);
      expect(SageTheme.dark.scaffoldBackgroundColor, SageColors.dark.surface);
    });
  });

  group('rule 2 — theme-invariant tokens', () {
    // Filled sage buttons and the orange coverage dot render identically in
    // both themes.
    test('accent, accentOn and warningAccent do not vary by theme', () {
      expect(SageColors.dark.accent, SageColors.light.accent);
      expect(SageColors.dark.accentOn, SageColors.light.accentOn);
      expect(SageColors.dark.warningAccent, SageColors.light.warningAccent);
    });

    test('the filled button uses that invariant pair', () {
      for (final ThemeData theme in <ThemeData>[
        SageTheme.light,
        SageTheme.dark,
      ]) {
        final ButtonStyle? style = theme.filledButtonTheme.style;
        expect(
          style?.backgroundColor?.resolve(<WidgetState>{}),
          SageColors.light.accent,
        );
        expect(
          style?.foregroundColor?.resolve(<WidgetState>{}),
          SageColors.light.accentOn,
        );
      }
    });
  });

  group('rule 1 — roles swap, hues do not', () {
    test('accentStrong moves to the opposite end of the ramp', () {
      // Dark on light, pale on dark.
      final double lightL = relativeLuminance(SageColors.light.accentStrong);
      final double darkL = relativeLuminance(SageColors.dark.accentStrong);
      expect(darkL, greaterThan(lightL));
    });

    test('grounds keep a green bias rather than going neutral grey', () {
      // Green channel leads in every ground. A neutral theme has r == g == b.
      for (final Color ground in <Color>[
        SageColors.dark.canvas,
        SageColors.dark.surface,
        SageColors.dark.card,
        SageColors.dark.cardRaised,
      ]) {
        expect(
          ground.g,
          greaterThan(ground.r),
          reason: 'ground lost its green bias',
        );
        expect(
          ground.g,
          greaterThan(ground.b),
          reason: 'ground lost its green bias',
        );
      }
    });
  });

  group('rule 3 — elevation changes mechanism', () {
    test('light lifts with shadow, dark with a lighter ground', () {
      expect(
        SageColors.light.cardRaised,
        SageColors.light.card,
        reason: 'light elevation is carried by shadow, not by a second ground',
      );
      expect(
        relativeLuminance(SageColors.dark.cardRaised),
        greaterThan(relativeLuminance(SageColors.dark.card)),
        reason: 'dark elevation needs a genuinely lighter surface, shadows are invisible',
      );
    });
  });

  group('contrast', () {
    // No type here qualifies as WCAG "large text", so 4.5:1 applies.
    const double aaNormal = 4.5;

    for (final (String label, SageColors c) in <(String, SageColors)>[
      ('light', SageColors.light),
      ('dark', SageColors.dark),
    ]) {
      test('$label — primary text clears AA on every ground', () {
        for (final (String name, Color ground) in <(String, Color)>[
          ('canvas', c.canvas),
          ('surface', c.surface),
          ('card', c.card),
          ('cardRaised', c.cardRaised),
        ]) {
          expect(
            contrastRatio(c.ink, ground),
            greaterThanOrEqualTo(aaNormal),
            reason: 'ink on $name',
          );
          expect(
            contrastRatio(c.inkHeading, ground),
            greaterThanOrEqualTo(aaNormal),
            reason: 'inkHeading on $name',
          );
        }
      });

      test('$label — action and semantic text clears AA on card', () {
        expect(
          contrastRatio(c.accentStrong, c.card),
          greaterThanOrEqualTo(aaNormal),
          reason: 'accentStrong on card',
        );
        expect(
          contrastRatio(c.danger, c.card),
          greaterThanOrEqualTo(aaNormal),
          reason: 'danger on card',
        );
        expect(
          contrastRatio(c.warning, c.card),
          greaterThanOrEqualTo(aaNormal),
          reason: 'warning on card',
        );
      });

      test('$label — secondary and label text clears AA', () {
        // Light values were raised above the canvas alphas to reach this bar.
        for (final (String name, Color ground) in <(String, Color)>[
          ('canvas', c.canvas),
          ('surface', c.surface),
          ('card', c.card),
        ]) {
          expect(
            contrastRatio(c.inkSecondary, ground),
            greaterThanOrEqualTo(aaNormal),
            reason: 'inkSecondary on $name',
          );
          expect(
            contrastRatio(c.inkLabel, ground),
            greaterThanOrEqualTo(aaNormal),
            reason: 'inkLabel on $name',
          );
        }
      });

      test('$label — the ink hierarchy stays ordered', () {
        // Bumping the light alphas for AA must not flatten or invert this.
        final double primary = contrastRatio(c.ink, c.card);
        final double secondary = contrastRatio(c.inkSecondary, c.card);
        final double small = contrastRatio(c.inkLabel, c.card);
        expect(primary, greaterThan(secondary), reason: 'ink vs inkSecondary');
        expect(
          secondary,
          greaterThan(small),
          reason: 'inkSecondary vs inkLabel',
        );
      });

      test('$label — text on tinted grounds clears AA', () {
        expect(
          contrastRatio(c.ink, c.accentTint),
          greaterThanOrEqualTo(aaNormal),
          reason: 'ink on accentTint',
        );
        expect(
          contrastRatio(c.ink, c.dangerTint),
          greaterThanOrEqualTo(aaNormal),
          reason: 'ink on dangerTint',
        );
        expect(
          contrastRatio(c.accentOn, c.accent),
          greaterThanOrEqualTo(aaNormal),
          reason: 'accentOn on a solid accent fill',
        );
      });
    }
  });
}
