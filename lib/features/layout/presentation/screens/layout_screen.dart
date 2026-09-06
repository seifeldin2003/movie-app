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
/// The tabs live in an `IndexedStack` so each keeps its scroll position when
/// the user moves between them.
class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  static const List<Widget> _tabs = [
    HomeTab(),
    SearchTab(),
    BrowseTab(),
    ProfileTab(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
