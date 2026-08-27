import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/features/categories/category_colors.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// Category selection on the payment form (spec 7).
///
/// A grid of existing categories, never a free-text field: typing the name
/// again is exactly how the duplicates and misspellings this app exists to
/// avoid get in.
class CategoryPickerField extends ConsumerWidget {
  const CategoryPickerField({
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final String? selectedId;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories =
        ref.watch(spaceCategoriesProvider).value ?? const <Category>[];

    return Wrap(
      spacing: SageSpace.sm,
      runSpacing: SageSpace.sm,
      children: <Widget>[
        _CategoryChip(
          label: tr('category.none'),
          color: context.sage.inkLabel,
          selected: selectedId == null,
          onTap: () => onChanged(null),
        ),
        for (final Category category in categories)
          _CategoryChip(
            label: category.title,
            color:
                parseCategoryColor(category.color) ?? context.sage.accentStrong,
            selected: category.id == selectedId,
            onTap: () => onChanged(category),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SageRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? sage.accentTint : sage.card,
          borderRadius: BorderRadius.circular(SageRadius.pill),
          border: Border.all(color: selected ? sage.accent : sage.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: SageSpace.sm),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
