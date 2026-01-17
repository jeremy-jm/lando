import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/theme_controller.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/services/audio/pronunciation_service_type.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
import 'package:lando/storage/preferences_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PronunciationServiceType? _currentPronunciationService;

  @override
  void initState() {
    super.initState();
    _loadPronunciationService();
  }

  void _loadPronunciationService() {
    final serviceTypeString = PreferencesStorage.getPronunciationServiceType();
    if (serviceTypeString == null || serviceTypeString.isEmpty) {
      _currentPronunciationService = PronunciationServiceType.system;
    } else {
      try {
        _currentPronunciationService = PronunciationServiceType.values.firstWhere(
          (type) => type.name == serviceTypeString,
          orElse: () => PronunciationServiceType.system,
        );
      } catch (e) {
        _currentPronunciationService = PronunciationServiceType.system;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onPronunciationServiceChanged(
    PronunciationServiceType? value,
  ) async {
    if (value == null) return;

    await PreferencesStorage.savePronunciationServiceType(value.name);
    PronunciationServiceManager().reloadService();
    
    if (mounted) {
      setState(() {
        _currentPronunciationService = value;
      });
    }
  }

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

  String _getPronunciationServiceName(
    AppLocalizations l10n,
    PronunciationServiceType type,
  ) {
    switch (type) {
      case PronunciationServiceType.system:
        return l10n.pronunciationSystem;
      case PronunciationServiceType.youdao:
        return l10n.pronunciationYoudao;
      case PronunciationServiceType.baidu:
        return l10n.pronunciationBaidu;
      case PronunciationServiceType.bing:
        return l10n.pronunciationBing;
      case PronunciationServiceType.google:
        return l10n.pronunciationGoogle;
      case PronunciationServiceType.apple:
        return l10n.pronunciationApple;
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
                  const Divider(),
                  // Pronunciation Source Selection Section
                  ListTile(
                    title: Text(l10n.pronunciationSource),
                    subtitle: Text(l10n.pronunciationSourceDescription),
                  ),
                  ...PronunciationServiceType.values.map((type) {
                    return RadioListTile<PronunciationServiceType>(
                      title: Text(_getPronunciationServiceName(l10n, type)),
                      value: type,
                      groupValue: _currentPronunciationService,
                      onChanged: _onPronunciationServiceChanged,
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
