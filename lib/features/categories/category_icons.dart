import 'package:flutter/widgets.dart';

/// The icons offered for a category (spec 7).
///
/// Emoji rather than a glyph font: they carry their own colour, need no asset,
/// and render on every platform the app targets without a licence. The colour
/// swatch behind them stays the thing that groups a category at a glance —
/// the icon is what tells two green categories apart.
///
/// The list is a starting point, not a limit. A category may hold any short
/// string, so the picker's last slot takes whatever the user types.
const List<String> categoryIconChoices = <String>[
  '🛒',
  '🏠',
  '💡',
  '💳',
  '🚌',
  '🍽️',
  '💊',
  '👕',
  '🎬',
  '📱',
  '🎓',
  '🎁',
  '✈️',
  '🐾',
  '🔧',
  '💧',
];

/// Whether a stored icon is something this build can draw.
///
/// A row written by a newer version, or by hand, may hold anything. Rendering
/// is not the place to find that out, so the length is capped where a caller
/// reads it rather than where it is drawn.
String? sanitiseCategoryIcon(String? icon) {
  final String? trimmed = icon?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  // Two grapheme clusters is enough for a flag or a family; beyond that it is
  // no longer an icon and would break the row's layout.
  return trimmed.characters.length > 2 ? null : trimmed;
}
