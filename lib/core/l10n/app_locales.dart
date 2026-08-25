import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Locales the app offers and where their dictionaries live.
abstract final class AppLocales {
  static const Locale en = Locale('en');
  static const Locale ru = Locale('ru');

  /// Pseudo-accented English for layout testing. Has no dictionary of its own —
  /// see `PseudoAssetLoader`.
  static const Locale pseudo = Locale('en', 'XA');

  static const Locale fallback = en;

  static const String path = 'assets/translations';

  /// Shipped locales, plus [pseudo] in debug builds.
  static List<Locale> get supported => <Locale>[en, ru, if (kDebugMode) pseudo];
}
