import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/models/settings_model.dart';

/// Manages all audio playback: sound effects and background music.
///
/// Sound files are expected in `assets/audio/`:
/// * `eat.wav`   – cheerful ascending chirp
/// * `game_over.wav` – sad descending tone
/// * `tap.wav`   – short UI click
/// * `bgm.wav`   – looping background melody
class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  /// Current music intensity (0 = calm, 1 = normal, 2 = intense).
  int _musicIntensity = 1;

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
      await _sfxPlayer.play(AssetSource('audio/eat.wav'));
    } catch (_) {
      // Gracefully ignore missing audio assets during development.
    }
  }

  /// Plays the game-over jingle.
  Future<void> playGameOver() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/game_over.wav'));
    } catch (_) {}
  }

  /// Plays a subtle UI tap sound.
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/tap.wav'));
    } catch (_) {}
  }

  /// Plays a special combo sound (higher pitch eat).
  Future<void> playCombo() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setPlaybackRate(1.5);
      await _sfxPlayer.play(AssetSource('audio/eat.wav'));
      // Reset playback rate after a delay
      Future.delayed(const Duration(milliseconds: 200), () {
        _sfxPlayer.setPlaybackRate(1.0);
      });
    } catch (_) {}
  }

  /// Plays a power-up pickup sound (low pitch eat).
  Future<void> playPowerUp() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setPlaybackRate(0.7);
      await _sfxPlayer.play(AssetSource('audio/eat.wav'));
      Future.delayed(const Duration(milliseconds: 300), () {
        _sfxPlayer.setPlaybackRate(1.0);
      });
    } catch (_) {}
  }

  // ── Dynamic Background Music ──────────────────────────────────────────────

  /// Starts the looping background music track.
  Future<void> startMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('audio/bgm.wav'));
    } catch (_) {}
  }

  /// Adjusts music intensity based on gameplay state.
  /// 0 = calm (slow), 1 = normal, 2 = intense (fast).
  Future<void> setMusicIntensity(int intensity) async {
    if (intensity == _musicIntensity) return;
    _musicIntensity = intensity;
    try {
      switch (intensity) {
        case 0:
          await _musicPlayer.setPlaybackRate(0.8);
          await _musicPlayer.setVolume(0.2);
          break;
        case 2:
          await _musicPlayer.setPlaybackRate(1.3);
          await _musicPlayer.setVolume(0.45);
          break;
        default:
          await _musicPlayer.setPlaybackRate(1.0);
          await _musicPlayer.setVolume(0.3);
      }
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
