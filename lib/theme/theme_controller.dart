import 'package:flutter/material.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Simple theme controller that centrally manages ThemeMode
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.system;
  bool _initialized = false;

  ThemeMode get mode => _mode;

  /// Initialize theme mode from storage
  Future<void> init() async {
    if (_initialized) return;

    final savedMode = PreferencesStorage.getThemeMode();
    if (savedMode != null) {
      _mode = _parseThemeMode(savedMode);
    }
    _initialized = true;
    notifyListeners();
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// Convert theme mode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Set theme mode and save to storage
  Future<void> setMode(ThemeMode newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    await PreferencesStorage.saveThemeMode(_themeModeToString(newMode));
    notifyListeners();
  }
}
