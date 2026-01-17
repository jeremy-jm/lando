import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_repository.dart';
import 'package:lando/features/home/query/query_bloc.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/features/home/widgets/translation_input_widget.dart';
import 'package:lando/features/me/settings_page.dart';
import 'package:lando/features/widgets/dict_widget.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
import 'package:lando/services/translation/translation_service_type.dart';
import 'package:lando/storage/preferences_storage.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  late final QueryBloc _bloc;
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final PronunciationServiceManager _pronunciationManager =
      PronunciationServiceManager();
  String? _detectedLanguage;

  @override
  void initState() {
    super.initState();
    // Default to Youdao service, can be changed later via settings
    _bloc = QueryBloc(
      QueryRepository(serviceType: TranslationServiceType.youdao),
    );
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _controller.addListener(_detectLanguage);
    _detectLanguage();

    // Auto focus and trigger search if initial query is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _bloc.add(QuerySearchSubmitted(widget.initialQuery!));
      }
    });
  }

  void _detectLanguage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _detectedLanguage = null;
      });
      return;
    }

    // Simple language detection (can be improved with ML or API)
    final detected = _simpleLanguageDetection(text);
    setState(() {
      _detectedLanguage = detected;
    });
  }

  String? _simpleLanguageDetection(String text) {
    // Simple heuristic: check for Chinese, Japanese, etc.
    // Returns language code (e.g., 'zh', 'ja', 'hi', 'en') for TTS compatibility
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return 'ja';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return 'hi';
    // Default to English for Latin scripts
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return 'en';
    return 'en'; // Default fallback
  }

  /// Converts language code to display name for UI
  String? _getLanguageDisplayName(String? languageCode) {
    if (languageCode == null) return null;
    switch (languageCode) {
      case 'zh':
        return '中文';
      case 'ja':
        return '日语';
      case 'hi':
        return '印地语';
      case 'en':
        return '英语';
      default:
        return languageCode.toUpperCase();
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _pronunciationManager.dispose();
    super.dispose();
  }

  /// Plays pronunciation for the given text or URL.
  ///
  /// If [url] is provided and the current service is not system TTS,
  /// it will use the URL. Otherwise, it will use system TTS with the [text].
  Future<void> _playPronunciation({
    required String text,
    String? url,
    String? languageCode,
  }) async {
    if (text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pronunciation not available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      await _pronunciationManager.stop();

      // Get current service type to determine if we should use URL or text
      final serviceType = PreferencesStorage.getPronunciationServiceType();
      final isSystemTts = serviceType == null || serviceType == 'system';

      // For system TTS, use text directly. For others, use URL if available.
      final success = await _pronunciationManager.speak(
        text: text,
        languageCode: languageCode,
        url: isSystemTts ? null : url,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error playing pronunciation'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: LanguageSelectorWidget(
          onLanguageChanged: (pair) {
            // Language pair changed, could trigger re-translation if needed
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 18),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search TextField
              StreamBuilder<QueryState>(
                stream: _bloc.stream,
                initialData: _bloc.state,
                builder: (context, snapshot) {
                  final state = snapshot.data ?? _bloc.state;
                  return TranslationInputWidget(
                    controller: _controller,
                    focusNode: _focusNode,
                    hintText: l10n.translation,
                    detectedLanguage: _getLanguageDisplayName(
                      _detectedLanguage,
                    ),
                    pronunciationUrl: state.inputPronunciationUrl,
                    onPronunciationTap: () => _playPronunciation(
                      text: state.query.isNotEmpty
                          ? state.query
                          : _controller.text,
                      url: state.inputPronunciationUrl,
                      languageCode:
                          _detectedLanguage, // Pass language code (e.g., 'zh', 'en')
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _bloc.add(QuerySearchSubmitted(value.trim()));
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24.0),
              // Results area
              Expanded(
                child: StreamBuilder<QueryState>(
                  stream: _bloc.stream,
                  initialData: _bloc.state,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? _bloc.state;

                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                if (state.query.isNotEmpty) {
                                  _bloc.add(QuerySearchSubmitted(state.query));
                                }
                              },
                              child: Text(l10n.translation),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show detailed Youdao result if available (check this first)
                    if (state.youdaoResponse != null) {
                      // // Build fanyi pronunciation URL if available
                      // final fanyi = state.youdaoResponse!.fanyi;
                      // final fanyiPronunciationUrl =
                      //     fanyi?.voice != null && fanyi!.voice!.isNotEmpty
                      //     ? 'https://dict.youdao.com/dictvoice?audio=${fanyi.voice}'
                      //     : null;

                      return DictWidget(
                        query: state.query,
                        platforms: [
                          TranslationServiceType.youdao,
                          // TranslationServiceType.google,
                          // TranslationServiceType.bing,
                        ],
                      );
                    }

                    // Show simple text result if available
                    if (state.result.isNotEmpty) {
                      return SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: SelectableText(
                            state.result,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ),
                      );
                    }

                    // Show empty state if no result
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            l10n.translation,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
