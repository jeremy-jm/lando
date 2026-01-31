import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_navigator_observer.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/services/analytics/analytics_tap_capture.dart';
import 'package:lando/services/hotkey/hotkey_service.dart';
import 'package:lando/services/translation/bing_token_service.dart';
import 'package:lando/services/window/window_visibility_service.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:lando/theme/app_colors.dart';
import 'package:lando/theme/theme_controller.dart';

void main() async {
  // Set up global error handlers for crash tracking first
  // This must be done before runZonedGuarded to catch errors during initialization
  _setupErrorHandlers();

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Required for iOS: do not await before runApp or the first frame stays white.
      // Run minimal root (_IosDeferredApp) immediately; init runs after first frame.
      if (Platform.isIOS) {
        runApp(const _IosDeferredApp());
        return;
      }

      await _runAppInit();
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // Suppress known harmless keyboard state assertion (never report or show)
      if (_isKeyboardStateSyncAssertion(error, stackTrace)) {
        if (kDebugMode) {
          debugPrint(
            '[Suppressed] Keyboard state sync in zone (harmless): $error',
          );
        }
        return;
      }
      // Report uncaught errors to Umeng APM
      AnalyticsService.instance.reportError(
        error,
        stackTrace,
        extra: <String, dynamic>{
          'type': 'uncaught_error',
          'platform': Platform.operatingSystem,
        },
      );
      // Also log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
          ),
        );
      }
    },
  );
}

/// All initialization that must complete before showing the full app.
Future<void> _runAppInit() async {
  await PreferencesStorage.init();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
    await hotKeyManager.unregisterAll();
    await HotkeyService.instance.initialize();
  }

  await ThemeController.instance.init();
  await LocaleController.instance.init();

  unawaited(
    BingTokenService.instance.getToken().then((token) {
      debugPrint('Bing token fetched on startup: ${token ?? '(null)'}');
      return token;
    }).catchError((e, stackTrace) {
      debugPrint('Failed to fetch Bing token on startup: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }),
  );

  try {
    await AnalyticsService.instance.initialize();
    if (Platform.isAndroid || Platform.isIOS) {
      await AnalyticsService.instance.initializeApm();
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('Analytics init failed (app will still run): $e');
      debugPrint('Stack: $stackTrace');
    }
  }
}

bool _isKeyboardStateSyncAssertion(Object error, StackTrace? stackTrace) {
  // Flutter HardwareKeyboard assertion: KeyDownEvent when key already pressed,
  // or KeyUpEvent when key not pressed. Common with global hotkeys or key repeat.
  if (error is! AssertionError) return false;
  final message = error.message?.toString() ?? '';
  final stack = stackTrace?.toString() ?? '';
  final isFromHardwareKeyboard = stack.contains('hardware_keyboard.dart');
  final isKeyStateSync = message.contains('physical key is already pressed') ||
      message.contains('physical key is not pressed');
  return isFromHardwareKeyboard && isKeyStateSync;
}

void _setupErrorHandlers() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final library = details.library ?? '';
    final stack = details.stack?.toString() ?? '';

    // Filter out known harmless keyboard state assertion (HardwareKeyboard).
    // Occurs when global hotkeys or key repeat cause Flutter's key state to desync.
    // Note: "Exception caught by services library" is printed by Flutter before
    // this handler; we only suppress our reporting and dialog.
    if (exception is AssertionError) {
      final message = exception.message?.toString() ?? '';
      final fromKeyboard = library.contains('hardware_keyboard.dart') ||
          stack.contains('hardware_keyboard.dart');
      final keyStateSync =
          message.contains('physical key is already pressed') ||
              message.contains('physical key is not pressed');
      if (fromKeyboard && keyStateSync) {
        if (kDebugMode) {
          debugPrint(
            '[Suppressed] Keyboard state sync (harmless): ${exception.message}',
          );
        }
        return;
      }
    }

    // Report Flutter errors to Umeng APM
    AnalyticsService.instance.reportError(
      details.exception,
      details.stack,
      extra: <String, dynamic>{
        'type': 'flutter_error',
        'library': details.library,
        'context': details.context?.toString(),
        'platform': Platform.operatingSystem,
      },
    );
    // Also log to console in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };
}

/// On iOS, show a minimal first frame then the full app to avoid white screen.
class _IosDeferredApp extends StatefulWidget {
  const _IosDeferredApp();

  @override
  State<_IosDeferredApp> createState() => _IosDeferredAppState();
}

class _IosDeferredAppState extends State<_IosDeferredApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // First frame: show "Hello" with no init (matches "only simple code works" case).
    // After first frame, run full init then show MyApp (always switch even if init fails).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _runAppInit().timeout(
          const Duration(microseconds: 10),
          onTimeout: () {
            if (kDebugMode)
              debugPrint('iOS deferred init timeout, showing app anyway');
          },
        );
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('iOS deferred init error: $e');
          debugPrint('$st');
        }
      }
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return const MyApp();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    _initWindowManager();
  }

  Future<void> _initWindowManager() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Hide window instead of closing when user clicks close button
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await windowManager.hide();
    }
  }

  @override
  void onWindowFocus() {
    // Notify that window has gained focus
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      WindowVisibilityService.instance.notifyWindowShown();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: LocaleController.instance,
          builder: (context, _) {
            return MaterialApp(
              title: 'Lando Dictionary',
              builder: (context, child) {
                return AnalyticsTapCapture(
                  child: child ?? const SizedBox.shrink(),
                );
              },
              // Localization configuration
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocaleController.supportedLocales,
              locale: LocaleController.instance.locale,
              // Theme configuration
              themeMode: ThemeController.instance.mode,
              theme: ThemeData(
                colorScheme: AppColors.getLightColorScheme(),
                useMaterial3: true,
                bottomNavigationBarTheme: AppColors.getLightBottomNavTheme(),
              ),
              darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                colorScheme: AppColors.getDarkColorScheme(),
                bottomNavigationBarTheme: AppColors.getDarkBottomNavTheme(),
              ),
              // Routing configuration
              initialRoute: AppRoutes.home,
              routes: AppRoutes.getRoutes(),
              onGenerateRoute: AppRoutes.generateRoute,
              navigatorObservers: [AnalyticsNavigatorObserver.instance],
            );
          },
        );
      },
    );
  }
}
