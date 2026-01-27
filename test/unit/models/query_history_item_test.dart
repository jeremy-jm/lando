import 'package:flutter_test/flutter_test.dart';
import 'package:lando/models/query_history_item.dart';

void main() {
  group('QueryHistoryItem', () {
    test('should create instance with required fields', () {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1234567890,
      );

      expect(item.word, 'hello');
      expect(item.meaning, '你好');
      expect(item.timestamp, 1234567890);
    });

    test('should convert to JSON correctly', () {
      final item = QueryHistoryItem(
        word: 'test',
        meaning: '测试',
        timestamp: 1234567890,
      );

      final json = item.toJson();

      expect(json['word'], 'test');
      expect(json['meaning'], '测试');
      expect(json['timestamp'], 1234567890);
    });

    test('should create from JSON correctly', () {
      final json = {
        'word': 'hello',
        'meaning': '你好',
        'timestamp': 1234567890,
      };

      final item = QueryHistoryItem.fromJson(json);

      expect(item.word, 'hello');
      expect(item.meaning, '你好');
      expect(item.timestamp, 1234567890);
    });

    test('should be equal when all fields match', () {
      final item1 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1234567890,
      );
      final item2 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1234567890,
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final item1 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1234567890,
      );
      final item2 = QueryHistoryItem(
        word: 'world',
        meaning: '你好',
        timestamp: 1234567890,
      );

      expect(item1, isNot(equals(item2)));
    });

    test('should handle empty strings', () {
      final item = QueryHistoryItem(
        word: '',
        meaning: '',
        timestamp: 0,
      );

      expect(item.word, '');
      expect(item.meaning, '');
      expect(item.timestamp, 0);
    });
  });
}
