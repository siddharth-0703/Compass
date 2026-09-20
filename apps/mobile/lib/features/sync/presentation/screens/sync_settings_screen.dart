import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';
import '../widgets/sync_task_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class SyncSettingsScreen extends ConsumerWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncNotifierProvider);
    final notifier = ref.read(syncNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Operations Center'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildStatusHeader(context, state),
                const SizedBox(height: 16),
                _buildSettings(state, notifier),
                const Divider(height: 32),

                // Queues
                if (state.pendingTasks.isNotEmpty) ...[
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Pending Sync',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18,),),
                  ),
                  ...state.pendingTasks.map((t) => SyncTaskCard(task: t)),
                  const SizedBox(height: 16),
                ],

                if (state.conflictTasks.isNotEmpty) ...[
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Action Required',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,),),
                  ),
                  ...state.conflictTasks.map(
                    (t) => SyncTaskCard(
                      task: t,
                      onRetry: () => notifier.retryTask(t.id),
                      onDiscard: () => notifier.discardTask(t.id),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (state.historyTasks.isNotEmpty) ...[
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Recent History',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18,),),
                  ),
                  ...state.historyTasks.map((t) => SyncTaskCard(task: t)),
                  const SizedBox(height: 16),
                ],
              ],
            ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, SyncState state) {
    Color connColor = state.isConnected ? Colors.green : Colors.red;
    String connText = state.isConnected
        ? 'Connected via ${state.connectionType ?? "Unknown"}'
        : 'Offline (Waiting for Connection)';
    IconData connIcon = state.isConnected ? Icons.wifi : Icons.wifi_off;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(connIcon, color: connColor),
                  const SizedBox(width: 8),
                  Text(connText,
                      style: TextStyle(
                          color: connColor, fontWeight: FontWeight.bold,),),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                  label: 'Pending',
                  value: state.pendingTasks.length.toString(),),
              _StatItem(
                  label: 'Failed',
                  value: state.conflictTasks.length.toString(),
                  color: Colors.red,),
              _StatItem(
                  label: 'Completed',
                  value: state.historyTasks.length.toString(),),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Last Successful Sync: ${state.lastSuccessfulSync != null ? timeago.format(state.lastSuccessfulSync!) : "Never"}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(SyncState state, SyncNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Sync only on Wi-Fi'),
            subtitle: const Text(
                'Save mobile data by restricting large syncs to Wi-Fi',),
            value: state.isWifiOnly,
            onChanged: (val) => notifier.setWifiOnly(val),
          ),
          // Placeholders for future features
          SwitchListTile(
            title: const Text('Background Sync'),
            subtitle: const Text('Sync even when the app is closed'),
            value: true,
            onChanged: (val) {},
            activeTrackColor: Colors.grey, // Disabled look for MVP
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color,),),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
