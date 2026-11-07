import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  int _notificationId = 0;
  final FlutterLocalNotificationsPlugin
  _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel
  _channel = AndroidNotificationChannel(
    'pantry_updates',
    'Pantry Updates',
    description:
    'Notifications about food pantry updates.',
    importance: Importance.high,
  );

  Future<void> initNotifications() async {
    const AndroidInitializationSettings
    androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS/macOS need their own settings or initialize() throws and
    // nothing below runs (topic subscribe, token).
    const DarwinInitializationSettings darwinSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      _channel,
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Ask for push permission and let iOS show FCM
      // notifications itself while the app is in the foreground.
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Listen for FCM messages while the app is open.
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        debugPrint(
          '================================',
        );
        debugPrint(
          'FCM MESSAGE RECEIVED',
        );
        debugPrint(
          'Message ID: ${message.messageId}',
        );
        debugPrint(
          'Title: ${message.notification?.title}',
        );
        debugPrint(
          'Body: ${message.notification?.body}',
        );
        debugPrint(
          'Data: ${message.data}',
        );
        debugPrint(
          '================================',
        );

        final RemoteNotification? notification =
            message.notification;

        // iOS already presents it (options above); avoid a duplicate.
        if (notification != null &&
            defaultTargetPlatform != TargetPlatform.iOS) {
          _showNotification(
            notification.title ??
                'Food Pantry Update',
            notification.body ?? '',
          );
        }
      },
    );

    // Runs when the user taps an FCM notification
    // while the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        debugPrint(
          'FCM notification opened: '
              '${message.messageId}',
        );
      },
    );

    // Check whether the app was launched by
    // tapping a notification.
    final RemoteMessage? initialMessage =
    await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'App opened from notification: '
            '${initialMessage.messageId}',
      );
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'pantry_updates',
      'Pantry Updates',
      channelDescription: 'Notifications about food pantry updates.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      _notificationId++,
      title,
      body,
      details,
    );
  }
}