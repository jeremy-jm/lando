import 'package:flutter/material.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/audio/pronunciation_service.dart';
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
  });

  /// The query text to translate.
  final String query;

  /// List of translation platforms to fetch results from.
  final List<TranslationServiceType> platforms;

  /// Optional translation service factory. If not provided, a default one will be created.
  final TranslationServiceFactory? translationServiceFactory;

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
  });

  final String query;
  final TranslationServiceType platform;
  final TranslationServiceFactory? translationServiceFactory;

  @override
  State<PlatformDictWidget> createState() => _PlatformDictWidgetState();
}

class _PlatformDictWidgetState extends State<PlatformDictWidget> {
  ResultModel? _result;
  String? _error;
  bool _loading = false;
  final PronunciationService _pronunciationService = PronunciationService();

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
    _pronunciationService.dispose();
    super.dispose();
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
        setState(() {
          _result = result;
          _loading = false;
          _error = null;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query word
        Text(
          result.query,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
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
            '词性',
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
                      width: 20,
                      child: Text(
                        translation['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
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
            '时态',
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
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          wf['value'] ?? '',
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

        // Phrases
        if (result.phrases != null && result.phrases!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            height: 0.5,
          ),
          const SizedBox(height: 16.0),
          Text(
            '短语',
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phrase['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
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
            '网络翻译',
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
                      Text(
                        '${webTrans['name'] ?? ''}: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
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
        try {
          await _pronunciationService.stop();
          await _pronunciationService.play(url);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error playing pronunciation: $e'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
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
}
