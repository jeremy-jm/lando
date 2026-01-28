import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Service for resolving translation language pairs with automatic detection.
///
/// Handles:
/// - Automatic language detection from input text
/// - Auto mode: selects target language based on system locale
/// - Language code normalization for different translation services
class TranslationLanguageResolver {
  TranslationLanguageResolver._();
  static final TranslationLanguageResolver instance = TranslationLanguageResolver._();

  /// Resolves the translation language pair for a given query text.
  ///
  /// Returns a [TranslationLanguagePair] with:
  /// - [fromLanguage]: Detected source language or user preference
  /// - [toLanguage]: Target language (never null, auto-resolved if needed)
  /// - [detectedSourceLanguage]: The detected language code from input text
  ///
  /// The [toLanguage] will always be resolved to a concrete language code,
  /// never null or 'auto', to ensure compatibility with all translation services.
  Future<TranslationLanguagePair> resolveLanguages(String query) async {
    final text = query.trim();
    if (text.isEmpty) {
      // Return default pair for empty text
      final defaultTo = await _getDefaultTargetLanguage();
      return TranslationLanguagePair(
        fromLanguage: null,
        toLanguage: defaultTo,
        detectedSourceLanguage: null,
      );
    }

    // 1. Detect source language from input text
    final detectedSource = _detectLanguageFromText(text);
    debugPrint('[TranslationLanguageResolver] Detected source language: $detectedSource');

    // 2. Get user preferences
    final userFrom = PreferencesStorage.getTranslationFromLanguage();
    final userTo = PreferencesStorage.getTranslationToLanguage();

    // 3. Determine source language (prefer user preference, fallback to detected)
    final fromLanguage = userFrom != null && userFrom != 'auto' ? userFrom : detectedSource;

    // 4. Resolve target language (auto mode -> system locale based)
    String toLanguage;
    if (userTo == null || userTo == 'auto') {
      // Auto mode: use system locale to determine target
      // Use the final fromLanguage (not detectedSource) to determine target
      // This ensures that if user manually sets from=en, we use that instead of detected
      toLanguage = await _resolveAutoTargetLanguage(fromLanguage);
      debugPrint('[TranslationLanguageResolver] Auto mode: resolved target=$toLanguage (system locale based, from=$fromLanguage)');
    } else {
      toLanguage = userTo;
    }
    
    // 5. Ensure from and to are different (prevent same-language translation)
    if (fromLanguage != null && fromLanguage == toLanguage) {
      // If from and to are the same, change to to system language or English
      final systemLanguage = _getSystemLanguageCode();
      if (fromLanguage == systemLanguage) {
        // If source is system language, translate to English
        toLanguage = 'en';
        debugPrint('[TranslationLanguageResolver] from==to==system, changed to=en');
      } else {
        // Otherwise, translate to system language
        toLanguage = systemLanguage;
        debugPrint('[TranslationLanguageResolver] from==to, changed to=system($systemLanguage)');
      }
    }

    // 6. Ensure target language is never null (required by Apple Service)
    if (toLanguage.isEmpty) {
      toLanguage = await _getDefaultTargetLanguage();
      debugPrint('[TranslationLanguageResolver] Target was empty, using default: $toLanguage');
    }

    return TranslationLanguagePair(
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
      detectedSourceLanguage: detectedSource,
    );
  }

  /// Detects language code from input text using heuristics.
  ///
  /// Returns language code (e.g., 'zh', 'en', 'ja', 'hi') or null if detection fails.
  String? _detectLanguageFromText(String text) {
    if (text.trim().isEmpty) return null;

    // Chinese (Simplified and Traditional)
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
      return 'zh';
    }

    // Japanese (Hiragana and Katakana)
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
      return 'ja';
    }

    // Hindi (Devanagari)
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) {
      return 'hi';
    }

    // Indonesian/Malay (Latin script, but can be detected by common words)
    // For now, treat as potential Indonesian if contains common Indonesian words
    // This is a simple heuristic and can be improved

    // Portuguese (Latin script, similar to Spanish)
    // Detection would require more sophisticated analysis

    // Russian (Cyrillic)
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(text)) {
      return 'ru';
    }

    // Default: English for Latin scripts
    // Match text that contains primarily Latin characters with common punctuation
    if (RegExp(r'^[a-zA-Z\s.,!?;:\-]+$').hasMatch(text)) {
      return 'en';
    }

    // Fallback: assume English for mixed content
    return 'en';
  }

  /// Resolves target language when user selects "auto" mode.
  ///
  /// [sourceLanguage] is the final source language (user preference or detected).
  ///
  /// Logic for auto mode:
  /// - If source is English -> translate to Chinese
  /// - If source is Chinese -> translate to English
  /// - Otherwise -> translate to system language (or English if same as source)
  ///
  /// Examples:
  /// - Source: English -> translate to Chinese
  /// - Source: Chinese -> translate to English
  /// - Source: Japanese -> translate to system language (or English)
  Future<String> _resolveAutoTargetLanguage(String? sourceLanguage) async {
    final systemLanguage = _getSystemLanguageCode();
    debugPrint('[TranslationLanguageResolver] System language: $systemLanguage, Source language: $sourceLanguage');

    if (sourceLanguage == null) {
      // If source is unknown, use system language
      return systemLanguage;
    }

    // Auto mode: English <-> Chinese bidirectional translation
    if (sourceLanguage == 'en') {
      // Input is English -> translate to Chinese
      return 'zh';
    } else if (sourceLanguage == 'zh') {
      // Input is Chinese -> translate to English
      return 'en';
    }

    // For other languages, translate to system language
    // But if source is same as system language, translate to English instead
    if (sourceLanguage == systemLanguage) {
      return 'en';
    }

    return systemLanguage;
  }

  /// Gets the system language code based on device locale.
  ///
  /// Returns a normalized language code (e.g., 'zh', 'en', 'ja').
  /// 
  /// Priority: Country code > Language code
  /// If country code indicates China (CN), return 'zh' even if language is 'en'
  String _getSystemLanguageCode() {
    try {
      // Get locale from Platform.localeName (available in Dart 2.17+)
      // Format: "language_COUNTRY" (e.g., "zh_CN", "en_US", "en_CN")
      final locale = Platform.localeName;
      debugPrint('[TranslationLanguageResolver] Platform locale: $locale');

      // Extract language code and country code
      final parts = locale.split('_');
      final langCode = parts[0].toLowerCase();
      final countryCode = parts.length > 1 ? parts[1].toUpperCase() : '';

      // Priority 1: Check country code for China (CN, HK, TW, MO)
      // If country is China-related, return 'zh' regardless of language code
      if (countryCode == 'CN' || countryCode == 'HK' || countryCode == 'TW' || countryCode == 'MO') {
        debugPrint('[TranslationLanguageResolver] Country code indicates China ($countryCode), returning zh');
        return 'zh';
      }

      // Priority 2: Normalize language code
      switch (langCode) {
        case 'zh':
        case 'zh-cn':
        case 'zh-hans':
          return 'zh';
        case 'zh-tw':
        case 'zh-hk':
        case 'zh-hant':
          return 'zh'; // Use 'zh' as base, services will handle script
        case 'en':
          return 'en';
        case 'ja':
        case 'jp':
          return 'ja';
        case 'hi':
          return 'hi';
        case 'id':
          return 'id';
        case 'pt':
          return 'pt';
        case 'ru':
          return 'ru';
        default:
          // Default to English for unknown languages
          return 'en';
      }
    } catch (e) {
      debugPrint('[TranslationLanguageResolver] Error getting system language: $e');
      return 'en'; // Fallback to English
    }
  }

  /// Gets default target language (fallback when auto resolution fails).
  Future<String> _getDefaultTargetLanguage() async {
    return _getSystemLanguageCode();
  }

  /// Maps language code to Bing translation service format.
  String mapToBingFormat(String? code) {
    if (code == null || code == 'auto') {
      return 'auto-detect';
    }

    switch (code.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
        return 'zh-Hans';
      case 'zh-tw':
      case 'zh-hk':
      case 'zh-hant':
        return 'zh-Hant';
      case 'en':
        return 'en';
      case 'ja':
        return 'ja';
      case 'hi':
        return 'hi';
      case 'id':
        return 'id';
      case 'pt':
        return 'pt';
      case 'ru':
        return 'ru';
      default:
        return code;
    }
  }

  /// Maps language code to Youdao translation service format.
  String mapToYoudaoFormat(String? code) {
    if (code == null || code == 'auto') {
      return 'auto';
    }

    switch (code.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
      case 'zh-hans':
        return 'zh-CHS';
      case 'zh-tw':
      case 'zh-hk':
      case 'zh-hant':
        return 'zh-CHT';
      case 'en':
        return 'en';
      case 'ja':
        return 'ja';
      case 'hi':
        return 'hi';
      case 'id':
        return 'id';
      case 'pt':
        return 'pt';
      case 'ru':
        return 'ru';
      default:
        return code;
    }
  }

  /// Maps language code to Apple translation service format.
  String mapToAppleFormat(String? code) {
    if (code == null || code == 'auto') {
      return 'auto';
    }

    switch (code.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
      case 'zh-hans':
        return 'zh-Hans';
      case 'zh-tw':
      case 'zh-hk':
      case 'zh-hant':
        return 'zh-Hant';
      default:
        return code;
    }
  }

  /// Maps language code to Google translation service format.
  String mapToGoogleFormat(String? code) {
    if (code == null || code == 'auto') {
      return 'auto';
    }

    // Google uses standard language codes
    switch (code.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
        return 'zh-CN';
      case 'zh-tw':
      case 'zh-hk':
        return 'zh-TW';
      default:
        return code;
    }
  }
}

/// Result of language resolution.
class TranslationLanguagePair {
  TranslationLanguagePair({
    required this.fromLanguage,
    required this.toLanguage,
    required this.detectedSourceLanguage,
  });

  /// Source language code (can be null for auto-detect).
  final String? fromLanguage;

  /// Target language code (never null, always resolved).
  final String toLanguage;

  /// Detected source language from input text.
  final String? detectedSourceLanguage;
}
