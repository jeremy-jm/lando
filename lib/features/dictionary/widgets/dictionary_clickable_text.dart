import 'package:flutter/material.dart';

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
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: text.contains(':') ? 14 : (text.length <= 4 ? 12 : 14),
            fontWeight: text.contains(':') ? FontWeight.w600 : FontWeight.w500,
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
