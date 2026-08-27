import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/settings/space_settings_page.dart';
import 'package:sielto/features/spaces/space_form_page.dart';

/// The Spaces switcher (spec 3.1).
///
/// Each row also opens that Space's settings without switching to it, which is
/// the second of the three entry points the spec lists (spec 3.4).
class SpacesPage extends ConsumerWidget {
  const SpacesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Space> spaces =
        ref.watch(spaceListProvider).value ?? const <Space>[];
    final String? currentId = ref.watch(currentSpaceProvider)?.id;

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(title: Text(tr('settings.spaces'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext _) => const SpaceFormPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: spaces.isEmpty
          ? EmptyState(message: tr('space.noneYet'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: spaces.length,
              itemBuilder: (BuildContext context, int index) {
                final Space space = spaces[index];
                return ListTile(
                  selected: space.id == currentId,
                  leading: Icon(
                    space.id == currentId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: space.id == currentId
                        ? context.sage.accentStrong
                        : context.sage.inkLabel,
                  ),
                  title: Text(space.title),
                  subtitle: Text(
                    '${tr('mode.${space.budgetMode.name}.name')} · '
                    '${space.currencyCode}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    tooltip: tr('spaceSettings.title'),
                    // Opens that Space's settings without switching to it, so
                    // the scope is pinned here rather than taken from the shell.
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext _) =>
                            SpaceSettingsPage(space: space),
                      ),
                    ),
                  ),
                  onTap: () async {
                    await ref
                        .read(currentSpaceIdProvider.notifier)
                        .select(space.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
    );
  }
}
