import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/providers/query_history_provider.dart';

void main() {
  group('QueryHistoryProvider', () {
    late QueryHistoryProvider provider;

    setUp(() {
      provider = QueryHistoryProvider();
    });

    test('should initialize with empty history', () {
      expect(provider.currentQuery, isNull);
      expect(provider.canGoBack, isFalse);
      expect(provider.canGoForward, isFalse);
      expect(provider.historyLength, equals(0));
    });

    test('should add query to history', () {
      provider.addQuery('hello');
      expect(provider.currentQuery, equals('hello'));
      expect(provider.historyLength, equals(1));
      expect(provider.canGoBack, isFalse);
      expect(provider.canGoForward, isFalse);
    });

    test('should not add empty query', () {
      provider.addQuery('');
      expect(provider.historyLength, equals(0));
      expect(provider.currentQuery, isNull);

      provider.addQuery('   ');
      expect(provider.historyLength, equals(0));
      expect(provider.currentQuery, isNull);
    });

    test('should trim query when adding', () {
      provider.addQuery('  hello  ');
      expect(provider.currentQuery, equals('hello'));
    });

    test('should not add duplicate query if it is current', () {
      provider.addQuery('hello');
      provider.addQuery('hello');
      expect(provider.historyLength, equals(1));
    });

    test('should navigate backward', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      expect(provider.currentQuery, equals('query3'));
      expect(provider.canGoBack, isTrue);
      expect(provider.canGoForward, isFalse);

      final previous = provider.goBack();
      expect(previous, equals('query2'));
      expect(provider.currentQuery, equals('query2'));
      expect(provider.canGoBack, isTrue);
      expect(provider.canGoForward, isTrue);

      final previous2 = provider.goBack();
      expect(previous2, equals('query1'));
      expect(provider.currentQuery, equals('query1'));
      expect(provider.canGoBack, isFalse);
      expect(provider.canGoForward, isTrue);
    });

    test('should navigate forward', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      // Go back twice
      provider.goBack();
      provider.goBack();

      expect(provider.currentQuery, equals('query1'));
      expect(provider.canGoBack, isFalse);
      expect(provider.canGoForward, isTrue);

      final next = provider.goForward();
      expect(next, equals('query2'));
      expect(provider.currentQuery, equals('query2'));
      expect(provider.canGoBack, isTrue);
      expect(provider.canGoForward, isTrue);

      final next2 = provider.goForward();
      expect(next2, equals('query3'));
      expect(provider.currentQuery, equals('query3'));
      expect(provider.canGoBack, isTrue);
      expect(provider.canGoForward, isFalse);
    });

    test('should return null when navigating backward at start', () {
      provider.addQuery('query1');
      expect(provider.canGoBack, isFalse);

      final result = provider.goBack();
      expect(result, isNull);
    });

    test('should return null when navigating forward at end', () {
      provider.addQuery('query1');
      expect(provider.canGoForward, isFalse);

      final result = provider.goForward();
      expect(result, isNull);
    });

    test('should remove forward history when adding new query', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      // Go back to query1
      provider.goBack();
      provider.goBack();

      expect(provider.currentQuery, equals('query1'));
      expect(provider.canGoForward, isTrue);

      // Add new query - should remove query2 and query3 from forward history
      provider.addQuery('query4');

      expect(provider.currentQuery, equals('query4'));
      expect(provider.canGoBack, isTrue);
      expect(provider.canGoForward, isFalse);
      expect(provider.historyLength, equals(2)); // query1 and query4
    });

    test('should check if query is current', () {
      provider.addQuery('hello');
      expect(provider.isCurrentQuery('hello'), isTrue);
      expect(provider.isCurrentQuery('world'), isFalse);
      expect(provider.isCurrentQuery('  hello  '), isTrue); // Should trim
    });

    test('should clear history', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      expect(provider.historyLength, equals(3));

      provider.clear();

      expect(provider.historyLength, equals(0));
      expect(provider.currentQuery, isNull);
      expect(provider.canGoBack, isFalse);
      expect(provider.canGoForward, isFalse);
    });

    test('should handle multiple sequential queries', () {
      final queries = ['query1', 'query2', 'query3', 'query4', 'query5'];
      for (final query in queries) {
        provider.addQuery(query);
      }

      expect(provider.historyLength, equals(5));
      expect(provider.currentQuery, equals('query5'));

      // Navigate back through all
      for (int i = queries.length - 2; i >= 0; i--) {
        final result = provider.goBack();
        expect(result, equals(queries[i]));
      }

      expect(provider.currentQuery, equals('query1'));
      expect(provider.canGoBack, isFalse);
    });
  });
}
