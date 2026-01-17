import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:lando/services/audio/abstract_pronunciation_service.dart';

/// Youdao pronunciation service.
///
/// Plays pronunciation audio from Youdao's audio URLs.
class YoudaoPronunciationService implements AbstractPronunciationService {
  YoudaoPronunciationService() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<bool> speak({
    required String text,
    String? languageCode,
    String? url,
  }) async {
    // For Youdao service, we need a URL to play
    if (url == null || url.isEmpty) {
      debugPrint('Youdao pronunciation service requires a URL');
      return false;
    }

    try {
      await _player.play(UrlSource(url));
      return true;
    } catch (e) {
      debugPrint('Error playing Youdao pronunciation: $e');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping Youdao pronunciation: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing Youdao pronunciation: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
  }
}
