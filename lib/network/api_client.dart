import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:lando/storage/preferences_storage.dart';

/// A simplified API client wrapper around Dio (similar to axios).
///
/// This class centralizes common logic for GET, POST, and file upload
/// so that the rest of the app only depends on this abstraction.
/// It provides a clean, simple interface similar to axios.
class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    String? corsProxyUrl,
  })  : _corsProxyUrl = corsProxyUrl,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? '',
                connectTimeout: connectTimeout ?? const Duration(seconds: 30),
                receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json, text/plain, */*',
                  'User-Agent':
                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36  ',
                },
              ),
            ) {
    // Configure proxy if enabled (only for non-Web platforms)
    if (!kIsWeb) {
      _configureProxy();
    }

    // Configure response interceptor for automatic JSON parsing
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // Dio automatically parses JSON, so we just pass it through
          handler.next(response);
        },
        onError: (error, handler) {
          // Log error details for debugging
          debugPrint('API Error: ${error.type} - ${error.message}');
          if (error.error != null) {
            debugPrint('Error details: ${error.error}');
          }
          // Always pass the error through so it can be handled by the catch blocks
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final String? _corsProxyUrl;

  /// Configures HTTP proxy for non-Web platforms.
  void _configureProxy() {
    final proxyEnabled = PreferencesStorage.getProxyEnabled();
    if (!proxyEnabled) {
      return;
    }

    final proxyHost = PreferencesStorage.getProxyHost();
    final proxyPort = PreferencesStorage.getProxyPort();

    try {
      // Ensure we're using IOHttpClientAdapter for non-Web platforms
      if (_dio.httpClientAdapter is! IOHttpClientAdapter) {
        _dio.httpClientAdapter = IOHttpClientAdapter();
      }

      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'PROXY $proxyHost:$proxyPort';
        };
        // Allow bad certificates if needed (for development)
        client.badCertificateCallback = (cert, host, port) => false;
        return client;
      };
      debugPrint('Proxy configured: $proxyHost:$proxyPort');
    } catch (e) {
      debugPrint('Failed to configure proxy: $e');
    }
  }

  /// Applies CORS proxy to URL if configured and on Web platform.
  String _applyCorsProxy(String uri) {
    if (!kIsWeb || _corsProxyUrl == null || _corsProxyUrl.isEmpty) {
      return uri;
    }

    // Only apply proxy to external URLs (http/https)
    if (!uri.startsWith('http://') && !uri.startsWith('https://')) {
      return uri;
    }

    // Remove trailing slash from proxy URL if present
    final proxy = _corsProxyUrl.endsWith('/')
        ? _corsProxyUrl.substring(0, _corsProxyUrl.length - 1)
        : _corsProxyUrl;

    return '$proxy/$uri';
  }

  /// Executes a GET request and returns the decoded JSON body.
  ///
  /// [uri] can be a full URL or a path relative to baseUrl.
  /// [headers] are merged with default headers.
  /// [queryParameters] are added as URL query parameters.
  Future<Map<String, dynamic>> getJson(
    String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final finalUri = _applyCorsProxy(uri);
      final response = await _dio.get<Map<String, dynamic>>(
        finalUri,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.data == null) {
        throw const FormatException('Response data is null');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Executes a POST request with form-encoded body and returns JSON.
  ///
  /// [uri] can be a full URL or a path relative to baseUrl.
  /// [body] is sent as application/x-www-form-urlencoded.
  /// [headers] are merged with default headers.
  Future<Map<String, dynamic>> postForm(
    String uri, {
    required Map<String, String> body,
    Map<String, String>? headers,
  }) async {
    try {
      // Convert Map to form-urlencoded string
      final formData = body.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      final finalUri = _applyCorsProxy(uri);
      final response = await _dio.post<Map<String, dynamic>>(
        finalUri,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
            if (headers != null) ...headers,
          },
        ),
      );

      if (response.data == null) {
        throw const FormatException('Response data is null');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      // Catch any other unexpected errors
      debugPrint('Unexpected error in postForm: $e');
      throw HttpException(
        'Unexpected error: ${e.toString()}',
        uri: Uri.tryParse(uri),
      );
    }
  }

  /// Executes a POST request with form-encoded body and returns dynamic JSON.
  ///
  /// Some endpoints (e.g. Bing `ttranslatev3`) return a JSON array, not a map.
  /// On 301/302, follows the Location header and retries the POST once.
  Future<dynamic> postFormDynamic(
    String uri, {
    required Map<String, String> body,
    Map<String, String>? headers,
  }) async {
    final formData = body.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    final baseHeaders = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      if (headers != null) ...headers,
    };

    Future<dynamic> doPost(String url) async {
      final finalUri = _applyCorsProxy(url);
      final response = await _dio.post<dynamic>(
        finalUri,
        data: formData,
        options: Options(
          headers: baseHeaders,
        ),
      );
      return response.data;
    }

    try {
      return await doPost(uri);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if ((status == 301 || status == 302) && e.response != null) {
        final location = e.response!.headers.value('location');
        if (location != null && location.isNotEmpty) {
          final redirectUrl = Uri.parse(uri).resolve(location).toString();
          debugPrint('postFormDynamic: following redirect $status to $redirectUrl');
          try {
            return await doPost(redirectUrl);
          } on DioException catch (e2) {
            if (e2.response != null) {
              debugPrint(
                  'postFormDynamic: DioException - Status ${e2.response!.statusCode}, Data: ${e2.response!.data}');
            }
            throw _handleDioError(e2);
          }
        }
      }
      if (e.response != null) {
        debugPrint(
            'postFormDynamic: DioException - Status ${e.response!.statusCode}, Data: ${e.response!.data}');
      } else {
        debugPrint('postFormDynamic: DioException - ${e.type}: ${e.message}');
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is HttpException) rethrow;
      debugPrint('Unexpected error in postFormDynamic: $e');
      throw HttpException(
        'Unexpected error: ${e.toString()}',
        uri: Uri.tryParse(uri),
      );
    }
  }

  /// Executes a POST request with JSON body and returns JSON.
  ///
  /// [uri] can be a full URL or a path relative to baseUrl.
  /// [body] is sent as application/json.
  /// [headers] are merged with default headers.
  Future<Map<String, dynamic>> postJson(
    String uri, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final finalUri = _applyCorsProxy(uri);
      final response = await _dio.post<Map<String, dynamic>>(
        finalUri,
        data: body,
        options: Options(headers: headers),
      );

      if (response.data == null) {
        throw const FormatException('Response data is null');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      // Catch any other unexpected errors
      debugPrint('Unexpected error in postJson: $e');
      throw HttpException(
        'Unexpected error: ${e.toString()}',
        uri: Uri.tryParse(uri),
      );
    }
  }

  /// Executes a multipart/form-data upload and returns JSON.
  ///
  /// [uri] can be a full URL or a path relative to baseUrl.
  /// [fields] are sent as form fields.
  /// [files] are uploaded as multipart files.
  /// [headers] are merged with default headers.
  Future<Map<String, dynamic>> upload(
    String uri, {
    required Map<String, String> fields,
    required Map<String, File> files,
    Map<String, String>? headers,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        ...files.map(
          (key, file) => MapEntry(
            key,
            MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      });

      final finalUri = _applyCorsProxy(uri);
      final response = await _dio.post<Map<String, dynamic>>(
        finalUri,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.data == null) {
        throw const FormatException('Response data is null');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      // Catch any other unexpected errors
      debugPrint('Unexpected error in upload: $e');
      throw HttpException(
        'Unexpected error: ${e.toString()}',
        uri: Uri.tryParse(uri),
      );
    }
  }

  /// Handles DioException and converts it to a more user-friendly error.
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      debugPrint(
          'DioException: Status ${error.response!.statusCode} - ${error.message}');
    } else {
      debugPrint('DioException: ${error.type} - ${error.message}');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpException(
          'Request timeout: ${error.message ?? 'Connection timed out'}',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.connectionError:
        // Provide a user-friendly message for connection errors
        final errorMessage = error.message ?? 'Unable to connect to the server';
        final isWebError = errorMessage.contains('XMLHttpRequest') ||
            errorMessage.contains('onError callback');

        // On Web, this is almost always a CORS issue
        if (kIsWeb && isWebError) {
          return HttpException(
            'CORS Error: The server does not allow cross-origin requests from web browsers. '
            'This is a browser security restriction. The API server needs to include '
            'CORS headers in its response. Please contact the API provider or use a CORS proxy for development.',
            uri: error.requestOptions.uri,
          );
        }

        return HttpException(
          isWebError
              ? 'Connection error: Unable to connect to the server. Please check your internet connection and try again.'
              : 'Connection error: $errorMessage',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.badResponse:
        return HttpException(
          'Request failed with status: ${error.response?.statusCode ?? 'unknown'}',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.cancel:
        return HttpException(
          'Request cancelled',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.badCertificate:
        return HttpException(
          'SSL certificate error: ${error.message ?? 'Invalid certificate'}',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.unknown:
        return HttpException(
          'Network error: ${error.message ?? 'An unknown error occurred'}',
          uri: error.requestOptions.uri,
        );
    }
  }

  /// Dispose resources (closes the underlying Dio instance).
  void dispose() {
    _dio.close();
  }
}
