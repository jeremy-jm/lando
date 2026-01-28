import 'package:flutter_test/flutter_test.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/storage/query_history_storage.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('QueryHistoryStorage', () {
    setUp(() async {
      await TestHelpers.initSharedPreferences();
      await QueryHistoryStorage.clearHistory();
    });

    tearDown(() async {
      await QueryHistoryStorage.clearHistory();
    });

    test('should save and retrieve history item', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final saved = await QueryHistoryStorage.saveHistoryItem(item);
      expect(saved, isTrue);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, equals(1));
      expect(history.first.word, equals('hello'));
      expect(history.first.meaning, equals('你好'));
    });

    test('should return empty list when no history exists', () async {
      final history = await QueryHistoryStorage.getHistory();
      expect(history, isEmpty);
    });

    test('should update existing item with same word', () async {
      final item1 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await QueryHistoryStorage.saveHistoryItem(item1);

      final item2 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好（更新）',
        timestamp: DateTime.now().millisecondsSinceEpoch + 1000,
      );

      await QueryHistoryStorage.saveHistoryItem(item2);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, equals(1));
      expect(history.first.word, equals('hello'));
      expect(history.first.meaning, equals('你好（更新）'));
    });

    test('should maintain most recent items first', () async {
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
        word: 'test',
        meaning: '测试',
        timestamp: 3000,
      );

      await QueryHistoryStorage.saveHistoryItem(item1);
      await QueryHistoryStorage.saveHistoryItem(item2);
      await QueryHistoryStorage.saveHistoryItem(item3);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, equals(3));
      expect(history[0].word, equals('test')); // Most recent first
      expect(history[1].word, equals('world'));
      expect(history[2].word, equals('hello'));
    });

    test('should limit history to 1000 items', () async {
      // Create 1001 items
      for (int i = 0; i < 1001; i++) {
        final item = QueryHistoryItem(
          word: 'word$i',
          meaning: 'meaning$i',
          timestamp: DateTime.now().millisecondsSinceEpoch + i,
        );
        await QueryHistoryStorage.saveHistoryItem(item);
      }

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, equals(1000));
      // Most recent should be the last one added
      expect(history.first.word, equals('word1000'));
      // Oldest should be word1 (word0 was removed)
      expect(history.last.word, equals('word1'));
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

      final deleted = await QueryHistoryStorage.deleteHistoryItem('hello');
      expect(deleted, isTrue);

      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, equals(1));
      expect(history.first.word, equals('world'));
    });

    test('should return false when deleting non-existent item', () async {
      final deleted = await QueryHistoryStorage.deleteHistoryItem('nonexistent');
      expect(deleted, isTrue); // Still returns true, just no-op
    });

    test('should clear all history', () async {
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

      final cleared = await QueryHistoryStorage.clearHistory();
      expect(cleared, isTrue);

      final history = await QueryHistoryStorage.getHistory();
      expect(history, isEmpty);
    });

    test('should handle JSON serialization correctly', () async {
      final item = QueryHistoryItem(
        word: 'test',
        meaning: '测试',
        timestamp: 1234567890,
      );

      await QueryHistoryStorage.saveHistoryItem(item);

      // Retrieve and verify JSON round-trip
      final history = await QueryHistoryStorage.getHistory();
      expect(history.length, equals(1));

      final json = item.toJson();
      final fromJson = QueryHistoryItem.fromJson(json);

      expect(fromJson.word, equals(item.word));
      expect(fromJson.meaning, equals(item.meaning));
      expect(fromJson.timestamp, equals(item.timestamp));
    });
  });
}
