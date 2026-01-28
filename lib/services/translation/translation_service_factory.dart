import 'package:lando/network/api_client.dart';
import 'package:lando/services/translation/apple_translate_service.dart';
import 'package:lando/services/translation/bing_translation_service.dart';
import 'package:lando/services/translation/google_translation_service.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/services/translation/youdao_translation_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Factory class for creating translation service instances.
class TranslationServiceFactory {
  TranslationServiceFactory({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ??
            ApiClient(
              corsProxyUrl: PreferencesStorage.getCorsProxyUrl(),
            );

  final ApiClient _apiClient;

  /// Creates a translation service instance based on the given [type].
  TranslationService create(TranslationServiceType type) {
    switch (type) {
      case TranslationServiceType.youdao:
        return YoudaoTranslationService(_apiClient);
      case TranslationServiceType.google:
        return GoogleTranslationService(_apiClient);
      case TranslationServiceType.bing:
        return BingTranslationService(_apiClient);
      case TranslationServiceType.apple:
        return AppleTranslateService();
    }
  }

  /// Creates all available translation services.
  List<TranslationService> createAll() {
    return [
      create(TranslationServiceType.youdao),
      create(TranslationServiceType.google),
      create(TranslationServiceType.bing),
      create(TranslationServiceType.apple),
    ];
  }
}
