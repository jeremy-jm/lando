import 'package:flutter/foundation.dart';

/// Service for notifying when window becomes visible/focused.
/// Used to trigger actions like selecting input field text.
class WindowVisibilityService {
  WindowVisibilityService._();
  static final WindowVisibilityService instance = WindowVisibilityService._();

  final ValueNotifier<bool> _windowShownNotifier = ValueNotifier<bool>(false);

  /// Stream of window visibility changes
  ValueNotifier<bool> get windowShownNotifier => _windowShownNotifier;

  /// Notify that window has been shown/focused
  void notifyWindowShown() {
    _windowShownNotifier.value = !_windowShownNotifier.value;
  }

  /// Dispose the service
  void dispose() {
    _windowShownNotifier.dispose();
  }
}
