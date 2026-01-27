// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lando Dictionary';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get about => 'About';

  @override
  String get notFound => '404';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeDescription =>
      'Switch between light, dark, or follow system';

  @override
  String get followSystem => 'Follow System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get translation => 'Translation';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chinese => 'Chinese';

  @override
  String get english => 'English';

  @override
  String get japanese => 'Japanese';

  @override
  String get hindi => 'Hindi';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get russian => 'Russian';

  @override
  String get pronunciationSource => 'Pronunciation Source';

  @override
  String get pronunciationSourceDescription =>
      'Select the pronunciation service to use';

  @override
  String get pronunciationSystem => 'System';

  @override
  String get pronunciationYoudao => 'Youdao';

  @override
  String get pronunciationBaidu => 'Baidu';

  @override
  String get pronunciationBing => 'Bing';

  @override
  String get pronunciationGoogle => 'Google';

  @override
  String get pronunciationApple => 'Apple';

  @override
  String get me => 'Me';

  @override
  String get favorites => 'Favorites';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No query history';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get delete => 'Delete';

  @override
  String get confirmClearHistory =>
      'Are you sure you want to clear all history?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get noFavorites => 'No favorites';

  @override
  String get clearFavorites => 'Clear Favorites';

  @override
  String get confirmClearFavorites =>
      'Are you sure you want to clear all favorites?';

  @override
  String get cannotFavorite => 'Cannot favorite: no translation available';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get general => 'General';

  @override
  String get dictionary => 'Dictionary';

  @override
  String get dictionarySettings => 'Dictionary Settings';

  @override
  String get dictionarySettingsDescription =>
      'Configure pronunciation and translation settings';

  @override
  String get appDescription =>
      'A translation software that uses third-party services for word lookup and has no advertisements';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get versionInfo => 'Version Information';

  @override
  String get versionInfoCopied => 'Version information copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyContent =>
      'This app respects your privacy. We do not collect, store, or share any personal information. All translation queries are processed through third-party services.';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceContent =>
      'By using this app, you agree to use it responsibly. This app provides translation services through third-party APIs. We are not responsible for the accuracy of translations.';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get copyright =>
      'Copyright © 2024 Lando Dictionary. All rights reserved.';

  @override
  String get close => 'Close';

  @override
  String get aboutDescription =>
      'About this app, version information, and legal documents';

  @override
  String get noSuggestionsFound => 'No suggestions found for your query';

  @override
  String get enterTextToTranslate => 'Enter text to translate';

  @override
  String get playAudio => 'Play audio';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get detectedAs => 'Detected as';

  @override
  String get pronunciationNotAvailable => 'Pronunciation not available';

  @override
  String get errorPlayingPronunciation => 'Error playing pronunciation';

  @override
  String errorPlayingPronunciationWithDetails(String error) {
    return 'Error playing pronunciation: $error';
  }

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get partOfSpeech => 'Part of Speech';

  @override
  String get tense => 'Tense';

  @override
  String get phrases => 'Phrases';

  @override
  String get webTranslations => 'Web Translations';

  @override
  String get navigateBack => 'Navigate back';

  @override
  String get navigateForward => 'Navigate forward';

  @override
  String get shortcuts => 'Shortcuts';

  @override
  String get showWindowHotkey => 'Show Window Hotkey';

  @override
  String get showWindowHotkeyDescription =>
      'Set a global hotkey to show the main window';

  @override
  String get currentHotkey => 'Current Hotkey';

  @override
  String get recordHotkey => 'Record';

  @override
  String get recording => 'Recording...';

  @override
  String get pressKeysToRecord => 'Press keys to record...';

  @override
  String get hotkeySaved => 'Hotkey saved';

  @override
  String get hotkeyRequiresModifier =>
      'Please include at least one modifier key (Ctrl/Cmd, Alt, or Shift), or use F1-F20';

  @override
  String get hotkeyRequiresValidKey =>
      'Please include a letter, digit, or symbol key';

  @override
  String get selectSourceLanguage => 'Select Source Language';

  @override
  String get selectTargetLanguage => 'Select Target Language';

  @override
  String get auto => 'Auto';
}
