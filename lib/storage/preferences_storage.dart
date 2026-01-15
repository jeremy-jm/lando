import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys for user preferences
class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String localeLanguageCode = 'locale_language_code';
}

/// Storage service for managing user preferences
class PreferencesStorage {
  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get shared preferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError(
        'PreferencesStorage not initialized. Call PreferencesStorage.init() first.',
      );
    }
    return _prefs!;
  }

  // ==================== Theme Mode ====================

  /// Save theme mode
  static Future<bool> saveThemeMode(String themeMode) async {
    return await prefs.setString(StorageKeys.themeMode, themeMode);
  }

  /// Get theme mode
  static String? getThemeMode() {
    return prefs.getString(StorageKeys.themeMode);
  }

  // ==================== Locale ====================

  /// Save locale language code
  static Future<bool> saveLocaleLanguageCode(String languageCode) async {
    return await prefs.setString(StorageKeys.localeLanguageCode, languageCode);
  }

  /// Get locale language code
  static String? getLocaleLanguageCode() {
    return prefs.getString(StorageKeys.localeLanguageCode);
  }

  // ==================== Clear ====================

  /// Clear all preferences
  static Future<bool> clearAll() async {
    return await prefs.clear();
  }

  /// Clear specific key
  static Future<bool> clear(String key) async {
    return await prefs.remove(key);
  }
}
