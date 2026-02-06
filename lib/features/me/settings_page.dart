import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
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

/// Settings page: General, Dictionary, About, and Data sections.
///
/// Layout aligned with Figma design:
/// [Lando - Settings](https://www.figma.com/design/Uf6gt2qk5wgACZHJZBcfR4/Lando?node-id=5-239)
/// - AppBar: back, title "设置" centered
/// - Sections: 通用 (theme, language, shortcuts), 词典 (dictionary, proxy), 关于, 数据 (clear local data with red style)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

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

  Widget _buildSectionTitle(
    ThemeData theme,
    String title,
  ) {
    return Padding(
      padding: AppDesign.paddingSectionTitle,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required Widget child,
  }) {
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppDesign.radiusL),
      child: child,
    );
  }

  Widget _buildGeneralSection(
    ThemeData theme,
    AppLocalizations l10n,
    ThemeMode mode,
    Locale currentLocale,
  ) {
    return Column(
      children: [
        _buildSectionTitle(theme, l10n.general),
        _buildSectionCard(
          theme: theme,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: AppDesign.paddingListTile,
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
              Divider(
                height: AppDesign.dividerHeight,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: AppDesign.alphaDivider),
              ),
              ListTile(
                contentPadding: AppDesign.paddingListTile,
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
              if (_isDesktop) ...[
                const HotkeySettingsWidget(),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDesign.spaceL),
      ],
    );
  }

  Widget _buildDictionarySection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildSectionTitle(theme, l10n.dictionary),
        _buildSectionCard(
          theme: theme,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: AppDesign.paddingListTile,
                leading:
                    Icon(AppIcons.book, color: theme.colorScheme.primary),
                title: Text(l10n.dictionarySettings),
                subtitle: Text(l10n.dictionarySettingsDescription),
                trailing: const Icon(AppIcons.chevronRight),
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
                contentPadding: AppDesign.paddingListTile,
                leading: Icon(AppIcons.settingsEthernet,
                    color: theme.colorScheme.primary),
                title: Text(l10n.proxySettings),
                subtitle: Text(l10n.proxySettingsDescription),
                trailing: const Icon(AppIcons.chevronRight),
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
            ],
          ),
        ),
        const SizedBox(height: AppDesign.spaceL),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildSectionTitle(theme, l10n.about),
        _buildSectionCard(
          theme: theme,
          child: ListTile(
            contentPadding: AppDesign.paddingListTile,
            leading: Icon(
              AppIcons.infoOutline,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.about),
            subtitle: Text(l10n.aboutDescription),
            trailing: const Icon(AppIcons.chevronRight),
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
        ),
        const SizedBox(height: AppDesign.spaceL),
      ],
    );
  }

  Widget _buildDataSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildSectionTitle(theme, l10n.data),
        _buildSectionCard(
          theme: theme,
          child: ListTile(
            contentPadding: AppDesign.paddingListTile,
            title: Text(
              l10n.clearLocalData,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(l10n.clearLocalDataDescription),
            trailing: Icon(
              AppIcons.deleteOutline,
              color: theme.colorScheme.error,
            ),
            onTap: AnalyticsService.instance.wrapTap(
              'tap_settings_clear_data',
              () => _showClearDataDialog(context),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: AppDesign.iconXs),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                padding: AppDesign.paddingPage,
                children: [
                  _buildGeneralSection(theme, l10n, mode, currentLocale),
                  _buildDictionarySection(theme, l10n),
                  _buildAboutSection(theme, l10n),
                  _buildDataSection(theme, l10n),
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
