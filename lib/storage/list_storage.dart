import 'dart:convert';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Generic synchronous JSON list store backed by [PreferencesStorage].
///
/// Used by [FavoritesStorage] and [QueryHistoryStorage] to avoid duplicating
/// the same read / write / upsert / remove pattern.
class ListStorage {
  const ListStorage(this._key);

  final String _key;

  List<QueryHistoryItem> read() {
    try {
      final raw = PreferencesStorage.prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List)
          .map((e) => QueryHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> write(List<QueryHistoryItem> items) {
    try {
      return PreferencesStorage.prefs.setString(
        _key,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      return Future.value(false);
    }
  }

  /// Insert [item] at the top, replacing any existing entry with the same
  /// word, and truncate to [maxItems].
  Future<bool> upsert(QueryHistoryItem item, {int maxItems = 1000}) {
    final items = read()..removeWhere((e) => e.word == item.word);
    items.insert(0, item);
    if (items.length > maxItems) items.removeRange(maxItems, items.length);
    return write(items);
  }

  Future<bool> remove(String word) {
    final items = read()..removeWhere((e) => e.word == word);
    return write(items);
  }

  Future<bool> clear() => PreferencesStorage.prefs.remove(_key);
}
