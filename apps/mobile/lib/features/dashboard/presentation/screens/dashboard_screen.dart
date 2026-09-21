import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/notifications/services/notification_service.dart';
import '../../../shared/presentation/widgets/voice_assistant_overlay.dart';

// Import screens for the bottom navigation
import '../../../learning/presentation/screens/learning_screen.dart';
import '../../../schemes/screens/scheme_recommender_screen.dart';
import '../../../businesses/presentation/screens/business_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    final List<Widget> screens = [
      _buildHomeTab(context, authState),
      const BusinessListScreen(),
      const LearningScreen(),
      const SchemeRecommenderScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final notifs = ref.watch(notificationServiceProvider).getHistory();
              final unreadCount = notifs.where((n) => !n.isRead).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.bell),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authState),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.building2),
            label: 'Businesses',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bookOpen),
            label: 'Learning',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.heartHandshake),
            label: 'Schemes',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton.extended(
            icon: const Icon(LucideIcons.mic, color: Colors.white),
            label: const Text('Voice Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () => VoiceAssistantOverlay.show(context),
          )
        : null,
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Compass';
      case 1:
        return 'Businesses';
      case 2:
        return 'Learning Hub';
      case 3:
        return 'Government Schemes';
      default:
        return 'Compass';
    }
  }

  Widget _buildDrawer(BuildContext context, AuthState authState) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                children: [
            Icon(LucideIcons.compass, size: 32, color: Color(0xFF14b8a6)), // Teal 500
            SizedBox(width: 12),
            Text(
                    'Compass',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerGroup('OVERVIEW'),
                  _buildDrawerItem(
                    icon: LucideIcons.layoutDashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                    selected: _currentIndex == 0,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDrawerGroup('MANAGEMENT'),
                  _buildDrawerItem(
                    icon: LucideIcons.building2,
                    title: 'Businesses',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                    selected: _currentIndex == 1,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.graduationCap,
                    title: 'Mentorship',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/mentors'); // Navigates out of IndexedStack for now
                    },
                    selected: false,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.heartHandshake,
                    title: 'Schemes',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    },
                    selected: _currentIndex == 3,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.lineChart,
                    title: 'Market Prices',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/market'); // Navigates out of IndexedStack for now
                    },
                    selected: false,
                  ),
                  const SizedBox(height: 16),

                  _buildDrawerGroup('AI & CONTENT'),
                  _buildDrawerItem(
                    icon: LucideIcons.bookOpen,
                    title: 'Learning Hub',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                    selected: _currentIndex == 2,
                  ),
                  const SizedBox(height: 16),

                  _buildDrawerGroup('SYSTEM'),
                  _buildDrawerItem(
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                    selected: false,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      (authState.user?.firstName?.isNotEmpty == true)
                          ? authState.user!.firstName![0].toUpperCase()
                          : 'U',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.firstName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          authState.user?.role.toUpperCase() ?? 'ENTREPRENEUR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut),
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerGroup(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool selected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: selected,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, AuthState authState) {
    return SafeArea(
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
              icon: LucideIcons.bookOpen,
              onTap: () => setState(() => _currentIndex = 2),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'My Businesses',
              description: 'Manage your business profiles and insights',
              icon: LucideIcons.building2,
              onTap: () => setState(() => _currentIndex = 1),
              color: Colors.purple.shade600,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Government Schemes',
              description: 'Discover grants and support for your business',
              icon: LucideIcons.heartHandshake,
              onTap: () => setState(() => _currentIndex = 3),
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Market Prices',
              description: 'Check daily mandi rates for commodities',
              icon: LucideIcons.lineChart,
              onTap: () => context.push('/market'),
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Mentorship',
              description: 'Connect with experts and schedule sessions',
              icon: LucideIcons.graduationCap,
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
                child: Icon(LucideIcons.refreshCw, color: Theme.of(context).colorScheme.onSurface),
              ),
              title: const Text('Offline Operations Center', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Manage data sync for offline access'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => context.push('/settings/sync'),
            ),
          ],
        ),
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
                LucideIcons.chevronRight,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
