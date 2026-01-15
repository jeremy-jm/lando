import 'package:flutter/material.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Locale controller that manages app language settings
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  Locale _locale = const Locale('en');
  bool _initialized = false;

  Locale get locale => _locale;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('zh'), // Chinese
    Locale('ja'), // Japanese
    Locale('hi'), // Hindi
    Locale('id'), // Indonesian
    Locale('pt'), // Portuguese
    Locale('ru'), // Russian
  ];

  /// Initialize locale from storage
  Future<void> init() async {
    if (_initialized) return;

    final savedLanguageCode = PreferencesStorage.getLocaleLanguageCode();
    if (savedLanguageCode != null) {
      final locale = Locale(savedLanguageCode);
      if (supportedLocales.contains(locale)) {
        _locale = locale;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Set locale and save to storage
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }
    _locale = locale;
    await PreferencesStorage.saveLocaleLanguageCode(locale.languageCode);
    notifyListeners();
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }
}
