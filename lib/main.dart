import 'package:budget_app/app/startup.dart';
import 'package:budget_app/core/db/app_database.dart';
import 'package:budget_app/core/l10n/app_locales.dart';
import 'package:budget_app/core/l10n/pseudo_asset_loader.dart';
import 'package:budget_app/core/theme/sage_theme.dart';
import 'package:budget_app/core/theme/theme_mode_controller.dart';
import 'package:budget_app/features/dev/token_gallery_page.dart';
import 'package:budget_app/features/security/decryption_failure_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set once the database is open. Read by the feature layer from M3; until
/// then only the startup path touches it.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>(
  (Ref ref) => throw StateError('databaseProvider was not overridden'),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reads the saved locale and the device locale before the first frame.
  await EasyLocalization.ensureInitialized();

  // Before the first frame: an unreadable database is a screen, not a crash.
  final Startup startup = await openDatabase();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallback,
      // Defaults to true, which resolves plurals by counting instead of by the
      // language's CLDR rules. Russian needs few and many.
      ignorePluralRules: false,
      assetLoader: const PseudoAssetLoader(),
      child: BudgetAppRoot(startup: startup),
    ),
  );
}

/// Holds whatever [openDatabase] returned and rebuilds when "Start over"
/// replaces it.
class BudgetAppRoot extends StatefulWidget {
  const BudgetAppRoot({required this.startup, super.key});

  final Startup startup;

  @override
  State<BudgetAppRoot> createState() => _BudgetAppRootState();
}

class _BudgetAppRootState extends State<BudgetAppRoot> {
  late Startup _startup = widget.startup;

  Future<void> _startOver(StartupLocked locked) async {
    final Startup next = await startOver(locked.manager);
    if (mounted) setState(() => _startup = next);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_startup) {
      StartupReady(:final AppDatabase database) => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const BudgetApp(home: TokenGalleryPage()),
      ),
      final StartupLocked locked => ProviderScope(
        child: BudgetApp(
          home: DecryptionFailurePage(onStartOver: () => _startOver(locked)),
        ),
      ),
    };
  }
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({required this.home, super.key});

  final Widget home;

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
      // No router until M3.
      home: home,
    );
  }
}
