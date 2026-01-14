import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'theme/theme_controller.dart';
import 'theme/app_colors.dart';

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
        return MaterialApp(
          title: 'Lando Dictionary',
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
          initialRoute: AppRoutes.home,
          routes: AppRoutes.getRoutes(),
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
