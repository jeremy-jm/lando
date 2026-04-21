import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mdict_reader/mdict_reader.dart';
import 'package:path_provider/path_provider.dart';

/// Manages MDict dictionary files (.mdx) - loading, querying, and lifecycle.
///
/// Supports:
/// - Loading default bundled dictionary from assets
/// - Loading user-imported dictionaries from documents directory
/// - Fallback from primary to secondary dictionary
/// - Platform-aware file handling (mobile/desktop vs web)
class MdictManager {
  MdictManager._();
  static final MdictManager instance = MdictManager._();

  /// Primary dictionary instance (user's custom or default).
  MdictReader? _primary;

  /// Secondary dictionary instance (fallback, e.g. ECDICT).
  MdictReader? _secondary;

  /// Completer for initialization, used to wait for init before lookup.
  Completer<void>? _initCompleter;

  /// Whether initialization has completed.
  bool _initialized = false;

  /// Whether the manager is available on the current platform.
  /// MDict is NOT supported on Web.
  bool get isSupported => !kIsWeb;

  bool get isInitialized => _initialized;
  bool get hasDictionary => _primary != null || _secondary != null;

  /// Initializes the default dictionary from bundled assets.
  /// Auto-initializes on first lookup if not already initialized.
  ///
  /// On mobile/desktop: copies the bundled .mdx from assets to temp dir,
  /// then loads it via mdict_reader.
  /// On Web: skipped (mdict_reader doesn't support web).
  Future<void> initDefault({
    String assetPath = 'assets/mdict/ecdict.mdx',
    String? secondaryAssetPath,
  }) async {
    debugPrint('MdictManager.initDefault called, isSupported: $isSupported');

    // If already initializing or initialized, return
    if (_initCompleter != null) {
      debugPrint('MdictManager: already initializing, waiting...');
      await _initCompleter!.future;
      return;
    }

    _initCompleter = Completer<void>();

    if (!isSupported) {
      _initialized = true;
      _initCompleter!.complete();
      return;
    }

    try {
      // Load primary dictionary
      await _loadFromAsset(assetPath, isPrimary: true);
      debugPrint('MdictManager: primary loaded, hasDictionary: $hasDictionary');

      // Load secondary dictionary if provided
      if (secondaryAssetPath != null) {
        await _loadFromAsset(secondaryAssetPath, isPrimary: false);
      }

      _initialized = true;
      debugPrint(
          'MdictManager: initDefault complete, hasDictionary: $hasDictionary');
      _initCompleter!.complete();
    } catch (e, stack) {
      debugPrint('MdictManager init failed: $e');
      debugPrint('Stack: $stack');
      _initialized = true; // Mark as initialized to allow fallback to online
      _initCompleter!.completeError(e);
    }
  }

  /// Ensures the dictionary is initialized. Called automatically on first lookup.
  Future<void> _ensureInitialized() async {
    if (_initCompleter == null) {
      debugPrint('MdictManager: first access, starting lazy init...');
      // Start initialization in background
      initDefault();
    }
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      debugPrint('MdictManager: waiting for in-progress init...');
      await _initCompleter!.future;
    }
  }

  /// Loads a dictionary from an asset path.
  Future<void> _loadFromAsset(String assetPath,
      {required bool isPrimary}) async {
    try {
      // Check if asset exists
      final assetExists = await _assetExists(assetPath);
      if (!assetExists) {
        debugPrint('MdictManager: asset not found at $assetPath, skipping');
        return;
      }
      debugPrint('MdictManager: asset exists at $assetPath');

      // Copy asset to temp file (required for mdict_reader on mobile/desktop)
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final destPath = '${tempDir.path}/$fileName';
      debugPrint('MdictManager: temp path = $destPath');

      // Only copy if file doesn't exist or is outdated
      final destFile = File(destPath);
      if (!await destFile.exists()) {
        debugPrint('MdictManager: copying asset to temp...');
        final data = await rootBundle.load(assetPath);
        await destFile.writeAsBytes(data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ));
        debugPrint('MdictManager: asset copied to temp');
      } else {
        debugPrint('MdictManager: temp file already exists, skipping copy');
      }

      await _loadFromPath(destPath, isPrimary: isPrimary);
    } catch (e) {
      debugPrint('MdictManager: failed to load asset $assetPath: $e');
    }
  }

  /// Checks if an asset exists.
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Loads a dictionary from an absolute file path.
  Future<void> loadFromPath(String path, {bool isPrimary = true}) async {
    if (!isSupported) return;
    await _loadFromPath(path, isPrimary: isPrimary);
  }

  Future<void> _loadFromPath(String path, {required bool isPrimary}) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('MdictManager: file not found at $path');
        return;
      }
      debugPrint(
          'MdictManager: file exists at $path, size: ${await file.length()}');

      // mdict_reader's MdictReader constructor takes the file path directly
      debugPrint('MdictManager: creating MdictReader...');
      final reader = MdictReader(path);
      debugPrint('MdictManager: MdictReader created successfully');

      if (isPrimary) {
        _primary = reader;
      } else {
        _secondary = reader;
      }

      debugPrint(
          'MdictManager: loaded dictionary from $path, isPrimary: $isPrimary');
    } catch (e) {
      debugPrint('MdictManager: failed to load $path: $e');
    }
  }

  /// Looks up a word in the dictionaries (synchronous).
  ///
  /// Tries primary first, then secondary. Returns null if not found in any.
  /// Returns HTML content that needs to be parsed by [MdictHtmlParser].
  String? lookup(String word) {
    if (!isSupported) return null;
    if (!hasDictionary) return null;
    return _lookupSync(word);
  }

  /// Looks up a word asynchronously, waiting for initialization if needed.
  Future<String?> lookupAsync(String word) async {
    debugPrint(
        'MdictManager.lookupAsync called: "$word", isSupported: $isSupported, hasDictionary: $hasDictionary');

    if (!isSupported) return null;

    // Ensure dictionary is initialized (lazy init on first use)
    await _ensureInitialized();

    // Wait for initialization if still in progress
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      debugPrint('MdictManager: waiting for initialization...');
      try {
        await _initCompleter!.future;
      } catch (e) {
        debugPrint('MdictManager: init failed, cannot lookup: $e');
        return null;
      }
    }

    debugPrint('MdictManager: after wait, hasDictionary: $hasDictionary');
    if (!hasDictionary) return null;

    return _lookupSync(word);
  }

  String? _lookupSync(String word) {
    // Try primary dictionary
    if (_primary != null) {
      try {
        debugPrint('MdictManager: querying primary with "$word"');
        final result = _primary!.query(word);
        final preview =
            result?.substring(0, result.length > 100 ? 100 : result.length) ??
                'null';
        debugPrint('MdictManager: primary result: $preview...');
        if (result != null && result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        debugPrint('MdictManager: lookup failed in primary: $e');
      }
    } else {
      debugPrint('MdictManager: _primary is null!');
    }

    // Try secondary dictionary
    if (_secondary != null) {
      try {
        final result = _secondary!.query(word);
        if (result != null && result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        debugPrint('MdictManager: lookup failed in secondary: $e');
      }
    }

    return null;
  }

  /// Whether the last lookup found a result (for auto-fallback decision).
  bool _lastLookupFound = false;

  bool get lastLookupFound => _lastLookupFound;

  /// Looks up a word, returns true if found in any dictionary.
  bool lookupExists(String word) {
    if (!isSupported) return false;
    final result = lookup(word);
    _lastLookupFound = result != null && result.isNotEmpty;
    return _lastLookupFound;
  }

  /// Async version of lookupExists, waits for initialization.
  Future<bool> lookupExistsAsync(String word) async {
    if (!isSupported) return false;
    final result = await lookupAsync(word);
    _lastLookupFound = result != null && result.isNotEmpty;
    return _lastLookupFound;
  }

  /// Closes all dictionary resources.
  void dispose() {
    _primary = null;
    _secondary = null;
    _initialized = false;
    _initCompleter = null;
  }
}
