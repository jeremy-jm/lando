import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';

/// US/UK pronunciation button (label + optional phonetic + volume icon).
class DictionaryPronunciationButton extends StatelessWidget {
  const DictionaryPronunciationButton({
    super.key,
    required this.label,
    this.phonetic,
    required this.onTap,
  });

  final String label;
  final String? phonetic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesign.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.spaceS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: AppDesign.alphaTertiary),
              ),
            ),
            const SizedBox(width: AppDesign.spaceS),
            if (phonetic != null && phonetic!.isNotEmpty) ...[
              Text(
                '/$phonetic/',
                style:
                    (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppDesign.spaceS),
            ],
            Icon(AppIcons.volumeUp,
                size: AppDesign.iconM, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
