import 'package:flutter/material.dart';

/// Locale controller that manages app language settings
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  Locale _locale = const Locale('en');

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

  /// Set locale
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }
    _locale = locale;
    notifyListeners();
  }

  /// Set locale by language code
  void setLocaleByCode(String languageCode) {
    final locale = Locale(languageCode);
    setLocale(locale);
  }
}
