import 'package:flutter/material.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// The disc with the Space's initial (design section 3.1).
///
/// The colour is derived from the id, so a Space keeps the same one for as
/// long as it exists. It is decoration, not status: the coverage dot beside it
/// in the switcher carries the meaning, and this palette stays clear of it.
///
/// The design shows a chosen icon here; that needs a column the schema does
/// not have yet, so the initial stands in rather than an empty placeholder.
class SpaceAvatar extends StatelessWidget {
  const SpaceAvatar({
    required this.spaceId,
    required this.title,
    this.size = 42,
    this.highlighted = false,
    super.key,
  });

  final String spaceId;
  final String title;
  final double size;

  /// The open Space wears a ring rather than a different fill, so the colour
  /// stays the Space's own identity.
  final bool highlighted;

  static const List<Color> _palette = <Color>[
    Color(0xFF6F9A74),
    Color(0xFFCB8B52),
    Color(0xFF6E8FA8),
    Color(0xFF8A7BA8),
    Color(0xFF5F7D7A),
    Color(0xFFA8748A),
  ];

  static Color colorOf(String spaceId) =>
      _palette[spaceId.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final String initial = title.trim().isEmpty
        ? '?'
        : title.trim().characters.first.toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorOf(spaceId),
        shape: BoxShape.circle,
        border: highlighted ? Border.all(color: sage.ink, width: 2) : null,
      ),
      child: Text(
        initial,
        style:
            (size >= 48
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.titleSmall)
                ?.copyWith(color: Colors.white),
      ),
    );
  }
}
