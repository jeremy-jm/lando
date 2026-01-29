import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/youdao/models/youdao_other_models.dart';
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

    try {
      final queryModel = _buildQueryModel(query: query);
      final response = await translateFullWithModel(queryModel);

      // Priority 0: Extract translation from Fanyi - highest priority
      if (response.fanyi != null &&
          response.fanyi!.tran != null &&
          response.fanyi!.tran!.isNotEmpty) {
        return response.fanyi!.tran!;
      }

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
    } on SocketException catch (e) {
      // Handle network connection errors
      throw Exception(
        'Network connection failed. Please check your internet connection and try again. Error: ${e.message}',
      );
    } on HttpException catch (e) {
      // Handle HTTP errors
      throw Exception('Translation request failed: ${e.message}');
    } catch (e) {
      // Handle any other errors
      throw Exception('Translation failed: $e');
    }
  }

  /// Get the full YoudaoResponse object for advanced usage.
  Future<YoudaoResponse> translateFull(String query) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    try {
      final queryModel = _buildQueryModel(query: query);
      return await translateFullWithModel(queryModel);
    } on SocketException catch (e) {
      // Handle network connection errors
      throw Exception(
        'Network connection failed. Please check your internet connection and try again. Error: ${e.message}',
      );
    } on HttpException catch (e) {
      // Handle HTTP errors
      throw Exception('Translation request failed: ${e.message}');
    } catch (e) {
      // Re-throw if it's already an ArgumentError
      if (e is ArgumentError) {
        rethrow;
      }
      // Handle any other errors
      throw Exception('Translation failed: $e');
    }
  }

  /// Get the full YoudaoResponse object using YoudaoQueryModel.
  Future<YoudaoResponse> translateFullWithModel(
    YoudaoQueryModel queryModel,
  ) async {
    const endpoint =
        'https://dict.youdao.com/jsonapi_s?doctype=json&jsonversion=4';

    final body = queryModel.toMap();

    // Headers for dict API (dict.youdao.com) - use dict origin/referer
    final headers = <String, String>{
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Connection': 'keep-alive',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origin': 'https://dict.youdao.com',
      'Referer': 'https://dict.youdao.com/',
      'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',
      'sec-ch-ua':
          '"Not(A:Brand";v="8", "Chromium";v="144", "Google Chrome";v="144"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"macOS"',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-site',
    };

    final json =
        await _apiClient.postForm(endpoint, body: body, headers: headers);
    return YoudaoResponse.fromJson(json);
  }

  /// Builds a YoudaoQueryModel with sign and timestamp.
  ///
  /// [le] is the target language code selected by the user (e.g., 'ja', 'zh', 'en').
  /// The language code comes from PreferencesStorage.getTranslationToLanguage().
  /// All values will be URL-encoded by ApiClient.postForm() when sending the request.
  ///
  /// Sign algorithm for dict API (dict.youdao.com/jsonapi_s) - webdict client:
  /// 1. ww = query + "webdict"
  /// 2. time = (ww.length % 10).toString()
  /// 3. salt = md5(ww)
  /// 4. key = "Mk6hqtUp33DGGtoS63tTJbMUYjRrG1Lu"
  /// 5. sign = md5("web" + query + time + key + salt)
  ///
  /// Do not use client=webmain/webfanyi for this endpoint; the dict API expects
  /// client=web, keyfrom=webdict and returns ec/ce in the response.
  YoudaoQueryModel _buildQueryModel({required String query}) {
    final ww = '${query}webdict';
    final time = (ww.length % 10).toString();

    final wwBytes = utf8.encode(ww);
    final salt = md5.convert(wwBytes).toString();

    const key = 'Mk6hqtUp33DGGtoS63tTJbMUYjRrG1Lu';
    final signContent = 'web$query$time$key$salt';
    final signBytes = utf8.encode(signContent);
    final sign = md5.convert(signBytes).toString();

    return YoudaoQueryModel(
      q: query,
      t: time,
      client: 'web',
      sign: sign,
      keyfrom: 'webdict',
    );
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
    final le = languageCode ??
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

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    if (query.trim().isEmpty) {
      return null;
    }

    try {
      final response = await translateFull(query);
      return _convertToResultModel(response, query);
    } catch (e) {
      // Return null on error, let the widget handle error display
      return null;
    }
  }

  /// Converts YoudaoResponse to ResultModel.
  ResultModel _convertToResultModel(YoudaoResponse response, String query) {
    // Get target language to determine which data source to prioritize
    final targetLanguage = PreferencesStorage.getTranslationToLanguage();
    final targetLanguageCode = _mapLanguageCodeToYoudao(targetLanguage);
    final isTargetChinese =
        targetLanguageCode == 'zh' || targetLanguageCode == 'zh-CHS';
    final isTargetEnglish =
        targetLanguageCode == 'eng' || targetLanguageCode == 'en';

    // Determine input language
    final guessLanguage = response.meta?.guessLanguage;
    final lang = response.meta?.lang;
    final isChineseInput =
        guessLanguage == 'zh' || lang == 'zh' || lang == 'zh-CHS';

    final ecWord = response.ec?.word;
    final ceWord = response.ce?.word;
    final eeWord = response.ee?.word; // Extended dictionary
    final phrs = response.phrs;
    final webTrans = response.webTrans;
    // Get word forms from multiple sources
    // Priority: ec.word.wfs > individual.anagram.wfs > expandEc.word.wfs
    final ecWordForms = response.ec?.word?.wfs;
    final individualAnagramForms = response.individual?.anagram?.wfs;
    // Check expandEc for word forms (expandEc.word is a list, each item may have wfs)
    List<YoudaoWf>? expandEcWordForms;
    final expandEcWord = response.expandEc?.word;
    if (expandEcWord != null && expandEcWord.isNotEmpty) {
      final tempList = <YoudaoWf>[];
      for (final word in expandEcWord) {
        final wfs = word.wfs;
        if (wfs != null && wfs.isNotEmpty) {
          tempList.addAll(wfs);
        }
      }
      if (tempList.isNotEmpty) {
        expandEcWordForms = tempList;
      }
    }
    final wordForms =
        ecWordForms ?? individualAnagramForms ?? expandEcWordForms;

    // Get simple explanation (main translation)
    // Priority: ceWord (Chinese) > ecWord (English) > eeWord (Extended) > fanyi
    String? simpleExplanation;
    if (isChineseInput && ceWord != null && ceWord.trs?.isNotEmpty == true) {
      simpleExplanation = ceWord.trs!.first.text;
    } else if (ecWord != null && ecWord.trs?.isNotEmpty == true) {
      // For English input or when language detection is uncertain, use ecWord
      simpleExplanation = ecWord.trs!.first.tran;
    } else if (eeWord != null && eeWord.trs != null && eeWord.trs!.isNotEmpty) {
      // Fallback to extended dictionary
      final firstTr = eeWord.trs!.first;
      if (firstTr.tr != null && firstTr.tr!.isNotEmpty) {
        simpleExplanation = firstTr.tr!.first.tran;
      }
    } else if (response.fanyi?.tran != null &&
        response.fanyi!.tran!.isNotEmpty) {
      simpleExplanation = response.fanyi!.tran;
    }

    // Get translations by part of speech
    // Priority based on target language:
    // - If target is Chinese: prioritize ec.word.trs
    // - If target is English: prioritize ee.word.trs
    List<Map<String, String>>? translationsByPosList;

    if (isTargetChinese) {
      // Target is Chinese: prioritize ec.word.trs (Chinese translations)
      // Do NOT fallback to ee.word.trs (English translations) when target is Chinese
      if (ecWord != null && ecWord.trs != null && ecWord.trs!.isNotEmpty) {
        translationsByPosList = ecWord.trs!
            .where((tr) => tr.tran != null && tr.tran!.isNotEmpty)
            .map((tr) => {'name': tr.pos ?? '', 'value': tr.tran!})
            .toList();
      } else if (response.expandEc?.word != null &&
          response.expandEc!.word!.isNotEmpty) {
        // Try expandEc.word.transList (may contain Chinese translations)
        translationsByPosList = <Map<String, String>>[];
        for (final word in response.expandEc!.word!) {
          if (word.transList != null && word.transList!.isNotEmpty) {
            for (final transItem in word.transList!) {
              if (transItem.trans != null && transItem.trans!.isNotEmpty) {
                translationsByPosList.add({
                  'name': word.pos ?? '',
                  'value': transItem.trans!,
                });
              }
            }
          }
        }
      }
    } else if (isTargetEnglish) {
      // Target is English: prioritize ee.word.trs
      if (eeWord != null && eeWord.trs != null && eeWord.trs!.isNotEmpty) {
        translationsByPosList = <Map<String, String>>[];
        for (final tr in eeWord.trs!) {
          if (tr.tr != null && tr.tr!.isNotEmpty) {
            for (final trItem in tr.tr!) {
              if (trItem.tran != null && trItem.tran!.isNotEmpty) {
                translationsByPosList.add({
                  'name': tr.pos ?? '',
                  'value': trItem.tran!,
                });
              }
            }
          }
        }
      } else if (ecWord != null &&
          ecWord.trs != null &&
          ecWord.trs!.isNotEmpty) {
        // Fallback to basic dictionary
        translationsByPosList = ecWord.trs!
            .where((tr) => tr.tran != null && tr.tran!.isNotEmpty)
            .map((tr) => {'name': tr.pos ?? '', 'value': tr.tran!})
            .toList();
      }
    } else {
      // Other target languages: use default priority (ecWord > eeWord)
      if (ecWord != null && ecWord.trs != null && ecWord.trs!.isNotEmpty) {
        translationsByPosList = ecWord.trs!
            .where((tr) => tr.tran != null && tr.tran!.isNotEmpty)
            .map((tr) => {'name': tr.pos ?? '', 'value': tr.tran!})
            .toList();
      } else if (eeWord != null &&
          eeWord.trs != null &&
          eeWord.trs!.isNotEmpty) {
        // Fallback to extended dictionary
        translationsByPosList = <Map<String, String>>[];
        for (final tr in eeWord.trs!) {
          if (tr.tr != null && tr.tr!.isNotEmpty) {
            for (final trItem in tr.tr!) {
              if (trItem.tran != null && trItem.tran!.isNotEmpty) {
                translationsByPosList.add({
                  'name': tr.pos ?? '',
                  'value': trItem.tran!,
                });
              }
            }
          }
        }
      }
    }

    // Get pronunciation URLs and phonetics
    // Priority: ecWord > eeWord > simple
    String? usPronunciationUrl;
    String? ukPronunciationUrl;
    String? usPhonetic;
    String? ukPhonetic;
    if (ecWord != null) {
      if (ecWord.usspeech != null) {
        usPronunciationUrl = buildPronunciationUrl(
          ecWord.usspeech,
          word: query,
        );
      }
      if (ecWord.ukspeech != null) {
        ukPronunciationUrl = buildPronunciationUrl(
          ecWord.ukspeech,
          word: query,
        );
      }
      // Get phonetics
      usPhonetic = ecWord.usphone;
      ukPhonetic = ecWord.ukphone;
    } else if (eeWord != null) {
      // Fallback to extended dictionary
      if (eeWord.speech != null) {
        // EE only has general speech, not US/UK specific
        usPronunciationUrl = buildPronunciationUrl(
          eeWord.speech,
          word: query,
        );
        ukPronunciationUrl = usPronunciationUrl; // Use same for both
      }
      usPhonetic = eeWord.phone;
      ukPhonetic = eeWord.phone; // Use same for both
    }

    // Try simple dictionary as last fallback
    if (usPronunciationUrl == null && response.simple != null) {
      final simpleWord = response.simple!.word?.firstOrNull;
      if (simpleWord?.usspeech != null) {
        usPronunciationUrl = buildPronunciationUrl(
          simpleWord!.usspeech!,
          word: query,
        );
      }
      if (ukPronunciationUrl == null && simpleWord?.ukspeech != null) {
        ukPronunciationUrl = buildPronunciationUrl(
          simpleWord!.ukspeech!,
          word: query,
        );
      }
    }

    // Get exam types
    // examType is at ec level, not ec.word level, so check even if ecWord is null
    List<String>? examTypes = response.ec?.examType;

    // Also check expandEc for exam types
    if ((examTypes == null || examTypes.isEmpty) && response.expandEc != null) {
      // expandEc might have examType in its content
      // Note: expandEc structure may vary, check if it has examType field
    }

    // Get word forms
    List<Map<String, String>>? wordFormList;
    if (wordForms != null && wordForms.isNotEmpty) {
      wordFormList = wordForms
          .where((wf) => wf.name != null && wf.value != null)
          .map((wf) => {'name': wf.name!, 'value': wf.value!})
          .toList();
    }

    // Get phrases
    // Priority: phrs > individual.idiomatic (collocations)
    List<Map<String, String>>? phrasesList;
    if (phrs?.phrs != null && phrs!.phrs!.isNotEmpty) {
      phrasesList = phrs.phrs!
          .where((p) => p.headword != null && p.translation != null)
          .map((p) => {'name': p.headword!, 'value': p.translation!})
          .toList();
    }

    // Try to get phrases from individual.idiomatic (collocations)
    if ((phrasesList == null || phrasesList.isEmpty) &&
        response.individual?.idiomatic != null &&
        response.individual!.idiomatic!.isNotEmpty) {
      phrasesList = <Map<String, String>>[];
      for (final idiomatic in response.individual!.idiomatic!) {
        if (idiomatic.colloc != null) {
          final en = idiomatic.colloc!.en;
          final zh = idiomatic.colloc!.zh;
          if (en != null && en.isNotEmpty && zh != null && zh.isNotEmpty) {
            phrasesList.add({'name': en, 'value': zh});
          }
        }
      }
    }

    // Try to get phrases from individual.sayings (sayings/proverbs)
    if ((phrasesList == null || phrasesList.isEmpty) &&
        response.individual?.sayings != null &&
        response.individual!.sayings!.isNotEmpty) {
      phrasesList = <Map<String, String>>[];
      for (final saying in response.individual!.sayings!) {
        final en = saying.en;
        final zh = saying.zh;
        if (en != null && en.isNotEmpty && zh != null && zh.isNotEmpty) {
          phrasesList.add({'name': en, 'value': zh});
        }
      }
    }

    // Get web translations
    List<Map<String, String>>? webTranslationsList;
    if (webTrans?.webTranslation != null &&
        webTrans!.webTranslation!.isNotEmpty) {
      webTranslationsList = <Map<String, String>>[];
      for (final webItem in webTrans.webTranslation!) {
        if (webItem.key != null &&
            webItem.trans != null &&
            webItem.trans!.isNotEmpty) {
          for (final transItem in webItem.trans!) {
            if (transItem.value != null && transItem.value!.isNotEmpty) {
              webTranslationsList.add({
                'name': webItem.key!,
                'value': transItem.value!,
              });
            }
          }
        }
      }
    }

    return ResultModel(
      query: query,
      simpleExplanation: simpleExplanation,
      translationsByPos: translationsByPosList,
      usPronunciationUrl: usPronunciationUrl,
      ukPronunciationUrl: ukPronunciationUrl,
      usPhonetic: usPhonetic,
      ukPhonetic: ukPhonetic,
      examTypes: examTypes,
      wordForm: wordFormList,
      phrases: phrasesList,
      webTranslations: webTranslationsList,
    );
  }
}
