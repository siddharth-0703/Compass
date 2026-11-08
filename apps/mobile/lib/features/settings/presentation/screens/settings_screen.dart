import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getThemeTitle(ThemeMode mode, AppStrings strings) {
    switch (mode) {
      case ThemeMode.system:
        return strings.systemDefault;
      case ThemeMode.light:
        return strings.lightTheme;
      case ThemeMode.dark:
        return strings.darkTheme;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final currentThemeMode = ref.watch(themeModeProvider);
    final strings = ref.watch(appStringsProvider);
    final savedLang = ref.watch(appLocaleProvider);

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

    final langTitle = savedLang == 'hi'
        ? 'Hindi (हिंदी)'
        : (savedLang == 'mr' ? 'Marathi (मराठी)' : 'English');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              strings.account,
              style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              strings.preferences,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(strings.language),
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            strings.selectLanguage,
                            style: const TextStyle(
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
                            await ref.read(appLocaleProvider.notifier).setLocale('en');
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
                            await ref.read(appLocaleProvider.notifier).setLocale('hi');
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
                            await ref.read(appLocaleProvider.notifier).setLocale('mr');
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
            title: Text(strings.appearance),
            subtitle: Text(_getThemeTitle(currentThemeMode, strings)),
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            strings.appearance,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.brightness_auto),
                          title: Text(strings.systemDefault),
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
                          title: Text(strings.lightTheme),
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
                          title: Text(strings.darkTheme),
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
            title: Text(strings.syncSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/sync'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              strings.logout,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(strings.logout),
                  content: Text(
                    strings.isHindi
                        ? 'क्या आप निश्चित रूप से लॉग आउट करना चाहते हैं?'
                        : (strings.isMarathi
                            ? 'तुम्हाला नक्की बाहेर पडायचे आहे का?'
                            : 'Are you sure you want to logout?'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(strings.cancel),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(strings.logout),
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
