import 'package:flutter/material.dart';
import 'prayer_time_page.dart';
import 'settings_page.dart';
import 'qibla_page.dart';
import 'map_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PrayerTimePage(),
    const QiblaPage(),
    const MapPage(),
    const SettingsPage(),
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
          // IndexedStack preserves page state across tab switches
          IndexedStack(index: _selectedIndex, children: _pages),

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
                  label: AppLocalizations.of(context)!.home,
                ),
                CustomNavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: AppLocalizations.of(context)!.qibla,
                ),
                CustomNavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: AppLocalizations.of(context)!.map,
                ),
                CustomNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: AppLocalizations.of(context)!.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
