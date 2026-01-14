import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'routes/app_routes.dart';
import 'theme/theme_controller.dart';
import 'theme/app_colors.dart';
import 'localization/locale_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
