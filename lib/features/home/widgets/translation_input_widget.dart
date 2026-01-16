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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter text to translate',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      if (widget.focusNode.canRequestFocus) {
                        widget.focusNode.requestFocus();
                      }
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          textInputAction: TextInputAction.search,
          onTap: widget.onTap,
          onSubmitted: widget.onSubmitted,
          onChanged: (_) => setState(() {}),
        ),

        // Language detection bar
        if (widget.detectedLanguage != null &&
            widget.detectedLanguage!.isNotEmpty &&
            hasText) ...[
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                // Audio and copy icons
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  onPressed: widget.onPronunciationTap,
                  tooltip: 'Play audio',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 20),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
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
              ],
            ),
          ),
        ],
      ],
    );
  }
}
