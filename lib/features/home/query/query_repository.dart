import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_service.dart';
import 'package:lando/services/translation/translation_service_factory.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/services/translation/youdao_translation_service.dart';

/// Repository responsible for translation queries.
///
/// Acts as a facade over [TranslationService]; no service-specific types
/// (e.g. YoudaoResponse) are exposed. All services return [ResultModel] for
/// detailed results.
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

  /// Queries the translation service with the given [query] and returns
  /// a human-readable summary string.
  Future<String> lookup(String query) async {
    return await translationService.translate(query);
  }

  /// Queries the translation service and returns translation plus optional
  /// pronunciation URLs and a generic [ResultModel] for detailed display.
  ///
  /// Returns: 'translation', 'usPronunciationUrl', 'ukPronunciationUrl',
  /// 'generalPronunciationUrl', 'inputPronunciationUrl', 'detailedResult'.
  /// Pronunciation URLs are only set when the active service supports them
  /// (e.g. Youdao). [detailedResult] is from the active service's
  /// [TranslationService.getDetailedResult].
  Future<Map<String, dynamic>> lookupWithPronunciation(String query) async {
    final translation = await lookup(query);
    final detailedResult =
        await translationService.getDetailedResult(query);

    String? usUrl;
    String? ukUrl;
    String? generalUrl;
    String? inputPronunciationUrl;

    if (translationService is YoudaoTranslationService) {
      final youdaoService = translationService as YoudaoTranslationService;
      try {
        final fullResponse = await youdaoService.translateFull(query);
        final urls = youdaoService.getPronunciationUrls(fullResponse, query);
        usUrl = urls['us'];
        ukUrl = urls['uk'];
        generalUrl = urls['general'];
        inputPronunciationUrl =
            youdaoService.getInputPronunciationUrl(fullResponse, query);
      } catch (_) {
        // Keep translation and detailedResult even if pronunciation fails
      }
    }

    return {
      'translation': translation,
      'usPronunciationUrl': usUrl,
      'ukPronunciationUrl': ukUrl,
      'generalPronunciationUrl': generalUrl,
      'inputPronunciationUrl': inputPronunciationUrl,
      'detailedResult': detailedResult,
    };
  }

  /// Switches to a different translation service.
  QueryRepository withService(TranslationServiceType type) {
    return QueryRepository(serviceType: type, factory: _factory);
  }
}
