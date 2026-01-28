import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/services/translation/bing_token_service.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:lando/theme/theme_controller.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/features/me/dictionary_settings_page.dart';
import 'package:lando/features/me/proxy_settings_page.dart';
import 'package:lando/features/me/about_page.dart';
import 'package:lando/features/me/hotkey_settings_widget.dart';
import 'package:lando/features/shared/widgets/confirm_dialog_widget.dart';

/// Settings page organized into three sections: General, Dictionary, and About.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
                  RadioGroup<ThemeMode>(
                    groupValue: mode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        AnalyticsService.instance.event(
                          'tap_settings_theme',
                          properties: {'theme': value.toString()},
                        );
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
                  // Language Selection
                  ListTile(
                    title: Text(l10n.language),
                    subtitle: Text(l10n.selectLanguage),
                  ),
                  RadioGroup<Locale>(
                    groupValue: currentLocale,
                    onChanged: (Locale? value) {
                      if (value != null) {
                        AnalyticsService.instance.event(
                          'tap_settings_language',
                          properties: {'locale': value.languageCode},
                        );
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
                  const Divider(height: 32),

                  // Hotkey Section (Desktop only)
                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        l10n.shortcuts,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const HotkeySettingsWidget(),
                    const Divider(height: 32),
                  ],

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
                    leading: Icon(Icons.book, color: theme.colorScheme.primary),
                    title: Text(l10n.dictionarySettings),
                    subtitle: Text(l10n.dictionarySettingsDescription),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: AnalyticsService.instance.wrapTap(
                      'tap_settings_dictionary',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DictionarySettingsPage(),
                            settings: const RouteSettings(
                              name: AppRoutes.dictionarySettings,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings_ethernet, color: theme.colorScheme.primary),
                    title: Text(l10n.proxySettings),
                    subtitle: Text(l10n.proxySettingsDescription),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: AnalyticsService.instance.wrapTap(
                      'tap_settings_proxy',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProxySettingsPage(),
                            settings: const RouteSettings(
                              name: AppRoutes.proxySettings,
                            ),
                          ),
                        );
                      },
                    ),
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
                    onTap: AnalyticsService.instance.wrapTap(
                      'tap_settings_about',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                            settings: const RouteSettings(
                              name: AppRoutes.about,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  // Clear Local Data
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(l10n.clearLocalData),
                    subtitle: Text(l10n.clearLocalDataDescription),
                    onTap: AnalyticsService.instance.wrapTap(
                      'tap_settings_clear_data',
                      () => _showClearDataDialog(context),
                    ),
                  ),
                  const Divider(height: 32),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final confirmed = await ConfirmDialogWidget.show(
      context,
      title: l10n.clearLocalData,
      content: l10n.confirmClearLocalData,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
      ),
    );

    if (confirmed == true && mounted) {
      await _clearLocalData(context);
    }
  }

  Future<void> _clearLocalData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Clear Bing token service cache (cookies and tokens)
      await BingTokenService.instance.clearCache();

      // Clear all preferences storage
      await PreferencesStorage.clearAll();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.localDataCleared),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      AnalyticsService.instance.event('clear_local_data');
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorWithDetails(e.toString())}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    }
  }
}
