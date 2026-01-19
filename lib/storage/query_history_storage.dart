import 'dart:convert';
import 'package:lando/models/query_history_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage key for query history.
class QueryHistoryStorageKeys {
  static const String queryHistory = 'query_history';
}

/// Storage service for managing query history.
class QueryHistoryStorage {
  /// Save a query history item.
  ///
  /// If the same word already exists, it will be updated with the new meaning
  /// and timestamp, and moved to the top of the list.
  static Future<bool> saveHistoryItem(QueryHistoryItem item) async {
    try {
      final history = await getHistory();
      
      // Remove existing item with the same word (if any)
      history.removeWhere((h) => h.word == item.word);
      
      // Add new item at the beginning (most recent first)
      history.insert(0, item);
      
      // Limit to last 1000 items to prevent storage bloat
      if (history.length > 1000) {
        history.removeRange(1000, history.length);
      }
      
      return await _saveHistory(history);
    } catch (e) {
      return false;
    }
  }

  /// Get all query history items, sorted by timestamp (most recent first).
  static Future<List<QueryHistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(QueryHistoryStorageKeys.queryHistory);
      
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map((json) => QueryHistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a specific history item by word.
  static Future<bool> deleteHistoryItem(String word) async {
    try {
      final history = await getHistory();
      history.removeWhere((item) => item.word == word);
      return await _saveHistory(history);
    } catch (e) {
      return false;
    }
  }

  /// Clear all query history.
  static Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(QueryHistoryStorageKeys.queryHistory);
    } catch (e) {
      return false;
    }
  }

  /// Save history list to storage.
  static Future<bool> _saveHistory(List<QueryHistoryItem> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        history.map((item) => item.toJson()).toList(),
      );
      return await prefs.setString(QueryHistoryStorageKeys.queryHistory, historyJson);
    } catch (e) {
      return false;
    }
  }
}
