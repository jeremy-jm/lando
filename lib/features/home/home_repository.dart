import 'dart:convert';

import 'package:lando/network/api_client.dart';

/// Repository responsible for interacting with the Youdao dictionary API.
class HomeRepository {
  HomeRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Queries the Youdao API with the given [query] text and returns
  /// a human-readable summary string.
  Future<String> lookup(String query) async {
    if (query.trim().isEmpty) {
      return '';
    }

    const endpoint =
        'https://dict.youdao.com/jsonapi_s?doctype=json&jsonversion=4';

    // These fields are based on the provided curl example.
    final body = <String, String>{
      'client': 'web',
      'keyfrom': 'webdict',
      'le': 'en',
      'q': query,
      // In the example, sign and t are provided. In a real application
      // you might need to compute sign. Here we send minimal parameters
      // to get a reasonable response.
    };

    final json = await _apiClient.postForm(endpoint, body: body);

    // The actual shape of the Youdao response can be complex. For now,
    // we try to extract some commonly used fields and fall back to raw JSON.
    final basic = json['ec']?['word']?[0]?['trs']?[0]?['tr']?[0]?['l']?['i'];
    if (basic is List && basic.isNotEmpty) {
      return basic.join('; ');
    }

    // Fallback: return a compact JSON string so user can see something.
    return const JsonEncoder.withIndent('  ').convert(json);
  }
}

