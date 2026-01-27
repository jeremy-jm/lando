import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/query/query_repository.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/services/translation/youdao_translation_service.dart';
import 'package:lando/services/translation/youdao/models/youdao_query_model.dart';
import 'package:lando/services/translation/youdao/models/youdao_response.dart';

void main() {
  group('QueryRepository', () {
    late MockTranslationService mockService;
    late QueryRepository repository;

    setUp(() {
      mockService = MockTranslationService();
      repository = QueryRepository(translationService: mockService);
    });

    test('should use provided translation service', () {
      expect(repository.translationService, mockService);
    });

    test('should create with service type', () {
      final repo = QueryRepository(
        serviceType: TranslationServiceType.youdao,
      );

      expect(repo.translationService, isA<TranslationService>());
    });

    test('should lookup translation', () async {
      mockService.setTranslation('Hello', '你好');

      final result = await repository.lookup('Hello');

      expect(result, '你好');
      expect(mockService.lastQuery, 'Hello');
    });

    test('should lookup with pronunciation for Youdao service', () async {
      final youdaoService = MockYoudaoTranslationService();
      final repo = QueryRepository(translationService: youdaoService);

      final result = await repo.lookupWithPronunciation('Hello');

      expect(result['translation'], '你好');
      expect(result['usPronunciationUrl'], isNotNull);
      expect(result['ukPronunciationUrl'], isNotNull);
      expect(result['youdaoResponse'], isNotNull);
    });

    test('should return translation only for non-Youdao service', () async {
      mockService.setTranslation('Hello', '你好');

      final result = await repository.lookupWithPronunciation('Hello');

      expect(result['translation'], '你好');
      expect(result['usPronunciationUrl'], isNull);
      expect(result['youdaoResponse'], isNull);
    });

    test('should switch to different service', () {
      final newRepo = repository.withService(TranslationServiceType.google);

      expect(newRepo, isA<QueryRepository>());
      expect(newRepo, isNot(same(repository)));
    });

    test('should handle empty query', () async {
      final result = await repository.lookup('');

      expect(result, '');
    });

    test('should handle translation errors', () async {
      mockService.setError(Exception('Translation failed'));

      expect(
        () => repository.lookup('Hello'),
        throwsException,
      );
    });
  });
}

// Mock translation service
class MockTranslationService implements TranslationService {
  String? _translation;
  Exception? _error;
  String? lastQuery;

  @override
  String get name => 'Mock';

  void setTranslation(String query, String translation) {
    _translation = translation;
    _error = null;
  }

  void setError(Exception error) {
    _error = error;
    _translation = null;
  }

  @override
  Future<String> translate(String query) async {
    lastQuery = query;
    if (_error != null) {
      throw _error!;
    }
    return _translation ?? '';
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    return null;
  }
}

// Mock Youdao translation service
class MockYoudaoTranslationService extends MockTranslationService
    implements YoudaoTranslationService {
  @override
  String get name => 'Youdao';

  @override
  Future<String> translate(String query) async {
    return '你好';
  }

  @override
  Future<YoudaoResponse> translateFull(String query) async {
    return YoudaoResponse.fromJson({
      'fanyi': {'tran': '你好'},
      'basic': {
        'us-phonetic': 'həˈloʊ',
        'uk-phonetic': 'həˈləʊ',
        'phonetic': 'həˈloʊ',
      },
    });
  }

  @override
  Future<YoudaoResponse> translateFullWithModel(YoudaoQueryModel queryModel) async {
    return YoudaoResponse.fromJson({
      'fanyi': {'tran': '你好'},
      'basic': {
        'us-phonetic': 'həˈloʊ',
        'uk-phonetic': 'həˈləʊ',
        'phonetic': 'həˈloʊ',
      },
    });
  }

  @override
  Map<String, String?> getPronunciationUrls(
    YoudaoResponse response,
    String query,
  ) {
    return {
      'us': 'https://dict.youdao.com/dictvoice?audio=hello_us',
      'uk': 'https://dict.youdao.com/dictvoice?audio=hello_uk',
      'general': 'https://dict.youdao.com/dictvoice?audio=hello',
    };
  }

  @override
  String? getInputPronunciationUrl(YoudaoResponse response, String query) {
    return 'https://dict.youdao.com/dictvoice?audio=hello';
  }

  @override
  String? buildPronunciationUrl(
    String? speechParam, {
    String? word,
    String? languageCode,
  }) {
    if (speechParam == null || speechParam.isEmpty) {
      if (word != null && word.isNotEmpty) {
        return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(word)}';
      }
      return null;
    }
    return 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(speechParam)}';
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    return null;
  }
}
