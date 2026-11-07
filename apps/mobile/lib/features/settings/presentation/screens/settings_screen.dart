import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/storage/hive_storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getThemeTitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final currentThemeMode = ref.watch(themeModeProvider);

    final fullName = (user?.firstName != null && user?.lastName != null)
        ? '${user!.firstName} ${user.lastName}'.trim()
        : (user?.firstName ?? 'Siddharth Jaiswar');
    final email = user?.email ?? 'siddharthjaiswar9107@gmail.com';

    final initials = fullName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join('');

    final savedLang = HiveStorage.settingsBox.get('app_language') ?? 'en';
    final langTitle = savedLang == 'hi'
        ? 'Hindi (हिंदी)'
        : (savedLang == 'mr' ? 'Marathi (मराठी)' : 'English');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade700,
              radius: 20,
              child: Text(
                initials.isNotEmpty ? initials : 'SJ',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '$email • ${user?.role.toUpperCase() ?? "ADMIN"}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/profile'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(langTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Select Language',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('English (en)'),
                          trailing: savedLang == 'en'
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () async {
                            await HiveStorage.settingsBox
                                .put('app_language', 'en');
                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Language set to English'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Hindi (हिंदी)'),
                          trailing: savedLang == 'hi'
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () async {
                            await HiveStorage.settingsBox
                                .put('app_language', 'hi');
                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('भाषा हिंदी चुनी गई'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Marathi (मराठी)'),
                          trailing: savedLang == 'mr'
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () async {
                            await HiveStorage.settingsBox
                                .put('app_language', 'mr');
                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('भाषा मराठी निवडली'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Appearance'),
            subtitle: Text(_getThemeTitle(currentThemeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Select Appearance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.brightness_auto),
                          title: const Text('System default'),
                          trailing: currentThemeMode == ThemeMode.system
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .setTheme(ThemeMode.system);
                            context.pop();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.light_mode),
                          title: const Text('Light theme'),
                          trailing: currentThemeMode == ThemeMode.light
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .setTheme(ThemeMode.light);
                            context.pop();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.dark_mode),
                          title: const Text('Dark theme'),
                          trailing: currentThemeMode == ThemeMode.dark
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .setTheme(ThemeMode.dark);
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/sync'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Compass App v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
