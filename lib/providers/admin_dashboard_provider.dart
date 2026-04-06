import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/event.dart';
import '../model/prayer_data.dart';
import '../repositories/mosalla_repository.dart';

class AdminDashboardProvider with ChangeNotifier {
  static const String _keySelectedIndex = 'admin_selected_index';
  static const String _keyShowPreview = 'admin_show_preview';
  static const String _keySelectedDate = 'admin_selected_date';

  int _selectedIndex = 0;
  bool _showAppPreview = false;
  DateTime _selectedDate = DateTime.now();
  bool _isInitialized = false;

  // Caching layer
  final Map<String, List<PrayerData?>> _prayerCache = {};
  List<Event>? _eventsCache;
  final Set<String> _loadingMonths = {};
  bool _isLoadingEvents = false;

  int get selectedIndex => _selectedIndex;
  bool get showAppPreview => _showAppPreview;
  DateTime get selectedDate => _selectedDate;
  bool get isInitialized => _isInitialized;
  List<Event>? get eventsCache => _eventsCache;
  bool get isLoadingEvents => _isLoadingEvents;

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

  // --- Caching Logic ---

  List<PrayerData?>? getCachedMonth(String mosallaId, DateTime date) {
    final key = '$mosallaId-${DateFormat('MM-yyyy').format(date)}';
    return _prayerCache[key];
  }

  Future<void> ensureMonthLoaded(MosallaRepository repo, String mosallaId, DateTime date) async {
    final monthStr = DateFormat('MM-yyyy').format(date);
    final key = '$mosallaId-$monthStr';
    
    if (_prayerCache.containsKey(key) || _loadingMonths.contains(key)) return;
    
    _loadingMonths.add(key);
    // Defer notification to avoid "setState during build" if triggered from build()
    Future.microtask(() => notifyListeners());

    try {
      final data = await repo.getPrayerTimesByMonth(mosallaId, monthStr);
      final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
      final monthArray = List<PrayerData?>.filled(daysInMonth, null);
      
      for (var p in data) {
        final day = int.tryParse(p.id.split('-')[0]);
        if (day != null && day <= daysInMonth) {
          monthArray[day - 1] = p;
        }
      }
      
      _prayerCache[key] = monthArray;
    } catch (e) {
      debugPrint('Error loading month $monthStr: $e');
    } finally {
      _loadingMonths.remove(key);
      notifyListeners();
    }
  }

  Future<void> ensureEventsLoaded(MosallaRepository repo, String mosallaId) async {
    if (_eventsCache != null || _isLoadingEvents) return;

    _isLoadingEvents = true;
    // Defer notification to avoid "setState during build" if triggered from build()
    Future.microtask(() => notifyListeners());

    try {
      // Use a one-shot fetch for caching purposes
      final snapshot = await repo.getEventsStream(mosallaId).first;
      _eventsCache = snapshot;
    } catch (e) {
      debugPrint('Error loading events: $e');
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  void invalidateCache() {
    _prayerCache.clear();
    _eventsCache = null;
    notifyListeners();
  }
}
