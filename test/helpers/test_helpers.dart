import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test helper utilities for common test operations.
class TestHelpers {
  /// Initialize SharedPreferences for testing.
  static Future<void> initSharedPreferences() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  }

  /// Clear SharedPreferences for testing.
  static Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Create a MaterialApp wrapper for widget testing.
  static Widget createMaterialApp({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: child),
      localizationsDelegates: const [],
    );
  }

  /// Create a MaterialApp with localization for widget testing.
  static Widget createLocalizedMaterialApp({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Wait for async operations to complete.
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Pump widget and wait for async operations.
  static Future<void> pumpAndSettleAsync(
    WidgetTester tester, {
    Duration? duration,
  }) async {
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
  }
}
