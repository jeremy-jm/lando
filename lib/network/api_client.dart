import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? '',
               connectTimeout: connectTimeout ?? const Duration(seconds: 30),
               receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
               headers: {
                 'Accept': '*/*',
                 'User-Agent': 'Lando/1.0.0 (Flutter)',
               },
             ),
           ) {
    // Configure response interceptor for automatic JSON parsing
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // Dio automatically parses JSON, so we just pass it through
          handler.next(response);
        },
        onError: (error, handler) {
          // Convert DioException to a more user-friendly error message
          debugPrint('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;

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
      final response = await _dio.get<Map<String, dynamic>>(
        uri,
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

      final response = await _dio.post<Map<String, dynamic>>(
        uri,
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
      final response = await _dio.post<Map<String, dynamic>>(
        uri,
        data: body,
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

      final response = await _dio.post<Map<String, dynamic>>(
        uri,
        data: formData,
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

  /// Handles DioException and converts it to a more user-friendly error.
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HttpException(
          'Request timeout: ${error.message}',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.badResponse:
        return HttpException(
          'Request failed with status: ${error.response?.statusCode}',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.cancel:
        return HttpException(
          'Request cancelled',
          uri: error.requestOptions.uri,
        );
      case DioExceptionType.unknown:
      default:
        return HttpException(
          'Network error: ${error.message}',
          uri: error.requestOptions.uri,
        );
    }
  }

  /// Dispose resources (closes the underlying Dio instance).
  void dispose() {
    _dio.close();
  }
}
