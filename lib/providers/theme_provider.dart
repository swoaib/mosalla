import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  system,
  light,
  dark,
  teal,
}

class ThemeProvider with ChangeNotifier {
  AppTheme _appTheme = AppTheme.system;

  AppTheme get appTheme => _appTheme;

  ThemeMode get themeMode {
    switch (_appTheme) {
      case AppTheme.light:
      case AppTheme.teal:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  bool get isTealTheme => _appTheme == AppTheme.teal;
  bool get isDarkMode => _appTheme == AppTheme.dark;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void setAppTheme(AppTheme theme) {
    if (_appTheme == theme) return;
    _appTheme = theme;
    _saveThemeToPrefs(theme);
    notifyListeners();
  }

  // Keep for backward compatibility
  void setThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        setAppTheme(AppTheme.light);
        break;
      case ThemeMode.dark:
        setAppTheme(AppTheme.dark);
        break;
      case ThemeMode.system:
        setAppTheme(AppTheme.system);
        break;
    }
  }

  void toggleTheme(bool isOn) {
    setAppTheme(isOn ? AppTheme.dark : AppTheme.light);
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? themeStr = prefs.getString('themeMode');
      if (themeStr != null) {
        _appTheme = _parseAppTheme(themeStr);
      } else {
        final bool? isDark = prefs.getBool('isDarkMode');
        if (isDark != null) {
          _appTheme = isDark ? AppTheme.dark : AppTheme.light;
          _saveThemeToPrefs(_appTheme);
        } else {
          _appTheme = AppTheme.system;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _appTheme = AppTheme.system;
      notifyListeners();
    }
  }

  Future<void> _saveThemeToPrefs(AppTheme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', theme.name);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  AppTheme _parseAppTheme(String themeStr) {
    switch (themeStr) {
      case 'teal':
        return AppTheme.teal;
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'system':
      default:
        return AppTheme.system;
    }
  }
}
