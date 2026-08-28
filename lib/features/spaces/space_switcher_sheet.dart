import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/domain/ledger/ledger_walker.dart';
import 'package:sielto/domain/value/enums.dart';
import 'package:sielto/features/settings/settings_page.dart';
import 'package:sielto/features/settings/space_settings_page.dart';
import 'package:sielto/features/spaces/space_avatar.dart';
import 'package:sielto/features/spaces/space_coverage.dart';
import 'package:sielto/features/spaces/space_form_page.dart';

/// The Spaces switcher (spec 3.1).
///
/// A sheet over the current screen rather than a screen of its own: switching
/// Space is a change of context, not a journey somewhere, and it closes by
/// swiping down or tapping the dimmed area behind it.
///
/// There is deliberately **no combined total** across Spaces. They can be in
/// different currencies, and adding those together would need exchange rates —
/// which would mean a network call this app does not make (spec 3.1).
///
/// The spec's swipe-up gesture belongs to M10; until then the entry point is
/// the tap on the Space name in the header, which the spec requires anyway.
Future<void> showSpaceSwitcher(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext _) => const _SpaceSwitcher(),
    );

class _SpaceSwitcher extends ConsumerStatefulWidget {
  const _SpaceSwitcher();

  @override
  ConsumerState<_SpaceSwitcher> createState() => _SpaceSwitcherState();
}

class _SpaceSwitcherState extends ConsumerState<_SpaceSwitcher> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Space> spaces =
        ref.watch(spaceListProvider).value ?? const <Space>[];
    final String? currentId = ref.watch(currentSpaceProvider)?.id;
    final Map<String, Coverage> coverage =
        ref.watch(spaceCoverageProvider).value ?? const <String, Coverage>{};

    final List<Space> shown = _query.isEmpty
        ? spaces
        : spaces
              .where(
                (Space s) =>
                    s.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SageSpace.gutter,
          0,
          SageSpace.gutter,
          SageSpace.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('settings.spaces'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SageSpace.md),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: tr('space.search'),
                isDense: true,
              ),
              onChanged: (String value) => setState(() => _query = value),
            ),
            const SizedBox(height: SageSpace.md),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: shown.length,
                separatorBuilder: (BuildContext _, int _) => const Hairline(),
                itemBuilder: (BuildContext context, int index) => _SpaceRow(
                  space: shown[index],
                  isCurrent: shown[index].id == currentId,
                  coverage: coverage[shown[index].id],
                  onOpen: () => _open(shown[index]),
                  onSettings: () => _openSettings(shown[index]),
                ),
              ),
            ),
            const SizedBox(height: SageSpace.md),
            DashedButton(
              label: '+ ${tr('space.createTitle')}',
              onTap: _createSpace,
            ),
            const SizedBox(height: SageSpace.md),
            const Hairline(),
            // The general settings, reachable without closing the sheet first
            // and hunting for the profile icon (spec 3.1).
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('settings.accountSettings')),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => const SettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(Space space) async {
    // In memory, and instant: a local Space needs no network (spec 3.1).
    await ref.read(currentSpaceIdProvider.notifier).select(space.id);
    if (mounted) Navigator.of(context).pop();
  }

  void _openSettings(Space space) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => SpaceSettingsPage(space: space),
      ),
    );
  }

  void _createSpace() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const SpaceFormPage(),
      ),
    );
  }
}

class _SpaceRow extends StatelessWidget {
  const _SpaceRow({
    required this.space,
    required this.isCurrent,
    required this.coverage,
    required this.onOpen,
    required this.onSettings,
  });

  final Space space;
  final bool isCurrent;

  /// Null when the Space has nothing to compute yet — no dot rather than a
  /// guessed one.
  final Coverage? coverage;

  final VoidCallback onOpen;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    final TextTheme text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onOpen,
      leading: SpaceAvatar(
        spaceId: space.id,
        title: space.title,
        highlighted: isCurrent,
      ),
      title: Text(
        space.title,
        overflow: TextOverflow.ellipsis,
        style: text.bodyLarge?.copyWith(
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: sage.accentTintAlt,
                borderRadius: BorderRadius.circular(SageRadius.pill),
              ),
              child: Text(
                tr('mode.${space.budgetMode.name}.name'),
                style: text.labelSmall?.copyWith(color: sage.accentStrong),
              ),
            ),
            const SizedBox(width: SageSpace.sm),
            // Cloud or device, so where the data lives reads at a glance
            // (spec 3.1). Beside the mode rather than beside the name, which
            // the design keeps for the name alone.
            Icon(
              space.storageMode == StorageMode.cloud
                  ? Icons.cloud_outlined
                  : Icons.smartphone,
              size: 14,
              color: sage.inkLabel,
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (coverage != null) ...<Widget>[
            CoverageDot(coverage!, size: 10),
            const SizedBox(width: SageSpace.md),
          ],
          // Opens that Space's settings without switching to it — the second
          // of the spec's three entry points (spec 3.4).
          SoftIconButton(
            icon: Icons.settings_outlined,
            tooltip: tr('spaceSettings.title'),
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}
