import 'package:budget_app/core/l10n/app_locales.dart';
import 'package:budget_app/core/settings/local_settings.dart';
import 'package:budget_app/core/settings/settings_providers.dart';
import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/theme/theme_mode_controller.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/features/categories/categories_page.dart';
import 'package:budget_app/features/spaces/spaces_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile and app settings (spec 4.2).
///
/// The spec's full list runs through security, backup, linked devices and
/// updates; those arrive with M7 and M11. What is here is what works — a row
/// that leads nowhere is worse than an absent one.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final FeedDensity density = ref.watch(feedDensityProvider);

    return Scaffold(
      backgroundColor: context.sage.surface,
      appBar: AppBar(title: Text(tr('settings.title'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: SageSpace.md),
        children: <Widget>[
          _SectionLabel(tr('settings.display')),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SageSpace.gutter,
              vertical: SageSpace.sm,
            ),
            child: LabelledField(
              label: tr('settings.theme'),
              child: SegmentedChoice<ThemeMode>(
                values: ThemeMode.values,
                selected: themeMode,
                labelOf: (ThemeMode mode) => tr('theme.${mode.name}'),
                onChanged: (ThemeMode mode) =>
                    ref.read(themeModeProvider.notifier).set(mode),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SageSpace.gutter,
              vertical: SageSpace.sm,
            ),
            child: LabelledField(
              label: tr('settings.feedDensity'),
              child: SegmentedChoice<FeedDensity>(
                values: FeedDensity.values,
                selected: density,
                labelOf: (FeedDensity value) => tr('density.${value.name}'),
                onChanged: (FeedDensity value) =>
                    ref.read(feedDensityProvider.notifier).set(value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SageSpace.gutter,
              vertical: SageSpace.sm,
            ),
            child: LabelledField(
              label: tr('settings.language'),
              child: SegmentedChoice<Locale>(
                values: const <Locale>[AppLocales.en, AppLocales.ru],
                selected: context.locale == AppLocales.ru
                    ? AppLocales.ru
                    : AppLocales.en,
                labelOf: (Locale locale) =>
                    tr('language.${locale.languageCode}'),
                onChanged: (Locale locale) => context.setLocale(locale),
              ),
            ),
          ),
          const SizedBox(height: SageSpace.md),
          _SectionLabel(tr('settings.data')),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: Text(tr('settings.spaces')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const SpacesPage(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: Text(tr('category.title')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) => const CategoriesPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SageSpace.gutter,
      SageSpace.md,
      SageSpace.gutter,
      SageSpace.xs,
    ),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall,
    ),
  );
}
