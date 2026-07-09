import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../map/map_screen.dart';
import '../map/nursery_screen.dart';
import '../gamification/my_forest_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  // Track which tabs have been visited for lazy initialization
  final Set<int> _visitedIndices = {0};

  Widget get _mapTab => const MapScreen();

  late final List<Widget> _screens = [
    const HomeScreen(),
    const NurseryScreen(),
    _mapTab,
    const MyForestScreen(),
    const ProfileScreen(),
  ];

  void _onTabTap(int index) {
    setState(() {
      _visitedIndices.add(index);
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lazy IndexedStack: only build a tab once it has been visited
      body: Stack(
        children: List.generate(_screens.length, (i) {
          // If this is the map tab (index 2) and it's not the current active tab, 
          // we remove it from the widget tree entirely. Keeping native AndroidViews 
          // inside an Offstage can cause the app to freeze when switching tabs.
          if (i == 2 && i != _currentIndex) {
            return const SizedBox.shrink();
          }
          
          return Offstage(
            offstage: i != _currentIndex,
            child: _visitedIndices.contains(i)
                ? TickerMode(enabled: i == _currentIndex, child: _screens[i])
                : const SizedBox.shrink(),
          );
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Nurseries',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map),
              activeIcon: Icon(CupertinoIcons.map_fill),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forest_outlined),
              activeIcon: Icon(Icons.forest),
              label: 'My Forest',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
