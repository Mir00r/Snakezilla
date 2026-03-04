import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/audio_service.dart';
import '../../../shared/services/storage_service.dart';
import '../models/settings_model.dart';

/// Manages [SettingsModel] state with automatic persistence.
///
/// Every mutation is immediately written to [SharedPreferences] via
/// [StorageService] and audio behaviour is synchronised.
class SettingsNotifier extends StateNotifier<SettingsModel> {
  final StorageService _storage;
  final AudioService _audio;

  SettingsNotifier(this._storage, this._audio)
      : super(_storage.loadSettings()) {
    // Sync audio service with the loaded settings on startup.
    _audio.updateSettings(state);
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    _audio.updateSettings(state);
    _persist();
  }

  void toggleMusic() {
    state = state.copyWith(musicEnabled: !state.musicEnabled);
    _audio.updateSettings(state);
    if (!state.musicEnabled) {
      _audio.stopMusic();
    }
    _persist();
  }

  void setDifficulty(Difficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
    _persist();
  }

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
    _persist();
  }

  void toggleBoundaryWrap() {
    state = state.copyWith(boundaryWrap: !state.boundaryWrap);
    _persist();
  }

  Future<void> _persist() async {
    await _storage.saveSettings(state);
  }
}

/// Riverpod provider for application settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final audio = ref.watch(audioServiceProvider);
  return SettingsNotifier(storage, audio);
});
