import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/core/l10n/app_locales.dart';

/// The picker highlights whatever [AppLocales.resolve] returns, so a locale
/// that resolves wrongly shows the user the wrong language as selected while
/// the app speaks another. The two-language version got away with a ternary;
/// this is what has to hold as translations are added.
void main() {
  test('every shipped language has a name and a distinct locale', () {
    expect(AppLocales.shipped, isNotEmpty);
    for (final AppLocale l in AppLocales.shipped) {
      expect(l.name.trim(), isNotEmpty, reason: 'a language needs a name');
    }
    final Set<Locale> locales = AppLocales.shipped
        .map((AppLocale l) => l.locale)
        .toSet();
    expect(locales, hasLength(AppLocales.shipped.length));
  });

  test('the fallback is one of the offered languages', () {
    expect(
      AppLocales.offered.map((AppLocale l) => l.locale),
      contains(AppLocales.fallback),
    );
  });

  test('an exact locale resolves to itself', () {
    expect(AppLocales.resolve(AppLocales.ru).locale, AppLocales.ru);
    expect(AppLocales.resolve(AppLocales.en).locale, AppLocales.en);
  });

  test('a locale with a country resolves to its language', () {
    // A device set to ru_RU must not read as English.
    expect(AppLocales.resolve(const Locale('ru', 'RU')).locale, AppLocales.ru);
    expect(AppLocales.resolve(const Locale('en', 'GB')).locale, AppLocales.en);
  });

  test('en with a country never resolves to the pseudolocale', () {
    // The pseudolocale is en_XA, so it shares a language code with English.
    expect(AppLocales.resolve(const Locale('en', 'US')).locale, AppLocales.en);
  });

  test('an unshipped language falls back rather than throwing', () {
    expect(AppLocales.resolve(const Locale('ja')).locale, AppLocales.fallback);
  });

  test('supported mirrors offered, so the picker cannot offer an unloadable '
      'language', () {
    expect(
      AppLocales.supported,
      AppLocales.offered.map((AppLocale l) => l.locale).toList(),
    );
  });
}
