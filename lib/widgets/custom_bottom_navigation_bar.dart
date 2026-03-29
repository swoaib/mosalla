import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<CustomNavItem> items;

  // Layout Constants
  static const double height = 55.0;
  static double bottomPadding = defaultTargetPlatform == TargetPlatform.android ? 16 : 0;
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
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.8)
        : Colors.black.withOpacity(0.1);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomPadding + MediaQuery.of(context).padding.bottom,
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
                  color: cardColor,
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
                                color: Colors.grey.withOpacity(0.1),
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
                                child: _buildNavItem(context, entry.key, entry.value),
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
            _buildSearchButton(context, cardColor, shadowColor),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchButton(
    BuildContext context,
    Color cardColor,
    Color shadowColor,
  ) {
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
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Icon(Icons.search, size: 24, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, CustomNavItem item) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey;

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
