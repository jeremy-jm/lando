import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/features/dictionary/widgets/dictionary_clickable_text.dart';

/// Web translations section: name (clickable) + value.
class DictionaryWebTranslationsSection extends StatelessWidget {
  const DictionaryWebTranslationsSection({
    super.key,
    required this.webTranslations,
    required this.l10n,
    required this.onQueryTap,
  });

  final List<Map<String, String>> webTranslations;
  final AppLocalizations? l10n;
  final ValueChanged<String>? onQueryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = l10n?.webTranslations ?? 'Web Translations';
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
        ...webTranslations.map((webTrans) {
          final name = webTrans['name'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DictionaryClickableText(
                  text: '$name: ',
                  onTap: () => onQueryTap?.call(name),
                ),
                Expanded(
                  child: Text(
                    webTrans['value'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
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
