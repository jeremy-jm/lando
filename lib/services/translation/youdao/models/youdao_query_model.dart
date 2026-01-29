import 'dart:convert';

/// Request body model for the Youdao dict API (dict.youdao.com/jsonapi_s) only.
///
/// Used exclusively by [YoudaoTranslationService]. Do not use for other
/// translation services (Bing, Apple, Google); they have their own request
/// shapes. This model contains Youdao-specific fields (client, keyfrom,
/// sign, dicts, etc.) and must not be passed to or shared with other services.
class YoudaoQueryModel {
  const YoudaoQueryModel({
    required this.q,
    this.t,
    this.client = 'web',
    this.sign,
    this.keyfrom = 'webdict',
    this.dicts,
  });

  /// Query text
  final String q;

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
  /// Does not include [le]; passing [le] to the dict API leads to ec not found.
  Map<String, String> toMap() {
    final map = <String, String>{
      'q': q,
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
    String? t,
    String? client,
    String? sign,
    String? keyfrom,
    List<String>? dicts,
  }) {
    return YoudaoQueryModel(
      q: q ?? this.q,
      t: t ?? this.t,
      client: client ?? this.client,
      sign: sign ?? this.sign,
      keyfrom: keyfrom ?? this.keyfrom,
      dicts: dicts ?? this.dicts,
    );
  }
}
