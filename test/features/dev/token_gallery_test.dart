import 'package:budget_app/core/theme/sage_theme.dart';
import 'package:budget_app/features/dev/token_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness(ThemeMode mode) {
    return ProviderScope(
      child: MaterialApp(
        theme: SageTheme.light,
        darkTheme: SageTheme.dark,
        themeMode: mode,
        home: const TokenGalleryPage(),
      ),
    );
  }

  testWidgets('renders in light without overflow', (WidgetTester tester) async {
    await tester.pumpWidget(harness(ThemeMode.light));
    expect(find.text('Sage tokens'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark without overflow', (WidgetTester tester) async {
    await tester.pumpWidget(harness(ThemeMode.dark));
    expect(find.text('Sage tokens'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme toggle cycles system to light to dark and back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(ThemeMode.system));

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
}
