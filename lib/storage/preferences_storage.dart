import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys for user preferences
class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String localeLanguageCode = 'locale_language_code';
  static const String translationFromLanguage = 'translation_from_language';
  static const String translationToLanguage = 'translation_to_language';
  static const String pronunciationServiceType = 'pronunciation_service_type';
  static const String corsProxyUrl = 'cors_proxy_url';
  static const String showWindowHotkey = 'show_window_hotkey';
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

  // ==================== Translation Language Pair ====================

  /// Save translation language pair
  /// If fromLanguage or toLanguage is null, it means auto-detect
  static Future<bool> saveTranslationLanguages({
    String? fromLanguage,
    String? toLanguage,
  }) async {
    final futures = <Future<bool>>[];
    if (fromLanguage == null) {
      futures.add(prefs.remove(StorageKeys.translationFromLanguage));
    } else {
      futures.add(
        prefs.setString(StorageKeys.translationFromLanguage, fromLanguage),
      );
    }
    if (toLanguage == null) {
      futures.add(prefs.remove(StorageKeys.translationToLanguage));
    } else {
      futures.add(
        prefs.setString(StorageKeys.translationToLanguage, toLanguage),
      );
    }
    final results = await Future.wait(futures);
    return results.every((r) => r);
  }

  /// Get translation from language
  static String? getTranslationFromLanguage() {
    return prefs.getString(StorageKeys.translationFromLanguage);
  }

  /// Get translation to language
  static String? getTranslationToLanguage() {
    return prefs.getString(StorageKeys.translationToLanguage);
  }

  // ==================== Pronunciation Service Type ====================

  /// Save pronunciation service type
  static Future<bool> savePronunciationServiceType(String serviceType) async {
    return await prefs.setString(StorageKeys.pronunciationServiceType, serviceType);
  }

  /// Get pronunciation service type
  static String? getPronunciationServiceType() {
    return prefs.getString(StorageKeys.pronunciationServiceType);
  }

  // ==================== CORS Proxy URL ====================

  /// Save CORS proxy URL (for Web platform development)
  /// Set to null to disable CORS proxy
  static Future<bool> saveCorsProxyUrl(String? proxyUrl) async {
    if (proxyUrl == null || proxyUrl.isEmpty) {
      return await prefs.remove(StorageKeys.corsProxyUrl);
    }
    return await prefs.setString(StorageKeys.corsProxyUrl, proxyUrl);
  }

  /// Get CORS proxy URL
  static String? getCorsProxyUrl() {
    return prefs.getString(StorageKeys.corsProxyUrl);
  }

  // ==================== Hotkey ====================

  /// Save show window hotkey
  /// Format: "keyCode:modifiers" (e.g., "76:3" for Cmd+Alt+L on Mac)
  static Future<bool> saveShowWindowHotkey(String hotkey) async {
    return await prefs.setString(StorageKeys.showWindowHotkey, hotkey);
  }

  /// Get show window hotkey
  /// Returns null if not set
  static String? getShowWindowHotkey() {
    return prefs.getString(StorageKeys.showWindowHotkey);
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
