import 'package:lando/network/api_client.dart';

/// Mock implementation of ApiClient for testing.
class MockApiClient extends ApiClient {
  MockApiClient({
    Map<String, dynamic>? mockGetResponse,
    Map<String, dynamic>? mockPostResponse,
    Exception? mockError,
  })  : _mockGetResponse = mockGetResponse,
        _mockPostResponse = mockPostResponse,
        _mockError = mockError,
        super();

  final Map<String, dynamic>? _mockGetResponse;
  final Map<String, dynamic>? _mockPostResponse;
  final Exception? _mockError;

  @override
  Future<Map<String, dynamic>> getJson(
    String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_mockError != null) {
      throw _mockError;
    }
    return _mockGetResponse ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> postForm(
    String uri, {
    required Map<String, String> body,
    Map<String, String>? headers,
  }) async {
    if (_mockError != null) {
      throw _mockError;
    }
    return _mockPostResponse ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String uri, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    if (_mockError != null) {
      throw _mockError;
    }
    return _mockPostResponse ?? <String, dynamic>{};
  }
}
