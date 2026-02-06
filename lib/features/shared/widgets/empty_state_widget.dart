import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';

/// A reusable empty state widget for displaying when lists are empty.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = AppDesign.emptyStateIconSize,
  });

  /// Icon to display.
  final IconData icon;

  /// Message to display.
  final String message;

  /// Size of the icon.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.colorScheme.onSurface
                .withValues(alpha: AppDesign.alphaEmptyIcon),
          ),
          const SizedBox(height: AppDesign.spaceL),
          Text(
            message,
            style: TextStyle(
              fontSize: AppDesign.emptyStateFontSize,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: AppDesign.alphaTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
