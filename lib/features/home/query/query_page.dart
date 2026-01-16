import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_repository.dart';
import 'package:lando/features/home/query/query_bloc.dart';
import 'package:lando/features/home/query/widgets/youdao_result_widget.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/features/home/widgets/translation_input_widget.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/audio/pronunciation_service.dart';
import 'package:lando/services/translation/translation_service_type.dart';

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
  final PronunciationService _pronunciationService = PronunciationService();
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
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return '中文';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return '日语';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return '印地语';
    // Default to English for Latin scripts
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return '英语';
    return '英语'; // Default fallback
  }

  @override
  void dispose() {
    _bloc.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _pronunciationService.dispose();
    super.dispose();
  }

  Future<void> _playPronunciation(String? url) async {
    if (url == null || url.isEmpty) {
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(l10n.translation),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    detectedLanguage: _detectedLanguage,
                    pronunciationUrl: state.inputPronunciationUrl,
                    onPronunciationTap: state.inputPronunciationUrl != null
                        ? () => _playPronunciation(state.inputPronunciationUrl)
                        : null,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _bloc.add(QuerySearchSubmitted(value.trim()));
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              // Language selector
              LanguageSelectorWidget(
                onLanguageChanged: (pair) {
                  // Language pair changed, could trigger re-translation if needed
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
                      // Build fanyi pronunciation URL if available
                      final fanyi = state.youdaoResponse!.fanyi;
                      final fanyiPronunciationUrl =
                          fanyi?.voice != null && fanyi!.voice!.isNotEmpty
                          ? 'https://dict.youdao.com/dictvoice?audio=${fanyi.voice}'
                          : null;

                      return YoudaoResultWidget(
                        response: state.youdaoResponse!,
                        query: state.query,
                        onUsPronunciationTap: state.usPronunciationUrl != null
                            ? () => _playPronunciation(state.usPronunciationUrl)
                            : null,
                        onUkPronunciationTap: state.ukPronunciationUrl != null
                            ? () => _playPronunciation(state.ukPronunciationUrl)
                            : null,
                        onGeneralPronunciationTap:
                            state.generalPronunciationUrl != null
                            ? () => _playPronunciation(
                                state.generalPronunciationUrl,
                              )
                            : null,
                        onFanyiPronunciationTap: fanyiPronunciationUrl != null
                            ? () => _playPronunciation(fanyiPronunciationUrl)
                            : null,
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
