import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/features/settings/settings_page.dart';
import 'package:sielto/features/settings/space_settings_page.dart';

/// The header the three main screens share (spec 4.2).
///
/// Both icons push over the current screen rather than switching the root tab,
/// so Back returns to exactly the state the user left — scroll position and
/// any open form included.
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({required this.title, this.trailing, this.bottom, super.key});

  final String title;

  /// Extra controls between the title and the gear.
  final List<Widget>? trailing;

  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    return AppBar(
      backgroundColor: sage.surface,
      titleSpacing: SageSpace.sm,
      leading: IconButton(
        icon: const Icon(Icons.account_circle_outlined),
        tooltip: tr('settings.title'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext _) => const SettingsPage(),
          ),
        ),
      ),
      title: Text(title, overflow: TextOverflow.ellipsis),
      actions: <Widget>[
        ...?trailing,
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: tr('spaceSettings.title'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext _) => SpaceSettingsPage(space: ref.space),
            ),
          ),
        ),
      ],
      bottom: bottom,
    );
  }
}
