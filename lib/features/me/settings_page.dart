import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/theme_controller.dart';
import 'package:lando/localization/locale_controller.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
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
                  // Theme Mode Section
                  ListTile(
                    title: Text(l10n.themeMode),
                    subtitle: Text(l10n.themeModeDescription),
                  ),
                  RadioGroup<ThemeMode>(
                    groupValue: mode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        ThemeController.instance.setMode(value);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: Text(l10n.followSystem),
                          value: ThemeMode.system,
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(l10n.light),
                          value: ThemeMode.light,
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(l10n.dark),
                          value: ThemeMode.dark,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Language Selection Section
                  ListTile(
                    title: Text(l10n.language),
                    subtitle: Text(l10n.selectLanguage),
                  ),
                  RadioGroup<Locale>(
                    groupValue: currentLocale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        LocaleController.instance.setLocale(value);
                      }
                    },
                    child: Column(
                      children: LocaleController.supportedLocales.map((locale) {
                        return RadioListTile<Locale>(
                          title: Text(
                            _getLanguageName(l10n, locale.languageCode),
                          ),
                          value: locale,
                        );
                      }).toList(),
                    ),
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
