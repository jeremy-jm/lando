import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/services/translation/bing_token_service.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Bing translation service implementation.
///
/// Uses Bing Translator web API (ttranslatev3 endpoint).
class BingTranslationService implements TranslationService {
  BingTranslationService(this._apiClient);

  final ApiClient _apiClient;

  @override
  String get name => 'Bing';

  /// Maps language codes to Bing format.
  ///
  /// Bing uses formats like 'zh-Hans', 'en', 'ja', etc.
  /// Based on the curl request, 'auto-detect' is used for auto detection.
  String _mapLanguageCodeToBing(String? code) {
    if (code == null || code == 'auto') {
      return 'auto-detect';
    }

    switch (code.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
        return 'zh-Hans';
      case 'zh-tw':
      case 'zh-hk':
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

  /// Gets the current timestamp for key parameter.
  int _getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Gets the Bing translation token.
  ///
  /// Fetches token dynamically from BingTokenService, which caches it.
  /// Falls back to hardcoded token if fetching fails.
  Future<String> _getToken() async {
    // Try to get token from BingTokenService
    final token = await BingTokenService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      return token;
    }

    // Fallback to hardcoded token if fetching fails
    // This should be removed once dynamic fetching is working reliably
    const fallbackToken = '4upwCFTG-OrfXW_vGXi8T1VMJOl6Zkj8';
    debugPrint('BingTranslationService: Using fallback token');
    return fallbackToken;
  }

  @override
  Future<String> translate(String query) async {
    if (query.trim().isEmpty) {
      return '';
    }

    try {
      final result = await getDetailedResult(query);
      return result?.simpleExplanation ?? query;
    } on SocketException catch (e) {
      throw Exception(
        'Network connection failed. Please check your internet connection and try again. Error: ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('Translation request failed: ${e.message}');
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    if (query.trim().isEmpty) {
      return null;
    }

    try {
      // Get language preferences
      final fromLanguage =
          PreferencesStorage.getTranslationFromLanguage() ?? 'auto';
      final toLanguage = PreferencesStorage.getTranslationToLanguage() ?? 'en';

      final fromLang = _mapLanguageCodeToBing(fromLanguage);
      final toLang = _mapLanguageCodeToBing(toLanguage);

      // Initialize session to get fresh token, cookies, and IG parameter
      final sessionInitialized = await BingTokenService.instance.initializeSession();
      if (!sessionInitialized) {
        debugPrint('BingTranslationService: Failed to initialize session');
        return null;
      }

      // Get dynamic authorization data
      var token = await _getToken();
      var allCookies = await BingTokenService.instance.getAllCookies();
      var ig = await BingTokenService.instance.getIG();
      var key = await BingTokenService.instance.getKey();

      // If missing cookies, try to refresh session
      if (allCookies == null) {
        debugPrint('BingTranslationService: Missing cookies, attempting refresh...');
        final refreshed = await BingTokenService.instance.initializeSession(forceRefresh: true);
        if (!refreshed) {
          debugPrint('BingTranslationService: Failed to refresh session');
          return null;
        }
        
        // Re-fetch credentials after refresh
        token = await _getToken();
        allCookies = await BingTokenService.instance.getAllCookies();
        ig = await BingTokenService.instance.getIG();
        key = await BingTokenService.instance.getKey();
        
        if (allCookies == null) {
          debugPrint('BingTranslationService: Failed to get cookies after refresh');
          return null;
        }
      }

      // Build Bing API URL with dynamic IG parameter
      // Use extracted IG or fallback to a default
      final igParam = ig ?? 'C64EF28C417741E6BD8B489FA56D7831';
      final url =
          'https://www.bing.com/ttranslatev3?isVertical=1&&IG=$igParam&IID=translator.5025';

      // Prepare request body
      // Use the key from params_AbusePreventionHelper if available, otherwise use current timestamp
      final keyParam = key ?? _getCurrentTimestamp().toString();
      
      final body = <String, String>{
        'fromLang': fromLang == 'auto-detect' ? 'auto-detect' : fromLang,
        'to': toLang,
        'text': query,
        'tryFetchingGenderDebiasedTranslations': 'true',
        'token': token,
        'key': keyParam,
      };

      // Prepare headers
      final headers = <String, String>{
        'accept': '*/*',
        'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
        'content-type': 'application/x-www-form-urlencoded',
        'ect': '4g',
        'origin': 'https://www.bing.com',
        'priority': 'u=1, i',
        'referer': 'https://www.bing.com/translator',
        'sec-ch-ua':
            '"Not(A:Brand";v="8", "Chromium";v="144", "Google Chrome";v="144"',
        'sec-ch-ua-arch': '"arm"',
        'sec-ch-ua-bitness': '"64"',
        'sec-ch-ua-full-version': '"144.0.7559.97"',
        'sec-ch-ua-full-version-list':
            '"Not(A:Brand";v="8.0.0.0", "Chromium";v="144.0.7559.97", "Google Chrome";v="144.0.7559.97"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-model': '""',
        'sec-ch-ua-platform': '"macOS"',
        'sec-ch-ua-platform-version': '"26.2.0"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'user-agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',
      };

      // Use dynamically fetched cookies
      headers['cookie'] = allCookies;

      // Make API call (Bing returns JSON array)
      dynamic responseData;
      try {
        responseData = await _apiClient.postFormDynamic(
          url,
          body: body,
          headers: headers,
        );
      } catch (e) {
        debugPrint('Bing API: Exception during request: $e');
        
        // Try to extract more details from the error
        if (e is DioException) {
          if (e.response != null) {
            debugPrint('Bing API: Response status: ${e.response!.statusCode}, data: ${e.response!.data}');
          }
        }
        rethrow;
      }

      if (responseData == null) {
        debugPrint('Bing API: Response data is null');
        return null;
      }

      // Check for error responses
      if (responseData is Map) {
        // Check for various error fields
        if (responseData.containsKey('error')) {
          debugPrint('Bing API Error: ${responseData['error']}');
          return null;
        }
        if (responseData.containsKey('statusCode')) {
          final statusCode = responseData['statusCode'];
          if (statusCode != null && statusCode != 200) {
            final errorMsg = responseData['statusMessage'] ?? responseData['message'] ?? 'Unknown error';
            debugPrint('Bing API Error: Status $statusCode - $errorMsg');
            return null;
          }
        }
        if (responseData.containsKey('ShowCaptcha')) {
          debugPrint('Bing API: Captcha required');
          return null;
        }
      } else if (responseData is List) {
        // Check if first item is an error
        if (responseData.isNotEmpty && responseData[0] is Map) {
          final firstItem = responseData[0] as Map;
          if (firstItem.containsKey('error') || firstItem.containsKey('statusCode')) {
            debugPrint('Bing API Error: $firstItem');
            return null;
          }
        }
      }

      // Parse response
      final result = _parseResponse(responseData, query);
      if (result == null) {
        debugPrint('Bing API: Failed to parse response');
      }
      return result;
    } on HttpException catch (e) {
      debugPrint('Bing API HttpException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Bing API Error: $e');
      return null;
    }
  }

  /// Parses Bing API response and converts it to ResultModel.
  ///
  /// Bing API returns an array of translation results.
  ResultModel? _parseResponse(dynamic response, String query) {
    try {
      // Bing API returns an array
      if (response is! List) {
        // Try to handle if it's wrapped in a map
        if (response is Map) {
          // Check if there's a data field or similar
          if (response.containsKey('data') && response['data'] is List) {
            return _parseResponse(response['data'], query);
          }
        }
        return null;
      }

      if (response.isEmpty) {
        return null;
      }

      final firstResult = response[0];
      if (firstResult is! Map<String, dynamic>) {
        return null;
      }

      // Extract translations
      // Try different possible field names
      dynamic translations = firstResult['translations'];
      if (translations == null) {
        translations = firstResult['translation'];
      }
      if (translations == null) {
        translations = firstResult['text'];
      }

      if (translations == null) {
        return null;
      }

      // Handle case where translations might be a string directly
      if (translations is String) {
        return ResultModel(
          query: query,
          simpleExplanation: translations,
        );
      }

      if (translations is! List) {
        return null;
      }

      if (translations.isEmpty) {
        return null;
      }

      // Get the main translation text
      String? simpleExplanation;
      final firstTranslation = translations[0];

      if (firstTranslation is Map<String, dynamic>) {
        // Try different possible field names
        simpleExplanation = firstTranslation['text'] as String?;
        if (simpleExplanation == null || simpleExplanation.isEmpty) {
          // Try alternative field names
          simpleExplanation = firstTranslation['translatedText'] as String?;
        }
        if (simpleExplanation == null || simpleExplanation.isEmpty) {
          simpleExplanation = firstTranslation['translation'] as String?;
        }
        if (simpleExplanation == null || simpleExplanation.isEmpty) {
          // Try to get any string value from the map
          for (final entry in firstTranslation.entries) {
            if (entry.value is String &&
                entry.value.toString().trim().isNotEmpty) {
              simpleExplanation = entry.value.toString();
              break;
            }
          }
        }
      } else if (firstTranslation is String) {
        // If translation is directly a string
        simpleExplanation = firstTranslation;
      }

      // Extract additional translations for webTranslations
      List<Map<String, String>>? webTranslationsList;
      if (translations.length > 1) {
        webTranslationsList = <Map<String, String>>[];
        for (var i = 1; i < translations.length; i++) {
          final trans = translations[i];
          if (trans is Map<String, dynamic>) {
            final text = trans['text'] as String?;
            if (text != null && text.isNotEmpty) {
              webTranslationsList.add({
                'name': query,
                'value': text,
              });
            }
          }
        }
      }

      // Only create ResultModel if we have at least simpleExplanation
      if (simpleExplanation == null || simpleExplanation.isEmpty) {
        return null;
      }

      return ResultModel(
        query: query,
        simpleExplanation: simpleExplanation,
        webTranslations: webTranslationsList?.isNotEmpty == true
            ? webTranslationsList
            : null,
        // Bing API doesn't provide these fields, so they remain null
        translationsByPos: null,
        usPronunciationUrl: null,
        ukPronunciationUrl: null,
        usPhonetic: null,
        ukPhonetic: null,
        examTypes: null,
        wordForm: null,
        phrases: null,
      );
    } catch (e) {
      debugPrint('Bing _parseResponse Error: $e');
      return null;
    }
  }
}
