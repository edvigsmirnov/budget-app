import 'package:budget_app/core/l10n/app_locales.dart';
import 'package:budget_app/core/l10n/pseudo_asset_loader.dart';
import 'package:budget_app/core/theme/sage_theme.dart';
import 'package:budget_app/core/theme/theme_mode_controller.dart';
import 'package:budget_app/features/dev/token_gallery_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reads the saved locale and the device locale before the first frame.
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallback,
      // Defaults to true, which resolves plurals by counting instead of by the
      // language's CLDR rules. Russian needs few and many.
      ignorePluralRules: false,
      assetLoader: const PseudoAssetLoader(),
      child: const ProviderScope(child: BudgetApp()),
    ),
  );
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // Product name, not UI copy: the same in every locale.
      title: 'Budget',
      debugShowCheckedModeBanner: false,
      theme: SageTheme.light,
      darkTheme: SageTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      // No router until M3. The token gallery is the only surface in M0.
      home: const TokenGalleryPage(),
    );
  }
}
