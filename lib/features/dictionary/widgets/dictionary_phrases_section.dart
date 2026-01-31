import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/features/dictionary/widgets/dictionary_clickable_text.dart';
import 'package:lando/features/dictionary/widgets/dictionary_phrase_pronunciation_button.dart';

/// Phrases section: name (clickable) + pronunciation button + value.
class DictionaryPhrasesSection extends StatelessWidget {
  const DictionaryPhrasesSection({
    super.key,
    required this.phrases,
    required this.l10n,
    required this.onQueryTap,
    required this.onPhrasePronunciationTap,
  });

  final List<Map<String, String>> phrases;
  final AppLocalizations? l10n;
  final ValueChanged<String>? onQueryTap;
  final ValueChanged<String> onPhrasePronunciationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = l10n?.phrases ?? 'Phrases';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12.0),
        ...phrases.map((phrase) {
          final phraseName = phrase['name'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DictionaryClickableText(
                      text: phraseName,
                      onTap: () => onQueryTap?.call(phraseName),
                    ),
                    const SizedBox(width: 8.0),
                    DictionaryPhrasePronunciationButton(
                      onTap: () => onPhrasePronunciationTap(phraseName),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  phrase['value'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
