import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_repository.dart';
import 'package:lando/features/home/query/query_bloc.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/features/home/widgets/translation_input_widget.dart';
import 'package:lando/features/me/settings_page.dart';
import 'package:lando/features/dictionary/widgets/dictionary_widget.dart';
import 'package:lando/features/home/providers/query_history_provider.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
import 'package:lando/services/translation/translation_language_resolver.dart';
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
  final QueryHistoryProvider _historyProvider = QueryHistoryProvider();
  String? _detectedLanguage;
  bool _isNavigating =
      false; // Flag to prevent adding to history during navigation
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Default to Youdao service, can be changed later via settings
    _bloc = QueryBloc(
      QueryRepository(serviceType: TranslationServiceType.youdao),
    );
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _controller.addListener(() => _detectLanguage());
    _detectLanguage();

    // Listen to window visibility changes (for desktop platforms)
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // WindowVisibilityService.instance.windowShownNotifier.addListener(
      //     _onWindowShown,
      //     );
    }

    // Auto focus and trigger search if initial query is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
          final trimmedQuery = widget.initialQuery!.trim();
          // Close suggestions by unfocusing first, then trigger search after a short delay
          // This ensures the suggestion list is closed before the query is triggered
          _focusNode.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!_isDisposed && mounted) {
              _historyProvider.addQuery(trimmedQuery);
              _bloc.add(QuerySearchSubmitted(trimmedQuery));
              if (mounted) {
                setState(() {}); // Update button states
              }
            }
          });
        } else {
          // Only request focus if there's no initial query
          _focusNode.requestFocus();
        }
      }
    });
  }

  /// Handle window shown/focused event
  /// Selects all text in the input field when window is shown via hotkey
  // void _onWindowShown() {
  //   if (_isDisposed || !mounted) return;

  //   // Small delay to ensure focus is set
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_isDisposed || !mounted) return;

  //     // Check if the input field has focus
  //     if (_focusNode.hasFocus) {
  //       // Select all text in the input field
  //       _controller.selection = TextSelection(
  //         baseOffset: 0,
  //         extentOffset: _controller.text.length,
  //       );
  //     } else {
  //       // Request focus first, then select text
  //       _focusNode.requestFocus();
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (_isDisposed || !mounted) return;
  //         _controller.selection = TextSelection(
  //           baseOffset: 0,
  //           extentOffset: _controller.text.length,
  //         );
  //       });
  //     }
  //   });
  // }

  void _handleNavigateBack() {
    final previousQuery = _historyProvider.goBack();
    if (previousQuery != null && mounted) {
      _isNavigating = true; // Set flag to prevent adding to history
      _controller.text = previousQuery;
      _detectLanguage(); // Update detected language
      _bloc.add(QuerySearchSubmitted(previousQuery));
      if (mounted) {
        setState(() {
          _isNavigating = false; // Reset flag after state update
        }); // Update button states
      }
    }
  }

  void _handleNavigateForward() {
    final nextQuery = _historyProvider.goForward();
    if (nextQuery != null && mounted) {
      _isNavigating = true; // Set flag to prevent adding to history
      _controller.text = nextQuery;
      _detectLanguage(); // Update detected language
      _bloc.add(QuerySearchSubmitted(nextQuery));
      if (mounted) {
        setState(() {
          _isNavigating = false; // Reset flag after state update
        }); // Update button states
      }
    }
  }

  void _handleQuerySubmitted(String query) {
    if (query.trim().isNotEmpty) {
      final trimmedQuery = query.trim();
      // Only add to history if not navigating and it's different from current query
      if (!_isNavigating && !_historyProvider.isCurrentQuery(trimmedQuery)) {
        _historyProvider.addQuery(trimmedQuery);
      }
      _bloc.add(QuerySearchSubmitted(trimmedQuery));
      if (mounted) {
        setState(() {}); // Update button states
      }
    }
  }

  void _detectLanguage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (mounted) {
        setState(() {
          _detectedLanguage = null;
        });
      }
      return;
    }

    // Use language resolver for consistent detection
    final languagePair =
        await TranslationLanguageResolver.instance.resolveLanguages(text);
    if (mounted) {
      setState(() {
        _detectedLanguage = languagePair.detectedSourceLanguage;
      });
    }
  }

  /// Converts language code to display name for UI
  String? _getLanguageDisplayName(String? languageCode) {
    if (languageCode == null) return null;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return languageCode.toUpperCase();
    }

    switch (languageCode) {
      case 'zh':
        return l10n.chinese;
      case 'ja':
        return l10n.japanese;
      case 'hi':
        return l10n.hindi;
      case 'en':
        return l10n.english;
      case 'id':
        return l10n.indonesian;
      case 'pt':
        return l10n.portuguese;
      case 'ru':
        return l10n.russian;
      default:
        return languageCode.toUpperCase();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Remove window visibility listener
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // WindowVisibilityService.instance.windowShownNotifier.removeListener(
      //   _onWindowShown,
      // );
    }

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
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n?.pronunciationNotAvailable ?? 'Pronunciation not available',
            ),
            duration: const Duration(seconds: 2),
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
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n?.errorPlayingPronunciation ?? 'Error playing pronunciation',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context);
        if (!mounted) return;
        messenger.showSnackBar(
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
              // Search TextField with navigation
              Builder(
                builder: (context) {
                  return StreamBuilder<QueryState>(
                    stream: _bloc.stream,
                    initialData: _bloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data ?? _bloc.state;
                      return TranslationInputWidget(
                        controller: _controller,
                        focusNode: _focusNode,
                        hintText: l10n.enterTextToTranslate,
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
                        onSubmitted: _handleQuerySubmitted,
                        onSuggestionTap: (word) {
                          // Auto-trigger query when suggestion is tapped
                          if (word.trim().isNotEmpty) {
                            final trimmedWord = word.trim();
                            if (!_historyProvider.isCurrentQuery(trimmedWord)) {
                              _historyProvider.addQuery(trimmedWord);
                            }
                            _bloc.add(QuerySearchSubmitted(trimmedWord));
                            setState(() {}); // Update button states
                          }
                        },
                        onNavigateBack: _handleNavigateBack,
                        onNavigateForward: _handleNavigateForward,
                        canNavigateBack: _historyProvider.canGoBack,
                        canNavigateForward: _historyProvider.canGoForward,
                      );
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

                    // Show dictionary (multi-platform) when we have a query.
                    // Each platform fetches via getDetailedResult(query); no
                    // service-specific types (e.g. YoudaoResponse) in UI.
                    if (state.query.isNotEmpty) {
                      return DictionaryWidget(
                        query: state.query,
                        platforms: [
                          TranslationServiceType.youdao,
                          TranslationServiceType.bing,
                          if (Platform.isIOS || Platform.isMacOS)
                            TranslationServiceType.apple,
                        ],
                        onQueryTap: (queryText) {
                          _controller.text = queryText;
                          _bloc.add(QuerySearchSubmitted(queryText));
                        },
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
