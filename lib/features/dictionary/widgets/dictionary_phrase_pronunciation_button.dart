import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';

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
      borderRadius: BorderRadius.circular(AppDesign.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.spaceXxs),
        child: Icon(
          AppIcons.volumeUp,
          size: AppDesign.iconXs,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
