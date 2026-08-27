import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/db/repositories/space_repository.dart';
import 'package:sielto/core/format/currencies.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/dialogs.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/categories/categories_page.dart';
import 'package:sielto/features/incomes/income_rules_page.dart';

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
        padding: const EdgeInsets.symmetric(
          horizontal: SageSpace.formGutter,
          vertical: SageSpace.md,
        ),
        children: <Widget>[
          // The Space's identity: its mark and its name on one line, as the
          // design opens the screen (design section 3.4).
          Row(
            children: <Widget>[
              _SpaceMark(spaceId: space.id, title: space.title),
              const SizedBox(width: SageSpace.md),
              Expanded(
                child: TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.bodyLarge,
                  onSubmitted: (String value) => repo.setTitle(space.id, value),
                  onTapOutside: (PointerDownEvent _) =>
                      repo.setTitle(space.id, _title.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: SageSpace.lg),

          // Facts read as label-left, value-right rows; only what can be
          // changed gets a control of its own.
          _FactRow(
            label: tr('space.fieldMode'),
            value: _LockedPill(text: tr('mode.${space.budgetMode.name}.name')),
          ),
          Text(
            tr('space.modeIsPermanent'),
            style: Theme.of(context).textTheme.bodySmall,
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

          if (_currencyEditable ?? false)
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
                onChanged: (String? code) async {
                  if (code == null) return;
                  await repo.setCurrency(space.id, code);
                },
              ),
            )
          else
            // Frozen by the first record, so it reads as a fact rather than a
            // disabled control (spec 9.2).
            _FactRow(
              label: tr('space.fieldCurrency'),
              value: _LockedPill(text: space.currencyCode),
            ),
          const Hairline(),

          _FactRow(
            label: tr('space.fieldTimezone'),
            value: Text(
              space.timezone,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Hairline(),

          // Categories and income rules are read for the open Space, so these
          // links only make sense when this screen is showing that Space.
          if (isCurrent) ...<Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('category.title')),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => const CategoriesPage(),
                ),
              ),
            ),
            const Hairline(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('income.regularTitle')),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => const IncomeRulesPage(),
                ),
              ),
            ),
            const Hairline(),
          ],

          const SizedBox(height: SageSpace.xl),
          _DangerButton(
            label: tr('space.archive'),
            onTap: () => _archive(space),
          ),
          const SizedBox(height: SageSpace.sm),
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

/// The Space's mark: its initial on a soft square.
///
/// The design shows a chosen icon here; that needs a column the schema does
/// not have yet, so the initial stands in rather than an empty placeholder.
class _SpaceMark extends StatelessWidget {
  const _SpaceMark({required this.spaceId, required this.title});

  final String spaceId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final String initial = title.trim().isEmpty
        ? '?'
        : title.trim().characters.first.toUpperCase();

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sage.accentTintAlt,
        borderRadius: BorderRadius.circular(SageRadius.card),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: sage.accentStrong),
      ),
    );
  }
}

/// A read-only setting: what it is on the left, what it says on the right.
class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: SageSpace.md),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(width: SageSpace.md),
        value,
      ],
    ),
  );
}

/// A value that cannot change, and says so.
class _LockedPill extends StatelessWidget {
  const _LockedPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: sage.canvas,
        borderRadius: BorderRadius.circular(SageRadius.pill),
        border: Border.all(color: sage.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.lock_outline, size: 13, color: sage.inkLabel),
          const SizedBox(width: SageSpace.xs),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: sage.inkSecondary),
          ),
        ],
      ),
    );
  }
}

/// A destructive action, on its own tint rather than as a red list row.
class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SageRadius.button),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sage.dangerTint,
          borderRadius: BorderRadius.circular(SageRadius.button),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: sage.danger),
        ),
      ),
    );
  }
}
