import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/query_history_item.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
import 'package:lando/storage/favorites_storage.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:lando/services/translation/translation_service_factory.dart';
import 'package:lando/services/translation/translation_service_type.dart';

/// A generic dictionary widget that can display results from multiple translation platforms.
///
/// This widget displays results from the specified platforms, with each platform
/// independently fetching and managing its own data. If one platform fails,
/// it doesn't affect other platforms.
class DictWidget extends StatelessWidget {
  const DictWidget({
    super.key,
    required this.query,
    required this.platforms,
    this.translationServiceFactory,
    this.onQueryTap,
  });

  /// The query text to translate.
  final String query;

  /// List of translation platforms to fetch results from.
  final List<TranslationServiceType> platforms;

  /// Optional translation service factory. If not provided, a default one will be created.
  final TranslationServiceFactory? translationServiceFactory;

  /// Callback when a word or phrase is tapped to query.
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
            child: PlatformDictWidget(
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

/// Individual platform dictionary widget that independently fetches and displays data.
///
/// Each platform widget manages its own state (loading, error, result),
/// so failures in one platform don't affect others.
class PlatformDictWidget extends StatefulWidget {
  const PlatformDictWidget({
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
  State<PlatformDictWidget> createState() => _PlatformDictWidgetState();
}

class _PlatformDictWidgetState extends State<PlatformDictWidget> {
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
  void didUpdateWidget(PlatformDictWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.platform != widget.platform) {
      _fetchResult();
    }
  }

  @override
  void dispose() {
    _pronunciationManager.dispose();
    super.dispose();
  }

  /// Extract meaning text from ResultModel.
  String _extractMeaning(ResultModel result) {
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

  /// Toggle favorite status for the current word.
  Future<void> _toggleFavorite(ResultModel result) async {
    if (result.query.trim().isEmpty) {
      return;
    }

    final meaning = _extractMeaning(result);
    if (meaning.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.cannotFavorite ??
                  'Cannot favorite: no translation available',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      if (_isFavorite) {
        // Remove from favorites
        final success = await FavoritesStorage.deleteFavorite(result.query);
        if (success && mounted) {
          setState(() {
            _isFavorite = false;
          });
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.removedFromFavorites ?? 'Removed from favorites',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        // Add to favorites
        final favoriteItem = QueryHistoryItem(
          word: result.query.trim(),
          meaning: meaning,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        final success = await FavoritesStorage.saveFavorite(favoriteItem);
        if (success && mounted) {
          setState(() {
            _isFavorite = true;
          });
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
    if (widget.query.trim().isEmpty) {
      return;
    }

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
        // Check if word is favorited
        final isFav = await FavoritesStorage.isFavorite(widget.query);
        setState(() {
          _result = result;
          _loading = false;
          _error = null;
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _result = null;
        });
      }
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
          // Platform header
          Row(
            children: [
              Text(
                widget.platform.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (_loading) ...[
                const SizedBox(width: 12.0),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16.0),

          // Loading state
          if (_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

          // Error state
          if (_error != null && !_loading)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Result content
          if (_result != null && !_loading)
            _buildResultContent(context, theme, _result!),
        ],
      ),
    );
  }

  Widget _buildResultContent(
    BuildContext context,
    ThemeData theme,
    ResultModel result,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query word with favorite button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                result.query,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onPressed: () => _toggleFavorite(result),
              tooltip: _isFavorite
                  ? (l10n?.removedFromFavorites ?? 'Remove from favorites')
                  : (l10n?.addedToFavorites ?? 'Add to favorites'),
            ),
          ],
        ),

        // Pronunciation
        if (result.usPronunciationUrl != null ||
            result.ukPronunciationUrl != null) ...[
          const SizedBox(height: 16.0),
          Row(
            children: [
              if (result.usPronunciationUrl != null)
                _buildPronunciationButton(
                  context,
                  theme,
                  'US',
                  result.usPronunciationUrl!,
                  result.usPhonetic,
                ),
              if (result.usPronunciationUrl != null &&
                  result.ukPronunciationUrl != null)
                const SizedBox(width: 16.0),
              if (result.ukPronunciationUrl != null)
                _buildPronunciationButton(
                  context,
                  theme,
                  'UK',
                  result.ukPronunciationUrl!,
                  result.ukPhonetic,
                ),
            ],
          ),
        ],

        // Simple explanation
        if (result.simpleExplanation != null &&
            result.translationsByPos == null) ...[
          const SizedBox(height: 12.0),
          Text(
            result.simpleExplanation!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],

        // Translations by part of speech
        if (result.translationsByPos != null &&
            result.translationsByPos!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            height: 0.5,
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n?.partOfSpeech ?? 'Part of Speech',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result.translationsByPos!.expand((translation) {
              return [
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 34,
                      child: _buildClickableText(
                        context,
                        theme,
                        translation['name'] ?? '',
                        onTap: () {
                          widget.onQueryTap?.call(translation['name'] ?? '');
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        translation['value'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ];
            }).toList(),
          ),
        ],

        // Exam types
        if (result.examTypes != null && result.examTypes!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: result.examTypes!.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        // Word forms
        if (result.wordForm != null && result.wordForm!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            height: 0.5,
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n?.tense ?? 'Tense',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.wordForm!.map((wf) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          wf['name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: _buildClickableText(
                          context,
                          theme,
                          wf['value'] ?? '',
                          onTap: () {
                            widget.onQueryTap?.call(wf['name'] ?? '');
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Phrases
        if (result.phrases != null && result.phrases!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            height: 0.5,
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n?.phrases ?? 'Phrases',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.phrases!.map((phrase) {
                final phraseName = phrase['name'] ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildClickableText(
                            context,
                            theme,
                            phraseName,
                            onTap: () {
                              widget.onQueryTap?.call(phraseName);
                            },
                          ),
                          const SizedBox(width: 8.0),
                          _buildPhrasePronunciationButton(
                            context,
                            theme,
                            phraseName,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        phrase['value'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Web translations
        if (result.webTranslations != null &&
            result.webTranslations!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            height: 0.5,
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n?.webTranslations ?? 'Web Translations',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.webTranslations!.map((webTrans) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClickableText(
                        context,
                        theme,
                        '${webTrans['name'] ?? ''}: ',
                        onTap: () {
                          widget.onQueryTap?.call(webTrans['name'] ?? '');
                        },
                      ),
                      Expanded(
                        child: Text(
                          webTrans['value'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPronunciationButton(
    BuildContext context,
    ThemeData theme,
    String label,
    String url,
    String? phonetic,
  ) {
    return InkWell(
      onTap: () async {
        if (!mounted) return;

        try {
          await _pronunciationManager.stop();

          // Get current service type to determine if we should use URL or text
          final serviceType = PreferencesStorage.getPronunciationServiceType();
          final isSystemTts = serviceType == null || serviceType == 'system';

          // For system TTS, use text directly. For others, use URL.
          final success = await _pronunciationManager.speak(
            text: widget.query,
            languageCode: null, // Could be extracted from result if needed
            url: isSystemTts ? null : url,
          );

          if (!mounted) return;

          if (!success) {
            if (!mounted) return;
            final l10n = AppLocalizations.of(context);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.errorPlayingPronunciation ??
                      'Error playing pronunciation',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;

          final l10n = AppLocalizations.of(context);
          if (!mounted) return;
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
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8.0),
            if (phonetic != null && phonetic.isNotEmpty) ...[
              Text(
                '/$phonetic/',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8.0),
            ],
            Icon(Icons.volume_up, size: 20, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// Builds a clickable text widget with primary color styling.
  Widget _buildClickableText(
    BuildContext context,
    ThemeData theme,
    String text, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: text.contains(':') ? 14 : (text.length <= 4 ? 12 : 14),
            fontWeight: text.contains(':') ? FontWeight.w600 : FontWeight.w500,
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// Builds a pronunciation button for phrases.
  Widget _buildPhrasePronunciationButton(
    BuildContext context,
    ThemeData theme,
    String phrase,
  ) {
    return InkWell(
      onTap: () async {
        if (!mounted) return;

        try {
          await _pronunciationManager.stop();

          // Build pronunciation URL for the phrase
          String? pronunciationUrl;
          if (widget.platform == TranslationServiceType.youdao) {
            // Get language code from preferences and map to Youdao format
            final languageCode = PreferencesStorage.getTranslationToLanguage();
            String le;
            if (languageCode == null || languageCode == 'auto') {
              le = 'auto';
            } else {
              final code = languageCode.toLowerCase();
              le = code == 'en' ? 'eng' : code;
            }

            final encodedPhrase = Uri.encodeComponent(phrase);

            // Build URL based on language
            if (le == 'eng') {
              pronunciationUrl =
                  'https://dict.youdao.com/dictvoice?audio=$encodedPhrase&le=$le&type=2';
            } else {
              pronunciationUrl =
                  'https://dict.youdao.com/dictvoice?audio=$encodedPhrase&le=$le';
            }
          }

          // Get current service type to determine if we should use URL or text
          final serviceType = PreferencesStorage.getPronunciationServiceType();
          final isSystemTts = serviceType == null || serviceType == 'system';

          // For system TTS, use text directly. For others, use URL.
          final success = await _pronunciationManager.speak(
            text: phrase,
            languageCode: null,
            url: isSystemTts ? null : pronunciationUrl,
          );

          if (!mounted) return;

          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.errorPlayingPronunciation ??
                      'Error playing pronunciation',
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
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          Icons.volume_up,
          size: 16,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
