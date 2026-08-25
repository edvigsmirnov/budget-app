import 'package:budget_app/core/l10n/app_locales.dart';
import 'package:budget_app/core/l10n/pseudolocalize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Serves [AppLocales.pseudo] by pseudolocalizing the fallback dictionary at
/// load time, so no pseudo translations are checked in and the harness cannot
/// drift from the real strings. Every other locale goes straight to [base].
class PseudoAssetLoader extends AssetLoader {
  const PseudoAssetLoader({this.base = const RootBundleAssetLoader()});

  final AssetLoader base;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    if (locale != AppLocales.pseudo) return base.load(path, locale);
    final Map<String, dynamic>? source = await base.load(
      path,
      AppLocales.fallback,
    );
    return source == null ? null : _walk(source);
  }

  /// Rewrites every string leaf. Plural forms are nested maps, so recurse.
  Map<String, dynamic> _walk(Map<String, dynamic> node) {
    return node.map(
      (String key, dynamic value) =>
          MapEntry<String, dynamic>(key, switch (value) {
            final String s => pseudolocalize(s),
            final Map<String, dynamic> m => _walk(m),
            _ => value,
          }),
    );
  }
}
