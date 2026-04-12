import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static const String _subscribedMosallaKey = 'last_subscribed_mosalla_id';
  
  static Future<void> initialize() async {
    // 1. Request permissions (especially useful on iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      criticalAlert: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    // 2. Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Setup local notification for foreground display
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_alerts_channel', // id
      'Prayer Alerts', // name
      description: 'Alerts for prayer times', // description
      importance: Importance.max,
      playSound: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received foreground message: ${message.messageId}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
            ),
          ),
        );
      }
    });
  }

  static Future<bool> getPermissionStatus() async {
    NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<void> updateSubscriptions(String mosallaId) async {
    final prefs = await SharedPreferences.getInstance();
    final prayersEnabled = prefs.getBool('notifications_prayers_enabled') ?? true;
    final eventsEnabled = prefs.getBool('notifications_events_enabled') ?? true;

    final prayersTopic = 'mosalla_${mosallaId}_prayers';
    final eventsTopic = 'mosalla_${mosallaId}_events';

    // Track previously subscribed mosque via SharedPreferences
    final String? lastSubscribedId = prefs.getString(_subscribedMosallaKey);

    // 1. On iOS, we MUST wait for the APNS token before any FCM action
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      log('Checking for APNS token...');
      try {
        String? token = await _firebaseMessaging.getAPNSToken();
        int retries = 0;
        // If we are on a simulator, getAPNSToken() might return null but not throw immediately,
        // or it might throw depending on the firebase_messaging version.
        while (token == null && retries < 5) {
          await Future.delayed(const Duration(seconds: 1));
          token = await _firebaseMessaging.getAPNSToken();
          retries++;
        }
        
        if (token == null) {
          log('APNS token not available (normal on simulators). Skipping topic subscriptions.');
          return; // Cannot subscribe without APNS token on iOS
        }
        log('APNS token received: $token');
      } catch (e) {
        log('APNS token check failed: $e. This is expected on simulators.');
        return; // Cannot proceed with subscriptions on this device
      }
    }

    // 2. Wrap all FCM actions in try-catch
    try {
      // Unsubscribe from old topic if mosalla changed
      if (lastSubscribedId != null && lastSubscribedId != mosallaId) {
        log('Unsubscribing from old mosalla topics: $lastSubscribedId');
        await _firebaseMessaging.unsubscribeFromTopic('mosalla_${lastSubscribedId}_prayers');
        await _firebaseMessaging.unsubscribeFromTopic('mosalla_${lastSubscribedId}_events');
        await _firebaseMessaging.unsubscribeFromTopic('mosalla_$lastSubscribedId');
      }

      if (prayersEnabled) {
        log('Subscribing to topic: $prayersTopic');
        await _firebaseMessaging.subscribeToTopic(prayersTopic);
      } else {
        log('Unsubscribing from topic: $prayersTopic');
        await _firebaseMessaging.unsubscribeFromTopic(prayersTopic);
      }

      if (eventsEnabled) {
        log('Subscribing to topic: $eventsTopic');
        await _firebaseMessaging.subscribeToTopic(eventsTopic);
      } else {
        log('Unsubscribing from topic: $eventsTopic');
        await _firebaseMessaging.unsubscribeFromTopic(eventsTopic);
      }

      // Save the new subscription state
      await prefs.setString(_subscribedMosallaKey, mosallaId);
      log('Successfully updated subscription persistence to: $mosallaId');
    } catch (e) {
      log('Error during topic subscription management: $e');
    }
  }
}
