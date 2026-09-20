import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const String _settingsBox = 'settings';
  static const String _userCacheBox = 'userCache';
  static const String _syncQueueBox = 'syncQueue';
  static const String _conflictQueueBox = 'conflictQueue';
  static const String _historyQueueBox = 'historyQueue';
  static const String _syncSettingsBox = 'syncSettings';
  static const String _downloadQueueBox = 'downloadQueue';
  static const String _notificationBox = 'notifications';
  static const String _learningMetadataBox = 'learningMetadata';
  static const String _courseProgressBox = 'courseProgress';
  static const String _favoritesBox = 'favorites';
  static const String _recentCoursesBox = 'recentCourses';
  static const String _schemesDraftBox = 'schemesDraft';
  static const String _schemesCacheBox = 'schemesCache';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_userCacheBox);
    await Hive.openBox(_syncQueueBox);
    await Hive.openBox(_conflictQueueBox);
    await Hive.openBox(_historyQueueBox);
    await Hive.openBox(_syncSettingsBox);
    await Hive.openBox(_downloadQueueBox);
    await Hive.openBox(_notificationBox);
    await Hive.openBox(_learningMetadataBox);
    await Hive.openBox(_courseProgressBox);
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_recentCoursesBox);
    await Hive.openBox(_schemesDraftBox);
    await Hive.openBox(_schemesCacheBox);
  }

  // --- Settings ---
  static Box get settingsBox => Hive.box(_settingsBox);

  static Future<void> saveThemeMode(String mode) async {
    await settingsBox.put('themeMode', mode);
  }

  static String? getThemeMode() {
    return settingsBox.get('themeMode') as String?;
  }

  // --- User Cache ---
  static Box get userCacheBox => Hive.box(_userCacheBox);

  // --- Sync Queue (Offline Engine) ---
  static Box get syncQueueBox => Hive.box(_syncQueueBox);
  static Box get conflictQueueBox => Hive.box(_conflictQueueBox);
  static Box get historyQueueBox => Hive.box(_historyQueueBox);
  static Box get syncSettingsBox => Hive.box(_syncSettingsBox);
  static Box get downloadQueueBox => Hive.box(_downloadQueueBox);
  static Box get notificationBox => Hive.box(_notificationBox);

  // --- Learning Hub ---
  static Box get learningMetadataBox => Hive.box(_learningMetadataBox);
  static Box get courseProgressBox => Hive.box(_courseProgressBox);
  static Box get favoritesBox => Hive.box(_favoritesBox);
  static Box get recentCoursesBox => Hive.box(_recentCoursesBox);

  // --- Schemes ---
  static Box get schemesDraftBox => Hive.box(_schemesDraftBox);
  static Box get schemesCacheBox => Hive.box(_schemesCacheBox);
}
