/// Abstract interface for translation services.
///
/// All translation service implementations (Youdao, Google, Bing, etc.)
/// should implement this interface to provide a consistent API.
abstract class TranslationService {
  /// The name of the translation service (e.g., "Youdao", "Google", "Bing").
  String get name;

  /// Translates the given [query] text and returns a human-readable result.
  ///
  /// [query] is the text to be translated.
  /// Returns a formatted string containing the translation result.
  /// Throws an exception if the translation fails.
  Future<String> translate(String query);
}
