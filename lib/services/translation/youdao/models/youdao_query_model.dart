import 'dart:convert';

/// Query model for Youdao API request.
class YoudaoQueryModel {
  const YoudaoQueryModel({
    required this.q,
    required this.le,
    this.t,
    this.client = 'web',
    this.sign,
    this.keyfrom = 'webdict',
    this.dicts,
  });

  /// Query text
  final String q;

  /// Target language code (e.g., 'ja' for Japanese, 'en' for English, 'zh' for Chinese)
  final String le;

  /// Timestamp or other parameter
  final String? t;

  /// Client identifier
  final String client;

  /// Signature for authentication
  final String? sign;

  /// Key from identifier
  final String keyfrom;

  /// Dictionary types to request (e.g., ["ec"] for English-Chinese, ["ce"] for Chinese-English)
  final List<String>? dicts;

  /// Converts the model to a map for API request.
  ///
  /// Note: The values will be URL-encoded by ApiClient.postForm() when sending the request.
  /// The language code (le) is passed directly as selected by the user.
  Map<String, String> toMap() {
    final map = <String, String>{
      'q': q, // Query text (will be URL-encoded)
      // 'le': le, // Target language code (e.g., 'ja', 'zh', 'en') - will be URL-encoded, it will be lead to ec not found
      'client': client,
      'keyfrom': keyfrom,
    };

    if (t != null && t!.isNotEmpty) {
      map['t'] = t!;
    }

    if (sign != null && sign!.isNotEmpty) {
      map['sign'] = sign!;
    }

    // Add dicts parameter if provided
    if (dicts != null && dicts!.isNotEmpty) {
      final dictsJson = {
        'count': dicts!.length.toString(),
        'dicts': dicts!,
      };
      map['dicts'] = jsonEncode(dictsJson);
    }

    return map;
  }

  /// Creates a copy with updated fields
  YoudaoQueryModel copyWith({
    String? q,
    String? le,
    String? t,
    String? client,
    String? sign,
    String? keyfrom,
    List<String>? dicts,
  }) {
    return YoudaoQueryModel(
      q: q ?? this.q,
      le: le ?? this.le,
      t: t ?? this.t,
      client: client ?? this.client,
      sign: sign ?? this.sign,
      keyfrom: keyfrom ?? this.keyfrom,
      dicts: dicts ?? this.dicts,
    );
  }
}
