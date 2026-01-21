/// Umeng analytics config via --dart-define.
///
/// Recommended:
/// - `--dart-define=UMENG_ANDROID_APPKEY=...`
/// - `--dart-define=UMENG_IOS_APPKEY=...`
/// - `--dart-define=UMENG_CHANNEL=AppStore`
/// - `--dart-define=UMENG_ENABLED=true`
///
/// Notes:
/// - Only used on Android/iOS. Other platforms will no-op.
/// - Leave keys empty to disable analytics without code changes.
class AnalyticsConfig {
  static const bool enabled = bool.fromEnvironment(
    'UMENG_ENABLED',
    defaultValue: true,
  );

  static const String umengAndroidAppKey = String.fromEnvironment(
    'UMENG_ANDROID_APPKEY',
    defaultValue: '6970ff086f259537c73f777c',
  );

  static const String umengIosAppKey = String.fromEnvironment(
    'UMENG_IOS_APPKEY',
    defaultValue: '6970fd559a7f3764883b2f2b',
  );

  static const String umengChannel = String.fromEnvironment(
    'UMENG_CHANNEL',
    defaultValue: 'AppStore',
  );
}
