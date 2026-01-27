import 'package:flutter_test/flutter_test.dart';
import 'package:lando/features/home/providers/query_history_provider.dart';

void main() {
  group('QueryHistoryProvider', () {
    late QueryHistoryProvider provider;

    setUp(() {
      provider = QueryHistoryProvider();
    });

    test('should start with empty history', () {
      expect(provider.currentQuery, isNull);
      expect(provider.canGoBack, false);
      expect(provider.canGoForward, false);
      expect(provider.historyLength, 0);
    });

    test('should add query to history', () {
      provider.addQuery('hello');

      expect(provider.currentQuery, 'hello');
      expect(provider.canGoBack, false);
      expect(provider.canGoForward, false);
      expect(provider.historyLength, 1);
    });

    test('should not add empty query', () {
      provider.addQuery('');
      provider.addQuery('   ');

      expect(provider.currentQuery, isNull);
      expect(provider.historyLength, 0);
    });

    test('should trim query when adding', () {
      provider.addQuery('  hello  ');

      expect(provider.currentQuery, 'hello');
    });

    test('should not add duplicate query', () {
      provider.addQuery('hello');
      provider.addQuery('hello');

      expect(provider.historyLength, 1);
      expect(provider.currentQuery, 'hello');
    });

    test('should navigate backward', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      expect(provider.currentQuery, 'query3');
      expect(provider.canGoBack, true);

      final previous = provider.goBack();

      expect(previous, 'query2');
      expect(provider.currentQuery, 'query2');
      expect(provider.canGoBack, true);
      expect(provider.canGoForward, true);
    });

    test('should navigate forward', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      provider.goBack();
      provider.goBack();

      expect(provider.currentQuery, 'query1');
      expect(provider.canGoForward, true);

      final next = provider.goForward();

      expect(next, 'query2');
      expect(provider.currentQuery, 'query2');
      expect(provider.canGoBack, true);
      expect(provider.canGoForward, true);
    });

    test('should not navigate backward when at beginning', () {
      provider.addQuery('query1');

      expect(provider.canGoBack, false);
      expect(provider.goBack(), isNull);
    });

    test('should not navigate forward when at end', () {
      provider.addQuery('query1');

      expect(provider.canGoForward, false);
      expect(provider.goForward(), isNull);
    });

    test('should remove forward history when adding new query', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      provider.goBack(); // Now at query2
      provider.goBack(); // Now at query1

      expect(provider.canGoForward, true);
      expect(provider.historyLength, 3);

      provider.addQuery('query4'); // Should remove query2 and query3

      expect(provider.currentQuery, 'query4');
      expect(provider.canGoBack, true);
      expect(provider.canGoForward, false);
      expect(provider.historyLength, 2);
      expect(provider.goBack(), 'query1');
    });

    test('should check if query is current', () {
      provider.addQuery('hello');

      expect(provider.isCurrentQuery('hello'), true);
      expect(provider.isCurrentQuery('world'), false);
      expect(provider.isCurrentQuery('  hello  '), true); // Should trim
    });

    test('should clear history', () {
      provider.addQuery('query1');
      provider.addQuery('query2');
      provider.addQuery('query3');

      expect(provider.historyLength, 3);

      provider.clear();

      expect(provider.currentQuery, isNull);
      expect(provider.canGoBack, false);
      expect(provider.canGoForward, false);
      expect(provider.historyLength, 0);
    });

    test('should handle multiple navigations correctly', () {
      provider.addQuery('q1');
      provider.addQuery('q2');
      provider.addQuery('q3');
      provider.addQuery('q4');

      // Navigate back twice
      provider.goBack();
      provider.goBack();

      expect(provider.currentQuery, 'q2');
      expect(provider.canGoBack, true);
      expect(provider.canGoForward, true);

      // Navigate forward once
      provider.goForward();

      expect(provider.currentQuery, 'q3');
      expect(provider.canGoBack, true);
      expect(provider.canGoForward, true);
    });
  });
}
