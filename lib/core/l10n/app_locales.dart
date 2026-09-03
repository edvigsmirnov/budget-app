import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A language the app offers, under the name it is shown by.
@immutable
class AppLocale {
  const AppLocale(this.locale, this.name);

  final Locale locale;

  /// The language's own name, never translated. Someone hunting for their
  /// language has to recognise it while the interface is still in a language
  /// they cannot read.
  final String name;
}

/// Locales the app offers and where their dictionaries live.
///
/// Adding a language is two steps: drop `assets/translations/<code>.json` in
/// place, and add one entry to [shipped]. The picker, `supportedLocales` and
/// the pseudolocale harness all read from here.
abstract final class AppLocales {
  static const Locale en = Locale('en');
  static const Locale ru = Locale('ru');

  /// Pseudo-accented English for layout testing. Has no dictionary of its own —
  /// see `PseudoAssetLoader`.
  static const Locale pseudo = Locale('en', 'XA');

  static const Locale fallback = en;

  static const String path = 'assets/translations';

  /// The shipped languages, in the order the picker lists them.
  ///
  /// Names live here rather than in the dictionaries. A name held in every
  /// dictionary needs one identical copy per language — a hundred entries at
  /// ten languages — and the parity test would demand every one of them.
  static const List<AppLocale> shipped = <AppLocale>[
    AppLocale(en, 'English'),
    AppLocale(ru, 'Русский'),
  ];

  /// What the picker offers: [shipped], plus the pseudolocale in debug builds
  /// so the long-string pass can be run from any screen.
  static List<AppLocale> get offered => <AppLocale>[
    ...shipped,
    if (kDebugMode) const AppLocale(pseudo, 'Pseudolocale'),
  ];

  static List<Locale> get supported =>
      offered.map((AppLocale l) => l.locale).toList(growable: false);

  /// The offered entry [locale] belongs to: an exact match, else the same
  /// language without a country, else [fallback].
  ///
  /// The middle step is what a device set to `ru_RU` needs; without it the
  /// picker would show English as selected while the app spoke Russian. It
  /// skips entries that name a country, so `en_US` cannot resolve to the
  /// pseudolocale.
  static AppLocale resolve(Locale locale) {
    final List<AppLocale> all = offered;
    for (final AppLocale l in all) {
      if (l.locale == locale) return l;
    }
    for (final AppLocale l in all) {
      if (l.locale.countryCode == null &&
          l.locale.languageCode == locale.languageCode) {
        return l;
      }
    }
    return all.firstWhere((AppLocale l) => l.locale == fallback);
  }
}
