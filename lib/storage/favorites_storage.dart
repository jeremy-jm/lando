import 'dart:convert';
import 'package:lando/models/query_history_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage key for favorites.
class FavoritesStorageKeys {
  static const String favorites = 'favorites';
}

/// Storage service for managing favorites.
class FavoritesStorage {
  /// Save a favorite item.
  ///
  /// If the same word already exists, it will be updated with the new meaning
  /// and timestamp.
  static Future<bool> saveFavorite(QueryHistoryItem item) async {
    try {
      final favorites = await getFavorites();
      
      // Remove existing item with the same word (if any)
      favorites.removeWhere((f) => f.word == item.word);
      
      // Add new item at the beginning (most recent first)
      favorites.insert(0, item);
      
      // Limit to last 1000 items to prevent storage bloat
      if (favorites.length > 1000) {
        favorites.removeRange(1000, favorites.length);
      }
      
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Get all favorite items, sorted by timestamp (most recent first).
  static Future<List<QueryHistoryItem>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(FavoritesStorageKeys.favorites);
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList
          .map((json) => QueryHistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if a word is favorited.
  static Future<bool> isFavorite(String word) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((item) => item.word == word);
    } catch (e) {
      return false;
    }
  }

  /// Delete a specific favorite item by word.
  static Future<bool> deleteFavorite(String word) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((item) => item.word == word);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Clear all favorites.
  static Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(FavoritesStorageKeys.favorites);
    } catch (e) {
      return false;
    }
  }

  /// Save favorites list to storage.
  static Future<bool> _saveFavorites(List<QueryHistoryItem> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        favorites.map((item) => item.toJson()).toList(),
      );
      return await prefs.setString(FavoritesStorageKeys.favorites, favoritesJson);
    } catch (e) {
      return false;
    }
  }
}
