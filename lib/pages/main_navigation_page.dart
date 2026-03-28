import 'package:flutter/material.dart';
import 'prayer_time_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PrayerTimePage(),
    const Scaffold(body: Center(child: Text('Tab 2 - Empty for now'))),
    const Scaffold(body: Center(child: Text('Tab 3 - Empty for now'))),
    const Scaffold(body: Center(child: Text('Tab 4 - Empty for now'))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Render current page
          _pages[_selectedIndex],
          
          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              items: [
                CustomNavItem(
                  icon: Icons.mosque_outlined,
                  activeIcon: Icons.mosque,
                  label: 'Home',
                ),
                CustomNavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explore',
                ),
                CustomNavItem(
                  icon: Icons.book_outlined,
                  activeIcon: Icons.book,
                  label: 'Library',
                ),
                CustomNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
