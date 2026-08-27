import 'package:budget_app/core/theme/sage_tokens.dart';
import 'package:budget_app/core/ui/sage_widgets.dart';
import 'package:budget_app/features/dashboard/dashboard_page.dart';
import 'package:budget_app/features/feed/feed_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The three main screens and the two ways to move between them: the bottom
/// bar and a horizontal swipe, both live at once (spec 4.1).
///
/// Settings is deliberately not a fourth tab — it is reached from the header
/// (spec 4.2).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
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

  @override
  Widget build(BuildContext context) {
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
