import 'package:flutter/material.dart';
import 'package:sielto/features/categories/category_icons.dart';

/// Category colours are user data, stored as `#rrggbb` text (spec 7).
///
/// They are deliberately not Sage tokens: the palette exists so a person can
/// tell their own categories apart at a glance, and it has to survive a theme
/// change unchanged. The swatches below are picked to stay legible on both
/// grounds.
const List<String> categoryPalette = <String>[
  '#8FB996',
  '#4C7A52',
  '#A34B3A',
  '#E29A5C',
  '#CBB98F',
  '#6E8FA8',
  '#8A6EA8',
  '#A86E8F',
  '#5F7D7A',
  '#9A9A6E',
];

/// A category's colour disc with its icon inside (design section 7).
///
/// The colour is what groups categories at a glance and the icon is what
/// separates two of the same colour, so they are drawn as one mark rather than
/// two competing ones. A category with no icon keeps the plain disc.
class CategoryMark extends StatelessWidget {
  const CategoryMark({
    required this.color,
    required this.icon,
    this.size = 34,
    super.key,
  });

  final String? color;
  final String? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color ground = parseCategoryColor(color) ?? const Color(0xFF8FB996);
    final String? glyph = sanitiseCategoryIcon(icon);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: ground, shape: BoxShape.circle),
      child: glyph == null
          ? null
          : Text(glyph, style: TextStyle(fontSize: size * 0.45)),
    );
  }
}

/// Parses `#rrggbb`. Returns null on anything else rather than throwing during
/// a build — a bad value must not take a screen down.
Color? parseCategoryColor(String? hex) {
  if (hex == null) return null;
  final String digits = hex.replaceFirst('#', '');
  if (digits.length != 6) return null;
  final int? value = int.tryParse(digits, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
