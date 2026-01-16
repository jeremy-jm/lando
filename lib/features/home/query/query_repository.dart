import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/translation_service_factory.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/services/translation/youdao_translation_service.dart';
import 'package:lando/services/translation/youdao/models/youdao_response.dart';

/// Repository responsible for translation queries.
///
/// This repository acts as a facade over different translation services,
/// allowing the app to switch between Youdao, Google, Bing, etc.
class QueryRepository {
  QueryRepository({
    TranslationService? translationService,
    TranslationServiceType? serviceType,
    TranslationServiceFactory? factory,
  }) : _factory = factory ?? TranslationServiceFactory() {
    _translationService =
        translationService ??
        _factory.create(serviceType ?? TranslationServiceType.youdao);
  }

  final TranslationServiceFactory _factory;
  late final TranslationService _translationService;

  TranslationService get translationService => _translationService;

  /// Queries the translation service with the given [query] text and returns
  /// a human-readable summary string.
  Future<String> lookup(String query) async {
    return await translationService.translate(query);
  }

  /// Queries the translation service and returns translation with pronunciation URLs.
  ///
  /// Returns a map with 'translation', 'usPronunciationUrl', 'ukPronunciationUrl', and 'youdaoResponse' keys.
  Future<Map<String, dynamic>> lookupWithPronunciation(String query) async {
    final translation = await lookup(query);
    
    // For Youdao service, get pronunciation URLs and full response
    String? usUrl;
    String? ukUrl;
    YoudaoResponse? youdaoResponse;
    
    if (translationService is YoudaoTranslationService) {
      final youdaoService = translationService as YoudaoTranslationService;
      try {
        youdaoResponse = await youdaoService.translateFull(query);
        final urls = youdaoService.getPronunciationUrls(youdaoResponse, query);
        usUrl = urls['us'];
        ukUrl = urls['uk'];
      } catch (e) {
        // If getting full response fails, still return translation
      }
    }

    return {
      'translation': translation,
      'usPronunciationUrl': usUrl,
      'ukPronunciationUrl': ukUrl,
      'youdaoResponse': youdaoResponse,
    };
  }

  /// Switches to a different translation service.
  QueryRepository withService(TranslationServiceType type) {
    return QueryRepository(serviceType: type, factory: _factory);
  }
}
