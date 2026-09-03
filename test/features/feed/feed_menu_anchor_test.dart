import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sielto/features/feed/feed_menu.dart';

/// The quick-add bubble opens out of the FAB, upward.
///
/// It used to open at the top of the screen: `showMenu` places the menu's top
/// edge at `position.top` and never reads `position.bottom`, so naming the
/// space above the button as the anchor put the bubble at y = 0. These tests
/// pin the geometry rather than the arithmetic, so the same mistake cannot
/// come back in a different form.
void main() {
  const int itemCount = 3;

  /// A bare Scaffold with a bottom-right FAB that opens a menu of [itemCount]
  /// items through [quickAddAnchor] — the Feed's FAB without the Feed, so the
  /// test needs no database.
  Future<Rect> openMenuAndMeasure(WidgetTester tester) async {
    final GlobalKey fabKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: Builder(
            builder: (BuildContext context) => FloatingActionButton(
              key: fabKey,
              onPressed: () => showMenu<int>(
                context: context,
                position: quickAddAnchor(context, fabKey, itemCount: itemCount),
                items: <PopupMenuEntry<int>>[
                  for (int i = 0; i < itemCount; i++)
                    PopupMenuItem<int>(
                      value: i,
                      height: quickAddItemHeight,
                      child: Text('item $i'),
                    ),
                ],
              ),
              child: const Icon(Icons.add),
            ),
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );

    await tester.tap(find.byKey(fabKey));
    await tester.pumpAndSettle();

    expect(find.text('item 0'), findsOneWidget);

    // The union of the item rects stands in for the bubble: the menu's own
    // Material is wrapped in transitions whose rect is animated.
    Rect bounds = tester.getRect(find.text('item 0'));
    for (int i = 1; i < itemCount; i++) {
      bounds = bounds.expandToInclude(tester.getRect(find.text('item $i')));
    }
    return bounds;
  }

  testWidgets('the bubble sits above the FAB, not at the top of the screen', (
    WidgetTester tester,
  ) async {
    final Rect menu = await openMenuAndMeasure(tester);
    final Rect fab = tester.getRect(find.byType(FloatingActionButton));
    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;

    // The whole menu is above the button.
    expect(
      menu.bottom,
      lessThanOrEqualTo(fab.top),
      reason: 'the bubble must not overlap the button it opened from',
    );

    // And it is nowhere near the top of the screen, which was the bug.
    expect(
      menu.top,
      greaterThan(screen.height / 2),
      reason: 'the bubble belongs to a FAB in the bottom half of the screen',
    );
  });

  testWidgets('the bubble is right-aligned with the FAB', (
    WidgetTester tester,
  ) async {
    final Rect menu = await openMenuAndMeasure(tester);
    final Rect fab = tester.getRect(find.byType(FloatingActionButton));

    // showMenu grows leftwards from a button nearer the right edge, so the
    // bubble's right edge tracks the button's rather than the screen's.
    expect(menu.right, lessThanOrEqualTo(fab.right));
    expect(menu.left, lessThan(fab.left));
  });
}
