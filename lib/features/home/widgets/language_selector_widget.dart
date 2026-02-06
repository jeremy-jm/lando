import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Language selector widget for translation from/to language selection.
class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({
    super.key,
    this.onLanguageChanged,
    this.showBackground = false,
  });

  final ValueChanged<LanguagePair>? onLanguageChanged;
  final bool showBackground;
  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget>
    with SingleTickerProviderStateMixin {
  String? _fromLanguage;
  String? _toLanguage;
  bool _isSwapping = false;
  bool _isDisposed = false;

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
    if (_isDisposed) return;
    final from = PreferencesStorage.getTranslationFromLanguage();
    final to = PreferencesStorage.getTranslationToLanguage();
    if (!_isDisposed && mounted) {
      setState(() {
        _fromLanguage = from;
        _toLanguage = to;
      });
    }
  }

  String _getLanguageName(String languageCode) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return languageCode.toUpperCase();
    }

    switch (languageCode) {
      case 'en':
        return l10n.english;
      case 'zh':
        return l10n.chinese;
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
        return languageCode.toUpperCase();
    }
  }

  Widget _buildLanguageSelector(
    ThemeData theme,
    String languageName,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spaceMd,
          vertical: AppDesign.spaceXs,
        ),
        decoration: BoxDecoration(
          color: widget.showBackground
              ? theme.colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDesign.radiusS),
          border: widget.showBackground
              ? Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageName,
              style: TextStyle(
                fontSize: AppDesign.fontSizeBodyS,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: AppDesign.spaceXxs),
            Icon(
              AppIcons.arrowDropDown,
              size: AppDesign.iconS,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: AppDesign.alphaTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFromLanguageDialog() async {
    final l10n = AppLocalizations.of(context);
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _LanguageDialog(
        title: l10n?.selectSourceLanguage ?? 'Select Source Language',
        currentSelection: _fromLanguage,
      ),
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
    final l10n = AppLocalizations.of(context);
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _LanguageDialog(
        title: l10n?.selectTargetLanguage ?? 'Select Target Language',
        currentSelection: _toLanguage,
      ),
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

  Future<void> _swapLanguages() async {
    if (_isSwapping) return;

    // Swap values immediately
    final temp = _fromLanguage;
    setState(() {
      _isSwapping = true;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;
    });

    setState(() {
      _isSwapping = false;
    });

    await PreferencesStorage.saveTranslationLanguages(
      fromLanguage: _fromLanguage,
      toLanguage: _toLanguage,
    );
    widget.onLanguageChanged?.call(
      LanguagePair(from: _fromLanguage, to: _toLanguage),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload language settings when dependencies change (e.g., when returning from another page)
    // This ensures the widget stays in sync with stored preferences
    if (!_isDisposed) {
      _checkAndReloadLanguages();
    }
  }

  void _checkAndReloadLanguages() {
    if (_isDisposed) return;
    final currentFrom = PreferencesStorage.getTranslationFromLanguage();
    final currentTo = PreferencesStorage.getTranslationToLanguage();
    if (currentFrom != _fromLanguage || currentTo != _toLanguage) {
      _loadSavedLanguages();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context);
    // Build language selector widgets
    final fromLanguageWidget = _buildLanguageSelector(
      theme,
      _fromLanguage == null
          ? (l10n?.auto ?? 'Auto')
          : _getLanguageName(_fromLanguage!),
      _showFromLanguageDialog,
    );

    final toLanguageWidget = _buildLanguageSelector(
      theme,
      _toLanguage == null
          ? (l10n?.auto ?? 'Auto')
          : _getLanguageName(_toLanguage!),
      _showToLanguageDialog,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDesign.spaceS),
      decoration: BoxDecoration(
        color: widget.showBackground
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDesign.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // From language selector with animation
          fromLanguageWidget,
          const SizedBox(width: AppDesign.spaceMd),
          // Swap languages button
          GestureDetector(
            onTap: _swapLanguages,
            child: Container(
              padding: const EdgeInsets.all(AppDesign.spaceXs),
              decoration: BoxDecoration(
                color: widget.showBackground
                    ? theme.colorScheme.surface
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDesign.radiusS),
                border: widget.showBackground
                    ? Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Icon(
                AppIcons.swapHoriz,
                size: AppDesign.iconS,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: AppDesign.alphaSecondary),
              ),
            ),
          ),
          const SizedBox(width: AppDesign.spaceMd),
          // To language selector with animation
          toLanguageWidget,
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
    final l10n = AppLocalizations.of(context);

    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Auto option
            _LanguageOption(
              code: 'auto',
              name: l10n?.auto ?? 'Auto',
              isSelected: currentSelection == null,
              onTap: () => Navigator.of(context).pop('auto'),
            ),
            Divider(
              height: AppDesign.dividerHeight,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: AppDesign.alphaDivider),
            ),
            // Language options
            ...supportedLanguages.map(
              (locale) => _LanguageOption(
                code: locale.languageCode,
                name: _getLanguageName(locale.languageCode, context),
                isSelected: currentSelection == locale.languageCode,
                onTap: () => Navigator.of(context).pop(locale.languageCode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return languageCode.toUpperCase();
    }

    switch (languageCode) {
      case 'en':
        return l10n.english;
      case 'zh':
        return l10n.chinese;
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
        return languageCode.toUpperCase();
    }
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
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: AppDesign.paddingListTile,
      title: Text(name),
      trailing: isSelected
          ? Icon(AppIcons.check, color: theme.colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: onTap,
    );
  }
}
