import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
import 'package:lando/storage/favorites_storage.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:lando/services/translation/translation_service_factory.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/features/dictionary/widgets/dictionary_platform_header.dart';
import 'package:lando/features/dictionary/widgets/dictionary_error_banner.dart';
import 'package:lando/features/dictionary/widgets/dictionary_result_content.dart';

/// Dictionary widget that displays results from multiple platforms.
/// Each platform fetches independently; one failure does not affect others.
class DictionaryWidget extends StatelessWidget {
  const DictionaryWidget({
    super.key,
    required this.query,
    required this.platforms,
    this.translationServiceFactory,
    this.onQueryTap,
  });

  final String query;
  final List<TranslationServiceType> platforms;
  final TranslationServiceFactory? translationServiceFactory;
  final ValueChanged<String>? onQueryTap;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: platforms.map((platform) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: PlatformDictionaryWidget(
              key: ValueKey('$platform-$query'),
              query: query,
              platform: platform,
              translationServiceFactory: translationServiceFactory,
              onQueryTap: onQueryTap,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Single-platform dictionary card: fetches and displays one platform's result.
class PlatformDictionaryWidget extends StatefulWidget {
  const PlatformDictionaryWidget({
    super.key,
    required this.query,
    required this.platform,
    this.translationServiceFactory,
    this.onQueryTap,
  });

  final String query;
  final TranslationServiceType platform;
  final TranslationServiceFactory? translationServiceFactory;
  final ValueChanged<String>? onQueryTap;

  @override
  State<PlatformDictionaryWidget> createState() =>
      _PlatformDictionaryWidgetState();
}

class _PlatformDictionaryWidgetState extends State<PlatformDictionaryWidget> {
  ResultModel? _result;
  String? _error;
  bool _loading = false;
  bool _isFavorite = false;
  final PronunciationServiceManager _pronunciationManager =
      PronunciationServiceManager();

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  @override
  void didUpdateWidget(PlatformDictionaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query || oldWidget.platform != widget.platform) {
      _fetchResult();
    }
  }

  @override
  void dispose() {
    _pronunciationManager.dispose();
    super.dispose();
  }

  static String _extractMeaning(ResultModel result) {
    if (result.simpleExplanation != null &&
        result.simpleExplanation!.isNotEmpty) {
      return result.simpleExplanation!;
    }
    if (result.translationsByPos != null &&
        result.translationsByPos!.isNotEmpty) {
      final meanings = result.translationsByPos!
          .map((t) => '${t['name'] ?? ''} ${t['value'] ?? ''}')
          .where((s) => s.trim().isNotEmpty)
          .join('; ');
      if (meanings.isNotEmpty) return meanings;
    }
    if (result.webTranslations != null && result.webTranslations!.isNotEmpty) {
      final meanings = result.webTranslations!
          .map((t) => '${t['key'] ?? ''} ${t['value'] ?? ''}')
          .where((s) => s.trim().isNotEmpty)
          .join('; ');
      if (meanings.isNotEmpty) return meanings;
    }
    return '';
  }

  Future<void> _toggleFavorite(ResultModel result) async {
    if (result.query.trim().isEmpty) return;
    final meaning = _extractMeaning(result);
    if (meaning.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.cannotFavorite ?? 'Cannot favorite: no translation available',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      if (_isFavorite) {
        final success = await FavoritesStorage.deleteFavorite(result.query);
        if (success && mounted) {
          setState(() => _isFavorite = false);
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.removedFromFavorites ?? 'Removed from favorites'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        final item = QueryHistoryItem(
          word: result.query.trim(),
          meaning: meaning,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        final success = await FavoritesStorage.saveFavorite(item);
        if (success && mounted) {
          setState(() => _isFavorite = true);
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.addedToFavorites ?? 'Added to favorites'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorWithDetails(e.toString()) ?? 'Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _fetchResult() async {
    if (widget.query.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final factory =
          widget.translationServiceFactory ?? TranslationServiceFactory();
      final service = factory.create(widget.platform);
      final result = await service.getDetailedResult(widget.query);

      if (mounted) {
        final isFav = await FavoritesStorage.isFavorite(widget.query);
        setState(() {
          _result = result;
          _loading = false;
          _error = result == null
              ? 'No translation result available from ${widget.platform.displayName}'
              : null;
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Failed to fetch translation from ${widget.platform.displayName}: ${e.toString()}';
          _loading = false;
          _result = null;
        });
      }
    }
  }

  static String? _detectLanguageCode(String text) {
    if (text.trim().isEmpty) return null;
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return 'ja';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return 'hi';
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return 'en';
    return 'en';
  }

  Future<void> _playUrlPronunciation(String? url) async {
    if (!mounted) return;
    try {
      await _pronunciationManager.stop();
      final serviceType = PreferencesStorage.getPronunciationServiceType();
      final isSystemTts = serviceType == null || serviceType == 'system';
      final success = await _pronunciationManager.speak(
        text: widget.query,
        languageCode: null,
        url: isSystemTts ? null : url,
      );
      if (!mounted) return;
      if (!success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.errorPlayingPronunciation ?? 'Error playing pronunciation',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.errorPlayingPronunciationWithDetails(e.toString()) ??
                'Error playing pronunciation: $e',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _playPhrasePronunciation(String phrase) async {
    if (!mounted) return;
    try {
      await _pronunciationManager.stop();

      String? pronunciationUrl;
      if (widget.platform == TranslationServiceType.youdao) {
        final detectedLang = PreferencesStorage.getTranslationToLanguage();
        String le;
        if (detectedLang == null || detectedLang == 'auto') {
          final phraseLang = _detectLanguageCode(phrase);
          if (phraseLang != null) {
            final code = phraseLang.toLowerCase();
            le = code == 'en' ? 'eng' : code;
          } else {
            le = 'auto';
          }
        } else {
          final code = detectedLang.toLowerCase();
          le = code == 'en' ? 'eng' : code;
        }
        final encoded = Uri.encodeComponent(phrase);
        pronunciationUrl = le == 'eng'
            ? 'https://dict.youdao.com/dictvoice?audio=$encoded&le=$le&type=2'
            : 'https://dict.youdao.com/dictvoice?audio=$encoded&le=$le';
      }

      final serviceType = PreferencesStorage.getPronunciationServiceType();
      final isSystemTts = serviceType == null || serviceType == 'system';
      final languageCode = _detectLanguageCode(phrase);
      final success = await _pronunciationManager.speak(
        text: phrase,
        languageCode: languageCode,
        url: isSystemTts ? null : pronunciationUrl,
      );

      if (!mounted) return;
      if (!success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.errorPlayingPronunciation ?? 'Error playing pronunciation',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.errorPlayingPronunciationWithDetails(e.toString()) ??
                'Error playing pronunciation: $e',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DictionaryPlatformHeader(
            platformName: widget.platform.displayName,
            loading: _loading,
          ),
          const SizedBox(height: 16.0),

          if (_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

          if (_error != null && !_loading)
            DictionaryErrorBanner(message: _error!),

          if (_result != null && !_loading)
            DictionaryResultContent(
              result: _result!,
              isFavorite: _isFavorite,
              onFavoriteTap: () => _toggleFavorite(_result!),
              onUsPronunciationTap: () =>
                  _playUrlPronunciation(_result!.usPronunciationUrl),
              onUkPronunciationTap: () =>
                  _playUrlPronunciation(_result!.ukPronunciationUrl),
              onQueryTap: widget.onQueryTap,
              onPhrasePronunciationTap: _playPhrasePronunciation,
            ),
        ],
      ),
    );
  }
}
