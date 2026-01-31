import 'package:flutter/material.dart';

/// Platform name and optional loading indicator for dictionary card.
class DictionaryPlatformHeader extends StatelessWidget {
  const DictionaryPlatformHeader({
    super.key,
    required this.platformName,
    this.loading = false,
  });

  final String platformName;
  final bool loading;

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
