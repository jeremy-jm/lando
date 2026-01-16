import 'package:flutter/material.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Language selector widget for translation from/to language selection.
class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key, this.onLanguageChanged});

  final ValueChanged<LanguagePair>? onLanguageChanged;

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  String? _fromLanguage;
  String? _toLanguage;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguages();
  }

  /// Reloads language settings from storage.
  /// This is useful when language settings are changed in another page.
  void reloadLanguages() {
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final from = PreferencesStorage.getTranslationFromLanguage();
    final to = PreferencesStorage.getTranslationToLanguage();
    if (mounted) {
      setState(() {
        _fromLanguage = from;
        _toLanguage = to;
      });
    }
  }

  String _getLanguageName(String languageCode) {
    const names = {
      'en': '英语',
      'zh': '中文',
      'ja': '日语',
      'hi': '印地语',
      'id': '印尼语',
      'pt': '葡萄牙语',
      'ru': '俄语',
    };
    return names[languageCode] ?? languageCode.toUpperCase();
  }

  Future<void> _showFromLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) =>
          _LanguageDialog(title: '选择源语言', currentSelection: _fromLanguage),
    );

    if (selected != null && mounted) {
      final newFromLanguage = selected == 'auto' ? null : selected;
      setState(() {
        _fromLanguage = newFromLanguage;
      });
      await PreferencesStorage.saveTranslationLanguages(
        fromLanguage: newFromLanguage,
        toLanguage: _toLanguage,
      );
      widget.onLanguageChanged?.call(
        LanguagePair(from: _fromLanguage, to: _toLanguage),
      );
    }
  }

  Future<void> _showToLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) =>
          _LanguageDialog(title: '选择目标语言', currentSelection: _toLanguage),
    );

    if (selected != null && mounted) {
      final newToLanguage = selected == 'auto' ? null : selected;
      setState(() {
        _toLanguage = newToLanguage;
      });
      await PreferencesStorage.saveTranslationLanguages(
        fromLanguage: _fromLanguage,
        toLanguage: newToLanguage,
      );
      widget.onLanguageChanged?.call(
        LanguagePair(from: _fromLanguage, to: _toLanguage),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload language settings when dependencies change (e.g., when returning from another page)
    // This ensures the widget stays in sync with stored preferences
    _checkAndReloadLanguages();
  }

  void _checkAndReloadLanguages() {
    final currentFrom = PreferencesStorage.getTranslationFromLanguage();
    final currentTo = PreferencesStorage.getTranslationToLanguage();
    if (currentFrom != _fromLanguage || currentTo != _toLanguage) {
      _loadSavedLanguages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Also check in build method as a fallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAndReloadLanguages();
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          // From language selector
          GestureDetector(
            onTap: _showFromLanguageDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fromLanguage == null
                        ? '自动'
                        : _getLanguageName(_fromLanguage!),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          // Arrow icon
          Icon(
            Icons.arrow_forward,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12.0),
          // To language selector
          GestureDetector(
            onTap: _showToLanguageDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _toLanguage == null ? '自动' : _getLanguageName(_toLanguage!),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Language pair data class.
class LanguagePair {
  const LanguagePair({this.from, this.to});

  final String? from;
  final String? to;
}

/// Language selection dialog.
class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog({required this.title, this.currentSelection});

  final String title;
  final String? currentSelection;

  @override
  Widget build(BuildContext context) {
    final supportedLanguages = LocaleController.supportedLocales;

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Auto option
            _LanguageOption(
              code: 'auto',
              name: '自动',
              isSelected: currentSelection == null,
              onTap: () => Navigator.of(context).pop('auto'),
            ),
            const Divider(),
            // Language options
            ...supportedLanguages.map(
              (locale) => _LanguageOption(
                code: locale.languageCode,
                name: _getLanguageName(locale.languageCode),
                isSelected: currentSelection == locale.languageCode,
                onTap: () => Navigator.of(context).pop(locale.languageCode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    const names = {
      'en': '英语',
      'zh': '中文',
      'ja': '日语',
      'hi': '印地语',
      'id': '印尼语',
      'pt': '葡萄牙语',
      'ru': '俄语',
    };
    return names[languageCode] ?? languageCode.toUpperCase();
  }
}

/// Language option item.
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: onTap,
    );
  }
}
