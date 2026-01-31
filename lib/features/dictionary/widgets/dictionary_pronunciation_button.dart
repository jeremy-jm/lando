import 'package:flutter/material.dart';

/// US/UK pronunciation button (label + optional phonetic + volume icon).
class DictionaryPronunciationButton extends StatelessWidget {
  const DictionaryPronunciationButton({
    super.key,
    required this.label,
    this.phonetic,
    required this.onTap,
  });

  final String label;
  final String? phonetic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
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
            if (phonetic != null && phonetic!.isNotEmpty) ...[
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
