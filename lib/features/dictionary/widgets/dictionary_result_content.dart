import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/app_design.dart';
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
    required this.onUsPronunciationTap,
    required this.onUkPronunciationTap,
    required this.onQueryTap,
    required this.onPhrasePronunciationTap,
  });

  final ResultModel result;
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
        // Simple explanation (when no POS)
        if (result.simpleExplanation != null &&
            result.translationsByPos == null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  result.simpleExplanation!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  AppIcons.copy,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  size: AppDesign.iconM,
                ),
                tooltip: l10n?.copy ?? 'Copy',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                onPressed: () async {
                  final text = result.simpleExplanation!;
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.copiedToClipboard ?? 'Copied to clipboard',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12.0),
        ],

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
