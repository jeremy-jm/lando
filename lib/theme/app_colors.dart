import 'package:flutter/material.dart';

/// Application color management class
/// Centralized management of all color configurations, including light and dark modes
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ==================== Theme Colors ====================
  /// Primary seed color - light blue
  static const Color primarySeedColor = Colors.lightBlue;

  // ==================== Light Mode Colors ====================
  /// Light mode - background color
  static const Color lightBackground = Colors.white;

  /// Light mode - bottom navigation bar background color
  static const Color lightBottomNavBackground = Colors.white;

  /// Light mode - bottom navigation bar selected item color
  static const Color lightBottomNavSelected = Colors.lightBlue;

  /// Light mode - bottom navigation bar unselected item color
  static const Color lightBottomNavUnselected = Colors.grey;

  /// Light mode - AppBar background color (uses theme's inversePrimary)
  /// Note: In actual use, get it through Theme.of(context).colorScheme.inversePrimary

  // ==================== Dark Mode Colors ====================
  /// Dark mode - background color
  static const Color darkBackground = Color(0xFF121212);

  /// Dark mode - bottom navigation bar background color
  static const Color darkBottomNavBackground = Color(0xFF1E1E1E);

  /// Dark mode - bottom navigation bar selected item color
  static Color get darkBottomNavSelected => Colors.lightBlue.shade300;

  /// Dark mode - bottom navigation bar unselected item color
  static Color get darkBottomNavUnselected => Colors.grey.shade600;

  // ==================== Common Colors ====================
  /// Text color - light mode
  static const Color lightText = Colors.black87;

  /// Text color - dark mode
  static const Color darkText = Colors.white70;

  /// Secondary text color - light mode
  static const Color lightSecondaryText = Colors.black54;

  /// Secondary text color - dark mode
  static const Color darkSecondaryText = Colors.white54;

  /// Divider color - light mode
  static const Color lightDivider = Colors.grey;

  /// Divider color - dark mode
  static const Color darkDivider = Colors.grey;

  /// Error color
  static const Color error = Colors.red;

  /// Success color
  static const Color success = Colors.green;

  /// Warning color
  static const Color warning = Colors.orange;

  /// Info color
  static const Color info = Colors.blue;

  // ==================== Theme Data Generation Methods ====================

  /// Get light theme ColorScheme
  static ColorScheme getLightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
    );
  }

  /// Get dark theme ColorScheme
  static ColorScheme getDarkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
    );
  }

  /// Get light theme BottomNavigationBarThemeData
  static BottomNavigationBarThemeData getLightBottomNavTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: lightBottomNavBackground,
      selectedItemColor: lightBottomNavSelected,
      unselectedItemColor: lightBottomNavUnselected,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
  }

  /// Get dark theme BottomNavigationBarThemeData
  static BottomNavigationBarThemeData getDarkBottomNavTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: darkBottomNavBackground,
      selectedItemColor: darkBottomNavSelected,
      unselectedItemColor: darkBottomNavUnselected,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
  }

  /// Get text color based on current theme mode
  static Color getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkText : lightText;
  }

  /// Get secondary text color based on current theme mode
  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? darkSecondaryText
        : lightSecondaryText;
  }

  /// Get background color based on current theme mode
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }
}
