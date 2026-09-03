import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/app/startup.dart';
import 'package:sielto/core/db/app_database.dart';
import 'package:sielto/core/l10n/app_locales.dart';
import 'package:sielto/core/l10n/pseudo_asset_loader.dart';
import 'package:sielto/core/settings/local_settings.dart';
import 'package:sielto/core/settings/settings_providers.dart';
import 'package:sielto/core/theme/sage_theme.dart';
import 'package:sielto/core/theme/theme_mode_controller.dart';
import 'package:sielto/features/onboarding/onboarding_page.dart';
import 'package:sielto/features/security/decryption_failure_page.dart';
import 'package:sielto/features/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reads the saved locale and the device locale before the first frame.
  await EasyLocalization.ensureInitialized();

  // Device-local preferences, and the local user id if this is a first run.
  final LocalSettings settings = await LocalSettings.load();

  // Before the first frame: an unreadable database is a screen, not a crash.
  final Startup startup = await openDatabase();

  // BudgetAppRoot.build returns the ProviderScope; the rule does not see
  // through a custom root widget.
  // ignore: riverpod_lint/missing_provider_scope
  runApp(BudgetAppRoot(startup: startup, settings: settings));
}

/// Holds whatever [openDatabase] returned and rebuilds when "Start over"
/// replaces it.
///
/// The [ProviderScope] sits above [EasyLocalization], not below it. Loading a
/// dictionary rebuilds everything under the localization widget; with the
/// scope down there, that rebuild disposes the provider container and every
/// database subscription it holds.
class BudgetAppRoot extends StatefulWidget {
  const BudgetAppRoot({
    required this.startup,
    required this.settings,
    super.key,
  });

  final Startup startup;
  final LocalSettings settings;

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
    final Startup startup = _startup;
    return ProviderScope(
      overrides: [
        localSettingsProvider.overrideWithValue(widget.settings),
        if (startup is StartupReady)
          databaseProvider.overrideWithValue(startup.database),
      ],
      child: EasyLocalization(
        supportedLocales: AppLocales.supported,
        path: AppLocales.path,
        fallbackLocale: AppLocales.fallback,
        // Defaults to true, which resolves plurals by counting instead of by
        // the language's CLDR rules. Russian needs few and many.
        ignorePluralRules: false,
        assetLoader: const PseudoAssetLoader(),
        child: switch (startup) {
          StartupReady() => const AppGate(),
          final StartupLocked locked => BudgetApp(
            home: DecryptionFailurePage(onStartOver: () => _startOver(locked)),
          ),
        },
      ),
    );
  }
}

/// Chooses between onboarding and the main shell.
///
/// Public so tests can boot the same routing the app boots, rather than
/// mounting a screen that assumes a Space the providers have not resolved yet.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Space?> resolved = ref.watch(resolvedSpaceProvider);

    return switch (resolved) {
      AsyncData<Space?>(value: final Space? space) =>
        space == null
            ? const BudgetApp(home: OnboardingPage())
            : const BudgetApp(home: MainShell()),
      AsyncError<Space?>() => const BudgetApp(home: _StartupError()),
      _ => const BudgetApp(home: _StartupLoading()),
    };
  }
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _StartupError extends StatelessWidget {
  const _StartupError();

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(tr('common.loadFailed'))));
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({required this.home, super.key});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // Product name, not UI copy: the same in every locale.
      title: 'Sielto',
      debugShowCheckedModeBanner: false,
      theme: SageTheme.light,
      darkTheme: SageTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: home,
    );
  }
}
