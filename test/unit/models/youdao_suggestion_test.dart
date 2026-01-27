import 'package:flutter_test/flutter_test.dart';
import 'package:lando/models/youdao_suggestion.dart';

void main() {
  group('YoudaoSuggestion', () {
    test('should create instance with word', () {
      final suggestion = YoudaoSuggestion(word: 'hello');

      expect(suggestion.word, 'hello');
      expect(suggestion.explain, isNull);
    });

    test('should create instance with word and explain', () {
      final suggestion = YoudaoSuggestion(
        word: 'hello',
        explain: 'a greeting',
      );

      expect(suggestion.word, 'hello');
      expect(suggestion.explain, 'a greeting');
    });

    test('should create from JSON with entry field', () {
      final json = {
        'entry': 'hello',
        'explain': 'a greeting',
      };

      final suggestion = YoudaoSuggestion.fromJson(json);

      expect(suggestion.word, 'hello');
      expect(suggestion.explain, 'a greeting');
    });

    test('should create from JSON with word field (legacy)', () {
      final json = {
        'word': 'hello',
        'explain': 'a greeting',
      };

      final suggestion = YoudaoSuggestion.fromJson(json);

      expect(suggestion.word, 'hello');
      expect(suggestion.explain, 'a greeting');
    });

    test('should handle JSON without explain', () {
      final json = {'entry': 'hello'};

      final suggestion = YoudaoSuggestion.fromJson(json);

      expect(suggestion.word, 'hello');
      expect(suggestion.explain, isNull);
    });

    test('should be equal when fields match', () {
      final suggestion1 = YoudaoSuggestion(
        word: 'hello',
        explain: 'greeting',
      );
      final suggestion2 = YoudaoSuggestion(
        word: 'hello',
        explain: 'greeting',
      );

      expect(suggestion1, equals(suggestion2));
      expect(suggestion1.hashCode, equals(suggestion2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final suggestion1 = YoudaoSuggestion(word: 'hello');
      final suggestion2 = YoudaoSuggestion(word: 'world');

      expect(suggestion1, isNot(equals(suggestion2)));
    });
  });

  group('YoudaoSuggestionResponse', () {
    test('should create with suggestions', () {
      final response = YoudaoSuggestionResponse(
        suggestions: [
          YoudaoSuggestion(word: 'hello'),
          YoudaoSuggestion(word: 'world'),
        ],
      );

      expect(response.suggestions.length, 2);
      expect(response.isNotFound, false);
    });

    test('should create with isNotFound flag', () {
      final response = YoudaoSuggestionResponse(
        suggestions: [],
        isNotFound: true,
      );

      expect(response.suggestions.isEmpty, true);
      expect(response.isNotFound, true);
    });

    test('should parse from JSON with new format', () {
      final json = {
        'result': {'msg': 'success', 'code': 200},
        'data': {
          'entries': [
            {'entry': 'hello', 'explain': 'greeting'},
            {'entry': 'world', 'explain': 'planet'},
          ],
        },
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.length, 2);
      expect(response.suggestions[0].word, 'hello');
      expect(response.suggestions[1].word, 'world');
      expect(response.isNotFound, false);
    });

    test('should parse from JSON with not found response', () {
      final json = {
        'result': {'msg': 'not found', 'code': 404},
        'data': {},
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.isEmpty, true);
      expect(response.isNotFound, true);
    });

    test('should parse from JSON with legacy format', () {
      final json = {
        'entries': [
          {'word': 'hello', 'explain': 'greeting'},
        ],
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.length, 1);
      expect(response.suggestions[0].word, 'hello');
    });

    test('should parse from JSON with array format', () {
      final json = {
        'entries': [
          ['hello', 'greeting'],
          ['world', 'planet'],
        ],
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.length, 2);
      expect(response.suggestions[0].word, 'hello');
      expect(response.suggestions[0].explain, 'greeting');
    });

    test('should parse from JSON with string format', () {
      final json = {
        'entries': ['hello', 'world'],
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.length, 2);
      expect(response.suggestions[0].word, 'hello');
      expect(response.suggestions[0].explain, isNull);
    });

    test('should handle empty entries', () {
      final json = {
        'result': {'msg': 'success', 'code': 200},
        'data': {'entries': []},
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.isEmpty, true);
      expect(response.isNotFound, false);
    });

    test('should handle missing entries', () {
      final json = {
        'result': {'msg': 'success', 'code': 200},
        'data': <String, dynamic>{}, // Explicitly type as Map<String, dynamic>
      };

      final response = YoudaoSuggestionResponse.fromJson(json);

      expect(response.suggestions.isEmpty, true);
      expect(response.isNotFound, false);
    });
  });
}
