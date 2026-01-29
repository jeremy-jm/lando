import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_language_resolver.dart';
import 'package:lando/services/translation/translation_service.dart';

/// Apple Translate service (iOS/macOS only).
///
/// Uses Apple's on-device Translation framework via platform channels.
/// On non-Apple platforms (or unsupported OS versions), returns null so UI hides it.
class AppleTranslateService implements TranslationService {
  static const MethodChannel _channel = MethodChannel('lando/apple_translate');

  @override
  String get name => 'Apple';

  bool get _isApplePlatform => Platform.isIOS || Platform.isMacOS;

  @override
  Future<String> translate(String query) async {
    try {
      final result = await getDetailedResult(query);
      return result?.simpleExplanation ?? '';
    } catch (e, st) {
      debugPrint('[AppleTranslate] translate failed: $e');
      if (kDebugMode) debugPrint('[AppleTranslate] $st');
      return '';
    }
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    try {
      return await _getDetailedResultImpl(query);
    } catch (e, st) {
      debugPrint('[AppleTranslate] getDetailedResult error: $e');
      if (kDebugMode) debugPrint('[AppleTranslate] $st');
      return null;
    }
  }

  Future<ResultModel?> _getDetailedResultImpl(String query) async {
    final text = query.trim();
    debugPrint('[AppleTranslate] getDetailedResult called, query length: ${text.length}');
    if (text.isEmpty) {
      debugPrint('[AppleTranslate] skip: query is empty');
      return null;
    }
    if (!_isApplePlatform) {
      debugPrint('[AppleTranslate] skip: not Apple platform (iOS/macOS)');
      return null;
    }

    final languagePair = await TranslationLanguageResolver.instance.resolveLanguages(text);
    final from = languagePair.fromLanguage != null
        ? TranslationLanguageResolver.instance.mapToAppleFormat(languagePair.fromLanguage)
        : null;
    final to = TranslationLanguageResolver.instance.mapToAppleFormat(languagePair.toLanguage);

    debugPrint(
      '[AppleTranslate] resolved: from=${languagePair.fromLanguage ?? "auto"}->${from ?? "null"}, '
      'to=${languagePair.toLanguage}->$to, '
      'detected=${languagePair.detectedSourceLanguage}, '
      'text preview: "${text.length > 30 ? text.substring(0, 30) : text}..."',
    );

    String? translated;
    try {
      debugPrint('[AppleTranslate] invoking platform channel translate...');
      const timeout = Duration(seconds: 25);
      translated = await _channel.invokeMethod<String>(
        'translate',
        <String, dynamic>{
          'text': text,
          'from': from,
          'to': to,
        },
      ).timeout(
        timeout,
        onTimeout: () {
          debugPrint('[AppleTranslate] native did not respond within ${timeout.inSeconds}s');
          return null;
        },
      );
    } on PlatformException catch (e) {
      debugPrint('[AppleTranslate] PlatformException code=${e.code} message=${e.message}');
      return null;
    } on Exception catch (e, st) {
      debugPrint('[AppleTranslate] Exception: $e');
      if (kDebugMode) debugPrint('[AppleTranslate] $st');
      return null;
    }

    debugPrint('[AppleTranslate] channel returned: translated=${translated != null ? "length ${translated.length}" : "null"}');

    if (translated == null || translated.trim().isEmpty) {
      return null;
    }

    return ResultModel(
      query: text,
      simpleExplanation: translated.trim(),
    );
  }
}

