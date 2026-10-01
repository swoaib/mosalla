import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<CustomNavItem> items;

  // Layout Constants
  static const double height = 55.0;
  static double bottomPadding =
      defaultTargetPlatform == TargetPlatform.android ? 16 : 0;
  static double totalHeight = height + bottomPadding;
  // Standard content padding to ensure items above navbar are clickable
  static double contentBottomPadding = totalHeight + 16.0;

  final VoidCallback? onSearchTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
    this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);

    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.1);

    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final computedBottom = bottomPadding + safeAreaBottom;
    final horizontalMargin = computedBottom > 16.0 ? computedBottom : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        computedBottom,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isTealTheme
                      ? const Color(0xFF00382E).withValues(alpha: 0.60)
                      : cardColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / items.length;
                    final itemHeight = constraints.maxHeight;
                    return Stack(
                      children: [
                        // Animated Pill Background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          left: selectedIndex * itemWidth,
                          top: 0,
                          bottom: 0,
                          width: itemWidth,
                          child: Center(
                            child: Container(
                              width: itemWidth * 0.8,
                              height: itemHeight * 0.77,
                              decoration: BoxDecoration(
                                color: isTealTheme
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                        // Navigation Items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: items.asMap().entries.map((entry) {
                            return Expanded(
                              child: Center(
                                child: _buildNavItem(
                                  context,
                                  entry.key,
                                  entry.value,
                                  isTealTheme: isTealTheme,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (onSearchTap != null) ...[
            const SizedBox(width: 12),
            _buildSearchButton(
              context,
              cardColor,
              shadowColor,
              isTealTheme: isTealTheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchButton(
    BuildContext context,
    Color cardColor,
    Color shadowColor, {
    bool isTealTheme = false,
  }) {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isTealTheme
                ? const Color(0xFF00382E).withValues(alpha: 0.95)
                : cardColor,
            borderRadius: BorderRadius.circular(30),
            border: isTealTheme
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.2,
                  )
                : null,
          ),
          child: Center(
            child: Icon(Icons.search,
                size: 24, color: isTealTheme ? Colors.white70 : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    CustomNavItem item, {
    bool isTealTheme = false,
  }) {
    final isSelected = selectedIndex == index;
    final selectedColor =
        isTealTheme ? Colors.white : Theme.of(context).primaryColor;
    final unselectedColor = isTealTheme ? Colors.white60 : Colors.grey;
    final color = isSelected ? selectedColor : unselectedColor;

    return IconButton(
      onPressed: () => onItemTapped(index),
      icon: Icon(
        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
        color: color,
        size: 24,
      ),
      tooltip: item.label,
      style: IconButton.styleFrom(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    );
  }
}

class CustomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  CustomNavItem({required this.icon, required this.label, this.activeIcon});
}
