import 'package:flutter_test/flutter_test.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/storage/favorites_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesStorage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesStorage.clearFavorites();
    });

    tearDown(() async {
      await FavoritesStorage.clearFavorites();
    });

    test('should save and get favorite item', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1234567890,
      );

      final result = await FavoritesStorage.saveFavorite(item);
      expect(result, true);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, 1);
      expect(favorites[0].word, 'hello');
      expect(favorites[0].meaning, '你好');
      expect(favorites[0].timestamp, 1234567890);
    });

    test('should return empty list when no favorites', () async {
      final favorites = await FavoritesStorage.getFavorites();

      expect(favorites.isEmpty, true);
    });

    test('should update existing favorite and move to top', () async {
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

      await FavoritesStorage.saveFavorite(item1);
      await FavoritesStorage.saveFavorite(item2);
      await FavoritesStorage.saveFavorite(item3);

      final favorites = await FavoritesStorage.getFavorites();

      expect(favorites.length, 2);
      expect(favorites[0].word, 'hello');
      expect(favorites[0].meaning, '你好（更新）');
      expect(favorites[0].timestamp, 3000);
      expect(favorites[1].word, 'world');
    });

    test('should limit to 1000 items', () async {
      for (int i = 0; i < 1005; i++) {
        final item = QueryHistoryItem(
          word: 'word$i',
          meaning: 'meaning$i',
          timestamp: i,
        );
        await FavoritesStorage.saveFavorite(item);
      }

      final favorites = await FavoritesStorage.getFavorites();

      expect(favorites.length, 1000);
      expect(favorites[0].word, 'word1004');
      expect(favorites[999].word, 'word5');
    });

    test('should check if word is favorited', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1000,
      );

      expect(await FavoritesStorage.isFavorite('hello'), false);

      await FavoritesStorage.saveFavorite(item);

      expect(await FavoritesStorage.isFavorite('hello'), true);
      expect(await FavoritesStorage.isFavorite('world'), false);
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

      final result = await FavoritesStorage.deleteFavorite('hello');
      expect(result, true);

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.length, 1);
      expect(favorites[0].word, 'world');
      expect(await FavoritesStorage.isFavorite('hello'), false);
    });

    test('should return true when deleting non-existent favorite', () async {
      final result = await FavoritesStorage.deleteFavorite('nonexistent');

      expect(result, true);
    });

    test('should clear all favorites', () async {
      final item = QueryHistoryItem(
        word: 'hello',
        meaning: '你好',
        timestamp: 1000,
      );

      await FavoritesStorage.saveFavorite(item);
      await FavoritesStorage.clearFavorites();

      final favorites = await FavoritesStorage.getFavorites();
      expect(favorites.isEmpty, true);
      expect(await FavoritesStorage.isFavorite('hello'), false);
    });

    test('should handle multiple favorites correctly', () async {
      final items = [
        QueryHistoryItem(word: 'word1', meaning: 'meaning1', timestamp: 1000),
        QueryHistoryItem(word: 'word2', meaning: 'meaning2', timestamp: 2000),
        QueryHistoryItem(word: 'word3', meaning: 'meaning3', timestamp: 3000),
      ];

      for (final item in items) {
        await FavoritesStorage.saveFavorite(item);
      }

      final favorites = await FavoritesStorage.getFavorites();

      expect(favorites.length, 3);
      expect(favorites[0].word, 'word3');
      expect(favorites[1].word, 'word2');
      expect(favorites[2].word, 'word1');
    });
  });
}
