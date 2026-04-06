import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardProvider with ChangeNotifier {
  static const String _keySelectedIndex = 'admin_selected_index';
  static const String _keyShowPreview = 'admin_show_preview';
  static const String _keySelectedDate = 'admin_selected_date';

  int _selectedIndex = 0;
  bool _showAppPreview = false;
  DateTime _selectedDate = DateTime.now();
  bool _isInitialized = false;

  int get selectedIndex => _selectedIndex;
  bool get showAppPreview => _showAppPreview;
  DateTime get selectedDate => _selectedDate;
  bool get isInitialized => _isInitialized;

  AdminDashboardProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedIndex = prefs.getInt(_keySelectedIndex) ?? 0;
      _showAppPreview = prefs.getBool(_keyShowPreview) ?? false;
      
      final dateStr = prefs.getString(_keySelectedDate);
      if (dateStr != null) {
        try {
          _selectedDate = DateTime.parse(dateStr);
        } catch (_) {
          _selectedDate = DateTime.now();
        }
      }
    } catch (e) {
      debugPrint('Error loading AdminDashboardProvider prefs: $e');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSelectedIndex(int index) async {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keySelectedIndex, index);
    } catch (e) {
      debugPrint('Error saving selectedIndex: $e');
    }
  }

  Future<void> setShowAppPreview(bool show) async {
    if (_showAppPreview == show) return;
    _showAppPreview = show;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyShowPreview, show);
    } catch (e) {
      debugPrint('Error saving showAppPreview: $e');
    }
  }

  Future<void> setSelectedDate(DateTime date) async {
    // Normalize to start of month for consistency
    final normalizedDate = DateTime(date.year, date.month);
    if (_selectedDate.year == normalizedDate.year && _selectedDate.month == normalizedDate.month) return;
    
    _selectedDate = normalizedDate;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedDate, _selectedDate.toIso8601String());
    } catch (e) {
      debugPrint('Error saving selectedDate: $e');
    }
  }
}
