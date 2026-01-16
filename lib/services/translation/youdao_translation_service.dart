import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/youdao/models/youdao_query_model.dart';
import 'package:lando/services/translation/youdao/models/youdao_response.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Youdao translation service implementation.
class YoudaoTranslationService implements TranslationService {
  YoudaoTranslationService(this._apiClient);

  final ApiClient _apiClient;

  @override
  String get name => 'Youdao';

  @override
  Future<String> translate(String query) async {
    if (query.trim().isEmpty) {
      return '';
    }

    // Get target language from preferences, default to 'auto' if not set
    final toLanguage = PreferencesStorage.getTranslationToLanguage() ?? 'auto';
    final le = _mapLanguageCodeToYoudao(toLanguage);

    final queryModel = _buildQueryModel(query: query, le: le);
    final response = await translateFullWithModel(queryModel);

    // Extract translation from EC (basic dictionary) - most common case
    final ecWord = response.ec?.word;
    if (ecWord != null) {
      final translations = <String>[];

      // Get translations from trs
      for (final tr in ecWord.trs ?? []) {
        if (tr.tran != null && tr.tran!.isNotEmpty) {
          final pos = tr.pos != null ? '${tr.pos} ' : '';
          translations.add('$pos${tr.tran}');
        }
      }

      if (translations.isNotEmpty) {
        return translations.join('; ');
      }
    }

    // Fallback: try web_trans
    final webTrans = response.webTrans?.webTranslation;
    if (webTrans != null && webTrans.isNotEmpty) {
      final firstTrans = webTrans.first;
      if (firstTrans.trans != null && firstTrans.trans!.isNotEmpty) {
        return firstTrans.trans!.map((t) => t.value ?? '').join('; ');
      }
    }

    // Fallback: try EE (extended dictionary)
    final eeWord = response.ee?.word;
    if (eeWord != null && eeWord.trs != null && eeWord.trs!.isNotEmpty) {
      final translations = <String>[];
      for (final tr in eeWord.trs!) {
        if (tr.tr != null) {
          for (final trItem in tr.tr!) {
            if (trItem.tran != null && trItem.tran!.isNotEmpty) {
              final pos = tr.pos != null ? '${tr.pos} ' : '';
              translations.add('$pos${trItem.tran}');
            }
          }
        }
      }
      if (translations.isNotEmpty) {
        return translations.join('; ');
      }
    }

    // Last fallback: return query word if no translation found
    return query;
  }

  /// Get the full YoudaoResponse object for advanced usage.
  Future<YoudaoResponse> translateFull(String query) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    // Get target language from preferences, default to 'auto' if not set
    final toLanguage = PreferencesStorage.getTranslationToLanguage() ?? 'auto';
    final le = _mapLanguageCodeToYoudao(toLanguage);

    final queryModel = _buildQueryModel(query: query, le: le);
    return await translateFullWithModel(queryModel);
  }

  /// Get the full YoudaoResponse object using YoudaoQueryModel.
  Future<YoudaoResponse> translateFullWithModel(
    YoudaoQueryModel queryModel,
  ) async {
    const endpoint =
        'https://dict.youdao.com/jsonapi_s?doctype=json&jsonversion=4';

    final body = queryModel.toMap();
    final json = await _apiClient.postForm(endpoint, body: body);
    return YoudaoResponse.fromJson(json);
  }

  /// Builds a YoudaoQueryModel with optional sign and timestamp.
  ///
  /// [le] is the target language code selected by the user (e.g., 'ja', 'zh', 'en').
  /// The language code comes from PreferencesStorage.getTranslationToLanguage().
  /// All values will be URL-encoded by ApiClient.postForm() when sending the request.
  YoudaoQueryModel _buildQueryModel({
    required String query,
    required String le,
    String? sign,
    String? t,
  }) {
    // Generate timestamp if not provided
    final timestamp = t ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Generate sign if not provided
    // Note: The actual sign algorithm may vary. This is a placeholder.
    // You may need to implement the actual sign generation based on Youdao's requirements.
    final generatedSign = sign ?? _generateSign(query, le, timestamp);

    return YoudaoQueryModel(
      q: query, // Query text
      le: le, // Target language code (e.g., 'ja' for Japanese, 'zh' for Chinese)
      t: timestamp,
      client: 'web',
      sign: generatedSign,
      keyfrom: 'webdict',
    );
  }

  /// Generates a sign for the request.
  /// Note: This is a placeholder implementation. You may need to adjust
  /// based on Youdao's actual sign generation algorithm.
  String _generateSign(String query, String le, String t) {
    // Simple MD5 hash as placeholder
    // In production, you should use the actual sign algorithm provided by Youdao
    final content = '$query$le$t';
    final bytes = utf8.encode(content);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Maps language code to Youdao's language code format.
  /// le parameter should be the language code directly (e.g., 'ja', 'zh', 'eng' for English)
  String _mapLanguageCodeToYoudao(String? languageCode) {
    if (languageCode == null || languageCode == 'auto') {
      return 'auto'; // Auto-detect
    }

    final code = languageCode.toLowerCase();

    // Map 'en' to 'eng' for Youdao API
    if (code == 'en') {
      return 'eng';
    }

    // Use language code directly as le parameter
    // Youdao API accepts standard language codes like 'ja', 'zh', 'eng', etc.
    return code;
  }

  /// Builds pronunciation URL from speech parameter.
  ///
  /// [speechParam] format: "word&type=1" (for UK) or "word&type=2" (for US)
  /// [languageCode] is the target language code (e.g., 'ja', 'zh', 'en')
  /// Returns the full URL for pronunciation audio.
  String? buildPronunciationUrl(
    String? speechParam, {
    String? word,
    String? languageCode,
  }) {
    // Get language code from preferences if not provided
    final le =
        languageCode ??
        _mapLanguageCodeToYoudao(PreferencesStorage.getTranslationToLanguage());

    if (speechParam == null || speechParam.isEmpty) {
      // Fallback: build URL from word if speechParam is not available
      if (word != null && word.isNotEmpty) {
        return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(word)}&le=$le';
      }
      return null;
    }

    // Parse speechParam (format: "word&type=1" or "word&type=2")
    final parts = speechParam.split('&');
    final audioWord = parts.isNotEmpty ? parts[0] : (word ?? '');

    if (audioWord.isEmpty) {
      return null;
    }

    // Extract type from speechParam or use default
    String? type;
    for (final part in parts) {
      if (part.startsWith('type=')) {
        type = part.substring(5);
        break;
      }
    }

    if (type != null) {
      return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(audioWord)}&le=$le&type=$type';
    } else {
      return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(audioWord)}&le=$le';
    }
  }

  /// Gets pronunciation URLs from YoudaoResponse.
  ///
  /// Returns a map with 'us', 'uk', and 'general' keys containing pronunciation URLs.
  /// 'general' is for non-English languages or when US/UK are not available.
  Map<String, String?> getPronunciationUrls(
    YoudaoResponse response,
    String query,
  ) {
    String? usUrl;
    String? ukUrl;
    String? generalUrl;

    // Get target language code
    final languageCode = _mapLanguageCodeToYoudao(
      PreferencesStorage.getTranslationToLanguage(),
    );

    // Try to get from EC (basic dictionary)
    final ecWord = response.ec?.word;
    if (ecWord != null) {
      if (ecWord.usspeech != null) {
        usUrl = buildPronunciationUrl(
          ecWord.usspeech,
          word: query,
          languageCode: languageCode,
        );
      }
      if (ecWord.ukspeech != null) {
        ukUrl = buildPronunciationUrl(
          ecWord.ukspeech,
          word: query,
          languageCode: languageCode,
        );
      }
    }

    // Fallback: try Simple
    if (response.simple != null) {
      final simpleWord = response.simple!.word?.firstOrNull;
      if (simpleWord != null) {
        if (usUrl == null && simpleWord.usspeech != null) {
          usUrl = buildPronunciationUrl(
            simpleWord.usspeech,
            word: query,
            languageCode: languageCode,
          );
        }
        if (ukUrl == null && simpleWord.ukspeech != null) {
          ukUrl = buildPronunciationUrl(
            simpleWord.ukspeech,
            word: query,
            languageCode: languageCode,
          );
        }
      }
    }

    // Try EE (extended dictionary) for other languages
    final eeWord = response.ee?.word;
    if (eeWord?.speech != null && eeWord!.speech!.isNotEmpty) {
      generalUrl = buildPronunciationUrl(
        eeWord.speech,
        word: query,
        languageCode: languageCode,
      );
    }

    // Try Web Translation for other languages
    final webTrans = response.webTrans;
    if (webTrans?.webTranslation != null) {
      for (final webItem in webTrans!.webTranslation!) {
        if (webItem.keySpeech != null && webItem.keySpeech!.isNotEmpty) {
          generalUrl ??= buildPronunciationUrl(
            webItem.keySpeech,
            word: query,
            languageCode: languageCode,
          );
          break;
        }
      }
    }

    // Last fallback: build URL from query word with appropriate language code
    if (generalUrl == null && (usUrl == null || ukUrl == null)) {
      generalUrl = buildPronunciationUrl(
        null,
        word: query,
        languageCode: languageCode,
      );
    }

    // For non-English languages, prefer general URL
    if (languageCode != 'eng' && languageCode != 'auto') {
      generalUrl ??= buildPronunciationUrl(
        null,
        word: query,
        languageCode: languageCode,
      );
    }

    return {'us': usUrl, 'uk': ukUrl, 'general': generalUrl};
  }

  /// Gets pronunciation URL for the input query text.
  ///
  /// Builds pronunciation URL directly using the format:
  /// https://dict.youdao.com/dictvoice?audio={encodedText}&le={language}&type={accentType}
  ///
  /// For English: type=1 (UK), type=2 (US)
  /// For other languages: no type parameter
  ///
  /// Returns US pronunciation URL by default for English, or general pronunciation for other languages.
  String? getInputPronunciationUrl(YoudaoResponse response, String query) {
    if (query.trim().isEmpty) {
      return null;
    }

    // Get target language code from preferences
    final languageCode = _mapLanguageCodeToYoudao(
      PreferencesStorage.getTranslationToLanguage(),
    );

    final encodedText = Uri.encodeComponent(query);

    // For English, use US pronunciation (type=2) by default
    if (languageCode == 'eng') {
      return 'https://dict.youdao.com/dictvoice?audio=$encodedText&le=$languageCode&type=2';
    }

    // For other languages, build URL without type parameter
    return 'https://dict.youdao.com/dictvoice?audio=$encodedText&le=$languageCode';
  }
}
