import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';

/// Exam type tags (e.g. CET4, IELTS).
class DictionaryExamTypesSection extends StatelessWidget {
  const DictionaryExamTypesSection({
    super.key,
    required this.types,
  });

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppDesign.spaceS,
      runSpacing: AppDesign.spaceS,
      children: types.map((type) {
        return Container(
          padding: AppDesign.paddingToolbar,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppDesign.radiusXs),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            type,
            style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
