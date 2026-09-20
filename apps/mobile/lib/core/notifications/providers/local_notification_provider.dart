import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_notification.dart';
import 'notification_provider.dart';

class LocalNotificationProvider implements AppNotificationProvider {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // In a real app, use a global navigation key or stream to route the user
      debugPrint(
          'User tapped notification, navigating to: \${response.payload}',);
    }
  }

  @override
  Future<void> showNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'rural_channel',
      'Rural Alerts',
      channelDescription: 'Important updates for your business',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.message,
      notificationDetails: details,
      payload: notification.deepLink,
    );
  }
}
