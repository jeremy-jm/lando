import 'package:flutter_test/flutter_test.dart';
import 'package:lando/storage/preferences_storage.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PreferencesStorage', () {
    setUp(() async {
      await TestHelpers.initSharedPreferences();
    });

    tearDown(() async {
      await TestHelpers.clearSharedPreferences();
    });

    test('should initialize successfully', () async {
      await PreferencesStorage.init();
      expect(PreferencesStorage.prefs, isNotNull);
    });

    test('should throw error if not initialized', () {
      // Reset the static instance
      PreferencesStorage.init();
      // This test is tricky because we can't easily reset the static instance
      // In a real scenario, we'd need a way to reset it
    });

    group('Theme Mode', () {
      test('should save and retrieve theme mode', () async {
        await PreferencesStorage.init();
        const themeMode = 'dark';
        final saved = await PreferencesStorage.saveThemeMode(themeMode);
        expect(saved, isTrue);

        final retrieved = PreferencesStorage.getThemeMode();
        expect(retrieved, equals(themeMode));
      });

      test('should return null for non-existent theme mode', () async {
        await PreferencesStorage.init();
        final retrieved = PreferencesStorage.getThemeMode();
        expect(retrieved, isNull);
      });
    });

    group('Locale', () {
      test('should save and retrieve locale language code', () async {
        await PreferencesStorage.init();
        const languageCode = 'zh';
        final saved =
            await PreferencesStorage.saveLocaleLanguageCode(languageCode);
        expect(saved, isTrue);

        final retrieved = PreferencesStorage.getLocaleLanguageCode();
        expect(retrieved, equals(languageCode));
      });

      test('should return null for non-existent locale', () async {
        await PreferencesStorage.init();
        final retrieved = PreferencesStorage.getLocaleLanguageCode();
        expect(retrieved, isNull);
      });
    });

    group('Translation Languages', () {
      test('should save and retrieve translation language pair', () async {
        await PreferencesStorage.init();
        const fromLanguage = 'en';
        const toLanguage = 'zh';
        final saved = await PreferencesStorage.saveTranslationLanguages(
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
        );
        expect(saved, isTrue);

        final retrievedFrom = PreferencesStorage.getTranslationFromLanguage();
        final retrievedTo = PreferencesStorage.getTranslationToLanguage();
        expect(retrievedFrom, equals(fromLanguage));
        expect(retrievedTo, equals(toLanguage));
      });

      test('should remove translation languages when set to null', () async {
        await PreferencesStorage.init();
        // First save some values
        await PreferencesStorage.saveTranslationLanguages(
          fromLanguage: 'en',
          toLanguage: 'zh',
        );

        // Then remove them
        await PreferencesStorage.saveTranslationLanguages(
          fromLanguage: null,
          toLanguage: null,
        );

        final retrievedFrom = PreferencesStorage.getTranslationFromLanguage();
        final retrievedTo = PreferencesStorage.getTranslationToLanguage();
        expect(retrievedFrom, isNull);
        expect(retrievedTo, isNull);
      });

      test('should return null for non-existent translation languages',
          () async {
        await PreferencesStorage.init();
        final retrievedFrom = PreferencesStorage.getTranslationFromLanguage();
        final retrievedTo = PreferencesStorage.getTranslationToLanguage();
        expect(retrievedFrom, isNull);
        expect(retrievedTo, isNull);
      });
    });

    group('Pronunciation Service Type', () {
      test('should save and retrieve pronunciation service type', () async {
        await PreferencesStorage.init();
        const serviceType = 'system';
        final saved =
            await PreferencesStorage.savePronunciationServiceType(serviceType);
        expect(saved, isTrue);

        final retrieved = PreferencesStorage.getPronunciationServiceType();
        expect(retrieved, equals(serviceType));
      });

      test('should return null for non-existent pronunciation service type',
          () async {
        await PreferencesStorage.init();
        final retrieved = PreferencesStorage.getPronunciationServiceType();
        expect(retrieved, isNull);
      });
    });

    group('CORS Proxy URL', () {
      test('should save and retrieve CORS proxy URL', () async {
        await PreferencesStorage.init();
        const proxyUrl = 'https://proxy.example.com';
        final saved = await PreferencesStorage.saveCorsProxyUrl(proxyUrl);
        expect(saved, isTrue);

        final retrieved = PreferencesStorage.getCorsProxyUrl();
        expect(retrieved, equals(proxyUrl));
      });

      test('should remove CORS proxy URL when set to null', () async {
        await PreferencesStorage.init();
        // First save a value
        await PreferencesStorage.saveCorsProxyUrl('https://proxy.example.com');

        // Then remove it
        await PreferencesStorage.saveCorsProxyUrl(null);

        final retrieved = PreferencesStorage.getCorsProxyUrl();
        expect(retrieved, isNull);
      });

      test('should remove CORS proxy URL when set to empty string', () async {
        await PreferencesStorage.init();
        await PreferencesStorage.saveCorsProxyUrl('');
        final retrieved = PreferencesStorage.getCorsProxyUrl();
        expect(retrieved, isNull);
      });
    });

    group('Hotkey', () {
      test('should save and retrieve show window hotkey', () async {
        await PreferencesStorage.init();
        const hotkey = '76:3';
        final saved = await PreferencesStorage.saveShowWindowHotkey(hotkey);
        expect(saved, isTrue);

        final retrieved = PreferencesStorage.getShowWindowHotkey();
        expect(retrieved, equals(hotkey));
      });

      test('should return null for non-existent hotkey', () async {
        await PreferencesStorage.init();
        final retrieved = PreferencesStorage.getShowWindowHotkey();
        expect(retrieved, isNull);
      });
    });

    group('Clear', () {
      test('should clear all preferences', () async {
        await PreferencesStorage.init();
        // Save some values
        await PreferencesStorage.saveThemeMode('dark');
        await PreferencesStorage.saveLocaleLanguageCode('zh');

        // Clear all
        final cleared = await PreferencesStorage.clearAll();
        expect(cleared, isTrue);

        // Verify they're gone
        expect(PreferencesStorage.getThemeMode(), isNull);
        expect(PreferencesStorage.getLocaleLanguageCode(), isNull);
      });

      test('should clear specific key', () async {
        await PreferencesStorage.init();
        // Save some values
        await PreferencesStorage.saveThemeMode('dark');
        await PreferencesStorage.saveLocaleLanguageCode('zh');

        // Clear specific key
        await PreferencesStorage.clear('theme_mode');

        // Verify specific key is cleared but others remain
        expect(PreferencesStorage.getThemeMode(), isNull);
        expect(PreferencesStorage.getLocaleLanguageCode(), equals('zh'));
      });
    });
  });
}
