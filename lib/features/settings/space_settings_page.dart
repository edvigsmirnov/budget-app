import 'package:budget_app/app/providers.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/db/repositories/space_repository.dart';
import 'package:budget_app/core/format/currencies.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/ui/dialogs.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/domain/value/enums.dart';
import 'package:budget_app/features/categories/categories_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings for one Space (spec 3.4).
///
/// The Space is passed in rather than read from the app state: the Spaces list
/// opens this screen for a Space without switching to it (spec 3.4, entry
/// point 2).
///
/// Members, storage mode and the delete branch belong to M8 and M9 and are
/// absent. What is here is the base every member sees: name, the locked mode
/// badge, currency and timezone, and the Feed order.
class SpaceSettingsPage extends ConsumerStatefulWidget {
  const SpaceSettingsPage({required this.space, super.key});

  final Space space;

  @override
  ConsumerState<SpaceSettingsPage> createState() => _SpaceSettingsPageState();
}

class _SpaceSettingsPageState extends ConsumerState<SpaceSettingsPage> {
  late final TextEditingController _title = TextEditingController(
    text: widget.space.title,
  );

  /// Null while the check is in flight.
  bool? _currencyEditable;

  @override
  void initState() {
    super.initState();
    _checkCurrency();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _checkCurrency() async {
    final bool editable = await ref
        .read(repositoriesProvider)
        .spaces
        .canChangeCurrency(widget.space.id);
    if (mounted) setState(() => _currencyEditable = editable);
  }

  @override
  Widget build(BuildContext context) {
    // Re-read so an edit made here is reflected without leaving the screen.
    final Space space =
        ref
            .watch(spaceListProvider)
            .value
            ?.where((Space s) => s.id == widget.space.id)
            .firstOrNull ??
        widget.space;
    final bool isCurrent = ref.watch(currentSpaceProvider)?.id == space.id;
    final SpaceRepository repo = ref.watch(repositoriesProvider).spaces;
    final String locale = context.locale.toString();

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(title: Text(tr('spaceSettings.title'))),
      body: ListView(
        padding: const EdgeInsets.all(SageSpace.formGutter),
        children: <Widget>[
          LabelledField(
            label: tr('space.fieldTitle'),
            child: TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (String value) => repo.setTitle(space.id, value),
              onTapOutside: (PointerDownEvent _) =>
                  repo.setTitle(space.id, _title.text),
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('space.fieldMode'),
            child: SageCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      tr('mode.${space.budgetMode.name}.name'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: context.sage.inkLabel,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SageSpace.xs),
          Text(
            tr('space.modeIsPermanent'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('space.fieldCurrency'),
            child: DropdownButtonFormField<String>(
              initialValue: space.currencyCode,
              items: <DropdownMenuItem<String>>[
                for (final String code in Currencies.offered(
                  space.currencyCode,
                ))
                  DropdownMenuItem<String>(
                    value: code,
                    child: Text(Currencies.label(code, locale)),
                  ),
              ],
              onChanged: (_currencyEditable ?? false)
                  ? (String? code) async {
                      if (code == null) return;
                      await repo.setCurrency(space.id, code);
                    }
                  : null,
            ),
          ),
          if (_currencyEditable == false)
            Padding(
              padding: const EdgeInsets.only(top: SageSpace.xs),
              child: Text(
                tr('space.currencyFrozen'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('space.fieldTimezone'),
            child: SageCard(
              child: Text(
                space.timezone,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          LabelledField(
            label: tr('space.fieldFeedOrder'),
            child: SegmentedChoice<FeedOrderMode>(
              values: FeedOrderMode.values,
              selected: space.feedOrderMode,
              labelOf: (FeedOrderMode mode) => tr('feedOrder.${mode.name}'),
              onChanged: (FeedOrderMode mode) =>
                  repo.setFeedOrderMode(space.id, mode),
            ),
          ),
          const SizedBox(height: SageSpace.lg),
          // Categories are read for the open Space, so the link only makes
          // sense when this screen is showing that Space.
          if (isCurrent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.label_outline),
              title: Text(tr('category.title')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => const CategoriesPage(),
                ),
              ),
            ),
          const Hairline(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.archive_outlined, color: context.sage.danger),
            title: Text(
              tr('space.archive'),
              style: TextStyle(color: context.sage.danger),
            ),
            onTap: () => _archive(space),
          ),
          Text(
            tr('space.archiveBody'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Archiving is local and never uploaded (spec 3.1). Deleting a Space
  /// outright arrives with the cloud work in M8, where the consequences of
  /// removing shared data are defined.
  Future<void> _archive(Space space) async {
    final bool confirmed = await confirmDialog(
      context,
      title: tr('space.archiveTitle'),
      body: tr(
        'space.archiveConfirm',
        namedArgs: <String, String>{'title': space.title},
      ),
      confirmLabel: tr('space.archive'),
      isDestructive: true,
    );
    if (!confirmed) return;

    await ref
        .read(repositoriesProvider)
        .spaces
        .setArchived(space.id, isArchived: true);
    await ref.read(currentSpaceIdProvider.notifier).select(null);
    if (mounted) Navigator.of(context).pop();
  }
}
