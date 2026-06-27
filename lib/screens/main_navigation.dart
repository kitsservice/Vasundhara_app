import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'nursery_screen.dart'; // import the new nursery screen
import 'map_screen.dart'; // import the new map screen
import 'my_forest_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NurseryScreen(), // Replaced Trees with Nursery
    const MapScreen(), // Map Screen integrated
    const MyForestScreen(), // My Forest
    const ProfileScreen(), // User Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
          onTap: (index) => setState(() => _currentIndex = index),
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
