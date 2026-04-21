import 'package:flutter/material.dart';

/// Platform name and optional loading indicator for dictionary card.
///
/// When [fallbackName] is provided, a small badge is shown to indicate the
/// result came from a fallback service (e.g., MDict → Youdao).
class DictionaryPlatformHeader extends StatelessWidget {
  const DictionaryPlatformHeader({
    super.key,
    required this.platformName,
    this.loading = false,
    this.fallbackName,
  });

  final String platformName;
  final bool loading;

  /// When non-null, a "via {fallbackName}" badge is shown next to the title.
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          platformName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        if (fallbackName != null) ...[
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'via $fallbackName',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
        if (loading) ...[
          const SizedBox(width: 12.0),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}
