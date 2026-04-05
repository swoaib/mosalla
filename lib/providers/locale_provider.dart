import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'selected_locale';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // Default to system locale if supported, else default to English
      String? systemLang;
      try {
        if (kIsWeb) {
          // On web, we can't use Platform.localeName
          // We can use null to let MaterialApp use the system locale
          systemLang = null; 
        } else {
          systemLang = Platform.localeName.split('_').first;
        }
      } catch (e) {
        systemLang = null;
      }

      if (systemLang == null || ['en', 'ja'].contains(systemLang)) {
        _locale = null; // null means use system
      } else {
        _locale = const Locale('en');
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    notifyListeners();
  }
}
