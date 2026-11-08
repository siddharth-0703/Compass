import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/hive_storage.dart';
import 'app_strings.dart';

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, String>((ref) {
  return AppLocaleNotifier();
});

class AppLocaleNotifier extends StateNotifier<String> {
  AppLocaleNotifier()
      : super(
          HiveStorage.settingsBox.get('app_language', defaultValue: 'en') as String,
        );

  Future<void> setLocale(String lang) async {
    if (lang != state) {
      await HiveStorage.settingsBox.put('app_language', lang);
      state = lang;
    }
  }
}

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLocaleProvider);
  return AppStrings(lang);
});

