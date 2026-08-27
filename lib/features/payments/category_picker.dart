import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/categories/category_colors.dart';
import 'package:sielto/features/categories/category_form_page.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The category on the payment form: a row that opens the picker (spec 7).
///
/// Never a free-text field. Typing the name again is exactly how the
/// duplicates and misspellings this app exists to avoid get in.
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
    final SageColors sage = context.sage;
    final List<Category> categories =
        ref.watch(spaceCategoriesProvider).value ?? const <Category>[];
    final Category? selected = categories
        .where((Category c) => c.id == selectedId)
        .firstOrNull;

    return InkWell(
      onTap: () async {
        final CategoryChoice? choice = await pickCategory(
          context,
          selectedId: selectedId,
        );
        if (choice != null) onChanged(choice.category);
      },
      borderRadius: BorderRadius.circular(SageRadius.input),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sage.card,
          borderRadius: BorderRadius.circular(SageRadius.input),
          border: Border.all(color: sage.border),
        ),
        child: Row(
          children: <Widget>[
            if (selected == null)
              Icon(Icons.label_outline, size: 20, color: sage.inkLabel)
            else
              CategoryMark(
                color: selected.color,
                icon: selected.icon,
                size: 26,
              ),
            const SizedBox(width: SageSpace.md),
            Expanded(
              child: Text(
                selected?.title ?? tr('category.none'),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected == null ? sage.inkLabel : sage.ink,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: sage.inkLabel),
          ],
        ),
      ),
    );
  }
}

/// What the picker returns. Null [category] is the "no category" row, which is
/// a choice — distinct from backing out, which returns null overall.
@immutable
class CategoryChoice {
  const CategoryChoice(this.category);

  final Category? category;
}

Future<CategoryChoice?> pickCategory(
  BuildContext context, {
  required String? selectedId,
}) => Navigator.of(context).push(
  MaterialPageRoute<CategoryChoice>(
    builder: (BuildContext _) => _CategoryPickerPage(selectedId: selectedId),
  ),
);

/// The picker screen (design section 6.2): search, then the categories grouped
/// by the type they default to.
///
/// Grouped rather than one flat list because the two behave differently in the
/// cascade — mandatory first, then variable — so the grouping is the same
/// distinction the figures are built on, not a filing convenience.
class _CategoryPickerPage extends ConsumerStatefulWidget {
  const _CategoryPickerPage({required this.selectedId});

  final String? selectedId;

  @override
  ConsumerState<_CategoryPickerPage> createState() =>
      _CategoryPickerPageState();
}

class _CategoryPickerPageState extends ConsumerState<_CategoryPickerPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final List<Category> all =
        ref.watch(spaceCategoriesProvider).value ?? const <Category>[];

    final String query = _query.trim().toLowerCase();
    final List<Category> shown = query.isEmpty
        ? all
        : all
              .where((Category c) => c.title.toLowerCase().contains(query))
              .toList();

    List<Category> ofType(ExpenseType type) =>
        shown.where((Category c) => c.expenseType == type).toList();

    final List<Category> mandatory = ofType(ExpenseType.mandatory);
    final List<Category> variable = ofType(ExpenseType.variable);

    return Scaffold(
      backgroundColor: sage.surface,
      appBar: AppBar(title: Text(tr('category.pick'))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(SageSpace.gutter),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: tr('category.search'),
                  isDense: true,
                ),
                onChanged: (String value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _Row(
                    title: tr('category.none'),
                    selected: widget.selectedId == null,
                    onTap: () =>
                        Navigator.of(context).pop(const CategoryChoice(null)),
                  ),
                  if (mandatory.isNotEmpty)
                    _GroupLabel(tr('expenseType.mandatory')),
                  for (final Category c in mandatory) _categoryRow(c),
                  if (variable.isNotEmpty)
                    _GroupLabel(tr('expenseType.variable')),
                  for (final Category c in variable) _categoryRow(c),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SageSpace.gutter),
              child: DashedButton(
                label: '+ ${tr('category.add')}',
                onTap: () => openCategoryForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(Category category) => _Row(
    title: category.title,
    mark: CategoryMark(color: category.color, icon: category.icon, size: 30),
    selected: category.id == widget.selectedId,
    onTap: () => Navigator.of(context).pop(CategoryChoice(category)),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.selected,
    required this.onTap,
    this.mark,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Widget? mark;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? sage.accentTint : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: SageSpace.gutter,
          vertical: SageSpace.md,
        ),
        child: Row(
          children: <Widget>[
            mark ?? Icon(Icons.block, size: 20, color: sage.inkLabel),
            const SizedBox(width: SageSpace.md),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (selected) Icon(Icons.check, size: 20, color: sage.accentStrong),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SageSpace.gutter,
      SageSpace.lg,
      SageSpace.gutter,
      SageSpace.xs,
    ),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall,
    ),
  );
}
