import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_service.dart';

/// Mock implementation of TranslationService for testing.
class MockTranslationService implements TranslationService {
  MockTranslationService({
    this.mockTranslation,
    this.mockDetailedResult,
    this.mockError,
  });

  final String? mockTranslation;
  final ResultModel? mockDetailedResult;
  final Exception? mockError;

  @override
  String get name => 'Mock';

  @override
  Future<String> translate(String query) async {
    if (mockError != null) {
      throw mockError!;
    }
    return mockTranslation ?? 'Mock translation for: $query';
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    if (mockError != null) {
      throw mockError!;
    }
    return mockDetailedResult;
  }
}
