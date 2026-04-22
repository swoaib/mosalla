import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/push_notification_service.dart';

class NotificationSettingsProvider with ChangeNotifier {
  static const String _prayersKey = 'notifications_prayers_enabled';
  static const String _eventsKey = 'notifications_events_enabled';

  bool _prayersEnabled = true;
  bool _eventsEnabled = true;
  bool _isPermissionGranted = false;

  bool _isLoading = true;
  bool _isPrayersLoading = false;
  bool _isEventsLoading = false;

  NotificationSettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Default to true if not set
    _prayersEnabled = prefs.getBool(_prayersKey) ?? true;
    _eventsEnabled = prefs.getBool(_eventsKey) ?? true;
    
    _isPermissionGranted = await PushNotificationService.getPermissionStatus();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkPermissionStatus() async {
    final status = await PushNotificationService.getPermissionStatus();
    if (_isPermissionGranted != status) {
      _isPermissionGranted = status;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  bool get isPrayersLoading => _isPrayersLoading;
  bool get isEventsLoading => _isEventsLoading;
  bool get prayersEnabled => _prayersEnabled;
  bool get eventsEnabled => _eventsEnabled;
  bool get isPermissionGranted => _isPermissionGranted;

  bool get allNotificationsEnabled => _prayersEnabled && _eventsEnabled;

  Future<void> setPrayersEnabled(bool enabled) async {
    if (_prayersEnabled == enabled) return;
    
    _isPrayersLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // We temporarily set it in prefs so PushNotificationService picks up the right value
      // but we don't update our local _prayersEnabled until we are sure it worked.
      final oldVal = _prayersEnabled;
      await prefs.setBool(_prayersKey, enabled);
      
      try {
        await _updateSubscriptions(prefs);
        _prayersEnabled = enabled;
      } catch (e) {
        // Revert prefs if it failed
        await prefs.setBool(_prayersKey, oldVal);
        rethrow;
      }
    } finally {
      _isPrayersLoading = false;
      notifyListeners();
    }
  }

  Future<void> setEventsEnabled(bool enabled) async {
    if (_eventsEnabled == enabled) return;
    
    _isEventsLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final oldVal = _eventsEnabled;
      await prefs.setBool(_eventsKey, enabled);
      
      try {
        await _updateSubscriptions(prefs);
        _eventsEnabled = enabled;
      } catch (e) {
        await prefs.setBool(_eventsKey, oldVal);
        rethrow;
      }
    } finally {
      _isEventsLoading = false;
      notifyListeners();
    }
  }

  Future<void> setAllNotificationsEnabled(bool enabled) async {
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
      await _updateSubscriptions(prefs);
    }
  }

  Future<void> _updateSubscriptions(SharedPreferences prefs) async {
    if (!kIsWeb) {
      final String? mosallaId = prefs.getString('selected_mosalla_id');
      if (mosallaId != null && mosallaId.isNotEmpty) {
        await PushNotificationService.updateSubscriptions(mosallaId);
      }
    }
  }
}
