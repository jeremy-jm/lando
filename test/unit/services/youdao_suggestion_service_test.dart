import 'package:flutter_test/flutter_test.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/services/suggestion/youdao_suggestion_service.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('YoudaoSuggestionService', () {
    late MockApiClient mockApiClient;
    late YoudaoSuggestionService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesStorage.init();
      mockApiClient = MockApiClient();
      service = YoudaoSuggestionService(mockApiClient);
    });

    tearDown(() async {
      await PreferencesStorage.clearAll();
    });

    test('should return null for empty query', () async {
      final result = await service.getSuggestions('');

      expect(result, isNull);
    });

    test('should return null for whitespace-only query', () async {
      final result = await service.getSuggestions('   ');

      expect(result, isNull);
    });

    test('should fetch suggestions successfully', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {
          'entries': [
            {'entry': 'hello', 'explain': 'greeting'},
            {'entry': 'world', 'explain': 'planet'},
          ],
        },
      });

      final result = await service.getSuggestions('hel');

      expect(result, isNotNull);
      expect(result!.suggestions.length, 2);
      expect(result.suggestions[0].word, 'hello');
      expect(result.suggestions[1].word, 'world');
      expect(result.isNotFound, false);
    });

    test('should handle not found response', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'not found', 'code': 404},
        'data': {},
      });

      final result = await service.getSuggestions('nonexistent');

      expect(result, isNotNull);
      expect(result!.suggestions.isEmpty, true);
      expect(result.isNotFound, true);
    });

    test('should handle API errors gracefully', () async {
      mockApiClient.setError(Exception('API error'));

      final result = await service.getSuggestions('hello');

      expect(result, isNull);
    });

    test('should trim query before sending', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('  hello  ');

      expect(mockApiClient.lastQueryParams?['q'], 'hello');
    });

    test('should use default maxResults', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('hello');

      expect(mockApiClient.lastQueryParams?['num'], '5');
    });

    test('should use custom maxResults', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('hello', maxResults: 10);

      expect(mockApiClient.lastQueryParams?['num'], '10');
    });

    test('should use language code from preferences', () async {
      await PreferencesStorage.saveTranslationLanguages(
        toLanguage: 'zh',
      );

      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('hello');

      expect(mockApiClient.lastQueryParams?['le'], 'zh');
    });

    test('should use provided language code', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('hello', languageCode: 'ja');

      expect(mockApiClient.lastQueryParams?['le'], 'ja');
    });

    test('should map English to eng for Youdao API', () async {
      await PreferencesStorage.saveTranslationLanguages(
        toLanguage: 'en',
      );

      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('hello');

      expect(mockApiClient.lastQueryParams?['le'], 'eng');
    });

    test('should use default language when preferences not set', () async {
      mockApiClient.setResponse({
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      });

      await service.getSuggestions('hello');

      expect(mockApiClient.lastQueryParams?['le'], 'eng');
    });
  });
}

// Mock API client for testing
class MockApiClient extends ApiClient {
  Map<String, dynamic>? _response;
  Exception? _error;
  Map<String, dynamic>? lastQueryParams;

  MockApiClient() : super();

  void setResponse(Map<String, dynamic> response) {
    _response = response;
    _error = null;
  }

  void setError(Exception error) {
    _error = error;
    _response = null;
  }

  @override
  Future<Map<String, dynamic>> getJson(
    String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastQueryParams = queryParameters;
    await Future.delayed(const Duration(milliseconds: 10));
    if (_error != null) {
      throw _error!;
    }
    return _response ?? {};
  }
}
