import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/services/notification_service.dart';
import 'package:go_router/go_router.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationService = ref.watch(notificationServiceProvider);
    final history = notificationService.getHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              await notificationService.clearAll();
              setState(() {});
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final notif = history[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        notif.isRead ? Colors.grey[200] : Colors.blue[100],
                    child: Icon(
                      _getIconForType(notif.type),
                      color: notif.isRead ? Colors.grey : Colors.blue,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight:
                          notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif.message),
                  trailing: Text(
                    _formatTime(notif.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () async {
                    if (!notif.isRead) {
                      await notificationService.markAsRead(notif.id);
                      setState(() {});
                    }
                    if (notif.deepLink != null) {
                      if (!context.mounted) return;
                      context.push(notif.deepLink!);
                    }
                  },
                );
              },
            ),
    );
  }

  IconData _getIconForType(type) {
    switch (type.toString()) {
      case 'NotificationType.sync':
        return Icons.sync;
      case 'NotificationType.marketplace':
        return Icons.storefront;
      case 'NotificationType.learning':
        return Icons.school;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '\${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '\${diff.inHours}h ago';
    return '\${diff.inDays}d ago';
  }
}
