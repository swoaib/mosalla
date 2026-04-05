import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _saveThemeToPrefs(mode);
    notifyListeners();
  }

  // Keep toggleTheme for backward compatibility if needed, 
  // but it will now toggle between light and dark only.
  void toggleTheme(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check for new string-based preference
      final String? themeStr = prefs.getString('themeMode');
      if (themeStr != null) {
        _themeMode = _parseThemeMode(themeStr);
      } else {
        // Migration from old bool-based preference
        final bool? isDark = prefs.getBool('isDarkMode');
        if (isDark != null) {
          _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          // Optionally clean up and save in new format
          _saveThemeToPrefs(_themeMode);
        } else {
          _themeMode = ThemeMode.system;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      // If SharedPreferences fails, default to system
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', mode.toString().split('.').last);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  ThemeMode _parseThemeMode(String themeStr) {
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
