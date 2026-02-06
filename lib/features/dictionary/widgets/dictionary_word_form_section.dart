import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/features/dictionary/widgets/dictionary_clickable_text.dart';

/// Word form (tense) section: name + value, tap to query.
class DictionaryWordFormSection extends StatelessWidget {
  const DictionaryWordFormSection({
    super.key,
    required this.wordForm,
    required this.l10n,
    required this.onQueryTap,
  });

  final List<Map<String, String>> wordForm;
  final AppLocalizations? l10n;
  final ValueChanged<String>? onQueryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = l10n?.tense ?? 'Tense';
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
        const SizedBox(height: AppDesign.spaceMd),
        ...wordForm.map((wf) {
          final name = wf['name'] ?? '';
          final value = wf['value'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDesign.spaceS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: InkWell(
                    onTap: () => onQueryTap?.call(value),
                    borderRadius: BorderRadius.circular(AppDesign.radiusXs),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDesign.spaceXxxs),
                      child: Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDesign.spaceL),
                Expanded(
                  child: DictionaryClickableText(
                    text: value,
                    onTap: () => onQueryTap?.call(value),
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
