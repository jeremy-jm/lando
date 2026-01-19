import 'package:lando/models/youdao_suggestion.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Service for fetching word suggestions from Youdao API.
///
/// This service provides a high-cohesion interface for suggestion functionality,
/// keeping all suggestion-related logic in one place.
class YoudaoSuggestionService {
  YoudaoSuggestionService(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches suggestions for the given query.
  ///
  /// [query] is the text to get suggestions for.
  /// [languageCode] is optional, defaults to the user's preferred translation language.
  /// [maxResults] is the maximum number of suggestions to return (default: 10).
  ///
  /// Returns a [YoudaoSuggestionResponse] containing suggestions and status information.
  /// Returns null if the query is empty or an error occurs.
  Future<YoudaoSuggestionResponse?> getSuggestions(
    String query, {
    String? languageCode,
    int maxResults = 5,
  }) async {
    if (query.trim().isEmpty) {
      return null;
    }

    try {
      // Get language code from preferences if not provided
      final le =
          languageCode ??
          _mapLanguageCodeToYoudao(
            PreferencesStorage.getTranslationToLanguage(),
          );

      final endpoint = 'https://dict.youdao.com/suggest';
      final queryParams = {
        'num': maxResults.toString(),
        'ver': '3.0',
        'doctype': 'json',
        'cache': 'false',
        'le': le,
        'q': query.trim(),
      };

      final response = await _apiClient.getJson(
        endpoint,
        queryParameters: queryParams,
      );

      return YoudaoSuggestionResponse.fromJson(response);
    } catch (e) {
      // Return null on error to indicate failure
      return null;
    }
  }

  /// Maps language code to Youdao's language code format.
  ///
  /// Maps 'en' to 'eng' for Youdao API, other codes are used as-is.
  String _mapLanguageCodeToYoudao(String? languageCode) {
    if (languageCode == null || languageCode == 'auto') {
      return 'eng'; // Default to English for suggestions
    }

    final code = languageCode.toLowerCase();

    // Map 'en' to 'eng' for Youdao API
    if (code == 'en') {
      return 'eng';
    }

    // Use language code directly
    return code;
  }
}
