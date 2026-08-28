import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/settings/settings_page.dart';
import 'package:sielto/features/settings/space_settings_page.dart';
import 'package:sielto/features/spaces/space_switcher_sheet.dart';

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

  /// Taller than the Material default. The bar carries nothing but the two
  /// controls and the Space name, and at 56 they sit against the status bar
  /// with the whole row reading as an afterthought.
  static const double _toolbarHeight = 68;

  /// The control, plus the room it needs on either side.
  static const double _controlSize = 44;

  @override
  Size get preferredSize =>
      Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SageColors sage = context.sage;
    return AppBar(
      backgroundColor: sage.surface,
      titleSpacing: 0,
      centerTitle: true,
      toolbarHeight: _toolbarHeight,
      leadingWidth: _controlSize + SageSpace.md * 2,
      leading: Center(
        child: _ProfileAvatar(
          size: _controlSize,
          initial: ref.watch(profileInitialProvider),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext _) => const SettingsPage(),
            ),
          ),
        ),
      ),
      // Tapping the Space name opens the switcher. The spec names this as
      // the required alternate to the swipe-up gesture, which lands in M10
      // (spec 3.1).
      title: InkWell(
        onTap: () => showSpaceSwitcher(context),
        borderRadius: BorderRadius.circular(SageRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SageSpace.sm,
            vertical: SageSpace.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: SageSpace.xs),
              Icon(Icons.expand_more, size: 18, color: sage.inkLabel),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ...?trailing,
        Padding(
          padding: const EdgeInsets.only(right: SageSpace.md),
          child: SoftIconButton(
            size: _controlSize,
            icon: Icons.settings_outlined,
            tooltip: tr('spaceSettings.title'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) =>
                    SpaceSettingsPage(space: ref.space),
              ),
            ),
          ),
        ),
      ],
      bottom: bottom,
    );
  }
}

/// The user, as the initial of their nickname on a sage disc (design
/// section 2). An unnamed user gets the dot rather than a stray letter.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.initial,
    required this.onTap,
    required this.size,
  });

  final String? initial;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final SageColors sage = context.sage;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Tooltip(
        message: tr('settings.title'),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sage.accentTintAlt,
            shape: BoxShape.circle,
          ),
          child: initial == null
              ? Icon(
                  Icons.person_outline,
                  size: size / 2,
                  color: sage.accentStrong,
                )
              : Text(
                  initial!,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: sage.accentStrong),
                ),
        ),
      ),
    );
  }
}
