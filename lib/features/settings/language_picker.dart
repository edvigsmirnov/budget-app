import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sielto/core/l10n/app_locales.dart';
import 'package:sielto/core/theme/sage_tokens.dart';

/// The language picker (spec 9.2).
///
/// A scrolling sheet, so the list grows with the number of translations without
/// the screen having to change. Each language is listed under its own name,
/// never a translated one — see [AppLocale.name].
Future<void> showLanguagePicker(BuildContext context) async {
  final Locale? picked = await showModalBottomSheet<Locale>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext _) => const _LanguagePicker(),
  );
  if (picked == null || !context.mounted) return;
  await context.setLocale(picked);
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final List<AppLocale> languages = AppLocales.offered;
    final AppLocale current = AppLocales.resolve(context.locale);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: SageSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SageSpace.gutter,
                0,
                SageSpace.gutter,
                SageSpace.sm,
              ),
              child: Text(
                tr('settings.language'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // Bounded so a long list scrolls inside the sheet instead of
            // pushing it past the top of the screen.
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (BuildContext context, int index) {
                  final AppLocale language = languages[index];
                  final bool selected = language.locale == current.locale;
                  return ListTile(
                    title: Text(language.name),
                    trailing: selected
                        ? Icon(Icons.check, color: context.sage.accentStrong)
                        : null,
                    selected: selected,
                    onTap: () => Navigator.of(context).pop(language.locale),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
