import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/query/query_bloc.dart';
import 'package:lando/features/home/query/query_repository.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_service.dart';

void main() {
  group('QueryBloc', () {
    late QueryBloc bloc;
    late MockTranslationService mockService;
    late QueryRepository repository;

    setUp(() {
      mockService = MockTranslationService();
      repository = QueryRepository(translationService: mockService);
      bloc = QueryBloc(repository);
    });

    tearDown(() {
      bloc.dispose();
    });

    test('should have initial state', () {
      expect(bloc.state.query, '');
      expect(bloc.state.isLoading, false);
      expect(bloc.state.result, '');
      expect(bloc.state.errorMessage, isNull);
    });

    test('should emit loading state when query submitted', () async {
      mockService.setTranslation('Hello', '你好');

      bloc.add(QuerySearchSubmitted('Hello'));

      // Wait for state to update
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.query, 'Hello');
      expect(bloc.state.isLoading, false); // Should be false after completion
      expect(bloc.state.result, '你好');
      expect(bloc.state.errorMessage, isNull);
    });

    test('should handle empty query', () async {
      bloc.add(QuerySearchSubmitted(''));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.query, '');
    });

    test('should handle translation error', () async {
      mockService.setError(Exception('Translation failed'));

      bloc.add(QuerySearchSubmitted('Hello'));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.errorMessage, isNotNull);
      expect(bloc.state.errorMessage, contains('Translation failed'));
    });

    test('should emit states through stream', () async {
      mockService.setTranslation('Hello', '你好');

      final states = <QueryState>[];
      final subscription = bloc.stream.listen((state) {
        states.add(state);
      });

      bloc.add(QuerySearchSubmitted('Hello'));

      await Future.delayed(const Duration(milliseconds: 200));

      expect(states.length, greaterThan(0));
      expect(states.last.query, 'Hello');
      expect(states.last.result, '你好');

      await subscription.cancel();
    });

    test('should handle multiple queries', () async {
      mockService.setTranslation('Hello', '你好');
      bloc.add(QuerySearchSubmitted('Hello'));
      await Future.delayed(const Duration(milliseconds: 100));

      mockService.setTranslation('World', '世界');
      bloc.add(QuerySearchSubmitted('World'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.query, 'World');
      expect(bloc.state.result, '世界');
    });

    test('should clear previous error on new query', () async {
      mockService.setError(Exception('First error'));
      bloc.add(QuerySearchSubmitted('Hello'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.errorMessage, isNotNull);

      mockService.setTranslation('World', '世界');
      mockService.setError(null);
      bloc.add(QuerySearchSubmitted('World'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.result, '世界');
    });
  });
}

// Mock translation service for testing
class MockTranslationService implements TranslationService {
  String? _translation;
  Exception? _error;

  @override
  String get name => 'Mock';

  void setTranslation(String query, String translation) {
    _translation = translation;
    _error = null;
  }

  void setError(Exception? error) {
    _error = error;
    _translation = null;
  }

  @override
  Future<String> translate(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
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
