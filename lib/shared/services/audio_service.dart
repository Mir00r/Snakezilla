import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/models/settings_model.dart';

/// Manages all audio playback: sound effects and background music.
///
/// Usage:
/// ```dart
/// final audio = ref.read(audioServiceProvider);
/// audio.playEat();
/// ```
///
/// Sound files are expected in `assets/audio/`:
/// * `eat.mp3`
/// * `game_over.mp3`
/// * `tap.mp3`
/// * `bgm.mp3`
class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  /// Pre-configures the audio players (loop mode, volume).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.3);
    await _sfxPlayer.setVolume(0.6);
  }

  /// Synchronises audio behaviour with the current [settings].
  void updateSettings(SettingsModel settings) {
    _soundEnabled = settings.soundEnabled;
    _musicEnabled = settings.musicEnabled;
    if (!_musicEnabled) {
      _musicPlayer.stop();
    }
  }

  // ── Sound Effects ──────────────────────────────────────────────────────────

  /// Plays a short "eat" blip.
  Future<void> playEat() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/eat.mp3'));
    } catch (_) {
      // Gracefully ignore missing audio assets during development.
    }
  }

  /// Plays the game-over jingle.
  Future<void> playGameOver() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/game_over.mp3'));
    } catch (_) {}
  }

  /// Plays a subtle UI tap sound.
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/tap.mp3'));
    } catch (_) {}
  }

  // ── Background Music ──────────────────────────────────────────────────────

  /// Starts the looping background music track.
  Future<void> startMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (_) {}
  }

  /// Stops background music immediately.
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Releases native audio resources.
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

/// Singleton [AudioService] available via Riverpod.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
