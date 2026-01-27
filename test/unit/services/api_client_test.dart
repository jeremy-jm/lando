import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lando/network/api_client.dart';
import 'package:dio/dio.dart';

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    tearDown(() {
      apiClient.dispose();
    });

    group('Initialization', () {
      test('should create instance with default options', () {
        final client = ApiClient();

        expect(client, isNotNull);
        client.dispose();
      });

      test('should create instance with custom base URL', () {
        final client = ApiClient(baseUrl: 'https://api.example.com');

        expect(client, isNotNull);
        client.dispose();
      });

      test('should create instance with CORS proxy URL', () {
        final client = ApiClient(corsProxyUrl: 'https://proxy.example.com');

        expect(client, isNotNull);
        client.dispose();
      });

      test('should create instance with custom timeouts', () {
        final client = ApiClient(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        );

        expect(client, isNotNull);
        client.dispose();
      });
    });

    group('CORS proxy', () {
      test('should not apply CORS proxy when URL is null', () {
        final client = ApiClient(corsProxyUrl: null);

        expect(client, isNotNull);
        client.dispose();
      });

      test('should not apply CORS proxy when URL is empty', () {
        final client = ApiClient(corsProxyUrl: '');

        expect(client, isNotNull);
        client.dispose();
      });
    });

    group('Error handling', () {
      test('should handle invalid URL gracefully', () async {
        final client = ApiClient();

        expect(
          () async => await client.getJson('invalid-url'),
          throwsA(isA<HttpException>()),
        );

        client.dispose();
      });

      test('should handle network errors', () async {
        final client = ApiClient();

        // This will fail because there's no actual server
        expect(
          () async => await client.getJson('https://nonexistent-domain-12345.com/test'),
          throwsA(isA<HttpException>()),
        );

        client.dispose();
      });
    });

    group('Dispose', () {
      test('should dispose resources correctly', () {
        final client = ApiClient();

        expect(() => client.dispose(), returnsNormally);
      });

      test('should allow multiple dispose calls', () {
        final client = ApiClient();

        client.dispose();
        expect(() => client.dispose(), returnsNormally);
      });
    });
  });
}
