import 'dart:convert';
import 'dart:io';

import 'package:budget_app/core/l10n/app_locales.dart';
import 'package:budget_app/core/l10n/pseudo_asset_loader.dart';
import 'package:budget_app/core/l10n/pseudolocalize.dart';
import 'package:budget_app/core/theme/sage_theme.dart';
import 'package:budget_app/features/dev/token_gallery_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads dictionaries off disk instead of through rootBundle, whose asset
/// loads never complete past the first widget test in a file. The JSON under
/// test is the same either way; that the files are declared as assets is
/// checked in translations_test.dart.
class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final File file = File('$path/${locale.languageCode}.json');
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // ensureInitialized reads the saved locale through shared_preferences.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  Widget harness({
    ThemeMode mode = ThemeMode.light,
    Locale locale = AppLocales.en,
  }) {
    return EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallback,
      startLocale: locale,
      saveLocale: false,
      ignorePluralRules: false,
      assetLoader: const PseudoAssetLoader(base: _FileAssetLoader()),
      child: ProviderScope(
        child: Builder(
          builder: (BuildContext context) => MaterialApp(
            theme: SageTheme.light,
            darkTheme: SageTheme.dark,
            themeMode: mode,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: const TokenGalleryPage(),
          ),
        ),
      ),
    );
  }

  /// Renders on a surface tall enough to build the whole gallery: the body is
  /// a lazy ListView, and on the default 800x600 everything below the fold
  /// stays unbuilt, so an overflow down there would go unnoticed.
  Future<void> pump(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    // MaterialApp builds nothing until the localization delegate resolves.
    await tester.pumpAndSettle();
  }

  testWidgets('renders in light without overflow', (WidgetTester tester) async {
    await pump(tester, harness());
    expect(find.text('Sage tokens'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark without overflow', (WidgetTester tester) async {
    await pump(tester, harness(mode: ThemeMode.dark));
    expect(find.text('Sage tokens'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the pseudolocale without overflow', (
    WidgetTester tester,
  ) async {
    await pump(tester, harness(locale: AppLocales.pseudo));
    // The long-string pass: every visible string is padded and bracketed.
    expect(find.text(pseudolocalize('Add payment')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme toggle cycles system to light to dark and back', (
    WidgetTester tester,
  ) async {
    await pump(tester, harness(mode: ThemeMode.system));

    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(find.text('Light'), findsOneWidget);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('locale toggle cycles en to ru to the pseudolocale', (
    WidgetTester tester,
  ) async {
    await pump(tester, harness());
    expect(find.text('Add payment'), findsOneWidget);

    await tester.tap(find.text('en'));
    await tester.pumpAndSettle();
    expect(find.text('Добавить платёж'), findsOneWidget);

    await tester.tap(find.text('ru'));
    await tester.pumpAndSettle();
    expect(find.text(pseudolocalize('Add payment')), findsOneWidget);
  });

  testWidgets('plurals resolve per locale', (WidgetTester tester) async {
    await pump(tester, harness());
    expect(find.text('1 paid expense excluded'), findsOneWidget);
    expect(find.text('2 paid expenses excluded'), findsOneWidget);

    await tester.tap(find.text('en'));
    await tester.pumpAndSettle();
    // Russian splits where English does not: 2 is "few", 5 is "many".
    expect(find.text('1 оплаченный расход исключён'), findsOneWidget);
    expect(find.text('2 оплаченных расхода исключены'), findsOneWidget);
    expect(find.text('5 оплаченных расходов исключены'), findsOneWidget);
  });
}
