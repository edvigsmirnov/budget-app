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
import 'package:sielto/features/categories/category_icons.dart';

/// Add or edit a category (spec 7, design section 7).
///
/// A screen rather than a sheet: the editor carries a colour row, an icon row
/// and a delete, and a sheet holding all of that is a screen wearing the wrong
/// clothes.
Future<void> openCategoryForm(BuildContext context, {Category? category}) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => CategoryFormPage(category: category),
      ),
    );

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({this.category, super.key});

  final Category? category;

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  late final TextEditingController _title = TextEditingController(
    text: widget.category?.title ?? '',
  );
  late String? _color = widget.category?.color ?? categoryPalette.first;
  late String? _icon = sanitiseCategoryIcon(widget.category?.icon);
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
        icon: _icon,
        expenseType: _type,
      );
    } else {
      // Colour, icon and type are always editable; the title only while
      // nothing visible binds to it (spec 7).
      await repo.updateAppearance(
        existing.id,
        color: Value<String?>(_color),
        icon: Value<String?>(_icon),
        expenseType: Value<ExpenseType>(_type),
      );
      if ((_canRename ?? false) && _title.text.trim() != existing.title) {
        await repo.rename(existing.id, _title.text);
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickCustomIcon() async {
    final String? typed = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const _CustomIconDialog(),
    );
    final String? cleaned = sanitiseCategoryIcon(typed);
    if (cleaned != null) setState(() => _icon = cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;
    final Category? existing = widget.category;
    final bool renameAllowed = _canRename ?? false;

    return Scaffold(
      backgroundColor: sage.surface,
      appBar: AppBar(
        title: Text(existing?.title ?? tr('category.add')),
        actions: <Widget>[
          TextButton(
            onPressed: _title.text.trim().isEmpty ? null : _save,
            child: Text(tr('common.save')),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SageSpace.formGutter),
          children: <Widget>[
            LabelledField(
              label: tr('category.fieldTitle'),
              child: TextField(
                controller: _title,
                enabled: renameAllowed,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  prefixIcon: _canRename == false
                      ? Icon(Icons.lock_outline, size: 18, color: sage.inkLabel)
                      : null,
                ),
              ),
            ),
            if (_canRename == false)
              Padding(
                padding: const EdgeInsets.only(top: SageSpace.xs),
                child: Text(
                  tr('category.titleFrozen'),
                  style: text.bodySmall?.copyWith(color: sage.warning),
                ),
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
            FieldLabel(tr('category.fieldIcon')),
            Wrap(
              spacing: SageSpace.sm,
              runSpacing: SageSpace.sm,
              children: <Widget>[
                for (final String glyph in categoryIconChoices)
                  _IconChoice(
                    glyph: glyph,
                    selected: _icon == glyph,
                    onTap: () => setState(() => _icon = glyph),
                  ),
                // Anything the list does not carry, typed in.
                _IconChoice(
                  glyph: '+',
                  selected: false,
                  onTap: _pickCustomIcon,
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

            const SizedBox(height: SageSpace.xl),
            FilledButton(
              onPressed: _title.text.trim().isEmpty ? null : _save,
              child: Text(tr('common.save')),
            ),
          ],
        ),
      ),
    );
  }
}

/// A colour, as a disc that shows the chosen icon on it.
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
    customBorder: const CircleBorder(),
    child: Container(
      width: 38,
      height: 38,
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

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

  final String glyph;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SageRadius.button),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sage.card,
          borderRadius: BorderRadius.circular(SageRadius.button),
          border: Border.all(
            color: selected ? sage.accentStrong : sage.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(glyph, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

/// One emoji, typed rather than chosen.
class _CustomIconDialog extends StatefulWidget {
  const _CustomIconDialog();

  @override
  State<_CustomIconDialog> createState() => _CustomIconDialogState();
}

class _CustomIconDialogState extends State<_CustomIconDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: context.sage.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SageRadius.card),
    ),
    title: Text(
      tr('category.fieldIcon'),
      style: Theme.of(context).textTheme.titleMedium,
    ),
    content: TextField(
      controller: _controller,
      autofocus: true,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 28),
      decoration: InputDecoration(hintText: tr('category.iconHint')),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(tr('common.cancel')),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: Text(tr('common.save')),
      ),
    ],
  );
}
