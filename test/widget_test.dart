import 'package:flutter_test/flutter_test.dart';
import 'package:mosalla/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default theme should be system', () {
      final provider = ThemeProvider();
      expect(provider.appTheme, AppTheme.system);
      expect(provider.isTealTheme, isFalse);
    });

    test('Setting app theme to teal updates state and persistence', () async {
      final provider = ThemeProvider();
      provider.setAppTheme(AppTheme.teal);

      expect(provider.appTheme, AppTheme.teal);
      expect(provider.isTealTheme, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'teal');
    });

    test('Setting app theme to dark updates state and persistence', () async {
      final provider = ThemeProvider();
      provider.setAppTheme(AppTheme.dark);

      expect(provider.appTheme, AppTheme.dark);
      expect(provider.isDarkMode, isTrue);
      expect(provider.isTealTheme, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'dark');
    });

    test('Loading saved teal theme preference restores teal', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'teal'});
      final provider = ThemeProvider();
      // Wait for async prefs loading
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.appTheme, AppTheme.teal);
      expect(provider.isTealTheme, isTrue);
    });
  });
}
