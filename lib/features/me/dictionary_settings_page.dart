import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/audio/pronunciation_service_type.dart';
import 'package:lando/services/audio/pronunciation_service_manager.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Dictionary settings page for pronunciation and translation settings.
class DictionarySettingsPage extends StatefulWidget {
  const DictionarySettingsPage({super.key});

  @override
  State<DictionarySettingsPage> createState() => _DictionarySettingsPageState();
}

class _DictionarySettingsPageState extends State<DictionarySettingsPage> {
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
        _currentPronunciationService = PronunciationServiceType.values
            .firstWhere(
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dictionarySettings),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Pronunciation Source Selection Section
          ListTile(
            title: Text(l10n.pronunciationSource),
            subtitle: Text(l10n.pronunciationSourceDescription),
          ),
          RadioGroup<PronunciationServiceType>(
            groupValue: _currentPronunciationService,
            onChanged: _onPronunciationServiceChanged,
            child: Column(
              children: PronunciationServiceType.values.map((type) {
                return RadioListTile<PronunciationServiceType>(
                  title: Text(_getPronunciationServiceName(l10n, type)),
                  value: type,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
