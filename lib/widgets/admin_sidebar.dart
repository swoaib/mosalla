import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final VoidCallback onLogout;
  final String? mosallaName;
  final String? mosallaLogo;

  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onLogout,
    this.mosallaName,
    this.mosallaLogo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          // Divider(
          //     indent: 16,
          //     endIndent: 16,
          //     color: theme.dividerColor.withValues(alpha: 0.1)),
          // const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(context, 0, Icons.info_outline, 'Bio'),
                _buildNavItem(context, 1, Icons.access_time, 'Prayers'),
                _buildNavItem(context, 2, Icons.event_note, 'Events'),
                _buildNavItem(context, 3, Icons.settings, 'Settings'),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/icon/logo_dark.png'
                      : 'assets/icon/logo.png',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mosalla',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7),
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    const accentColor = Colors.teal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.grey.withValues(alpha: 0.15),
          splashColor: Colors.grey.withValues(alpha: 0.2),
          mouseCursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.grey.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.9)
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.9)
                        : theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.grey.withValues(alpha: 0.1),
          splashColor: Colors.grey.withValues(alpha: 0.15),
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.logout,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                    size: 20),
                const SizedBox(width: 16),
                Text(
                  'Logout',
                  style: TextStyle(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
