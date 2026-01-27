import 'package:flutter_test/flutter_test.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/storage/query_history_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('QueryHistoryStorage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await QueryHistoryStorage.clearHistory();
    });

    tearDown(() async {
      await QueryHistoryStorage.clearHistory();
    });

    test('should save and get history item', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1234567890,
      );

      final result = await QueryHistoryStorage.saveHistoryItem(item);
      expect(result, true);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, 1);
      expect(history[0].word, 'hello');
      expect(history[0].meaning, '你好');
      expect(history[0].timestamp, 1234567890);
    });

    test('should return empty list when no history', () async {
      final history = await QueryHistoryStorage.getHistory();

      expect(history.isEmpty, true);
    });

    test('should update existing item and move to top', () async {
      final item1 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1000,
      );
      final item2 = QueryHistoryItem(
        word: 'world',
        meaning: '世界',
        timestamp: 2000,
      );
      final item3 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好（更新）',
        timestamp: 3000,
      );

      await QueryHistoryStorage.saveHistoryItem(item1);
      await QueryHistoryStorage.saveHistoryItem(item2);
      await QueryHistoryStorage.saveHistoryItem(item3);

      final history = await QueryHistoryStorage.getHistory();

      expect(history.length, 2);
      expect(history[0].word, 'hello');
      expect(history[0].meaning, '你好（更新）');
      expect(history[0].timestamp, 3000);
      expect(history[1].word, 'world');
    });

    test('should limit to 1000 items', () async {
      for (int i = 0; i < 1005; i++) {
        final item = QueryHistoryItem(
          word: 'word$i',
          meaning: 'meaning$i',
          timestamp: i,
        );
        await QueryHistoryStorage.saveHistoryItem(item);
      }

      final history = await QueryHistoryStorage.getHistory();

      expect(history.length, 1000);
      expect(history[0].word, 'word1004');
      expect(history[999].word, 'word5');
    });

    test('should delete specific history item', () async {
      final item1 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1000,
      );
      final item2 = QueryHistoryItem(
        word: 'world',
        meaning: '世界',
        timestamp: 2000,
      );

      await QueryHistoryStorage.saveHistoryItem(item1);
      await QueryHistoryStorage.saveHistoryItem(item2);

      final result = await QueryHistoryStorage.deleteHistoryItem('hello');
      expect(result, true);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, 1);
      expect(history[0].word, 'world');
    });

    test('should return true when deleting non-existent item', () async {
      final result = await QueryHistoryStorage.deleteHistoryItem('nonexistent');

      expect(result, true);
    });

    test('should clear all history', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1000,
      );

      await QueryHistoryStorage.saveHistoryItem(item);
      await QueryHistoryStorage.clearHistory();

      final history = await QueryHistoryStorage.getHistory();
      expect(history.isEmpty, true);
    });

    test('should handle multiple items correctly', () async {
      final items = [
        QueryHistoryItem(word: 'word1', meaning: 'meaning1', timestamp: 1000),
        QueryHistoryItem(word: 'word2', meaning: 'meaning2', timestamp: 2000),
        QueryHistoryItem(word: 'word3', meaning: 'meaning3', timestamp: 3000),
      ];

      for (final item in items) {
        await QueryHistoryStorage.saveHistoryItem(item);
      }

      final history = await QueryHistoryStorage.getHistory();

      expect(history.length, 3);
      expect(history[0].word, 'word3');
      expect(history[1].word, 'word2');
      expect(history[2].word, 'word1');
    });

    test('should handle empty word gracefully', () async {
      final item = QueryHistoryItem(
        word: '',
        meaning: 'meaning',
        timestamp: 1000,
      );

      final result = await QueryHistoryStorage.saveHistoryItem(item);
      expect(result, true);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, 1);
    });
  });
}
