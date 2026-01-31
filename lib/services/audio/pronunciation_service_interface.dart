/// Interface for pronunciation services (TTS, Youdao, etc.).
abstract class PronunciationServiceInterface {
  /// Plays pronunciation for [text] in [languageCode], or from [url].
  Future<bool> speak({
    required String text,
    String? languageCode,
    String? url,
  });

  Future<void> stop();
  Future<void> pause();
  void dispose();
}
