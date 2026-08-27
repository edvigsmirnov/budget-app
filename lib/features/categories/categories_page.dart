import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/category_repository.dart';
import 'package:sielto/core/db/repositories/payment_repository.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/dialogs.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/categories/category_colors.dart';
import 'package:sielto/features/categories/category_form_page.dart';
import 'package:sielto/features/space/space_ledger.dart';

/// The category list (spec 7): add, reorder, recolour, soft-delete with undo.
///
/// Renaming is missing from most rows on purpose — a title freezes once a
/// visible payment binds to it, and the repository refuses the write even if
/// the screen were routed around.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> categories =
        ref.watch(spaceCategoriesProvider).value ?? const <Category>[];

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(
        title: Text(tr('category.title')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: tr('category.add'),
            onPressed: () => openCategoryForm(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: categories.isEmpty
                ? EmptyState(message: tr('category.empty'))
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: EdgeInsets.zero,
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _CategoryTile(
                          key: ValueKey<String>(categories[index].id),
                          index: index,
                          category: categories[index],
                          onEdit: () => openCategoryForm(
                            context,
                            category: categories[index],
                          ),
                          onDelete: () =>
                              _delete(context, ref, categories[index]),
                        ),
                    onReorderItem: (int oldIndex, int newIndex) =>
                        _reorder(ref, categories, oldIndex, newIndex),
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
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final bool confirmed = await confirmDialog(
      context,
      title: tr('category.deleteTitle'),
      body: tr(
        'category.deleteBody',
        namedArgs: <String, String>{'title': category.title},
      ),
      confirmLabel: tr('common.delete'),
      isDestructive: true,
    );
    if (!confirmed) return;

    final CategoryRepository repo = ref.read(repositoriesProvider).categories;
    await repo.softDelete(category.id);
    if (!context.mounted) return;
    showUndoSnackbar(
      context,
      message: tr(
        'category.deleted',
        namedArgs: <String, String>{'title': category.title},
      ),
      onUndo: () => repo.restore(category.id),
    );
  }

  /// Renumbers the whole list with the standard gap. Cheap — a Space has tens
  /// of categories, not thousands — and it avoids hunting for a free slot.
  ///
  /// [newIndex] comes from `onReorderItem`, which reports the position after
  /// the dragged row was lifted out; no off-by-one correction is needed.
  Future<void> _reorder(
    WidgetRef ref,
    List<Category> categories,
    int oldIndex,
    int newIndex,
  ) async {
    final List<Category> ordered = List<Category>.of(categories);
    final Category moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);

    final CategoryRepository repo = ref.read(repositoriesProvider).categories;
    for (int i = 0; i < ordered.length; i++) {
      final int order = i * PaymentRepository.sortOrderGap;
      if (ordered[i].sortOrder == order) continue;
      await repo.updateAppearance(ordered[i].id, sortOrder: Value<int>(order));
    }
  }
}

/// One category: grip, mark, name, its default type, and a way in.
///
/// The grip leads rather than trails, because reordering categories is what
/// sets the order they are offered in when filing a payment — it is the row's
/// most-used control, not an afterthought (design section 7).
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.index,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final int index;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey<String>('dismiss:${category.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: sage.dangerTint,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: SageSpace.lg),
        child: Icon(Icons.delete_outline, size: 20, color: sage.danger),
      ),
      confirmDismiss: (DismissDirection _) async {
        onDelete();
        // The undo snackbar puts the row back, so the list is what decides
        // whether it is gone, not the dismiss animation.
        return false;
      },
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SageSpace.gutter,
            vertical: SageSpace.md,
          ),
          child: Row(
            children: <Widget>[
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator,
                  size: 20,
                  color: sage.inkLabel,
                ),
              ),
              const SizedBox(width: SageSpace.md),
              CategoryMark(color: category.color, icon: category.icon),
              const SizedBox(width: SageSpace.md),
              Expanded(
                child: Text(
                  category.title,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: SageSpace.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: sage.canvas,
                  borderRadius: BorderRadius.circular(SageRadius.pill),
                ),
                child: Text(
                  tr('expenseType.${category.expenseType.name}'),
                  style: text.labelSmall?.copyWith(color: sage.inkSecondary),
                ),
              ),
              const SizedBox(width: SageSpace.xs),
              Icon(Icons.chevron_right, size: 18, color: sage.inkLabel),
            ],
          ),
        ),
      ),
    );
  }
}
