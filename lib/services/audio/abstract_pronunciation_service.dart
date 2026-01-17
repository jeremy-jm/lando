/// Abstract interface for pronunciation services.
///
/// Different pronunciation services implement this interface to provide
/// pronunciation functionality from various sources (system TTS, Youdao, etc.)
abstract class AbstractPronunciationService {
  /// Plays pronunciation for the given [text] in the specified [languageCode].
  ///
  /// For system TTS services, this will use text-to-speech.
  /// For URL-based services (Youdao, etc.), this will use the provided [url].
  ///
  /// Returns true if playback started successfully, false otherwise.
  Future<bool> speak({
    required String text,
    String? languageCode,
    String? url,
  });

  /// Stops the currently playing audio.
  Future<void> stop();

  /// Pauses the currently playing audio.
  Future<void> pause();

  /// Disposes the service and releases resources.
  void dispose();
}
