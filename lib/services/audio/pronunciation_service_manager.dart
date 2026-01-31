import 'package:flutter/foundation.dart';
import 'package:lando/services/audio/pronunciation_service_interface.dart';
import 'package:lando/services/audio/pronunciation_service_type.dart';
import 'package:lando/services/audio/system_tts_pronunciation_service.dart';
import 'package:lando/services/audio/youdao_pronunciation_service.dart';
import 'package:lando/services/audio/baidu_pronunciation_service.dart';
import 'package:lando/services/audio/bing_pronunciation_service.dart';
import 'package:lando/services/audio/google_pronunciation_service.dart';
import 'package:lando/services/audio/apple_pronunciation_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Selects and caches the pronunciation service from user preferences.
class PronunciationServiceManager {
  PronunciationServiceManager._();

  static final PronunciationServiceManager _instance =
      PronunciationServiceManager._();

  /// Singleton instance
  factory PronunciationServiceManager() => _instance;

  PronunciationServiceInterface? _currentService;
  PronunciationServiceType? _currentServiceType;

  /// Returns the current pronunciation service from preferences (cached when unchanged).
  PronunciationServiceInterface getService() {
    final serviceType = _getServiceTypeFromPreferences();

    // Return cached service if type hasn't changed
    if (_currentServiceType == serviceType && _currentService != null) {
      return _currentService!;
    }

    // Dispose old service if exists
    _currentService?.dispose();

    // Create new service based on type
    _currentService = _createService(serviceType);
    _currentServiceType = serviceType;

    return _currentService!;
  }

  /// Gets the service type from preferences, defaulting to system.
  PronunciationServiceType _getServiceTypeFromPreferences() {
    final serviceTypeString =
        PreferencesStorage.getPronunciationServiceType();
    if (serviceTypeString == null || serviceTypeString.isEmpty) {
      return PronunciationServiceType.system; // Default
    }

    try {
      return PronunciationServiceType.values.firstWhere(
        (type) => type.name == serviceTypeString,
        orElse: () => PronunciationServiceType.system,
      );
    } catch (e) {
      debugPrint('Error parsing pronunciation service type: $e');
      return PronunciationServiceType.system;
    }
  }

  PronunciationServiceInterface _createService(PronunciationServiceType type) {
    switch (type) {
      case PronunciationServiceType.system:
        return SystemTtsPronunciationService();
      case PronunciationServiceType.youdao:
        return YoudaoPronunciationService();
      case PronunciationServiceType.baidu:
        return BaiduPronunciationService();
      case PronunciationServiceType.bing:
        return BingPronunciationService();
      case PronunciationServiceType.google:
        return GooglePronunciationService();
      case PronunciationServiceType.apple:
        return ApplePronunciationService();
    }
  }

  /// Plays pronunciation using the current service.
  ///
  /// [text] is the text to pronounce (required for system TTS).
  /// [languageCode] is the language code (e.g., 'en', 'zh', 'ja').
  /// [url] is the audio URL (required for non-system services like Youdao).
  Future<bool> speak({
    required String text,
    String? languageCode,
    String? url,
  }) async {
    final service = getService();
    return await service.speak(
      text: text,
      languageCode: languageCode,
      url: url,
    );
  }

  /// Stops the currently playing pronunciation.
  Future<void> stop() async {
    await _currentService?.stop();
  }

  /// Pauses the currently playing pronunciation.
  Future<void> pause() async {
    await _currentService?.pause();
  }

  /// Disposes all services and releases resources.
  void dispose() {
    _currentService?.dispose();
    _currentService = null;
    _currentServiceType = null;
  }

  /// Forces a reload of the service based on current preferences.
  ///
  /// Call this when the user changes the pronunciation service preference.
  void reloadService() {
    _currentService?.dispose();
    _currentService = null;
    _currentServiceType = null;
  }
}
