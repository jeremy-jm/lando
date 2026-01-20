import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/hotkey/hotkey_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Widget for configuring global hotkey to toggle main window visibility.
/// Toggles between showing and hiding the window (not closing the application).
/// Only available on desktop platforms (Windows, macOS, Linux).
class HotkeySettingsWidget extends StatefulWidget {
  const HotkeySettingsWidget({super.key});

  @override
  State<HotkeySettingsWidget> createState() => _HotkeySettingsWidgetState();
}

class _HotkeySettingsWidgetState extends State<HotkeySettingsWidget> {
  HotKey? _currentHotKey;
  bool _isRecording = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHotkey();
  }

  Future<void> _loadHotkey() async {
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
      await _saveHotkey(hotkey);
    }

    setState(() {
      _currentHotKey = hotkey;
    });

    // Register the hotkey
    await _registerHotkey(hotkey);
  }

  Future<void> _saveHotkey(HotKey hotkey) async {
    // Calculate modifiers value
    int modifiersValue = 0;
    final mods = hotkey.modifiers;
    if (mods != null) {
      if (mods.contains(HotKeyModifier.alt)) modifiersValue |= 1;
      if (mods.contains(HotKeyModifier.control)) modifiersValue |= 2;
      if (mods.contains(HotKeyModifier.shift)) modifiersValue |= 4;
      if (mods.contains(HotKeyModifier.meta)) modifiersValue |= 8;
    }

    final physicalKey = hotkey.key as PhysicalKeyboardKey;
    final hotkeyString = '${physicalKey.usbHidUsage}:$modifiersValue';
    await PreferencesStorage.saveShowWindowHotkey(hotkeyString);
  }

  String _formatHotkey(HotKey? hotkey) {
    if (hotkey == null) return '';
    final modifiers = <String>[];
    final mods = hotkey.modifiers;
    if (mods != null && mods.contains(HotKeyModifier.control)) {
      modifiers.add(Platform.isMacOS ? '⌃' : 'Ctrl');
    }
    if (mods != null && mods.contains(HotKeyModifier.meta)) {
      modifiers.add(Platform.isMacOS ? '⌘' : 'Meta');
    }
    if (mods != null && mods.contains(HotKeyModifier.alt)) {
      modifiers.add(Platform.isMacOS ? '⌥' : 'Alt');
    }
    if (mods != null && mods.contains(HotKeyModifier.shift)) {
      modifiers.add(Platform.isMacOS ? '⇧' : 'Shift');
    }

    final physicalKey = hotkey.key as PhysicalKeyboardKey;
    final keyName = _getKeyName(physicalKey);
    return '${modifiers.join(' + ')} + $keyName';
  }

  String _getKeyName(PhysicalKeyboardKey key) {
    // Map common keys
    if (key == PhysicalKeyboardKey.space) return 'Space';
    if (key == PhysicalKeyboardKey.enter) return 'Enter';
    if (key == PhysicalKeyboardKey.escape) return 'Esc';

    // Map symbol keys to readable names
    final symbolKeyMap = {
      PhysicalKeyboardKey.quote: "'",
      PhysicalKeyboardKey.comma: ',',
      PhysicalKeyboardKey.period: '.',
      PhysicalKeyboardKey.slash: '/',
      PhysicalKeyboardKey.semicolon: ';',
      PhysicalKeyboardKey.minus: '-',
      PhysicalKeyboardKey.equal: '=',
      PhysicalKeyboardKey.bracketLeft: '[',
      PhysicalKeyboardKey.bracketRight: ']',
      PhysicalKeyboardKey.backslash: '\\',
      PhysicalKeyboardKey.backquote: '`',
    };
    if (symbolKeyMap.containsKey(key)) {
      return symbolKeyMap[key]!;
    }

    // Check for function keys F1-F20
    final keyName = key.debugName ?? '';
    final functionKeyPattern = RegExp(r'^F([1-9]|1[0-9]|20)$');
    if (functionKeyPattern.hasMatch(keyName)) {
      return keyName.toUpperCase();
    }

    // Try to extract letter from key name
    if (keyName.startsWith('Key ')) {
      return keyName.substring(4).toUpperCase();
    }

    // Check for digits
    if (keyName.startsWith('Digit ')) {
      return keyName.substring(6);
    }

    // Try to get from logical key
    try {
      final logicalKey = LogicalKeyboardKey.findKeyByKeyId(key.usbHidUsage);
      if (logicalKey != null) {
        final label = logicalKey.keyLabel;
        if (label.isNotEmpty && label.length == 1) {
          return label;
        }
      }
    } catch (e) {
      // Ignore
    }

    return keyName.isNotEmpty ? keyName : 'Key';
  }

  /// Check if a key is a function key (F1-F20)
  bool _isFunctionKey(PhysicalKeyboardKey key) {
    final keyName = key.debugName ?? '';
    // Check if it's F1-F20
    final functionKeyPattern = RegExp(r'^F([1-9]|1[0-9]|20)$');
    return functionKeyPattern.hasMatch(keyName);
  }

  /// Check if a key is a letter, digit, or single-char symbol
  bool _isValidKey(PhysicalKeyboardKey key) {
    // Function keys F1-F20 are valid
    if (_isFunctionKey(key)) {
      return true;
    }

    // Check if it's a letter (A-Z) - check common letter keys
    final commonLetters = [
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
    ];
    if (commonLetters.contains(key)) {
      return true;
    }

    // Check if it's a digit (0-9)
    final commonDigits = [
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
    ];
    if (commonDigits.contains(key)) {
      return true;
    }

    // Check if it's a symbol key (on the right side of keyboard or near Enter)
    final symbolKeys = [
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
    if (symbolKeys.contains(key)) {
      return true;
    }

    // Check if it's a single-char symbol by trying to get logical key
    try {
      final logicalKey = LogicalKeyboardKey.findKeyByKeyId(key.usbHidUsage);
      if (logicalKey != null) {
        final label = logicalKey.keyLabel;
        // Single character symbols are valid (like !, @, #, etc.)
        if (label.isNotEmpty && label.length == 1) {
          return true;
        }
      }
    } catch (e) {
      // Ignore
    }

    // Check by debug name for other keys
    final keyName = key.debugName ?? '';
    if (keyName.startsWith('Key ')) {
      final letter = keyName.substring(4);
      if (letter.length == 1) {
        return true; // Assume it's a valid key
      }
    }

    return false;
  }

  /// Validate hotkey according to rules:
  /// 1. Must have at least one modifier (Ctrl/Cmd, Alt, Shift) OR be F1-F20
  /// 2. Must have at least one letter/digit/symbol (unless it's F1-F20)
  String? _validateHotkey(HotKey hotkey) {
    final physicalKey = hotkey.key as PhysicalKeyboardKey;
    final modifiers = hotkey.modifiers;
    final hasModifiers = modifiers != null && modifiers.isNotEmpty;
    final isFunctionKey = _isFunctionKey(physicalKey);
    final isValidKey = _isValidKey(physicalKey);

    // Rule 1: F1-F20 can be used alone (no modifiers needed)
    if (isFunctionKey) {
      return null; // Valid
    }

    // Rule 2: Must have at least one modifier
    if (!hasModifiers) {
      return AppLocalizations.of(context)?.hotkeyRequiresModifier ??
          'Please include at least one modifier key (Ctrl/Cmd, Alt, or Shift), or use F1-F20';
    }

    // Rule 3: Must have a valid key (letter, digit, or symbol)
    if (!isValidKey) {
      return AppLocalizations.of(context)?.hotkeyRequiresValidKey ??
          'Please include a letter, digit, or symbol key';
    }

    return null; // Valid
  }

  /// Check if a hotkey only has modifiers without an actual key
  /// Returns true if the key itself is a modifier key (not a letter, digit, symbol, or function key)
  bool _isOnlyModifiers(HotKey hotkey) {
    final physicalKey = hotkey.key as PhysicalKeyboardKey;

    // If it's a valid key (letter, digit, symbol, or function key), it's not only modifiers
    if (_isValidKey(physicalKey)) {
      return false;
    }

    // Check if the key itself is a modifier key by name
    final keyName = physicalKey.debugName ?? '';
    final isModifierKey =
        keyName.contains('Control') ||
        keyName.contains('Alt') ||
        keyName.contains('Shift') ||
        keyName.contains('Meta') ||
        keyName.contains('Super');

    return isModifierKey;
  }

  Future<void> _onHotkeyRecorded(HotKey? newHotkey) async {
    if (newHotkey == null) {
      setState(() {
        _isRecording = false;
      });
      return;
    }

    // If only modifiers are pressed (no actual key), ignore and continue waiting
    if (_isOnlyModifiers(newHotkey)) {
      // Don't stop recording, just ignore this callback
      // The recorder will continue waiting for a valid key combination
      return;
    }

    // Validate hotkey
    final validationError = _validateHotkey(newHotkey);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
        _isRecording = false;
      });
      return;
    }

    try {
      // Unregister old hotkey
      if (_currentHotKey != null) {
        await hotKeyManager.unregister(_currentHotKey!);
      }

      // Register new hotkey
      await _registerHotkey(newHotkey);

      setState(() {
        _currentHotKey = newHotkey;
        _isRecording = false;
        _errorMessage = null;
      });

      await _saveHotkey(newHotkey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.hotkeySaved ?? 'Hotkey saved',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving hotkey: $e';
          _isRecording = false;
        });
      }
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _errorMessage = null;
    });
  }

  Future<void> _registerHotkey(HotKey hotkey) async {
    try {
      // Use HotkeyService to register the hotkey
      await HotkeyService.instance.registerHotkey(hotkey);
    } catch (e) {
      debugPrint('Error registering hotkey: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error registering hotkey: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Only show on desktop platforms
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(l10n?.showWindowHotkey ?? 'Show Window Hotkey'),
          subtitle: Text(
            l10n?.showWindowHotkeyDescription ??
                'Set a global hotkey to show the main window',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: _isRecording
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: _isRecording ? 2 : 1,
                  ),
                ),
                child: _isRecording
                    ? HotKeyRecorder(onHotKeyRecorded: _onHotkeyRecorded)
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.currentHotkey ?? 'Current Hotkey',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatHotkey(_currentHotKey),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _startRecording,
                            icon: const Icon(Icons.edit),
                            label: Text(l10n?.recordHotkey ?? 'Record'),
                          ),
                        ],
                      ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
