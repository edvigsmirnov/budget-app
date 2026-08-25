import 'package:budget_app/core/theme/sage_theme.dart';
import 'package:budget_app/core/theme/theme_mode_controller.dart';
import 'package:budget_app/features/dev/token_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BudgetApp()));
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Budget',
      debugShowCheckedModeBanner: false,
      theme: SageTheme.light,
      darkTheme: SageTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      // No router until M3. The token gallery is the only surface in M0.
      home: const TokenGalleryPage(),
    );
  }
}
