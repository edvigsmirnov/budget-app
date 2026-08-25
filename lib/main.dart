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
      // M0 has no router yet. The token gallery is the only surface, and it is
      // what the M0 exit criterion is checked against. M3 introduces the real
      // shell and drops this page from release builds.
      home: const TokenGalleryPage(),
    );
  }
}
