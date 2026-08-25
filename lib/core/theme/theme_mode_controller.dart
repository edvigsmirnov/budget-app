import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which theme the app renders in.
///
/// This is a **device-local** setting, deliberately. It sits alongside the app
/// lock flag rather than in the synced cloud profile: two people sharing a Space
/// may reasonably want different themes on their own phones, and one of them
/// flipping to dark must not reach across the sync boundary.
///
/// M1 replaces the in-memory default with a value read from local settings
/// storage. Nothing else about this controller changes when that lands.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;

  /// Cycles system -> light -> dark -> system. Used by the token gallery; the
  /// real Settings screen offers the three as an explicit choice.
  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}

final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
