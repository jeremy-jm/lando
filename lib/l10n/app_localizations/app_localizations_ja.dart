// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Lando 辞書';

  @override
  String get settings => '設定';

  @override
  String get profile => 'プロフィール';

  @override
  String get about => 'について';

  @override
  String get notFound => '404';

  @override
  String get pageNotFound => 'ページが見つかりません';

  @override
  String get themeMode => 'テーマモード';

  @override
  String get themeModeDescription => 'ライト、ダーク、またはシステムに従うの間で切り替え';

  @override
  String get followSystem => 'システムに従う';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get translation => '翻訳';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get chinese => '中国語';

  @override
  String get english => '英語';

  @override
  String get japanese => '日本語';

  @override
  String get hindi => 'ヒンディー語';

  @override
  String get indonesian => 'インドネシア語';

  @override
  String get portuguese => 'ポルトガル語';

  @override
  String get russian => 'ロシア語';

  @override
  String get pronunciationSource => '発音ソース';

  @override
  String get pronunciationSourceDescription => '使用する発音サービスを選択';

  @override
  String get pronunciationSystem => 'システム';

  @override
  String get pronunciationYoudao => '有道';

  @override
  String get pronunciationBaidu => '百度';

  @override
  String get pronunciationBing => 'Bing';

  @override
  String get pronunciationGoogle => 'Google';

  @override
  String get pronunciationApple => 'Apple';

  @override
  String get me => '私';

  @override
  String get favorites => 'お気に入り';

  @override
  String get history => '検索履歴';

  @override
  String get noHistory => '検索履歴がありません';

  @override
  String get clearHistory => '履歴をクリア';

  @override
  String get delete => '削除';

  @override
  String get confirmClearHistory => 'すべての検索履歴をクリアしてもよろしいですか？';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get noFavorites => 'お気に入りがありません';

  @override
  String get clearFavorites => 'お気に入りをクリア';

  @override
  String get confirmClearFavorites => 'すべてのお気に入りをクリアしてもよろしいですか？';

  @override
  String get cannotFavorite => 'お気に入りに追加できません：翻訳が利用できません';

  @override
  String get removedFromFavorites => 'お気に入りから削除しました';

  @override
  String get addedToFavorites => 'お気に入りに追加しました';

  @override
  String get general => '一般';

  @override
  String get dictionary => '辞書';

  @override
  String get dictionarySettings => '辞書設定';

  @override
  String get dictionarySettingsDescription => '発音と翻訳設定を構成';

  @override
  String get appDescription => 'サードパーティサービスを使用して単語検索を行い、広告のない翻訳ソフトウェア';

  @override
  String get version => 'バージョン';

  @override
  String get buildNumber => 'ビルド番号';

  @override
  String get versionInfo => 'バージョン情報';

  @override
  String get versionInfoCopied => 'バージョン情報がクリップボードにコピーされました';

  @override
  String get copy => 'コピー';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get privacyPolicyContent =>
      'このアプリはあなたのプライバシーを尊重します。個人情報を収集、保存、共有することはありません。すべての翻訳クエリはサードパーティサービスを通じて処理されます。';

  @override
  String get termsOfService => '利用規約';

  @override
  String get termsOfServiceContent =>
      'このアプリを使用することで、責任を持って使用することに同意したものとみなされます。このアプリはサードパーティAPIを通じて翻訳サービスを提供します。翻訳の正確性については責任を負いません。';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get copyright => '著作権 © 2024 Lando 辞書。全著作権所有。';

  @override
  String get close => '閉じる';

  @override
  String get aboutDescription => 'このアプリ、バージョン情報、法的文書について';

  @override
  String get noSuggestionsFound => '検索結果が見つかりませんでした';

  @override
  String get enterTextToTranslate => '翻訳するテキストを入力';

  @override
  String get playAudio => '音声を再生';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get detectedAs => '検出:';

  @override
  String get pronunciationNotAvailable => '発音が利用できません';

  @override
  String get errorPlayingPronunciation => '発音の再生中にエラーが発生しました';

  @override
  String errorPlayingPronunciationWithDetails(String error) {
    return '発音の再生中にエラーが発生しました：$error';
  }

  @override
  String errorWithDetails(String error) {
    return 'エラー：$error';
  }

  @override
  String get partOfSpeech => '品詞';

  @override
  String get tense => '時制';

  @override
  String get phrases => 'フレーズ';

  @override
  String get webTranslations => 'ウェブ翻訳';
}
