import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lando/services/window/window_visibility_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Service for managing global hotkeys to toggle main window visibility.
/// Toggles between showing and hiding the window (not closing the application).
/// Only available on desktop platforms (Windows, macOS, Linux).
class HotkeyService {
  HotkeyService._();
  static final HotkeyService instance = HotkeyService._();

  HotKey? _currentHotKey;
  VoidCallback? _onHotkeyPressed;

  /// Initialize and register the hotkey from preferences.
  Future<void> initialize({VoidCallback? onHotkeyPressed}) async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }

    _onHotkeyPressed = onHotkeyPressed;
    await _loadAndRegisterHotkey();
  }

  /// Load hotkey from preferences and register it.
  Future<void> _loadAndRegisterHotkey() async {
    final saved = PreferencesStorage.getShowWindowHotkey();
    HotKey? hotkey;

    if (saved != null) {
      try {
        final parts = saved.split(':');
        if (parts.length == 2) {
          final keyId = int.parse(parts[0]);
          final modifiersValue = int.parse(parts[1]);

          // Find PhysicalKeyboardKey by keyId
          PhysicalKeyboardKey? physicalKey;
          // Try common keys first
          final commonKeys = [
            PhysicalKeyboardKey.keyA,
            PhysicalKeyboardKey.keyB,
            PhysicalKeyboardKey.keyC,
            PhysicalKeyboardKey.keyD,
            PhysicalKeyboardKey.keyE,
            PhysicalKeyboardKey.keyF,
            PhysicalKeyboardKey.keyG,
            PhysicalKeyboardKey.keyH,
            PhysicalKeyboardKey.keyI,
            PhysicalKeyboardKey.keyJ,
            PhysicalKeyboardKey.keyK,
            PhysicalKeyboardKey.keyL,
            PhysicalKeyboardKey.keyM,
            PhysicalKeyboardKey.keyN,
            PhysicalKeyboardKey.keyO,
            PhysicalKeyboardKey.keyP,
            PhysicalKeyboardKey.keyQ,
            PhysicalKeyboardKey.keyR,
            PhysicalKeyboardKey.keyS,
            PhysicalKeyboardKey.keyT,
            PhysicalKeyboardKey.keyU,
            PhysicalKeyboardKey.keyV,
            PhysicalKeyboardKey.keyW,
            PhysicalKeyboardKey.keyX,
            PhysicalKeyboardKey.keyY,
            PhysicalKeyboardKey.keyZ,
            PhysicalKeyboardKey.digit0,
            PhysicalKeyboardKey.digit1,
            PhysicalKeyboardKey.digit2,
            PhysicalKeyboardKey.digit3,
            PhysicalKeyboardKey.digit4,
            PhysicalKeyboardKey.digit5,
            PhysicalKeyboardKey.digit6,
            PhysicalKeyboardKey.digit7,
            PhysicalKeyboardKey.digit8,
            PhysicalKeyboardKey.digit9,
            PhysicalKeyboardKey.space,
            PhysicalKeyboardKey.enter,
            PhysicalKeyboardKey.escape,
            PhysicalKeyboardKey.f1,
            PhysicalKeyboardKey.f2,
            PhysicalKeyboardKey.f3,
            PhysicalKeyboardKey.f4,
            PhysicalKeyboardKey.f5,
            PhysicalKeyboardKey.f6,
            PhysicalKeyboardKey.f7,
            PhysicalKeyboardKey.f8,
            PhysicalKeyboardKey.f9,
            PhysicalKeyboardKey.f10,
            PhysicalKeyboardKey.f11,
            PhysicalKeyboardKey.f12,
            PhysicalKeyboardKey.f13,
            PhysicalKeyboardKey.f14,
            PhysicalKeyboardKey.f15,
            PhysicalKeyboardKey.f16,
            PhysicalKeyboardKey.f17,
            PhysicalKeyboardKey.f18,
            PhysicalKeyboardKey.f19,
            PhysicalKeyboardKey.f20,
            // Symbol keys on the right side of the keyboard or near Enter
            PhysicalKeyboardKey.quote, // ' or "
            PhysicalKeyboardKey.comma, // ,
            PhysicalKeyboardKey.period, // .
            PhysicalKeyboardKey.slash, // /
            PhysicalKeyboardKey.semicolon, // ;
            PhysicalKeyboardKey.minus, // -
            PhysicalKeyboardKey.equal, // =
            PhysicalKeyboardKey.bracketLeft, // [
            PhysicalKeyboardKey.bracketRight, // ]
            PhysicalKeyboardKey.backslash, // \
            PhysicalKeyboardKey.backquote, // `
          ];

          for (final key in commonKeys) {
            if (key.usbHidUsage == keyId) {
              physicalKey = key;
              break;
            }
          }

          // Fallback: create a key from keyId if not found
          if (physicalKey == null) {
            physicalKey = PhysicalKeyboardKey(keyId);
          }

          // Parse modifiers
          final modifiers = <HotKeyModifier>[];
          if (modifiersValue & 1 != 0) modifiers.add(HotKeyModifier.alt);
          if (modifiersValue & 2 != 0) modifiers.add(HotKeyModifier.control);
          if (modifiersValue & 4 != 0) modifiers.add(HotKeyModifier.shift);
          if (modifiersValue & 8 != 0) modifiers.add(HotKeyModifier.meta);

          hotkey = HotKey(
            key: physicalKey,
            modifiers: modifiers,
            scope: HotKeyScope.system,
          );
        }
      } catch (e) {
        debugPrint('Error loading hotkey: $e');
      }
    }

    // Set default hotkey if not loaded: Cmd+Alt+L on Mac, Ctrl+Alt+L on Windows/Linux
    if (hotkey == null) {
      final defaultModifiers = Platform.isMacOS
          ? [HotKeyModifier.meta, HotKeyModifier.alt]
          : [HotKeyModifier.control, HotKeyModifier.alt];
      hotkey = HotKey(
        key: PhysicalKeyboardKey.keyL,
        modifiers: defaultModifiers,
        scope: HotKeyScope.system,
      );
      // Save default
      int modifiersValue = 0;
      final mods = hotkey.modifiers;
      if (mods != null) {
        if (mods.contains(HotKeyModifier.alt)) modifiersValue |= 1;
        if (mods.contains(HotKeyModifier.control)) modifiersValue |= 2;
        if (mods.contains(HotKeyModifier.shift)) modifiersValue |= 4;
        if (mods.contains(HotKeyModifier.meta)) modifiersValue |= 8;
      }
      final physicalKey = hotkey.key as PhysicalKeyboardKey;
      await PreferencesStorage.saveShowWindowHotkey(
        '${physicalKey.usbHidUsage}:$modifiersValue',
      );
    }

    await registerHotkey(hotkey);
  }

  /// Register a hotkey.
  Future<void> registerHotkey(HotKey hotkey) async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }

    try {
      // Unregister old hotkey if exists
      if (_currentHotKey != null) {
        await hotKeyManager.unregister(_currentHotKey!);
      }

      // Register new hotkey
      await hotKeyManager.register(
        hotkey,
        keyDownHandler: (hotKey) async {
          // Toggle window visibility: show if hidden, hide if visible
          // Note: This hides/shows the window, NOT closes the application
          try {
            final isVisible = await windowManager.isVisible();
            if (isVisible) {
              // Window is visible, hide it (application continues running)
              await windowManager.hide();
            } else {
              // Window is hidden, show and focus it
              await windowManager.show();
              await windowManager.focus();
              // Notify that window has been shown
              WindowVisibilityService.instance.notifyWindowShown();
            }
          } catch (e) {
            debugPrint('Error toggling window visibility: $e');
            // Fallback: try to show if error occurs
            try {
              await windowManager.show();
              await windowManager.focus();
            } catch (e2) {
              debugPrint('Error showing window: $e2');
            }
          }
          _onHotkeyPressed?.call();
        },
      );

      _currentHotKey = hotkey;
      final physicalKey = hotkey.key as PhysicalKeyboardKey;
      debugPrint(
        'Hotkey registered: ${physicalKey.debugName} with modifiers ${hotkey.modifiers}',
      );
    } catch (e) {
      debugPrint('Error registering hotkey: $e');
      rethrow;
    }
  }

  /// Unregister the current hotkey.
  Future<void> unregisterHotkey() async {
    if (_currentHotKey != null) {
      await hotKeyManager.unregister(_currentHotKey!);
      _currentHotKey = null;
    }
  }

  /// Get the current hotkey.
  HotKey? get currentHotKey => _currentHotKey;

  /// Dispose the service.
  Future<void> dispose() async {
    await unregisterHotkey();
    _onHotkeyPressed = null;
  }
}
