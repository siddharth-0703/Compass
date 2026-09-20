import 'package:flutter/material.dart';
import '../../../../core/network/models/sync_task.dart';
import '../../domain/mappers/operation_mapper.dart';
import 'package:timeago/timeago.dart' as timeago;

class SyncTaskCard extends StatelessWidget {
  final SyncTask task;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  const SyncTaskCard({
    super.key,
    required this.task,
    this.onRetry,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final title = OperationMapper.getHumanReadableTitle(task);

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help;
    String statusText = task.status.name.toUpperCase();

    switch (task.status) {
      case SyncStatus.queued:
      case SyncStatus.waiting:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case SyncStatus.syncing:
        statusColor = Colors.blue;
        statusIcon = Icons.cloud_upload;
        break;
      case SyncStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.failed:
      case SyncStatus.conflict:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case SyncStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16,),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Added ${timeago.format(task.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (task.lastAttempt != null)
              Text(
                'Last attempt ${timeago.format(task.lastAttempt!)} (${task.retryCount} retries)',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

            // Actions for failed/conflict tasks
            if (task.status == SyncStatus.failed ||
                task.status == SyncStatus.conflict)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onDiscard,
                      child: const Text('DISCARD',
                          style: TextStyle(color: Colors.red),),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
