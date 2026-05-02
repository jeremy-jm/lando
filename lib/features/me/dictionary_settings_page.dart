import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';

/// Dictionary settings page (pronunciation uses system TTS only).
class DictionarySettingsPage extends StatelessWidget {
  const DictionarySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dictionarySettings),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppDesign.spaceXl),
        children: [
          Padding(
            padding: AppDesign.paddingSectionTitle,
            child: Text(
              l10n.pronunciationSource,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            contentPadding: AppDesign.paddingListTile,
            title: Text(l10n.pronunciationSystem),
            subtitle: Text(l10n.pronunciationSourceDescription),
          ),
        ],
      ),
    );
  }
}
