import 'package:flutter/material.dart';
import 'package:lando/features/home/home_page.dart';
import 'package:lando/features/me/about_page.dart';
import 'package:lando/features/me/not_found_page.dart';
import 'package:lando/features/me/profile_page.dart';
import 'package:lando/features/me/settings_page.dart';

/// Route name constants class
/// Centralized management of all route names to avoid hardcoded strings
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route name constants
  static const String home = '/';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String about = '/about';

  /// Route generator
  /// Returns the corresponding Widget based on route name
  static Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MyHomePage(title: 'Lando Dictionary'),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: routeSettings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: routeSettings,
        );
      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutPage(),
          settings: routeSettings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
          settings: routeSettings,
        );
    }
  }

  /// Get all route configurations
  /// Used for MaterialApp's routes parameter
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (_) => const MyHomePage(title: 'Lando Dictionary'),
      settings: (_) => const SettingsPage(),
      profile: (_) => const ProfilePage(),
      about: (_) => const AboutPage(),
    };
  }
}

/// Route navigation utility class
/// Provides convenient navigation methods
class AppNavigator {
  AppNavigator._();

  /// Navigate to specified route
  static Future<T?>? pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Replace current route
  static Future<T?>? pushReplacementNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Pop and navigate to new route
  static Future<T?>? popAndPushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.popAndPushNamed<T, T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Pop until specified route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Pop current route
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Navigate to home page and clear all route stack
  static void pushAndRemoveUntilHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MyHomePage(title: 'Lando Dictionary'),
      ),
      (route) => false,
    );
  }
}
