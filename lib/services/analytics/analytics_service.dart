import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:umeng_apm_sdk/umeng_apm_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:lando/services/analytics/analytics_config.dart';

/// Analytics facade for the app.
///
/// - Automatically no-ops on non-mobile platforms.
/// - Uses Umeng `pageStart/pageEnd` for page duration tracking.
/// - Uses Umeng `onEvent` for click/event counts (Umeng aggregates counts).
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  bool _initialized = false;
  bool _apmInitialized = false;

  bool get isInitialized => _initialized;
  bool get isApmInitialized => _apmInitialized;

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!_isMobile) return;
    if (!AnalyticsConfig.enabled) return;

    final androidKey = AnalyticsConfig.umengAndroidAppKey.trim();
    final iosKey = AnalyticsConfig.umengIosAppKey.trim();
    final channel = AnalyticsConfig.umengChannel.trim();

    if (androidKey.isEmpty || iosKey.isEmpty || channel.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[Analytics] Umeng disabled: missing UMENG_ANDROID_APPKEY / UMENG_IOS_APPKEY / UMENG_CHANNEL',
        );
      }
      return;
    }

    await UmengCommonSdk.initCommon(androidKey, iosKey, channel);
    UmengCommonSdk.setPageCollectionModeManual();
    _initialized = true;
  }

  /// Initialize APM SDK for error tracking.
  /// This should be called after the app is running to avoid binding conflicts.
  Future<void> initializeApm() async {
    if (_apmInitialized) return;
    if (!_isMobile) return;
    if (!AnalyticsConfig.enabled) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // Initialize Umeng APM SDK
      // Note: initFlutterBinding callback returns existing binding to avoid re-initialization
      final umengApmSdk = UmengApmSdk(
        name: appName,
        bver: appVersion,
        flutterVersion: '3.38.6',
        engineVersion: 'stable',
        enableLog: kDebugMode,
        enableTrackingPageFps: false,
        enableTrackingPagePerf: false,
        enableTrackingApi: false,
        errorFilter: {
          'mode': 'ignore',
          'rules': <RegExp>[],
        },
        initFlutterBinding: () => WidgetsBinding.instance,
      );

      // Initialize APM SDK
      await umengApmSdk.init(appRunner: (_) async {
        // App is already running, return a dummy widget
        return const SizedBox.shrink();
      });

      _apmInitialized = true;
      if (kDebugMode) {
        debugPrint('[Analytics] Umeng APM initialized for error tracking');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Analytics] Failed to initialize Umeng APM: $e');
      }
    }
  }

  void pageStart(String pageName) {
    if (!_initialized) return;
    UmengCommonSdk.onPageStart(pageName);
  }

  void pageEnd(String pageName) {
    if (!_initialized) return;
    UmengCommonSdk.onPageEnd(pageName);
  }

  /// Report an event.
  ///
  /// Umeng aggregates event counts on the server side, so calling this on every
  /// click is sufficient for "counting clicks".
  void event(
    String eventName, {
    Map<String, dynamic>? properties,
  }) {
    if (!_initialized) return;
    // Note: umeng_common_sdk uses positional args for onEvent in current API.
    UmengCommonSdk.onEvent(eventName, properties ?? <String, dynamic>{});
  }

  /// Wrap an action and report an event before executing.
  ///
  /// Use for button taps / gesture callbacks.
  VoidCallback wrapTap(
    String eventName,
    VoidCallback? action, {
    Map<String, dynamic>? properties,
  }) {
    return () {
      event(eventName, properties: properties);
      action?.call();
    };
  }

  /// Report an error/crash to Umeng APM.
  ///
  /// Use this to manually report caught exceptions or custom errors.
  void reportError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extra,
  }) {
    if (!_apmInitialized) {
      // Try to initialize APM if not already initialized
      unawaited(initializeApm());
      // Still try to report even if not initialized yet
    }
    try {
      // Umeng APM 2.3.5 uses ExceptionTrace.captureException
      // Convert error to Exception if it's not already
      final exception = error is Exception
          ? error
          : Exception(error.toString());
      ExceptionTrace.captureException(
        exception: exception,
        stack: stackTrace?.toString(),
        extra: extra,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Analytics] Failed to report error: $e');
      }
    }
  }

  /// Report a custom error message.
  ///
  /// Use this for non-exception errors (e.g., API failures, validation errors).
  void reportCustomError(
    String message, {
    Map<String, dynamic>? extra,
  }) {
    if (!_apmInitialized) {
      // Try to initialize APM if not already initialized
      unawaited(initializeApm());
      // Still try to report even if not initialized yet
    }
    try {
      // Use captureException for custom errors as well
      ExceptionTrace.captureException(
        exception: Exception(message),
        extra: extra,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Analytics] Failed to report custom error: $e');
      }
    }
  }
}

