import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing pronunciation audio.
class PronunciationService {
  PronunciationService() : _player = AudioPlayer();

  final AudioPlayer _player;

  /// Plays pronunciation audio from the given [url].
  ///
  /// Returns true if playback started successfully, false otherwise.
  Future<bool> play(String url) async {
    if (url.isEmpty) {
      return false;
    }

    try {
      await _player.play(UrlSource(url));
      return true;
    } catch (e) {
      debugPrint('Error playing pronunciation: $e');
      return false;
    }
  }

  /// Stops the currently playing audio.
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping pronunciation: $e');
    }
  }

  /// Pauses the currently playing audio.
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing pronunciation: $e');
    }
  }

  /// Disposes the audio player.
  void dispose() {
    _player.dispose();
  }
}
