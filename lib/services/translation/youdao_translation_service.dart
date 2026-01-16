import 'package:lando/network/api_client.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/youdao/models/youdao_response.dart';

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

    const endpoint =
        'https://dict.youdao.com/jsonapi_s?doctype=json&jsonversion=4';

    // These fields are based on the provided curl example.
    final body = <String, String>{
      'client': 'web',
      'keyfrom': 'webdict',
      'le': 'en',
      'q': query,
      // In the example, sign and t are provided. In a real application
      // you might need to compute sign. Here we send minimal parameters
      // to get a reasonable response.
    };

    final json = await _apiClient.postForm(endpoint, body: body);

    // Parse JSON into YoudaoResponse model
    final response = YoudaoResponse.fromJson(json);

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

    const endpoint =
        'https://dict.youdao.com/jsonapi_s?doctype=json&jsonversion=4';

    final body = <String, String>{
      'client': 'web',
      'keyfrom': 'webdict',
      'le': 'en',
      'q': query,
    };

    final json = await _apiClient.postForm(endpoint, body: body);
    return YoudaoResponse.fromJson(json);
  }

  /// Builds pronunciation URL from speech parameter.
  ///
  /// [speechParam] format: "word&type=1" (for UK) or "word&type=2" (for US)
  /// Returns the full URL for pronunciation audio.
  String? buildPronunciationUrl(String? speechParam, {String? word}) {
    if (speechParam == null || speechParam.isEmpty) {
      // Fallback: build URL from word if speechParam is not available
      if (word != null && word.isNotEmpty) {
        return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(word)}&le=eng';
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
      return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(audioWord)}&le=eng&type=$type';
    } else {
      return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(audioWord)}&le=eng';
    }
  }

  /// Gets pronunciation URLs from YoudaoResponse.
  ///
  /// Returns a map with 'us' and 'uk' keys containing pronunciation URLs.
  Map<String, String?> getPronunciationUrls(
    YoudaoResponse response,
    String query,
  ) {
    String? usUrl;
    String? ukUrl;

    // Try to get from EC (basic dictionary)
    final ecWord = response.ec?.word;
    if (ecWord != null) {
      if (ecWord.usspeech != null) {
        usUrl = buildPronunciationUrl(ecWord.usspeech, word: query);
      }
      if (ecWord.ukspeech != null) {
        ukUrl = buildPronunciationUrl(ecWord.ukspeech, word: query);
      }
    }

    // Fallback: try Simple
    if ((usUrl == null || ukUrl == null) && response.simple != null) {
      final simpleWord = response.simple!.word?.firstOrNull;
      if (simpleWord != null) {
        if (usUrl == null && simpleWord.usspeech != null) {
          usUrl = buildPronunciationUrl(simpleWord.usspeech, word: query);
        }
        if (ukUrl == null && simpleWord.ukspeech != null) {
          ukUrl = buildPronunciationUrl(simpleWord.ukspeech, word: query);
        }
      }
    }

    // Last fallback: build URLs from query word
    if (usUrl == null) {
      usUrl = buildPronunciationUrl(null, word: query);
    }
    if (ukUrl == null) {
      ukUrl = buildPronunciationUrl(null, word: query);
    }

    return {'us': usUrl, 'uk': ukUrl};
  }
}
