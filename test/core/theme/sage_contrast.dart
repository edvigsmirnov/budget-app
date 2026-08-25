import 'dart:math' as math;
import 'dart:ui';

/// WCAG 2.1 contrast helpers for the theme tests.

/// Composites a translucent [foreground] over an opaque [background].
/// Ink tokens carry alpha, so contrast must use the composited result.
Color composite(Color foreground, Color background) {
  final double a = foreground.a;
  double mix(double f, double b) => f * a + b * (1 - a);
  return Color.from(
    alpha: 1,
    red: mix(foreground.r, background.r),
    green: mix(foreground.g, background.g),
    blue: mix(foreground.b, background.b),
  );
}

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

/// Relative luminance per WCAG 2.1. Assumes an opaque colour.
double relativeLuminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// Contrast ratio between [foreground] (composited over [background]) and
/// [background]. Ranges from 1.0 to 21.0.
double contrastRatio(Color foreground, Color background) {
  final Color fg = composite(foreground, background);
  final double a = relativeLuminance(fg);
  final double b = relativeLuminance(background);
  final double lighter = math.max(a, b);
  final double darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}
