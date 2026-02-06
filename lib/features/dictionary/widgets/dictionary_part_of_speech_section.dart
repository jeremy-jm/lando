import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/features/dictionary/widgets/dictionary_selectable_toolbar.dart';

/// Part of speech section: title + list of name/value rows (selectable).
class DictionaryPartOfSpeechSection extends StatelessWidget {
  const DictionaryPartOfSpeechSection({
    super.key,
    required this.translationsByPos,
    required this.l10n,
  });

  final List<Map<String, String>> translationsByPos;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = l10n?.partOfSpeech ?? 'Part of Speech';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          contextMenuBuilder: (context, editableTextState) =>
              buildDictionarySelectableToolbar(
                  context, editableTextState, l10n),
        ),
        ...translationsByPos.expand((translation) {
          final name = translation['name'] ?? '';
          final value = translation['value'] ?? '';
          return [
            const SizedBox(height: AppDesign.spaceMd),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDesign.spaceS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: SelectableText(
                      name,
                      style: (theme.textTheme.bodyMedium ?? const TextStyle())
                          .copyWith(
                        fontSize: name.contains(':')
                            ? AppDesign.fontSizeBody
                            : (name.length <= 4
                                ? AppDesign.fontSizeCaption
                                : AppDesign.fontSizeBody),
                        fontWeight: name.contains(':')
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                      contextMenuBuilder: (context, editableTextState) =>
                          buildDictionarySelectableToolbar(
                              context, editableTextState, l10n),
                    ),
                  ),
                  const SizedBox(width: AppDesign.spaceL),
                  Expanded(
                    child: SelectableText(
                      value,
                      style: (theme.textTheme.bodyMedium ?? const TextStyle())
                          .copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      contextMenuBuilder: (context, editableTextState) =>
                          buildDictionarySelectableToolbar(
                              context, editableTextState, l10n),
                    ),
                  ),
                ],
              ),
            ),
          ];
        }),
      ],
    );
  }
}
