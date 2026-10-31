import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'prayer_time_page.dart';
import 'settings_page.dart';
import 'qibla_page.dart';
import 'map_page.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final CupertinoTabController _tabController = CupertinoTabController();

  final List<Widget> _pages = [
    const PrayerTimePage(),
    const QiblaPage(),
    const MapPage(),
    const SettingsPage(),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _tabController.index = index;
    setState(() {}); // trigger rebuild for CustomBottomNavigationBar
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);

    return AppBackground(
      child: Scaffold(
        backgroundColor: isTealTheme ? Colors.transparent : null,
        body: Stack(
        children: [
          IndexedStack(
            index: _tabController.index,
            children: _pages.map((page) {
              return CupertinoTabView(
                builder: (context) => page,
              );
            }).toList(),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              selectedIndex: _tabController.index,
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
    ),
  );
}
}
