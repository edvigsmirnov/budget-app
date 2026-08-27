import 'package:drift/drift.dart' show Value;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/category_repository.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/categories/category_colors.dart';

/// Add or edit a category (spec 7).
Future<void> showCategorySheet(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (BuildContext _) => _CategorySheet(category: category),
);

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({this.category});

  final Category? category;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.category?.title ?? '',
  );
  late String? _color = widget.category?.color;
  late ExpenseType _type = widget.category?.expenseType ?? ExpenseType.variable;

  /// Null until the freeze check has run; the title field stays disabled
  /// meanwhile rather than flickering from editable to locked.
  bool? _canRename;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _checkRename();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _checkRename() async {
    final Category? existing = widget.category;
    if (existing == null) {
      setState(() => _canRename = true);
      return;
    }
    final bool allowed = await ref
        .read(repositoriesProvider)
        .categories
        .canRename(existing.id);
    if (mounted) setState(() => _canRename = allowed);
  }

  Future<void> _save() async {
    final CategoryRepository repo = ref.read(repositoriesProvider).categories;
    final Category? existing = widget.category;

    if (existing == null) {
      await repo.create(
        spaceId: ref.read(currentSpaceProvider)!.id,
        title: _title.text,
        color: _color,
        expenseType: _type,
      );
    } else {
      // Colour and type are always editable; the title only while nothing
      // visible binds to it (spec 7).
      await repo.updateAppearance(
        existing.id,
        color: Value<String?>(_color),
        expenseType: Value<ExpenseType>(_type),
      );
      if ((_canRename ?? false) && _title.text.trim() != existing.title) {
        await repo.rename(existing.id, _title.text);
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool renameAllowed = _canRename ?? false;

    return Padding(
      padding: EdgeInsets.only(
        left: SageSpace.formGutter,
        right: SageSpace.formGutter,
        top: SageSpace.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SageSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.category == null ? tr('category.add') : tr('category.edit'),
            style: text.titleMedium,
          ),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('category.fieldTitle'),
            child: TextField(
              controller: _title,
              enabled: renameAllowed,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          if (_canRename == false)
            Padding(
              padding: const EdgeInsets.only(top: SageSpace.xs),
              child: Text(tr('category.titleFrozen'), style: text.bodySmall),
            ),
          const SizedBox(height: SageSpace.lg),
          FieldLabel(tr('category.fieldColor')),
          Wrap(
            spacing: SageSpace.sm,
            runSpacing: SageSpace.sm,
            children: <Widget>[
              for (final String hex in categoryPalette)
                _Swatch(
                  hex: hex,
                  selected: _color == hex,
                  onTap: () => setState(() => _color = hex),
                ),
            ],
          ),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('category.fieldDefaultType'),
            child: SegmentedChoice<ExpenseType>(
              values: ExpenseType.values,
              selected: _type,
              labelOf: (ExpenseType t) => tr('expenseType.${t.name}'),
              onChanged: (ExpenseType t) => setState(() => _type = t),
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          FilledButton(
            onPressed: _title.text.trim().isEmpty ? null : _save,
            child: Text(tr('common.save')),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(SageRadius.pill),
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: parseCategoryColor(hex),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.sage.ink : Colors.transparent,
          width: 2,
        ),
      ),
    ),
  );
}
