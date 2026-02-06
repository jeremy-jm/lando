import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/models/result_model.dart';
import 'package:lando/features/dictionary/widgets/dictionary_pronunciation_button.dart';
import 'package:lando/features/dictionary/widgets/dictionary_part_of_speech_section.dart';
import 'package:lando/features/dictionary/widgets/dictionary_exam_types_section.dart';
import 'package:lando/features/dictionary/widgets/dictionary_word_form_section.dart';
import 'package:lando/features/dictionary/widgets/dictionary_phrases_section.dart';
import 'package:lando/features/dictionary/widgets/dictionary_web_translations_section.dart';

/// Full dictionary result content: query row, pronunciation, sections.
class DictionaryResultContent extends StatelessWidget {
  const DictionaryResultContent({
    super.key,
    required this.result,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onUsPronunciationTap,
    required this.onUkPronunciationTap,
    required this.onQueryTap,
    required this.onPhrasePronunciationTap,
  });

  final ResultModel result;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onUsPronunciationTap;
  final VoidCallback onUkPronunciationTap;
  final ValueChanged<String>? onQueryTap;
  final ValueChanged<String> onPhrasePronunciationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query word + favorite
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                result.query,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isFavorite ? AppIcons.star : AppIcons.starBorder,
                color: isFavorite
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onPressed: onFavoriteTap,
              tooltip: isFavorite
                  ? (l10n?.removedFromFavorites ?? 'Remove from favorites')
                  : (l10n?.addedToFavorites ?? 'Add to favorites'),
            ),
          ],
        ),

        // US/UK pronunciation
        if (result.usPronunciationUrl != null ||
            result.ukPronunciationUrl != null) ...[
          const SizedBox(height: 16.0),
          Row(
            children: [
              if (result.usPronunciationUrl != null)
                DictionaryPronunciationButton(
                  label: 'US',
                  phonetic: result.usPhonetic,
                  onTap: onUsPronunciationTap,
                ),
              if (result.usPronunciationUrl != null &&
                  result.ukPronunciationUrl != null)
                const SizedBox(width: 16.0),
              if (result.ukPronunciationUrl != null)
                DictionaryPronunciationButton(
                  label: 'UK',
                  phonetic: result.ukPhonetic,
                  onTap: onUkPronunciationTap,
                ),
            ],
          ),
        ],

        // Simple explanation (when no POS)
        if (result.simpleExplanation != null &&
            result.translationsByPos == null) ...[
          const SizedBox(height: 12.0),
          Text(
            result.simpleExplanation!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],

        // Part of speech
        if (result.translationsByPos != null &&
            result.translationsByPos!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              height: 0.5),
          const SizedBox(height: 16.0),
          DictionaryPartOfSpeechSection(
            translationsByPos: result.translationsByPos!,
            l10n: l10n,
          ),
        ],

        // Exam types
        if (result.examTypes != null && result.examTypes!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          DictionaryExamTypesSection(types: result.examTypes!),
        ],

        // Word form
        if (result.wordForm != null && result.wordForm!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              height: 0.5),
          const SizedBox(height: 16.0),
          DictionaryWordFormSection(
            wordForm: result.wordForm!,
            l10n: l10n,
            onQueryTap: onQueryTap,
          ),
        ],

        // Phrases
        if (result.phrases != null && result.phrases!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              height: 0.5),
          const SizedBox(height: 16.0),
          DictionaryPhrasesSection(
            phrases: result.phrases!,
            l10n: l10n,
            onQueryTap: onQueryTap,
            onPhrasePronunciationTap: onPhrasePronunciationTap,
          ),
        ],

        // Web translations
        if (result.webTranslations != null &&
            result.webTranslations!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              height: 0.5),
          const SizedBox(height: 16.0),
          DictionaryWebTranslationsSection(
            webTranslations: result.webTranslations!,
            l10n: l10n,
            onQueryTap: onQueryTap,
          ),
        ],
      ],
    );
  }
}
