import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
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
            padding: const EdgeInsets.only(bottom: AppDesign.spaceXl),
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

  /// True when MDict returned no result and we fell back to Youdao.
  bool _isMdictFallback = false;
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

  Future<void> _fetchResult() async {
    if (widget.query.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _isMdictFallback = false;
    });

    final factory =
        widget.translationServiceFactory ?? TranslationServiceFactory();

    try {
      final service = factory.create(widget.platform);
      final result = await service.getDetailedResult(widget.query);

      // MDict returned no result → fall back to Youdao
      if (result == null && widget.platform == TranslationServiceType.mdict) {
        await _fetchFallback(factory);
        return;
      }

      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
          _error = result == null
              ? 'No translation result available from ${widget.platform.displayName}'
              : null;
        });
      }
    } catch (e) {
      debugPrint('[DictionaryWidget] ${widget.platform.displayName} error: $e');
      // MDict threw an exception → fall back to Youdao
      if (widget.platform == TranslationServiceType.mdict) {
        await _fetchFallback(factory);
        return;
      }
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

  /// Fallback: fetch from Youdao when MDict has no result.
  Future<void> _fetchFallback(TranslationServiceFactory factory) async {
    debugPrint(
        '[DictionaryWidget] MDict has no result, falling back to Youdao');
    try {
      final fallback = factory.create(TranslationServiceType.youdao);
      final result = await fallback.getDetailedResult(widget.query);
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
          _isMdictFallback = result != null;
          _error = result == null
              ? 'No translation result available from ${widget.platform.displayName}'
              : null;
        });
      }
    } catch (e) {
      debugPrint('[DictionaryWidget] Youdao fallback also failed: $e');
      if (mounted) {
        setState(() {
          _error =
              'Failed to fetch translation from ${widget.platform.displayName}: ${e.toString()}';
          _loading = false;
          _result = null;
          _isMdictFallback = false;
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

  Future<void> _playHeadwordPronunciation() async {
    if (!mounted) return;
    try {
      await _pronunciationManager.stop();
      final success = await _pronunciationManager.speak(
        text: widget.query,
        languageCode: null,
        url: null,
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

      final languageCode = _detectLanguageCode(phrase);
      final success = await _pronunciationManager.speak(
        text: phrase,
        languageCode: languageCode,
        url: null,
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
      padding: AppDesign.paddingCard,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDesign.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DictionaryPlatformHeader(
            platformName: widget.platform.displayName,
            loading: _loading,
            fallbackName: _isMdictFallback
                ? TranslationServiceType.youdao.displayName
                : null,
          ),
          const SizedBox(height: AppDesign.spaceL),
          if (_loading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDesign.spaceXl),
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
              onUsPronunciationTap: _playHeadwordPronunciation,
              onUkPronunciationTap: _playHeadwordPronunciation,
              onQueryTap: widget.onQueryTap,
              onPhrasePronunciationTap: _playPhrasePronunciation,
            ),
        ],
      ),
    );
  }
}
