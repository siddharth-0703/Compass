import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_notification.dart';
import '../providers/notification_provider.dart';
import '../providers/local_notification_provider.dart';
import '../../storage/hive_storage.dart';
import 'package:uuid/uuid.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final provider = LocalNotificationProvider();
  final service = NotificationService(provider);
  service.init();
  return service;
});

class NotificationService {
  final AppNotificationProvider _provider;

  NotificationService(this._provider);

  Future<void> init() async {
    await _provider.initialize();
  }

  Future<void> push(String title, String message, NotificationType type,
      {String? deepLink,}) async {
    final notification = AppNotification(
      id: const Uuid().v4(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      deepLink: deepLink,
    );

    // Save to history
    await HiveStorage.notificationBox
        .put(notification.id, notification.toJson());

    // Show on device
    await _provider.showNotification(notification);
  }

  List<AppNotification> getHistory() {
    final box = HiveStorage.notificationBox;
    final rawList = box.values.toList();
    final list = rawList
        .map((e) =>
            AppNotification.fromJson(Map<String, dynamic>.from(e as Map)),)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> markAsRead(String id) async {
    final box = HiveStorage.notificationBox;
    final raw = box.get(id);
    if (raw != null) {
      var notif =
          AppNotification.fromJson(Map<String, dynamic>.from(raw as Map));
      notif = notif.copyWith(isRead: true);
      await box.put(id, notif.toJson());
    }
  }

  Future<void> clearAll() async {
    await HiveStorage.notificationBox.clear();
  }
}
