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

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
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

        if (notification != null) {
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