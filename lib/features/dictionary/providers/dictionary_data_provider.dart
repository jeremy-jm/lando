import 'package:lando/models/query_history_item.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/translation/translation_service_factory.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/storage/favorites_storage.dart';

/// Data provider for dictionary results.
///
/// This class handles data fetching and state management,
/// separating data logic from UI presentation.
class DictionaryDataProvider {
  DictionaryDataProvider({
    TranslationServiceFactory? translationServiceFactory,
  }) : _translationServiceFactory =
            translationServiceFactory ?? TranslationServiceFactory();

  final TranslationServiceFactory _translationServiceFactory;

  /// Fetches dictionary result for a query from a specific platform.
  ///
  /// Returns a [DictionaryResult] containing the result, loading state,
  /// error message, and favorite status.
  Future<DictionaryResult> fetchResult({
    required String query,
    required TranslationServiceType platform,
  }) async {
    if (query.trim().isEmpty) {
      return DictionaryResult(
        result: null,
        isLoading: false,
        error: null,
        isFavorite: false,
      );
    }

    try {
      final service = _translationServiceFactory.create(platform);
      final result = await service.getDetailedResult(query);

      // Check if word is favorited
      final isFavorite = await FavoritesStorage.isFavorite(query);

      return DictionaryResult(
        result: result,
        isLoading: false,
        error: null,
        isFavorite: isFavorite,
      );
    } catch (e) {
      return DictionaryResult(
        result: null,
        isLoading: false,
        error: e.toString(),
        isFavorite: false,
      );
    }
  }

  /// Toggles favorite status for a word.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> toggleFavorite({
    required String word,
    required String meaning,
    required bool currentFavoriteStatus,
  }) async {
    if (word.trim().isEmpty || meaning.isEmpty) {
      return false;
    }

    try {
      if (currentFavoriteStatus) {
        return await FavoritesStorage.deleteFavorite(word);
      } else {
        final favoriteItem = QueryHistoryItem(
          word: word.trim(),
          meaning: meaning,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        return await FavoritesStorage.saveFavorite(favoriteItem);
      }
    } catch (e) {
      return false;
    }
  }

  /// Extracts meaning text from ResultModel.
  String extractMeaning(ResultModel result) {
    // Priority 1: simpleExplanation
    if (result.simpleExplanation != null &&
        result.simpleExplanation!.isNotEmpty) {
      return result.simpleExplanation!;
    }

    // Priority 2: translationsByPos
    if (result.translationsByPos != null &&
        result.translationsByPos!.isNotEmpty) {
      final meanings = result.translationsByPos!
          .map((t) => '${t['name'] ?? ''} ${t['value'] ?? ''}')
          .where((s) => s.trim().isNotEmpty)
          .join('; ');
      if (meanings.isNotEmpty) {
        return meanings;
      }
    }

    // Priority 3: webTranslations
    if (result.webTranslations != null && result.webTranslations!.isNotEmpty) {
      final meanings = result.webTranslations!
          .map((t) => '${t['key'] ?? ''} ${t['value'] ?? ''}')
          .where((s) => s.trim().isNotEmpty)
          .join('; ');
      if (meanings.isNotEmpty) {
        return meanings;
      }
    }

    // Fallback: return empty string
    return '';
  }
}

/// Result data class for dictionary queries.
class DictionaryResult {
  const DictionaryResult({
    required this.result,
    required this.isLoading,
    required this.error,
    required this.isFavorite,
  });

  final ResultModel? result;
  final bool isLoading;
  final String? error;
  final bool isFavorite;
}
