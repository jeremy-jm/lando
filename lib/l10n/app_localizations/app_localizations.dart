import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'app_localizations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Lando Dictionary'**
  String get appTitle;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// About page title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Not found page title
  ///
  /// In en, this message translates to:
  /// **'404'**
  String get notFound;

  /// Page not found message
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Theme mode setting title
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Theme mode setting description
  ///
  /// In en, this message translates to:
  /// **'Switch between light, dark, or follow system'**
  String get themeModeDescription;

  /// Follow system theme option
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Translation tab label
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language prompt
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Chinese language option
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// Indonesian language option
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// Portuguese language option
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// Russian language option
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// Pronunciation source setting title
  ///
  /// In en, this message translates to:
  /// **'Pronunciation Source'**
  String get pronunciationSource;

  /// Pronunciation source setting description
  ///
  /// In en, this message translates to:
  /// **'Select the pronunciation service to use'**
  String get pronunciationSourceDescription;

  /// System TTS pronunciation option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get pronunciationSystem;

  /// Youdao pronunciation option
  ///
  /// In en, this message translates to:
  /// **'Youdao'**
  String get pronunciationYoudao;

  /// Baidu pronunciation option
  ///
  /// In en, this message translates to:
  /// **'Baidu'**
  String get pronunciationBaidu;

  /// Bing pronunciation option
  ///
  /// In en, this message translates to:
  /// **'Bing'**
  String get pronunciationBing;

  /// Google pronunciation option
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get pronunciationGoogle;

  /// Apple pronunciation option
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get pronunciationApple;

  /// Me page title
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// Favorites page title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// History page title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Message shown when there is no query history
  ///
  /// In en, this message translates to:
  /// **'No query history'**
  String get noHistory;

  /// Button to clear all query history
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirmation message before clearing all history
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all history?'**
  String get confirmClearHistory;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Message shown when there are no favorites
  ///
  /// In en, this message translates to:
  /// **'No favorites'**
  String get noFavorites;

  /// Button to clear all favorites
  ///
  /// In en, this message translates to:
  /// **'Clear Favorites'**
  String get clearFavorites;

  /// Confirmation message before clearing all favorites
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all favorites?'**
  String get confirmClearFavorites;

  /// Message shown when trying to favorite a word without translation
  ///
  /// In en, this message translates to:
  /// **'Cannot favorite: no translation available'**
  String get cannotFavorite;

  /// Message shown when a word is removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// Message shown when a word is added to favorites
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// General settings section title
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Dictionary settings section title
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get dictionary;

  /// Dictionary settings page title
  ///
  /// In en, this message translates to:
  /// **'Dictionary Settings'**
  String get dictionarySettings;

  /// Dictionary settings description
  ///
  /// In en, this message translates to:
  /// **'Configure pronunciation and translation settings'**
  String get dictionarySettingsDescription;

  /// App description text
  ///
  /// In en, this message translates to:
  /// **'A translation software that uses third-party services for word lookup and has no advertisements'**
  String get appDescription;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Build number label
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// Version information title
  ///
  /// In en, this message translates to:
  /// **'Version Information'**
  String get versionInfo;

  /// Message shown when version info is copied
  ///
  /// In en, this message translates to:
  /// **'Version information copied to clipboard'**
  String get versionInfoCopied;

  /// Copy button label
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Select All button label in text context menu
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Privacy policy title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy content
  ///
  /// In en, this message translates to:
  /// **'This app respects your privacy. We do not collect, store, or share any personal information. All translation queries are processed through third-party services.'**
  String get privacyPolicyContent;

  /// Terms of service title
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Terms of service content
  ///
  /// In en, this message translates to:
  /// **'By using this app, you agree to use it responsibly. This app provides translation services through third-party APIs. We are not responsible for the accuracy of translations.'**
  String get termsOfServiceContent;

  /// Open source licenses title
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// Copyright text
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2024 Lando Dictionary. All rights reserved.'**
  String get copyright;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// About page description
  ///
  /// In en, this message translates to:
  /// **'About this app, version information, and legal documents'**
  String get aboutDescription;

  /// Message shown when no suggestions are found for the query
  ///
  /// In en, this message translates to:
  /// **'No suggestions found for your query'**
  String get noSuggestionsFound;

  /// Placeholder text for translation input field
  ///
  /// In en, this message translates to:
  /// **'Enter text to translate'**
  String get enterTextToTranslate;

  /// Tooltip for play audio button
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get playAudio;

  /// Message shown when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Label shown before detected language name
  ///
  /// In en, this message translates to:
  /// **'Detected as'**
  String get detectedAs;

  /// Message shown when pronunciation is not available
  ///
  /// In en, this message translates to:
  /// **'Pronunciation not available'**
  String get pronunciationNotAvailable;

  /// Error message shown when pronunciation fails
  ///
  /// In en, this message translates to:
  /// **'Error playing pronunciation'**
  String get errorPlayingPronunciation;

  /// Error message shown when pronunciation fails with error details
  ///
  /// In en, this message translates to:
  /// **'Error playing pronunciation: {error}'**
  String errorPlayingPronunciationWithDetails(String error);

  /// Generic error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// Label for part of speech section
  ///
  /// In en, this message translates to:
  /// **'Part of Speech'**
  String get partOfSpeech;

  /// Label for tense/word form section
  ///
  /// In en, this message translates to:
  /// **'Tense'**
  String get tense;

  /// Label for phrases section
  ///
  /// In en, this message translates to:
  /// **'Phrases'**
  String get phrases;

  /// Label for web translations section
  ///
  /// In en, this message translates to:
  /// **'Web Translations'**
  String get webTranslations;

  /// Tooltip for navigate back button
  ///
  /// In en, this message translates to:
  /// **'Navigate back'**
  String get navigateBack;

  /// Tooltip for navigate forward button
  ///
  /// In en, this message translates to:
  /// **'Navigate forward'**
  String get navigateForward;

  /// Shortcuts settings section title
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// Show window hotkey setting title
  ///
  /// In en, this message translates to:
  /// **'Show Window Hotkey'**
  String get showWindowHotkey;

  /// Show window hotkey setting description
  ///
  /// In en, this message translates to:
  /// **'Set a global hotkey to show the main window'**
  String get showWindowHotkeyDescription;

  /// Label for current hotkey display
  ///
  /// In en, this message translates to:
  /// **'Current Hotkey'**
  String get currentHotkey;

  /// Button to record a new hotkey
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordHotkey;

  /// Text shown when recording a hotkey
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// Instruction text when recording hotkey
  ///
  /// In en, this message translates to:
  /// **'Press keys to record...'**
  String get pressKeysToRecord;

  /// Message shown when hotkey is saved
  ///
  /// In en, this message translates to:
  /// **'Hotkey saved'**
  String get hotkeySaved;

  /// Error message when hotkey doesn't have modifier keys
  ///
  /// In en, this message translates to:
  /// **'Please include at least one modifier key (Ctrl/Cmd, Alt, or Shift), or use F1-F20'**
  String get hotkeyRequiresModifier;

  /// Error message when hotkey doesn't have a valid key
  ///
  /// In en, this message translates to:
  /// **'Please include a letter, digit, or symbol key'**
  String get hotkeyRequiresValidKey;

  /// Title for source language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Source Language'**
  String get selectSourceLanguage;

  /// Title for target language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Target Language'**
  String get selectTargetLanguage;

  /// Auto-detect language option
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// Clear local data button title
  ///
  /// In en, this message translates to:
  /// **'Clear Local Data'**
  String get clearLocalData;

  /// Description for clear local data option
  ///
  /// In en, this message translates to:
  /// **'Clear all locally stored data, including settings, cookies, and cache'**
  String get clearLocalDataDescription;

  /// Confirmation message before clearing local data
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all local data? This action cannot be undone.'**
  String get confirmClearLocalData;

  /// Message shown when local data is cleared
  ///
  /// In en, this message translates to:
  /// **'Local data cleared'**
  String get localDataCleared;

  /// Proxy settings page title
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get proxySettings;

  /// Description for proxy settings option
  ///
  /// In en, this message translates to:
  /// **'Configure HTTP proxy for network requests'**
  String get proxySettingsDescription;

  /// Enable proxy switch label
  ///
  /// In en, this message translates to:
  /// **'Enable Proxy'**
  String get enableProxy;

  /// Description for enable proxy switch
  ///
  /// In en, this message translates to:
  /// **'Enable HTTP proxy for all network requests'**
  String get enableProxyDescription;

  /// Proxy host input label
  ///
  /// In en, this message translates to:
  /// **'Proxy Host'**
  String get proxyHost;

  /// Placeholder for proxy host input
  ///
  /// In en, this message translates to:
  /// **'e.g., localhost'**
  String get proxyHostHint;

  /// Proxy port input label
  ///
  /// In en, this message translates to:
  /// **'Proxy Port'**
  String get proxyPort;

  /// Placeholder for proxy port input
  ///
  /// In en, this message translates to:
  /// **'e.g., 9091'**
  String get proxyPortHint;

  /// Message shown when validating proxy
  ///
  /// In en, this message translates to:
  /// **'Validating proxy connection...'**
  String get validatingProxy;

  /// Message shown when proxy validation succeeds
  ///
  /// In en, this message translates to:
  /// **'Proxy connection successful'**
  String get proxyValidationSuccess;

  /// Message shown when proxy validation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to proxy server'**
  String get proxyValidationFailed;

  /// Button label to validate proxy connection
  ///
  /// In en, this message translates to:
  /// **'Validate Proxy'**
  String get validateProxy;

  /// Message shown when proxy is configured
  ///
  /// In en, this message translates to:
  /// **'Proxy configured'**
  String get proxyConfigured;

  /// Title for proxy information card
  ///
  /// In en, this message translates to:
  /// **'Proxy Information'**
  String get proxyInfo;

  /// Description text for proxy information
  ///
  /// In en, this message translates to:
  /// **'Configure a local proxy server (e.g., localhost:9091) to route all network requests through it. The proxy will be used for all API calls when enabled.'**
  String get proxyInfoDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'hi',
        'id',
        'ja',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
