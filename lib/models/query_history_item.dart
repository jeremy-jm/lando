/// Model for a single query history item.
class QueryHistoryItem {
  QueryHistoryItem({
    required this.word,
    required this.meaning,
    required this.timestamp,
  });

  /// The queried word or phrase.
  final String word;

  /// The translation/meaning of the word.
  final String meaning;

  /// Timestamp when the query was made (milliseconds since epoch).
  final int timestamp;

  /// Convert to JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'timestamp': timestamp,
    };
  }

  /// Create from JSON map.
  factory QueryHistoryItem.fromJson(Map<String, dynamic> json) {
    return QueryHistoryItem(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QueryHistoryItem &&
        other.word == word &&
        other.meaning == meaning &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(word, meaning, timestamp);
}
