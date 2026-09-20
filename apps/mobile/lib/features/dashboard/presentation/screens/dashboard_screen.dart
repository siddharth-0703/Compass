import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/notifications/services/notification_service.dart';
import '../../../shared/presentation/widgets/voice_assistant_overlay.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final notifs =
                  ref.watch(notificationServiceProvider).getHistory();
              final unreadCount = notifs.where((n) => !n.isRead).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10,),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${authState.user?.firstName ?? authState.user?.phone ?? "User"}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to explore today?',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildFeatureCard(
                context,
                title: 'Learning Hub',
                description: 'Access courses, tutorials, and business skills',
                icon: Icons.school_outlined,
                onTap: () => context.push('/learning'),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'My Businesses',
                description: 'Manage your business profiles and insights',
                icon: Icons.storefront_outlined,
                onTap: () => context.push('/businesses'),
                color: Colors.purple.shade600,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Government Schemes',
                description: 'Discover grants and support for your business',
                icon: Icons.gavel_outlined,
                onTap: () => context.push('/schemes'),
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Market Prices',
                description: 'Check daily mandi rates for commodities',
                icon: Icons.currency_rupee,
                onTap: () => context.push('/market'),
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Mentorship',
                description: 'Connect with experts and schedule sessions',
                icon: Icons.people_outline,
                onTap: () => context.push('/mentors'),
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 32),
              
              const Divider(),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.sync, color: Theme.of(context).colorScheme.onSurface),
                ),
                title: const Text('Offline Operations Center', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Manage data sync for offline access'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/sync'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.mic, color: Colors.white),
        label: const Text('Voice Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => VoiceAssistantOverlay.show(context),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
