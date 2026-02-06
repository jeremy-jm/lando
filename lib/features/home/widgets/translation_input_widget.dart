import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/models/youdao_suggestion.dart';
import 'package:lando/network/api_client.dart';
import 'package:lando/services/suggestion/youdao_suggestion_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Unified translation input widget with language detection display and suggestions.
class TranslationInputWidget extends StatefulWidget {
  const TranslationInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.onSubmitted,
    this.onTap,
    this.detectedLanguage,
    this.readOnly = false,
    this.pronunciationUrl,
    this.onPronunciationTap,
    this.suggestionService,
    this.onSuggestionTap,
    this.enableSuggestions = true,
    this.onNavigateBack,
    this.onNavigateForward,
    this.canNavigateBack = false,
    this.canNavigateForward = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? detectedLanguage;
  final bool readOnly;
  final String? pronunciationUrl;
  final VoidCallback? onPronunciationTap;
  final YoudaoSuggestionService? suggestionService;
  final ValueChanged<String>? onSuggestionTap;
  final bool enableSuggestions;
  final VoidCallback? onNavigateBack;
  final VoidCallback? onNavigateForward;
  final bool canNavigateBack;
  final bool canNavigateForward;

  @override
  State<TranslationInputWidget> createState() => _TranslationInputWidgetState();
}

class _TranslationInputWidgetState extends State<TranslationInputWidget> {
  YoudaoSuggestionService? _suggestionService;
  List<YoudaoSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _isNotFound = false;
  Timer? _debounceTimer;
  Timer? _focusDelayTimer;
  Timer? _suggestionResetTimer;
  Timer? _navigationResetTimer;
  String _lastQuery = '';
  bool _isSelectingSuggestion =
      false; // Flag to prevent re-fetching when selecting a suggestion
  bool _isNavigating =
      false; // Flag to prevent re-fetching suggestions during navigation

  @override
  void initState() {
    super.initState();
    if (widget.enableSuggestions) {
      _suggestionService = widget.suggestionService ??
          YoudaoSuggestionService(
            ApiClient(corsProxyUrl: PreferencesStorage.getCorsProxyUrl()),
          );
    }
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusDelayTimer?.cancel();
    _suggestionResetTimer?.cancel();
    _navigationResetTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (widget.focusNode.hasFocus) {
      // When TextField gains focus, show suggestions if there's text
      _focusDelayTimer?.cancel();
      final query = widget.controller.text.trim();
      if (query.isNotEmpty &&
          widget.enableSuggestions &&
          !widget.readOnly &&
          !_isSelectingSuggestion &&
          !_isNavigating) {
        // If we already have suggestions for this query, show them immediately
        if (_suggestions.isNotEmpty && _lastQuery == query) {
          // Suggestions already loaded, just ensure they're visible
          return;
        }
        // Otherwise, fetch suggestions with a small delay
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 200), () {
          if (mounted &&
              widget.focusNode.hasFocus &&
              widget.controller.text.trim() == query) {
            _fetchSuggestions(query);
          }
        });
      }
    } else {
      // Close suggestions when TextField loses focus
      // Delay to allow suggestion tap to complete first
      if (!_isSelectingSuggestion) {
        _debounceTimer?.cancel();
        _focusDelayTimer?.cancel();
        // Small delay to allow suggestion tap to complete
        _focusDelayTimer = Timer(const Duration(milliseconds: 150), () {
          if (mounted &&
              !widget.focusNode.hasFocus &&
              !_isSelectingSuggestion) {
            _closeSuggestions();
          }
        });
      }
    }
  }

  void _closeSuggestions() {
    _debounceTimer?.cancel();
    if (mounted) {
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
        _isNotFound = false;
      });
    }
  }

  void _onTextChanged() {
    if (!widget.enableSuggestions ||
        widget.readOnly ||
        _isSelectingSuggestion ||
        _isNavigating) {
      return;
    }

    final query = widget.controller.text.trim();

    // Clear suggestions if query is empty
    if (query.isEmpty) {
      _debounceTimer?.cancel();
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
        _isNotFound = false;
      });
      return;
    }

    // Skip if query hasn't changed
    if (query == _lastQuery) {
      return;
    }

    _lastQuery = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce: wait 300ms before fetching suggestions
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().isEmpty || _suggestionService == null) {
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
      _isNotFound = false;
    });

    try {
      final response = await _suggestionService!.getSuggestions(query);
      if (mounted && widget.controller.text.trim() == query) {
        setState(() {
          if (response != null) {
            _suggestions = response.suggestions;
            _isNotFound = response.isNotFound;
          } else {
            _suggestions = [];
            _isNotFound = false;
          }
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
          _isNotFound = false;
        });
      }
    }
  }

  void _onSuggestionTap(YoudaoSuggestion suggestion) {
    final word = suggestion.word;

    // Cancel any pending suggestion requests
    _debounceTimer?.cancel();

    // Set flag to prevent re-fetching suggestions when text changes
    _isSelectingSuggestion = true;

    // Clear suggestions and reset all suggestion-related states first
    setState(() {
      _suggestions = [];
      _isNotFound = false;
      _isLoadingSuggestions = false;
      _lastQuery = word; // Set to current word to prevent re-fetching
    });

    // Update controller text (this will trigger _onTextChanged, but it will be ignored due to _isSelectingSuggestion flag)
    widget.controller.text = word;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: word.length),
    );

    // Reset flag after a delay to allow text change and focus handling to complete
    _suggestionResetTimer?.cancel();
    _suggestionResetTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isSelectingSuggestion = false;
        });
      }
    });

    // Trigger submission - prefer onSuggestionTap, fallback to onSubmitted
    if (widget.onSuggestionTap != null) {
      widget.onSuggestionTap!.call(word);
    } else if (widget.onSubmitted != null) {
      widget.onSubmitted!.call(word);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasText = widget.controller.text.isNotEmpty;
    final showSuggestions = widget.enableSuggestions &&
        !widget.readOnly &&
        _suggestions.isNotEmpty &&
        hasText;
    final showNotFound = widget.enableSuggestions &&
        !widget.readOnly &&
        _isNotFound &&
        hasText &&
        !_isLoadingSuggestions;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDesign.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input field
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              hintText: widget.hintText ??
                  (l10n?.enterTextToTranslate ?? 'Enter text to translate'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusL),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: AppDesign.paddingInput,
            ),
            cursorHeight: AppDesign.inputCursorHeight,
            textInputAction: TextInputAction.search,
            onTap: widget.onTap,
            onSubmitted: widget.onSubmitted,
            minLines: AppDesign.inputMinLines,
            maxLines: AppDesign.inputMaxLines,
          ),

          // Language detection bar
          if (widget.detectedLanguage != null &&
              widget.detectedLanguage!.isNotEmpty &&
              hasText) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDesign.spaceS),
              alignment: Alignment.center,
              height: AppDesign.toolbarHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDesign.radiusM),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppDesign.spaceMd),
                  // Audio and copy icons
                  IconButton(
                    icon: const Icon(AppIcons.volumeUp, size: AppDesign.iconXs),
                    onPressed: widget.onPronunciationTap,
                    tooltip: l10n?.playAudio ?? 'Play audio',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppDesign.spaceMd),
                  IconButton(
                    icon: const Icon(AppIcons.copy, size: AppDesign.iconXs),
                    onPressed: () {
                      if (widget.controller.text.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: widget.controller.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.copiedToClipboard ?? 'Copied to clipboard',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    tooltip: l10n?.copy ?? 'Copy',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  // Navigation bar (back/forward buttons)
                  // Always show navigation bar in query page (when callbacks are provided)
                  if (!widget.readOnly &&
                      (widget.onNavigateBack != null ||
                          widget.onNavigateForward != null))
                    Container(
                      padding: AppDesign.paddingToolbar,
                      height: AppDesign.toolbarHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: AppDesign.alphaDivider,
                            ),
                            width: AppDesign.dividerHeight,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Back button
                          if (widget.onNavigateBack != null)
                            Tooltip(
                              message: l10n?.navigateBack ?? 'Navigate back',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.canNavigateBack
                                      ? () {
                                          _isNavigating = true;
                                          _closeSuggestions();
                                          widget.onNavigateBack?.call();
                                          // Reset navigation flag after a delay to allow text change to complete
                                          _navigationResetTimer?.cancel();
                                          _navigationResetTimer = Timer(
                                            const Duration(milliseconds: 300),
                                            () {
                                              if (mounted) {
                                                setState(() {
                                                  _isNavigating = false;
                                                  // Update _lastQuery to prevent re-fetching
                                                  _lastQuery = widget
                                                      .controller.text
                                                      .trim();
                                                });
                                              }
                                            },
                                          );
                                        }
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(AppDesign.radiusXl),
                                  splashColor: widget.canNavigateBack
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: AppDesign.alphaDivider,
                                        )
                                      : null,
                                  highlightColor: widget.canNavigateBack
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.05,
                                        )
                                      : null,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      AppIcons.backAlt,
                                      size: AppDesign.iconM,
                                      color: widget.canNavigateBack
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Forward button
                          if (widget.onNavigateForward != null) ...[
                            if (widget.onNavigateBack != null)
                              const SizedBox(width: 4),
                            Tooltip(
                              message:
                                  l10n?.navigateForward ?? 'Navigate forward',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.canNavigateForward
                                      ? () {
                                          _isNavigating = true;
                                          _closeSuggestions();
                                          widget.onNavigateForward?.call();
                                          // Reset navigation flag after a delay to allow text change to complete
                                          _navigationResetTimer?.cancel();
                                          _navigationResetTimer = Timer(
                                            const Duration(milliseconds: 300),
                                            () {
                                              if (mounted) {
                                                setState(() {
                                                  _isNavigating = false;
                                                  // Update _lastQuery to prevent re-fetching
                                                  _lastQuery = widget
                                                      .controller.text
                                                      .trim();
                                                });
                                              }
                                            },
                                          );
                                        }
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(AppDesign.radiusXl),
                                  splashColor: widget.canNavigateForward
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: AppDesign.alphaDivider,
                                        )
                                      : null,
                                  highlightColor: widget.canNavigateForward
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.05,
                                        )
                                      : null,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      AppIcons.forward,
                                      size: AppDesign.iconM,
                                      color: widget.canNavigateForward
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  // Language detection label
                  GestureDetector(
                    onTap: () {
                      // Language selection can be triggered here
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(AppDesign.radiusS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${l10n?.detectedAs ?? 'Detected as'}: ',
                            style: TextStyle(
                              fontSize: AppDesign.fontSizeCaption,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: AppDesign.alphaSecondary,
                              ),
                            ),
                          ),
                          Text(
                            widget.detectedLanguage!,
                            style: TextStyle(
                              fontSize: AppDesign.fontSizeCaption,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(AppIcons.clear, size: AppDesign.iconS),
                    onPressed: () {
                      widget.controller.clear();
                      if (widget.focusNode.canRequestFocus) {
                        widget.focusNode.requestFocus();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],

          // Suggestions list
          if (showSuggestions) ...[
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDesign.radiusL),
                    bottomRight: Radius.circular(AppDesign.radiusL),
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDesign.spaceXxs),
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outline
                        .withValues(alpha: AppDesign.alphaDivider),
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () => _onSuggestionTap(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.spaceL,
                          vertical: AppDesign.spaceMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.search,
                              size: AppDesign.iconS,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: AppDesign.alphaTertiary),
                            ),
                            const SizedBox(width: AppDesign.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.word,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (suggestion.explain != null &&
                                      suggestion.explain!.isNotEmpty) ...[
                                    const SizedBox(height: AppDesign.spaceXxs),
                                    Text(
                                      suggestion.explain!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(
                                                alpha: AppDesign.alphaTertiary),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Loading indicator for suggestions
          if (_isLoadingSuggestions && hasText && !widget.readOnly) ...[
            const SizedBox(height: AppDesign.spaceS),
            Container(
              padding: const EdgeInsets.all(AppDesign.spaceMd),
              alignment: Alignment.center,
              child: SizedBox(
                width: AppDesign.iconXs,
                height: AppDesign.iconXs,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],

          // Not found message
          if (showNotFound) ...[
            const SizedBox(height: AppDesign.spaceS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.spaceL,
                vertical: AppDesign.spaceMd,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppDesign.radiusL),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.infoOutline,
                    size: AppDesign.iconS,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: AppDesign.alphaTertiary),
                  ),
                  const SizedBox(width: AppDesign.spaceMd),
                  Expanded(
                    child: Text(
                      l10n?.noSuggestionsFound ??
                          'No suggestions found for your query',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: AppDesign.alphaSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
