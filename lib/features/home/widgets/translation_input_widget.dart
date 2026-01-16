import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Unified translation input widget with language detection display.
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

  @override
  State<TranslationInputWidget> createState() => _TranslationInputWidgetState();
}

class _TranslationInputWidgetState extends State<TranslationInputWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
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
              hintText: widget.hintText ?? 'Enter text to translate',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 7.0,
              ),
            ),
            cursorHeight: 16,
            textInputAction: TextInputAction.search,
            onTap: widget.onTap,
            onSubmitted: widget.onSubmitted,
            onChanged: (_) => setState(() {}),
            minLines: 2,
            maxLines: 6,
          ),

          // Language detection bar
          if (widget.detectedLanguage != null &&
              widget.detectedLanguage!.isNotEmpty &&
              hasText) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 40,
              decoration: BoxDecoration(
                // color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  // Audio and copy icons
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 16),
                    onPressed: widget.onPronunciationTap,
                    tooltip: 'Play audio',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 16),
                    onPressed: () {
                      if (widget.controller.text.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: widget.controller.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    tooltip: 'Copy',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
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
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '识别为 ',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          Text(
                            widget.detectedLanguage!,
                            style: TextStyle(
                              fontSize: 12,
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
                    icon: const Icon(Icons.clear, size: 18),
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
        ],
      ),
    );
  }
}
