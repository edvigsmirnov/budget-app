import 'package:budget_app/core/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme selection. Device-local, not synced: members of a shared Space set
/// this independently (plan section 5, rule 5).
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(localSettingsProvider).themeMode;

  Future<void> set(ThemeMode mode) async {
    await ref.read(localSettingsProvider).setThemeMode(mode);
    state = mode;
  }

  /// Cycles system -> light -> dark. Used by the token gallery; Settings
  /// offers the three as an explicit choice.
  Future<void> cycle() => set(switch (state) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });
}

final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
