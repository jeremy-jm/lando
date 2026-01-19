import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/theme_controller.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/features/me/dictionary_settings_page.dart';
import 'package:lando/features/me/about_page.dart';

/// Settings page organized into three sections: General, Dictionary, and About.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _getLanguageName(AppLocalizations l10n, String languageCode) {
    switch (languageCode) {
      case 'zh':
        return l10n.chinese;
      case 'en':
        return l10n.english;
      case 'ja':
        return l10n.japanese;
      case 'hi':
        return l10n.hindi;
      case 'id':
        return l10n.indonesian;
      case 'pt':
        return l10n.portuguese;
      case 'ru':
        return l10n.russian;
      default:
        return languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, _) {
          return AnimatedBuilder(
            animation: LocaleController.instance,
            builder: (context, _) {
              final mode = ThemeController.instance.mode;
              final currentLocale = LocaleController.instance.locale;

              return ListView(
                children: [
                  // General Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.general,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  // Theme Mode
                  ListTile(
                    title: Text(l10n.themeMode),
                    subtitle: Text(l10n.themeModeDescription),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.followSystem),
                    value: ThemeMode.system,
                    groupValue: mode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        ThemeController.instance.setMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.light),
                    value: ThemeMode.light,
                    groupValue: mode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        ThemeController.instance.setMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.dark),
                    value: ThemeMode.dark,
                    groupValue: mode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        ThemeController.instance.setMode(value);
                      }
                    },
                  ),
                  const Divider(),
                  // Language Selection
                  ListTile(
                    title: Text(l10n.language),
                    subtitle: Text(l10n.selectLanguage),
                  ),
                  ...LocaleController.supportedLocales.map((locale) {
                    return RadioListTile<Locale>(
                      title: Text(
                        _getLanguageName(l10n, locale.languageCode),
                      ),
                      value: locale,
                      groupValue: currentLocale,
                      onChanged: (Locale? value) {
                        if (value != null) {
                          LocaleController.instance.setLocale(value);
                        }
                      },
                    );
                  }),
                  const Divider(height: 32),
                  
                  // Dictionary Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.dictionary,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.book,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.dictionarySettings),
                    subtitle: Text(l10n.dictionarySettingsDescription),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DictionarySettingsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  
                  // About Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.about,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(l10n.about),
                    subtitle: Text(l10n.aboutDescription),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

