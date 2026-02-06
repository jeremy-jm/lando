import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/app_design.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notFound),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text(
          l10n.pageNotFound,
          style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: AppDesign.alphaTertiary),
              ) ??
              TextStyle(
                fontSize: AppDesign.fontSizeBodyL,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: AppDesign.alphaTertiary),
              ),
        ),
      ),
    );
  }
}
