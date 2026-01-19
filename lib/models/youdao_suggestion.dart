/// Model for Youdao suggestion item.
class YoudaoSuggestion {
  YoudaoSuggestion({required this.word, this.explain});

  /// The suggested word or phrase.
  final String word;

  /// Optional explanation or translation of the suggestion.
  final String? explain;

  /// Create from JSON map.
  ///
  /// Handles both formats:
  /// - {"entry": "word", "explain": "..."} (new format)
  /// - {"word": "word", "explain": "..."} (legacy format)
  factory YoudaoSuggestion.fromJson(Map<String, dynamic> json) {
    // New format uses "entry" field, legacy uses "word"
    final word = json['entry'] as String? ?? json['word'] as String? ?? '';
    return YoudaoSuggestion(word: word, explain: json['explain'] as String?);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YoudaoSuggestion &&
        other.word == word &&
        other.explain == explain;
  }

  @override
  int get hashCode => Object.hash(word, explain);
}

/// Response model for Youdao suggestion API.
class YoudaoSuggestionResponse {
  YoudaoSuggestionResponse({
    required this.suggestions,
    this.isNotFound = false,
  });

  /// List of suggestions.
  final List<YoudaoSuggestion> suggestions;

  /// Whether the API returned a "not found" response (code 404).
  final bool isNotFound;

  /// Create from JSON map.
  ///
  /// Handles the actual Youdao API response format:
  /// {
  ///   "result": {"msg": "success", "code": 200},
  ///   "data": {
  ///     "entries": [
  ///       {"entry": "word", "explain": "..."},
  ///       ...
  ///     ],
  ///     "query": "...",
  ///     "language": "...",
  ///     "type": "..."
  ///   }
  /// }
  ///
  /// Also handles "not found" response:
  /// {
  ///   "result": {"msg": "not found", "code": 404},
  ///   "data": {}
  /// }
  ///
  /// Also supports legacy formats for backward compatibility.
  factory YoudaoSuggestionResponse.fromJson(Map<String, dynamic> json) {
    // Check for "not found" response (code 404)
    bool isNotFound = false;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      final result = json['result'] as Map<String, dynamic>;
      final code = result['code'];
      if (code == 404 || (code is int && code == 404)) {
        isNotFound = true;
      }
    }

    // Try to get entries from the new format: data.entries
    List<dynamic>? entries;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      entries = data['entries'] as List<dynamic>?;
    }

    // If not found, return empty suggestions with isNotFound flag
    if (isNotFound) {
      return YoudaoSuggestionResponse(suggestions: [], isNotFound: true);
    }

    // Fallback to legacy formats
    entries ??= json['entries'] as List<dynamic>?;
    entries ??= json['result'] as List<dynamic>?;
    entries ??= json['r'] as List<dynamic>?;

    if (entries == null || entries.isEmpty) {
      return YoudaoSuggestionResponse(suggestions: []);
    }

    final suggestions = entries
        .map((entry) {
          if (entry is Map<String, dynamic>) {
            // Handle object format: {"entry": "...", "explain": "..."}
            // or {"word": "...", "explain": "..."}
            // or {"c": "..."}
            return YoudaoSuggestion.fromJson(entry);
          } else if (entry is List && entry.isNotEmpty) {
            // Handle array format: ["word", "explain"]
            return YoudaoSuggestion(
              word: entry[0]?.toString() ?? '',
              explain: entry.length > 1 ? entry[1]?.toString() : null,
            );
          } else if (entry is String) {
            // Handle simple string format
            return YoudaoSuggestion(word: entry, explain: null);
          }
          return null;
        })
        .whereType<YoudaoSuggestion>()
        .toList();

    return YoudaoSuggestionResponse(suggestions: suggestions);
  }
}
