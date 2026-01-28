import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Service for fetching and caching Bing Translator token.
///
/// The token is required for Bing translation API calls and can be found in:
/// 1. The Bing Translator page HTML/JavaScript
/// 2. Cookie 'btstkn'
/// 3. JavaScript variables in the page
class BingTokenService {
  BingTokenService._() {
    // Initialize Dio with cookie management
    _dio = Dio(BaseOptions(
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',
      },
    ));
  }

  static final BingTokenService instance = BingTokenService._();

  static const String _storageKey = 'bing_translation_token';
  static const String _storageKeyTimestamp = 'bing_translation_token_timestamp';
  static const String _storageKeyAllCookies = 'bing_translation_all_cookies';
  static const String _storageKeyIG = 'bing_translation_ig';
  static const String _storageKeyKey = 'bing_translation_key'; // Key from params_AbusePreventionHelper
  
  // Token expires after 24 hours (in milliseconds)
  static const int _tokenExpiryMs = 24 * 60 * 60 * 1000;
  
  String? _cachedToken;
  String? _cachedAllCookies; // Full cookie string for API calls
  String? _cachedIG; // IG parameter for API URL
  String? _cachedKey; // Key parameter from params_AbusePreventionHelper
  DateTime? _tokenTimestamp;

  // Dio instance with cookie management
  late final Dio _dio;

  // A conservative validator for tokens we can safely send.
  // Avoids capturing JS template strings like "+encodeURIComponent(u)+".
  // Tokens are typically alphanumeric with some special characters like - and _
  // Examples: "XpxazTiTwwcB4lETfrL81Z0tBLS4diew", "4upwCFTG-OrfXW_vGXi8T1VMJOl6Zkj8"
  static final RegExp _tokenValueValidator = RegExp(
    r'^[A-Za-z0-9_\-]{15,}$', // Minimum 15 chars, alphanumeric, underscore, hyphen
  );

  /// Gets the Bing translation token, fetching it if necessary.
  ///
  /// Returns null if token cannot be fetched.
  Future<String?> getToken({bool forceRefresh = false}) async {
    // Check if we have a valid cached token
    if (!forceRefresh && _cachedToken != null && _isTokenValid()) {
      return _cachedToken;
    }

    // Try to load from storage
    if (!forceRefresh) {
      await _loadFromStorage();
      if (_cachedToken != null && _isTokenValid()) {
        return _cachedToken;
      }
    }

    // Fetch new token from Bing Translator page
    try {
      final ok = await initializeSession(forceRefresh: forceRefresh);
      if (ok && _cachedToken != null) {
        return _cachedToken;
      }
    } catch (e) {
      debugPrint('BingTokenService: Failed to fetch token: $e');
    }

    // If fetching fails, try to use stored token even if expired
    if (_cachedToken != null) {
      return _cachedToken;
    }

    return null;
  }

  /// Gets all cookies as a string for API calls.
  /// This should be called after initializing the session.
  Future<String?> getAllCookies() async {
    if (_cachedAllCookies != null) {
      return _cachedAllCookies;
    }

    // Try to load from storage
    await _loadFromStorage();
    if (_cachedAllCookies != null) {
      return _cachedAllCookies;
    }

    // Initialize session to get cookies
    await initializeSession();
    return _cachedAllCookies;
  }

  /// Gets the IG parameter for API URL.
  Future<String?> getIG() async {
    if (_cachedIG != null) {
      return _cachedIG;
    }

    // Try to load from storage
    await _loadFromStorage();
    if (_cachedIG != null) {
      return _cachedIG;
    }

    // Initialize session to get IG
    await initializeSession();
    return _cachedIG;
  }

  /// Gets the key parameter for API requests.
  /// This is the first element from params_AbusePreventionHelper array.
  Future<String?> getKey() async {
    if (_cachedKey != null) {
      return _cachedKey;
    }

    // Try to load from storage
    await _loadFromStorage();
    if (_cachedKey != null) {
      return _cachedKey;
    }

    // Initialize session to get key
    await initializeSession();
    return _cachedKey;
  }

  /// Initializes the session by fetching the translator page.
  /// This extracts token, cookies, and IG parameter.
  Future<bool> initializeSession({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        _cachedToken = null;
        _cachedAllCookies = null;
        _cachedIG = null;
        _cachedKey = null;
        _tokenTimestamp = null;
      }

      final response = await _dio.get<String>(
        'https://www.bing.com/translator',
        options: Options(
          headers: _getPageHeaders(),
          followRedirects: true,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint(
            'BingTokenService: Failed to fetch page, status: ${response.statusCode}');
        return false;
      }

      final html = response.data!;

      // Extract all cookies from response headers
      final allCookies = _extractAllCookies(response.headers);
      if (allCookies != null && allCookies.isNotEmpty) {
        _cachedAllCookies = allCookies;
      } else {
        debugPrint('BingTokenService: ⚠️ No cookies extracted from response');
      }

      // Extract token and key from params_AbusePreventionHelper
      final tokenData = _extractTokenAndKeyFromHTML(html);
      if (tokenData != null && tokenData['token'] != null) {
        _cachedToken = tokenData['token'];
        _cachedKey = tokenData['key'];
        _tokenTimestamp = DateTime.now();
      } else {
        // Fallback: try to extract just token
        final token = _extractTokenFromHTML(html);
        if (token != null) {
          _cachedToken = token;
          _tokenTimestamp = DateTime.now();
        }
      }

      // Extract IG parameter from HTML or cookies
      final ig = _extractIG(html, allCookies);
      if (ig != null) {
        _cachedIG = ig;
      }

      // Save to storage
      await _saveToStorage();

      return _cachedToken != null && allCookies != null;
    } catch (e) {
      debugPrint('BingTokenService: Error initializing session: $e');
      return false;
    }
  }

  /// Gets standard headers for page requests.
  Map<String, String> _getPageHeaders() {
    return {
      'accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
      'cache-control': 'max-age=0',
      'referer': 'https://www.bing.com/',
      'sec-ch-ua':
          '"Not(A:Brand";v="8", "Chromium";v="144", "Google Chrome";v="144"',
      'sec-ch-ua-arch': '"arm"',
      'sec-ch-ua-bitness': '"64"',
      'sec-ch-ua-full-version': '"144.0.7559.97"',
      'sec-ch-ua-full-version-list':
          '"Not(A:Brand";v="8.0.0.0", "Chromium";v="144.0.7559.97", "Google Chrome";v="144.0.7559.97"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-model': '""',
      'sec-ch-ua-platform': '"macOS"',
      'sec-ch-ua-platform-version': '"26.2.0"',
      'sec-fetch-dest': 'document',
      'sec-fetch-mode': 'navigate',
      'sec-fetch-site': 'same-origin',
      'sec-fetch-user': '?1',
      'upgrade-insecure-requests': '1',
    };
  }

  /// Extracts all cookies from response headers and formats them as a cookie string.
  String? _extractAllCookies(Headers headers) {
    final setCookieValues = headers.map['set-cookie'] ?? const [];
    if (setCookieValues.isEmpty) {
      return null;
    }

    final cookies = <String>[];
    final cookieNames = <String>{};
    
    for (final setCookie in setCookieValues) {
      // Extract cookie name and value (before first semicolon)
      final parts = setCookie.split(';');
      if (parts.isNotEmpty) {
        final cookiePair = parts[0].trim();
        if (cookiePair.isNotEmpty) {
          // Extract cookie name to check for duplicates
          final nameMatch = RegExp(r'^([^=]+)=').firstMatch(cookiePair);
          if (nameMatch != null) {
            final cookieName = nameMatch.group(1)!;
            // Only add if we haven't seen this cookie name before
            // (later cookies override earlier ones)
            if (!cookieNames.contains(cookieName)) {
              cookies.add(cookiePair);
              cookieNames.add(cookieName);
            } else {
              // Replace existing cookie with same name
              final index = cookies.indexWhere((c) => c.startsWith('$cookieName='));
              if (index >= 0) {
                cookies[index] = cookiePair;
              }
            }
          } else {
            // If no '=' found, add as-is
            cookies.add(cookiePair);
          }
        }
      }
    }

    if (cookies.isEmpty) {
      return null;
    }

    return cookies.join('; ');
  }

  /// Extracts IG parameter from HTML or cookies.
  String? _extractIG(String html, String? allCookies) {
    // Try to extract from HTML first
    // IG might be in: var params = {IG: "...", ...} or IG="..."
    final igPatterns = [
      RegExp(r'\bIG\s*[:=]\s*["\x27]([A-Z0-9]{32})["\x27]',
          caseSensitive: false),
      RegExp(r'["\x27]IG["\x27]\s*:\s*["\x27]([A-Z0-9]{32})["\x27]',
          caseSensitive: false),
      RegExp(r'IG=([A-Z0-9]{32})', caseSensitive: false),
    ];

    for (final pattern in igPatterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        final ig = match.group(1);
        if (ig != null && ig.length == 32) {
          return ig;
        }
      }
    }

    // Try to extract from cookies (SRCHHPGUSR contains IG)
    if (allCookies != null) {
      final srchhpgusrPattern =
          RegExp(r'SRCHHPGUSR=[^;]*&IG=([A-Z0-9]{32})', caseSensitive: false);
      final match = srchhpgusrPattern.firstMatch(allCookies);
      if (match != null) {
        final ig = match.group(1);
        if (ig != null && ig.length == 32) {
          return ig;
        }
      }
    }

    return null;
  }

  /// Checks if the cached token is still valid.
  bool _isTokenValid() {
    if (_tokenTimestamp == null) {
      return false;
    }
    final age = DateTime.now().difference(_tokenTimestamp!);
    return age.inMilliseconds < _tokenExpiryMs;
  }

  /// Extracts both token and key from params_AbusePreventionHelper array.
  /// Returns a map with 'token' and 'key' keys, or null if not found.
  Map<String, String>? _extractTokenAndKeyFromHTML(String html) {
    // Primary pattern: Extract token and key from params_AbusePreventionHelper array
    // Format: params_AbusePreventionHelper = [<key>, "<token>", <ttl>]
    final abusePattern = RegExp(
      r'params_AbusePreventionHelper\s*=\s*\[\s*(\d+)\s*,\s*"([^"]+)"\s*,\s*(\d+)\s*\]',
      caseSensitive: false,
      dotAll: true,
    );
    final abuseMatch = abusePattern.firstMatch(html);
    if (abuseMatch != null) {
      final key = abuseMatch.group(1);
      final token = abuseMatch.group(2);
      
      if (token != null &&
          key != null &&
          token.length > 10 &&
          _tokenValueValidator.hasMatch(token)) {
        return {
          'token': token,
          'key': key,
        };
      }
    }

    // Try flexible pattern (2 or 3 elements)
    final flexiblePattern = RegExp(
      r'params_AbusePreventionHelper\s*=\s*\[\s*(\d+)\s*,\s*"([^"]+)"',
      caseSensitive: false,
      dotAll: true,
    );
    final flexibleMatch = flexiblePattern.firstMatch(html);
    if (flexibleMatch != null) {
      final key = flexibleMatch.group(1);
      final token = flexibleMatch.group(2);
      if (token != null &&
          key != null &&
          token.length > 10 &&
          _tokenValueValidator.hasMatch(token)) {
        return {
          'token': token,
          'key': key,
        };
      }
    }

    return null;
  }

  /// Extracts token from HTML using multiple patterns (fallback method).
  String? _extractTokenFromHTML(String html) {
    // First try to get token and key together
    final tokenData = _extractTokenAndKeyFromHTML(html);
    if (tokenData != null && tokenData['token'] != null) {
      return tokenData['token'];
    }

    // Try flexible pattern
    final flexiblePattern = RegExp(
      r'params_AbusePreventionHelper\s*=\s*\[\s*(\d+)\s*,\s*"([^"]+)"',
      caseSensitive: false,
      dotAll: true,
    );
    final flexibleMatch = flexiblePattern.firstMatch(html);
    if (flexibleMatch != null) {
      final token = flexibleMatch.group(2);
      if (token != null &&
          token.length > 10 &&
          _tokenValueValidator.hasMatch(token)) {
        return token;
      }
    }

    return null;
  }

  /// Loads token and cookie from storage.
  Future<void> _loadFromStorage() async {
    try {
      final prefs = PreferencesStorage.prefs;
      _cachedToken = prefs.getString(_storageKey);
      _cachedAllCookies = prefs.getString(_storageKeyAllCookies);
      _cachedIG = prefs.getString(_storageKeyIG);
      _cachedKey = prefs.getString(_storageKeyKey);

      final timestampStr = prefs.getString(_storageKeyTimestamp);
      if (timestampStr != null) {
        _tokenTimestamp = DateTime.parse(timestampStr);
      }
    } catch (e) {
      debugPrint('BingTokenService: Error loading from storage: $e');
    }
  }

  /// Saves token and cookie to storage.
  Future<void> _saveToStorage() async {
    try {
      final prefs = PreferencesStorage.prefs;
      if (_cachedToken != null) {
        await prefs.setString(_storageKey, _cachedToken!);
      }
      if (_cachedAllCookies != null) {
        await prefs.setString(_storageKeyAllCookies, _cachedAllCookies!);
      }
      if (_cachedIG != null) {
        await prefs.setString(_storageKeyIG, _cachedIG!);
      }
      if (_cachedKey != null) {
        await prefs.setString(_storageKeyKey, _cachedKey!);
      }
      if (_tokenTimestamp != null) {
        await prefs.setString(
            _storageKeyTimestamp, _tokenTimestamp!.toIso8601String());
      }
    } catch (e) {
      debugPrint('BingTokenService: Error saving to storage: $e');
    }
  }

  /// Clears cached token and cookie.
  Future<void> clearCache() async {
    _cachedToken = null;
    _cachedAllCookies = null;
    _cachedIG = null;
    _cachedKey = null;
    _tokenTimestamp = null;
    
    try {
      final prefs = PreferencesStorage.prefs;
      await prefs.remove(_storageKey);
      await prefs.remove(_storageKeyAllCookies);
      await prefs.remove(_storageKeyIG);
      await prefs.remove(_storageKeyKey);
      await prefs.remove(_storageKeyTimestamp);
    } catch (e) {
      debugPrint('BingTokenService: Error clearing cache: $e');
    }
  }
}
