import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Apple Translate service (iOS/macOS only).
///
/// Uses Apple's on-device Translation framework via platform channels.
/// On non-Apple platforms (or unsupported OS versions), returns null so UI hides it.
class AppleTranslateService implements TranslationService {
  static const MethodChannel _channel = MethodChannel('lando/apple_translate');

  @override
  String get name => 'Apple';

  bool get _isApplePlatform => Platform.isIOS || Platform.isMacOS;

  String _mapLanguageCodeToApple(String? code) {
    if (code == null || code == 'auto') return 'auto';
    final c = code.trim();
    if (c.isEmpty) return 'auto';

    switch (c.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
      case 'zh-hans':
        return 'zh-Hans';
      case 'zh-tw':
      case 'zh-hk':
      case 'zh-hant':
        return 'zh-Hant';
      default:
        return c;
    }
  }

  @override
  Future<String> translate(String query) async {
    final result = await getDetailedResult(query);
    return result?.simpleExplanation ?? '';
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
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

    final rawFrom = PreferencesStorage.getTranslationFromLanguage();
    final rawTo = PreferencesStorage.getTranslationToLanguage() ?? 'en';
    final from = _mapLanguageCodeToApple(rawFrom);
    final to = _mapLanguageCodeToApple(rawTo);
    debugPrint(
      '[AppleTranslate] from=$rawFrom->${from == "auto" ? "auto" : from}, '
      'to=$rawTo->$to, '
      'text preview: "${text.length > 30 ? text.substring(0, 30) : text}..."',
    );

    try {
      debugPrint('[AppleTranslate] invoking platform channel translate...');
      final translated = await _channel.invokeMethod<String>(
        'translate',
        <String, dynamic>{
          'text': text,
          // null means auto-detect on native side
          'from': (from == 'auto') ? null : from,
          'to': to,
        },
      );
      debugPrint('[AppleTranslate] channel returned: translated=${translated != null ? "length ${translated.length}" : "null"}');

      if (translated == null || translated.trim().isEmpty) {
        debugPrint('[AppleTranslate] result empty or null, returning null');
        return null;
      }

      debugPrint('[AppleTranslate] success, returning ResultModel');
      return ResultModel(
        query: text,
        simpleExplanation: translated.trim(),
      );
    } on PlatformException catch (e) {
      debugPrint('[AppleTranslate] PlatformException code=${e.code} message=${e.message} details=${e.details}');
      return null;
    } catch (e, st) {
      debugPrint('[AppleTranslate] catch: $e');
      debugPrint('[AppleTranslate] stack: $st');
      return null;
    }
  }
}

