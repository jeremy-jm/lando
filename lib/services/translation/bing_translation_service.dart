import 'package:lando/models/result_model.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/services/translation/translation_service.dart';

/// Bing translation service implementation.
///
/// Note: This is a placeholder implementation. You'll need to:
/// 1. Obtain Bing Translator API credentials (Azure Cognitive Services)
/// 2. Implement the actual API call based on Bing Translator API documentation
/// 3. Handle authentication (API key)
class BingTranslationService implements TranslationService {
  BingTranslationService(this._apiClient);

  // ignore: unused_field
  final ApiClient _apiClient;

  @override
  String get name => 'Bing';

  @override
  Future<String> translate(String query) async {
    if (query.trim().isEmpty) {
      return '';
    }

    // TODO: Implement Bing Translator API integration
    // Example endpoint: https://api.cognitive.microsofttranslator.com/translate
    // You'll need:
    // - Azure subscription key
    // - Source and target language codes
    // - Proper request format (JSON body)

    // Placeholder implementation
    throw UnimplementedError(
      'Bing Translation Service is not yet implemented. '
      'Please configure Azure Cognitive Services credentials and implement the API call.',
    );
  }

  @override
  Future<ResultModel?> getDetailedResult(String query) async {
    if (query.trim().isEmpty) {
      return null;
    }

    try {
      // TODO: Implement Bing Translator API integration for detailed results
      // For now, return a simple result with just the translation text
      final translation = await translate(query);
      return ResultModel(
        query: query,
        simpleExplanation: translation,
      );
    } catch (e) {
      // Return null on error
      return null;
    }
  }
}
