import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';

/// Clickable text (e.g. for query tap on word/phrase).
class DictionaryClickableText extends StatelessWidget {
  const DictionaryClickableText({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesign.radiusXs),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 0, vertical: AppDesign.spaceXxxs),
        child: Text(
          text,
          style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
            fontSize: text.contains(':')
                ? AppDesign.fontSizeBody
                : (text.length <= 4
                    ? AppDesign.fontSizeCaption
                    : AppDesign.fontSizeBody),
            fontWeight: text.contains(':') ? FontWeight.w600 : FontWeight.w500,
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.primary
                .withValues(alpha: AppDesign.alphaDisabled),
          ),
        ),
      ),
    );
  }
}
