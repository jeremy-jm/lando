import 'package:flutter_test/flutter_test.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/storage/favorites_storage.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('FavoritesStorage', () {
    setUp(() async {
      await TestHelpers.initSharedPreferences();
      await FavoritesStorage.clearFavorites();
    });

    tearDown(() async {
      await FavoritesStorage.clearFavorites();
    });

    test('should save and retrieve favorite item', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final saved = await FavoritesStorage.saveFavorite(item);
      expect(saved, isTrue);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, equals(1));
      expect(favorites.first.word, equals('hello'));
      expect(favorites.first.meaning, equals('你好'));
    });

    test('should return empty list when no favorites exist', () async {
      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites, isEmpty);
    });

    test('should update existing favorite with same word', () async {
      final item1 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await FavoritesStorage.saveFavorite(item1);

      final item2 = QueryHistoryItem(
        word: 'hello',
        meaning: '你好（更新）',
        timestamp: DateTime.now().millisecondsSinceEpoch + 1000,
      );

      await FavoritesStorage.saveFavorite(item2);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, equals(1));
      expect(favorites.first.word, equals('hello'));
      expect(favorites.first.meaning, equals('你好（更新）'));
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

      await FavoritesStorage.saveFavorite(item1);
      await FavoritesStorage.saveFavorite(item2);
      await FavoritesStorage.saveFavorite(item3);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, equals(3));
      expect(favorites[0].word, equals('test')); // Most recent first
      expect(favorites[1].word, equals('world'));
      expect(favorites[2].word, equals('hello'));
    });

    test('should limit favorites to 1000 items', () async {
      // Create 1001 items
      for (int i = 0; i < 1001; i++) {
        final item = QueryHistoryItem(
          word: 'word$i',
          meaning: 'meaning$i',
          timestamp: DateTime.now().millisecondsSinceEpoch + i,
        );
        await FavoritesStorage.saveFavorite(item);
      }

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, equals(1000));
      // Most recent should be the last one added
      expect(favorites.first.word, equals('word1000'));
      // Oldest should be word1 (word0 was removed)
      expect(favorites.last.word, equals('word1'));
    });

    test('should check if word is favorited', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1000,
      );

      await FavoritesStorage.saveFavorite(item);

      final isFavorite = await FavoritesStorage.isFavorite('hello');
      expect(isFavorite, isTrue);

      final isNotFavorite = await FavoritesStorage.isFavorite('world');
      expect(isNotFavorite, isFalse);
    });

    test('should delete specific favorite item', () async {
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

      await FavoritesStorage.saveFavorite(item1);
      await FavoritesStorage.saveFavorite(item2);

      final deleted = await FavoritesStorage.deleteFavorite('hello');
      expect(deleted, isTrue);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, equals(1));
      expect(favorites.first.word, equals('world'));
    });

    test('should return false when deleting non-existent favorite', () async {
      final deleted = await FavoritesStorage.deleteFavorite('nonexistent');
      expect(deleted, isTrue); // Still returns true, just no-op
    });

    test('should clear all favorites', () async {
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

      await FavoritesStorage.saveFavorite(item1);
      await FavoritesStorage.saveFavorite(item2);

      final cleared = await FavoritesStorage.clearFavorites();
      expect(cleared, isTrue);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites, isEmpty);
    });

    test('should handle JSON serialization correctly', () async {
      final item = QueryHistoryItem(
        word: 'test',
        meaning: '测试',
        timestamp: 1234567890,
      );

      await FavoritesStorage.saveFavorite(item);

      // Retrieve and verify JSON round-trip
      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, equals(1));

      final json = item.toJson();
      final fromJson = QueryHistoryItem.fromJson(json);

      expect(fromJson.word, equals(item.word));
      expect(fromJson.meaning, equals(item.meaning));
      expect(fromJson.timestamp, equals(item.timestamp));
    });
  });
}
