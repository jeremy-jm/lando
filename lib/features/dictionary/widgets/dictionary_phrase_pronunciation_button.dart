import 'package:flutter/material.dart';

/// Small volume icon button for phrase pronunciation.
class DictionaryPhrasePronunciationButton extends StatelessWidget {
  const DictionaryPhrasePronunciationButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          Icons.volume_up,
          size: 16,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
