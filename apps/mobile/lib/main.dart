import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_storage.dart';
import 'core/router/app_router.dart';
import 'core/network/sync_manager.dart';

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

    // You could also watch the theme provider here if implemented

    return MaterialApp.router(
      title: 'Rural Entrepreneur App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode:
          ThemeMode.system, // Will be overridden by Hive settings in the future
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
