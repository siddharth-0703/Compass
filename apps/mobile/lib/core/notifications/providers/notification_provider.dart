import '../models/app_notification.dart';

abstract class AppNotificationProvider {
  Future<void> initialize();
  Future<void> showNotification(AppNotification notification);
}
