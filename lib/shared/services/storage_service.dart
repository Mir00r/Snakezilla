import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/leaderboard/models/leaderboard_entry.dart';
import '../../features/settings/models/settings_model.dart';

/// SharedPreferences key constants.
class _Keys {
  static const settings = 'snakezilla_settings';
  static const leaderboard = 'snakezilla_leaderboard';
  static const highScore = 'snakezilla_high_score';
}

/// Thin persistence layer wrapping [SharedPreferences].
///
/// Provides typed read/write helpers for settings, high-score,
/// and leaderboard data. All writes are `async` / fire-and-forget.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ── Settings ───────────────────────────────────────────────────────────────

  /// Loads persisted settings or returns safe defaults.
  SettingsModel loadSettings() {
    final raw = _prefs.getString(_Keys.settings);
    if (raw == null) return const SettingsModel();
    try {
      return SettingsModel.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const SettingsModel();
    }
  }

  /// Persists [settings] as a JSON string.
  Future<void> saveSettings(SettingsModel settings) async {
    await _prefs.setString(
      _Keys.settings,
      jsonEncode(settings.toMap()),
    );
  }

  // ── High Score ─────────────────────────────────────────────────────────────

  /// Returns the stored high score, or `0` on first launch.
  int loadHighScore() => _prefs.getInt(_Keys.highScore) ?? 0;

  /// Writes a new high score.
  Future<void> saveHighScore(int score) async {
    await _prefs.setInt(_Keys.highScore, score);
  }

  // ── Leaderboard ────────────────────────────────────────────────────────────

  /// Returns all stored leaderboard entries sorted by descending score.
  List<LeaderboardEntry> loadLeaderboard() {
    final raw = _prefs.getString(_Keys.leaderboard);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => LeaderboardEntry.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));
    } catch (_) {
      return [];
    }
  }

  /// Overwrites the stored leaderboard with [entries].
  Future<void> saveLeaderboard(List<LeaderboardEntry> entries) async {
    await _prefs.setString(
      _Keys.leaderboard,
      jsonEncode(entries.map((e) => e.toMap()).toList()),
    );
  }

  /// Deletes all leaderboard data.
  Future<void> clearLeaderboard() async {
    await _prefs.remove(_Keys.leaderboard);
  }
}

/// Riverpod provider for [StorageService].
///
/// Must be overridden in [ProviderScope] at app startup with the real
/// [SharedPreferences]-backed instance (see `main.dart`).
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'storageServiceProvider must be overridden at startup.',
  );
});
