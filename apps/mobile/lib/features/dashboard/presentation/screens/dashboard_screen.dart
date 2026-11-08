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
import '../widgets/hero_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/metric_card.dart';

import '../../../../core/widgets/compass_logo.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';

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
    final strings = ref.watch(appStringsProvider);

    final List<Widget> screens = [
      _buildHomeTab(context, authState),
      const BusinessListScreen(),
      const LearningScreen(),
      const SchemeRecommenderScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? const CompassBrandHeader(iconSize: 26, fontSize: 20, animated: true)
            : Text(_getAppBarTitle(_currentIndex, strings)),
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
      drawer: _buildDrawer(context, authState, strings),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.layoutDashboard),
            label: strings.overview,
          ),
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.building2),
            label: strings.businesses,
          ),
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.bookOpen),
            label: strings.learning,
          ),
          BottomNavigationBarItem(
            icon: const Icon(LucideIcons.heartHandshake),
            label: strings.schemes,
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

  String _getAppBarTitle(int index, AppStrings strings) {
    switch (index) {
      case 0:
        return 'Compass';
      case 1:
        return strings.businesses;
      case 2:
        return strings.learning;
      case 3:
        return strings.schemes;
      default:
        return 'Compass';
    }
  }

  Widget _buildDrawer(BuildContext context, AuthState authState, AppStrings strings) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CompassBrandHeader(
                    iconSize: 32,
                    fontSize: 24,
                    animated: true,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerGroup(strings.overview),
                  _buildDrawerItem(
                    icon: LucideIcons.layoutDashboard,
                    title: strings.dashboard,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                    selected: _currentIndex == 0,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.barChart2,
                    title: strings.analytics,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/analytics');
                    },
                    selected: false,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDrawerGroup(strings.management),
                  _buildDrawerItem(
                    icon: LucideIcons.users,
                    title: strings.users,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/users');
                    },
                    selected: false,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.building2,
                    title: strings.businesses,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                    selected: _currentIndex == 1,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.graduationCap,
                    title: strings.mentorship,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/mentors');
                    },
                    selected: false,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.heartHandshake,
                    title: strings.schemes,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    },
                    selected: _currentIndex == 3,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.lineChart,
                    title: strings.marketPrices,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/market');
                    },
                    selected: false,
                  ),
                  const SizedBox(height: 16),

                  _buildDrawerGroup(strings.aiContent),
                  _buildDrawerItem(
                    icon: LucideIcons.shieldCheck,
                    title: 'Moderation',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/moderation');
                    },
                    selected: false,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.bookOpen,
                    title: strings.learning,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                    selected: _currentIndex == 2,
                  ),
                  const SizedBox(height: 16),

                  _buildDrawerGroup(strings.system),
                  _buildDrawerItem(
                    icon: LucideIcons.activity,
                    title: 'Observability',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/observability');
                    },
                    selected: false,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.settings,
                    title: strings.settings,
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
                    tooltip: strings.logout,
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

  Widget _buildHomeTab(BuildContext context, dynamic authState) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic here
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeroBanner(),
              const SizedBox(height: 24),
              QuickActions(
                onTabSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Business Health',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: const [
                    MetricCard(
                      title: 'Active Businesses',
                      value: '1',
                      trend: 'vs last month',
                      trendValue: 0.0,
                      icon: LucideIcons.building2,
                    ),
                    MetricCard(
                      title: 'Community Members',
                      value: '12',
                      trend: 'vs last month',
                      trendValue: 12.5,
                      icon: LucideIcons.users,
                    ),
                    MetricCard(
                      title: 'Learning Hours',
                      value: '4.5',
                      trend: 'vs last week',
                      trendValue: 5.2,
                      icon: LucideIcons.graduationCap,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }


}
