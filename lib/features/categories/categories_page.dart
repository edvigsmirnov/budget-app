import 'package:budget_app/app/providers.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/repositories/category_repository.dart';
import 'package:budget_app/core/db/repositories/payment_repository.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/ui/dialogs.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/features/categories/category_colors.dart';
import 'package:budget_app/features/categories/category_form_sheet.dart';
import 'package:budget_app/features/space/space_ledger.dart';
import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(title: Text(tr('category.title'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategorySheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categories.isEmpty
          ? EmptyState(message: tr('category.empty'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) => _CategoryTile(
                key: ValueKey<String>(categories[index].id),
                category: categories[index],
                onEdit: () => showCategorySheet(
                  context,
                  ref,
                  category: categories[index],
                ),
                onDelete: () => _delete(context, ref, categories[index]),
              ),
              onReorderItem: (int oldIndex, int newIndex) =>
                  _reorder(ref, categories, oldIndex, newIndex),
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return ListTile(
      onTap: onEdit,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: parseCategoryColor(category.color) ?? sage.accent,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(category.title),
      subtitle: Text(tr('expenseType.${category.expenseType.name}')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: tr('common.delete'),
            onPressed: onDelete,
          ),
          Icon(Icons.drag_indicator, size: 18, color: sage.inkLabel),
        ],
      ),
    );
  }
}
