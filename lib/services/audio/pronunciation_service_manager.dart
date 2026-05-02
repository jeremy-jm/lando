import 'package:lando/services/audio/pronunciation_service_interface.dart';
import 'package:lando/services/audio/system_tts_pronunciation_service.dart';

/// Pronunciation uses the device system text-to-speech engine only.
class PronunciationServiceManager {
  PronunciationServiceManager._();

  static final PronunciationServiceManager _instance =
      PronunciationServiceManager._();

  factory PronunciationServiceManager() => _instance;

  PronunciationServiceInterface? _currentService;

  PronunciationServiceInterface getService() {
    if (_currentService != null) {
      return _currentService!;
    }
    _currentService = SystemTtsPronunciationService();
    return _currentService!;
  }

  Future<bool> speak({
    required String text,
    String? languageCode,
    String? url,
  }) async {
    final service = getService();
    return service.speak(
      text: text,
      languageCode: languageCode,
      url: url,
    );
  }

  Future<void> stop() async {
    await _currentService?.stop();
  }

  Future<void> pause() async {
    await _currentService?.pause();
  }

  void dispose() {
    _currentService?.dispose();
    _currentService = null;
  }
}
