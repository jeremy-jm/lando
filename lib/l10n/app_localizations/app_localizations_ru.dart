// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Lando Словарь';

  @override
  String get settings => 'Настройки';

  @override
  String get profile => 'Профиль';

  @override
  String get user => 'Пользователь';

  @override
  String get about => 'О программе';

  @override
  String get notFound => '404';

  @override
  String get pageNotFound => 'Страница не найдена';

  @override
  String get themeMode => 'Режим темы';

  @override
  String get themeModeDescription =>
      'Переключение между светлой, темной или следовать системе';

  @override
  String get followSystem => 'Следовать системе';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get translation => 'Перевод';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get chinese => 'Китайский';

  @override
  String get english => 'Английский';

  @override
  String get japanese => 'Японский';

  @override
  String get hindi => 'Хинди';

  @override
  String get indonesian => 'Индонезийский';

  @override
  String get portuguese => 'Португальский';

  @override
  String get russian => 'Русский';

  @override
  String get pronunciationSource => 'Источник произношения';

  @override
  String get pronunciationSourceDescription =>
      'Выберите службу произношения для использования';

  @override
  String get pronunciationSystem => 'Система';

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
  String get me => 'Я';

  @override
  String get favorites => 'Избранное';

  @override
  String get history => 'История';

  @override
  String get noHistory => 'Нет истории запросов';

  @override
  String get clearHistory => 'Очистить историю';

  @override
  String get delete => 'Удалить';

  @override
  String get confirmClearHistory =>
      'Вы уверены, что хотите очистить всю историю?';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get cancel => 'Отмена';

  @override
  String get noFavorites => 'Нет избранного';

  @override
  String get clearFavorites => 'Очистить избранное';

  @override
  String get confirmClearFavorites =>
      'Вы уверены, что хотите очистить все избранное?';

  @override
  String get cannotFavorite =>
      'Невозможно добавить в избранное: перевод недоступен';

  @override
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get general => 'Общие';

  @override
  String get dictionary => 'Словарь';

  @override
  String get dictionarySettings => 'Настройки словаря';

  @override
  String get dictionarySettingsDescription =>
      'Настройка параметров произношения и перевода';

  @override
  String get appDescription =>
      'Программа перевода, использующая сторонние сервисы для поиска слов и не содержащая рекламы';

  @override
  String get version => 'Версия';

  @override
  String get buildNumber => 'Номер сборки';

  @override
  String get versionInfo => 'Информация о версии';

  @override
  String get versionInfoCopied =>
      'Информация о версии скопирована в буфер обмена';

  @override
  String get copy => 'Копировать';

  @override
  String get selectAll => 'Выбрать всё';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicyContent =>
      'Это приложение уважает вашу конфиденциальность. Мы не собираем, не храним и не передаем личную информацию. Все запросы на перевод обрабатываются через сторонние сервисы.';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get termsOfServiceContent =>
      'Используя это приложение, вы соглашаетесь использовать его ответственно. Это приложение предоставляет услуги перевода через сторонние API. Мы не несем ответственности за точность переводов.';

  @override
  String get openSourceLicenses => 'Лицензии с открытым исходным кодом';

  @override
  String get copyright =>
      'Авторские права © 2024 Lando Словарь. Все права защищены.';

  @override
  String get close => 'Закрыть';

  @override
  String get aboutDescription =>
      'Об этом приложении, информации о версии и юридических документах';

  @override
  String get noSuggestionsFound => 'Не найдено предложений для вашего запроса';

  @override
  String get enterTextToTranslate => 'Введите текст для перевода';

  @override
  String get playAudio => 'Воспроизвести аудио';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get detectedAs => 'Определено как';

  @override
  String get pronunciationNotAvailable => 'Произношение недоступно';

  @override
  String get errorPlayingPronunciation => 'Ошибка воспроизведения произношения';

  @override
  String errorPlayingPronunciationWithDetails(String error) {
    return 'Ошибка воспроизведения произношения: $error';
  }

  @override
  String errorWithDetails(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get partOfSpeech => 'Часть речи';

  @override
  String get tense => 'Время';

  @override
  String get phrases => 'Фразы';

  @override
  String get webTranslations => 'Веб-переводы';

  @override
  String get navigateBack => 'Назад';

  @override
  String get navigateForward => 'Вперед';

  @override
  String get shortcuts => 'Горячие клавиши';

  @override
  String get showWindowHotkey => 'Горячая клавиша показа окна';

  @override
  String get showWindowHotkeyDescription =>
      'Установить глобальную горячую клавишу для показа главного окна';

  @override
  String get currentHotkey => 'Текущая горячая клавиша';

  @override
  String get recordHotkey => 'Записать';

  @override
  String get recording => 'Запись...';

  @override
  String get pressKeysToRecord => 'Нажмите клавиши для записи...';

  @override
  String get hotkeySaved => 'Горячая клавиша сохранена';

  @override
  String get hotkeyRequiresModifier =>
      'Пожалуйста, включите хотя бы одну клавишу-модификатор (Ctrl/Cmd, Alt или Shift) или используйте F1-F20';

  @override
  String get hotkeyRequiresValidKey =>
      'Пожалуйста, включите клавишу буквы, цифры или символа';

  @override
  String get selectSourceLanguage => 'Выбрать исходный язык';

  @override
  String get selectTargetLanguage => 'Выбрать целевой язык';

  @override
  String get auto => 'Авто';

  @override
  String get data => 'Данные';

  @override
  String get clearLocalData => 'Очистить локальные данные';

  @override
  String get clearLocalDataDescription =>
      'Очистить все локально сохраненные данные, включая настройки, cookie и кеш';

  @override
  String get confirmClearLocalData =>
      'Вы уверены, что хотите очистить все локальные данные? Это действие нельзя отменить.';

  @override
  String get localDataCleared => 'Локальные данные очищены';

  @override
  String get proxySettings => 'Proxy Settings';

  @override
  String get proxySettingsDescription =>
      'Configure HTTP proxy for network requests';

  @override
  String get enableProxy => 'Enable Proxy';

  @override
  String get enableProxyDescription =>
      'Enable HTTP proxy for all network requests';

  @override
  String get proxyHost => 'Proxy Host';

  @override
  String get proxyHostHint => 'e.g., localhost';

  @override
  String get proxyPort => 'Proxy Port';

  @override
  String get proxyPortHint => 'e.g., 9091';

  @override
  String get validatingProxy => 'Validating proxy connection...';

  @override
  String get proxyValidationSuccess => 'Proxy connection successful';

  @override
  String get proxyValidationFailed => 'Failed to connect to proxy server';

  @override
  String get validateProxy => 'Validate Proxy';

  @override
  String get proxyConfigured => 'Proxy configured';

  @override
  String get proxyInfo => 'Proxy Information';

  @override
  String get proxyInfoDescription =>
      'Configure a local proxy server (e.g., localhost:9091) to route all network requests through it. The proxy will be used for all API calls when enabled.';
}
