import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/localization/locale_controller.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/hotkey/hotkey_service.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:lando/theme/app_colors.dart';
import 'package:lando/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await PreferencesStorage.init();

  // Initialize window manager and hotkey manager for desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Initialize window manager
    await windowManager.ensureInitialized();

    // Prevent window from closing (hide instead)
    // This allows the app to stay running when window is hidden
    await windowManager.setPreventClose(true);

    // Initialize hotkey manager
    await hotKeyManager.unregisterAll();

    // Initialize hotkey service
    await HotkeyService.instance.initialize();
  }

  // Initialize controllers with saved preferences
  await ThemeController.instance.init();
  await LocaleController.instance.init();

  runApp(const MyApp());
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
            );
          },
        );
      },
    );
  }
}
