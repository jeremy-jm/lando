// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '兰多·词典';

  @override
  String get settings => '设置';

  @override
  String get profile => '个人资料';

  @override
  String get user => '用户';

  @override
  String get about => '关于';

  @override
  String get notFound => '404';

  @override
  String get pageNotFound => '页面未找到';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeModeDescription => '在浅色、深色或跟随系统之间切换';

  @override
  String get followSystem => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get translation => '翻译';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get chinese => '中文';

  @override
  String get english => '英语';

  @override
  String get japanese => '日语';

  @override
  String get hindi => '印地语';

  @override
  String get indonesian => '印尼语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get russian => '俄语';

  @override
  String get pronunciationSource => '发音来源';

  @override
  String get pronunciationSourceDescription => '选择要使用的发音服务';

  @override
  String get pronunciationSystem => '系统';

  @override
  String get pronunciationYoudao => '有道';

  @override
  String get pronunciationBaidu => '百度';

  @override
  String get pronunciationBing => '必应';

  @override
  String get pronunciationGoogle => '谷歌';

  @override
  String get pronunciationApple => '苹果';

  @override
  String get me => '我的';

  @override
  String get favorites => '收藏';

  @override
  String get history => '查词记录';

  @override
  String get noHistory => '暂无查词记录';

  @override
  String get clearHistory => '清空历史';

  @override
  String get delete => '删除';

  @override
  String get confirmClearHistory => '确定要清空所有查词记录吗？';

  @override
  String get confirm => '确定';

  @override
  String get cancel => '取消';

  @override
  String get noFavorites => '暂无收藏';

  @override
  String get clearFavorites => '清空收藏';

  @override
  String get confirmClearFavorites => '确定要清空所有收藏吗？';

  @override
  String get cannotFavorite => '无法收藏：没有可用的翻译';

  @override
  String get removedFromFavorites => '已从收藏中移除';

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get general => '通用';

  @override
  String get dictionary => '词典';

  @override
  String get dictionarySettings => '词典设置';

  @override
  String get dictionarySettingsDescription => '配置发音和翻译设置';

  @override
  String get appDescription => '一款使用第三方服务进行查词且无广告的翻译软件';

  @override
  String get version => '版本';

  @override
  String get buildNumber => '构建号';

  @override
  String get versionInfo => '版本信息';

  @override
  String get versionInfoCopied => '版本信息已复制到剪贴板';

  @override
  String get copy => '复制';

  @override
  String get selectAll => '选择';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicyContent =>
      '本应用尊重您的隐私。我们不收集、存储或分享任何个人信息。所有翻译查询均通过第三方服务处理。';

  @override
  String get termsOfService => '服务条款';

  @override
  String get termsOfServiceContent =>
      '使用本应用即表示您同意负责任地使用。本应用通过第三方API提供翻译服务。我们对翻译的准确性不承担责任。';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get copyright => '版权所有 © 2024 兰多·词典。保留所有权利。';

  @override
  String get close => '关闭';

  @override
  String get aboutDescription => '关于本应用、版本信息和法律文档';

  @override
  String get noSuggestionsFound => '没有你要查询的内容';

  @override
  String get enterTextToTranslate => '输入要翻译的文本';

  @override
  String get playAudio => '播放音频';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get detectedAs => '识别为';

  @override
  String get pronunciationNotAvailable => '发音不可用';

  @override
  String get errorPlayingPronunciation => '播放发音时出错';

  @override
  String errorPlayingPronunciationWithDetails(String error) {
    return '播放发音时出错：$error';
  }

  @override
  String errorWithDetails(String error) {
    return '错误：$error';
  }

  @override
  String get partOfSpeech => '词性';

  @override
  String get tense => '时态';

  @override
  String get phrases => '短语';

  @override
  String get webTranslations => '网络翻译';

  @override
  String get navigateBack => '后退';

  @override
  String get navigateForward => '前进';

  @override
  String get shortcuts => '快捷键';

  @override
  String get showWindowHotkey => '显示窗口快捷键';

  @override
  String get showWindowHotkeyDescription => '设置全局快捷键以显示主窗口';

  @override
  String get currentHotkey => '当前快捷键';

  @override
  String get recordHotkey => '录制';

  @override
  String get recording => '录制中...';

  @override
  String get pressKeysToRecord => '按下按键进行录制...';

  @override
  String get hotkeySaved => '快捷键已保存';

  @override
  String get hotkeyRequiresModifier =>
      '请至少包含一个修饰键（Ctrl/Cmd、Alt 或 Shift），或使用 F1-F20';

  @override
  String get hotkeyRequiresValidKey => '请包含一个字母、数字或符号键';

  @override
  String get selectSourceLanguage => '选择源语言';

  @override
  String get selectTargetLanguage => '选择目标语言';

  @override
  String get auto => '自动';

  @override
  String get data => '数据';

  @override
  String get clearLocalData => '清除本地数据';

  @override
  String get clearLocalDataDescription => '清除所有本地存储的数据，包括设置、Cookie 和缓存';

  @override
  String get confirmClearLocalData => '确定要清除所有本地数据吗？此操作不可撤销。';

  @override
  String get localDataCleared => '本地数据已清除';

  @override
  String get proxySettings => '代理设置';

  @override
  String get proxySettingsDescription => '配置网络请求的 HTTP 代理';

  @override
  String get enableProxy => '启用代理';

  @override
  String get enableProxyDescription => '为所有网络请求启用 HTTP 代理';

  @override
  String get proxyHost => '代理地址';

  @override
  String get proxyHostHint => '例如：localhost';

  @override
  String get proxyPort => '代理端口';

  @override
  String get proxyPortHint => '例如：9091';

  @override
  String get validatingProxy => '正在验证代理连接...';

  @override
  String get proxyValidationSuccess => '代理连接成功';

  @override
  String get proxyValidationFailed => '无法连接到代理服务器';

  @override
  String get validateProxy => '验证代理';

  @override
  String get proxyConfigured => '代理已配置';

  @override
  String get proxyInfo => '代理信息';

  @override
  String get proxyInfoDescription =>
      '配置本地代理服务器（例如：localhost:9091）以将所有网络请求通过它路由。启用后，所有 API 调用都将使用此代理。';
}
