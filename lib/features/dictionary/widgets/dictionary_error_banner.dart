import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';

/// Error message banner for dictionary card.
class DictionaryErrorBanner extends StatelessWidget {
  const DictionaryErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDesign.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDesign.radiusM),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.errorOutline,
            color: theme.colorScheme.onErrorContainer,
            size: AppDesign.iconM,
          ),
          const SizedBox(width: AppDesign.spaceS),
          Expanded(
            child: Text(
              message,
              style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
