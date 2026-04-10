import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/push_notification_service.dart';

class NotificationSettingsProvider with ChangeNotifier {
  static const String _prayersKey = 'notifications_prayers_enabled';
  static const String _eventsKey = 'notifications_events_enabled';

  bool _prayersEnabled = true;
  bool _eventsEnabled = true;

  bool _isLoading = true;

  NotificationSettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Default to true if not set
    _prayersEnabled = prefs.getBool(_prayersKey) ?? true;
    _eventsEnabled = prefs.getBool(_eventsKey) ?? true;
    
    _isLoading = false;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  bool get prayersEnabled => _prayersEnabled;
  bool get eventsEnabled => _eventsEnabled;

  bool get allNotificationsEnabled => _prayersEnabled && _eventsEnabled;

  void setPrayersEnabled(bool enabled) async {
    if (_prayersEnabled == enabled) return;
    _prayersEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prayersKey, enabled);
    _updateSubscriptions(prefs);
  }

  void setEventsEnabled(bool enabled) async {
    if (_eventsEnabled == enabled) return;
    _eventsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eventsKey, enabled);
    _updateSubscriptions(prefs);
  }

  void setAllNotificationsEnabled(bool enabled) async {
    bool changed = false;
    final prefs = await SharedPreferences.getInstance();
    
    if (_prayersEnabled != enabled) {
      _prayersEnabled = enabled;
      await prefs.setBool(_prayersKey, enabled);
      changed = true;
    }
    
    if (_eventsEnabled != enabled) {
      _eventsEnabled = enabled;
      await prefs.setBool(_eventsKey, enabled);
      changed = true;
    }

    if (changed) {
      notifyListeners();
      _updateSubscriptions(prefs);
    }
  }

  void _updateSubscriptions(SharedPreferences prefs) {
    if (!kIsWeb) {
      final String? mosallaId = prefs.getString('selected_mosalla_id');
      if (mosallaId != null && mosallaId.isNotEmpty) {
        PushNotificationService.updateSubscriptions(mosallaId);
      }
    }
  }
}
