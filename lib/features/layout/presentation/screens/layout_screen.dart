import 'package:flutter/material.dart';

import '../../../browse/presentation/screens/browse_tab.dart';
import '../../../home/presentation/screens/home_tab.dart';
import '../../../profile/presentation/screens/profile_tab.dart';
import '../../../search/presentation/screens/search_tab.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Owns the bottom navigation and swaps the body between the four tabs.
/// Figma nodes 47:1248 (Home), 50:60 (Search), 50:462 (Browse), 51:511
/// (Profile).
///
/// Two deliberate choices here, both about cost:
///
///  * **Lazy.** A plain `IndexedStack` builds every child on the first frame,
///    so opening the app would build all four tabs and their image decodes at
///    once. A tab is only built after it has been visited; once built it stays
///    in the tree and keeps its scroll position and state.
///  * **Tickers off when hidden.** `IndexedStack` lays out and keeps every
///    child alive, and it does *not* stop their animations — the Home carousel
///    would keep ticking while the user sits on Profile. [TickerMode] freezes
///    the ones that are not on screen.
class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  static const int _tabCount = 4;

  int _currentIndex = 0;

  /// Which tabs have ever been opened. Home starts true because it is the
  /// landing tab.
  final List<bool> _visited = [
    true,
    ...List<bool>.filled(_tabCount - 1, false),
  ];

  Widget _tabAt(int index) {
    switch (index) {
      case 0:
        return const HomeTab();
      case 1:
        return const SearchTab();
      case 2:
        return const BrowseTab();
      default:
        return const ProfileTab();
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _visited[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The nav bar floats, so the tab content runs underneath it.
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_tabCount, (index) {
          if (!_visited[index]) return const SizedBox.shrink();

          return TickerMode(
            enabled: index == _currentIndex,
            child: _tabAt(index),
          );
        }),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
