import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:lando/services/audio/pronunciation_service_interface.dart';

/// System TTS pronunciation service.
///
/// Uses the device's built-in text-to-speech engine to pronounce text.
class SystemTtsPronunciationService implements PronunciationServiceInterface {
  SystemTtsPronunciationService() {
    _tts = FlutterTts();
    _init();
  }

  late FlutterTts _tts;
  bool _isInitialized = false;

  Future<void> _init() async {
    await _tts.setLanguage('en-US'); // Default language
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
    }
    _isInitialized = true;
  }

  /// Maps language code to TTS language code.
  ///
  /// Converts standard language codes (e.g., 'en', 'zh', 'ja') to
  /// TTS-compatible language codes (e.g., 'en-US', 'zh-CN', 'ja-JP').
  String _mapLanguageCode(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return 'en-US'; // Default to English
    }

    final code = languageCode.toLowerCase();
    switch (code) {
      case 'en':
      case 'eng':
        return 'en-US';
      case 'zh':
      case 'zh-cn':
        return 'zh-CN';
      case 'ja':
      case 'jp':
        return 'ja-JP';
      case 'ko':
        return 'ko-KR';
      case 'fr':
        return 'fr-FR';
      case 'de':
        return 'de-DE';
      case 'es':
        return 'es-ES';
      case 'it':
        return 'it-IT';
      case 'pt':
        return 'pt-BR';
      case 'ru':
        return 'ru-RU';
      case 'hi':
        return 'hi-IN';
      default:
        // Try to use the language code directly, or fallback to English
        return code.length >= 2 ? '$code-${code.toUpperCase()}' : 'en-US';
    }
  }

  @override
  Future<bool> speak({
    required String text,
    String? languageCode,
    String? url,
  }) async {
    if (text.trim().isEmpty) {
      return false;
    }

    try {
      if (!_isInitialized) {
        await _init();
      }

      // For system TTS, ignore the URL and use text directly
      final ttsLanguage = _mapLanguageCode(languageCode);

      // Check if language is supported before setting it
      final supportedLanguages = await _tts.getLanguages;
      final isLanguageSupported = supportedLanguages.contains(ttsLanguage);

      if (!isLanguageSupported) {
        debugPrint(
          'Language $ttsLanguage is not supported, trying alternatives...',
        );

        // Try to find a close match (e.g., 'zh-CN' -> 'zh-TW' or 'zh')
        final baseCode = ttsLanguage.split('-')[0];
        final alternatives = supportedLanguages
            .where((lang) => lang.startsWith('$baseCode-') || lang == baseCode)
            .toList();

        if (alternatives.isNotEmpty) {
          final fallbackLanguage = alternatives.first;
          debugPrint('Using fallback language: $fallbackLanguage');
          await _tts.setLanguage(fallbackLanguage);
        } else {
          debugPrint('No suitable language found, using default: en-US');
          await _tts.setLanguage('en-US');
        }
      } else {
        await _tts.setLanguage(ttsLanguage);
      }

      await _tts.speak(text);
      return true;
    } catch (e) {
      debugPrint('Error playing system TTS pronunciation: $e');
      // If setting language fails, try with default language
      try {
        await _tts.setLanguage('en-US');
        await _tts.speak(text);
        return true;
      } catch (e2) {
        debugPrint('Error playing with fallback language: $e2');
        return false;
      }
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Error stopping system TTS: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (e) {
      debugPrint('Error pausing system TTS: $e');
    }
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
