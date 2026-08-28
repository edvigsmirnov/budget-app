import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sielto/app/providers.dart';
import 'package:sielto/core/theme/sage_tokens.dart';
import 'package:sielto/core/ui/sage_widgets.dart';
import 'package:sielto/features/dashboard/dashboard_page.dart';
import 'package:sielto/features/feed/feed_page.dart';

/// The three main screens and the two ways to move between them: the bottom
/// bar and a horizontal swipe, both live at once (spec 4.1).
///
/// Settings is deliberately not a fourth tab — it is reached from the header
/// (spec 4.2).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _index = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  /// A newly opened Space starts on its Dashboard.
  ///
  /// The shell outlives the Space, so without this a switch lands on whichever
  /// tab the previous Space was left on — and a Space created from the Feed
  /// opened straight into an empty Feed.
  void _resetOnSpaceChange() {
    ref.listen<String?>(currentSpaceIdProvider, (
      String? previous,
      String? next,
    ) {
      if (previous == next || _index == 0) return;
      // Jumped, not animated: a switch is a change of subject, and after a
      // frame, because the notification can arrive mid-build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _index = 0);
        if (_controller.hasClients) _controller.jumpToPage(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _resetOnSpaceChange();
    return Scaffold(
      backgroundColor: context.sage.surface,
      body: PageView(
        controller: _controller,
        onPageChanged: (int index) => setState(() => _index = index),
        children: const <Widget>[
          DashboardPage(),
          FeedPage(),
          _CalendarPlaceholder(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.donut_small_outlined),
            selectedIcon: const Icon(Icons.donut_small),
            label: tr('nav.dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: tr('nav.feed'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: tr('nav.calendar'),
          ),
        ],
      ),
    );
  }
}

/// The Calendar screen lands in M6. The tab exists now so the navigation the
/// spec describes is complete and does not have to be rebuilt later.
class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder();

  @override
  Widget build(BuildContext context) =>
      SafeArea(child: EmptyState(message: tr('calendar.notYet')));
}
