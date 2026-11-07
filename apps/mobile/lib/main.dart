import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_storage.dart';
import 'core/router/app_router.dart';
import 'core/network/sync_manager.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (Hive)
  await HiveStorage.init();

  runApp(
    const ProviderScope(
      child: RuralEntrepreneurApp(),
    ),
  );
}

class RuralEntrepreneurApp extends ConsumerWidget {
  const RuralEntrepreneurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Watch syncManagerProvider to initialize the background sync listener
    ref.watch(syncManagerProvider);

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Rural Entrepreneur App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
