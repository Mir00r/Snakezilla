import 'package:flutter_test/flutter_test.dart';

import 'package:snakezilla/features/settings/models/settings_model.dart';
import 'package:snakezilla/features/leaderboard/models/leaderboard_entry.dart';

void main() {
  // ── SettingsModel ────────────────────────────────────────────────────────

  group('SettingsModel', () {
    test('default constructor provides sensible defaults', () {
      const s = SettingsModel();
      expect(s.soundEnabled, isTrue);
      expect(s.musicEnabled, isTrue);
      expect(s.difficulty, Difficulty.medium);
      expect(s.darkMode, isTrue);
      expect(s.boundaryWrap, isFalse);
    });

    test('toMap and fromMap roundtrip preserves values', () {
      const original = SettingsModel(
        soundEnabled: false,
        musicEnabled: false,
        difficulty: Difficulty.hard,
        darkMode: false,
        boundaryWrap: true,
      );

      final restored = SettingsModel.fromMap(original.toMap());

      expect(restored.soundEnabled, original.soundEnabled);
      expect(restored.musicEnabled, original.musicEnabled);
      expect(restored.difficulty, original.difficulty);
      expect(restored.darkMode, original.darkMode);
      expect(restored.boundaryWrap, original.boundaryWrap);
    });

    test('fromMap handles missing keys with defaults', () {
      final s = SettingsModel.fromMap({});
      expect(s.soundEnabled, isTrue);
      expect(s.difficulty, Difficulty.medium);
    });

    test('copyWith replaces individual fields', () {
      const s = SettingsModel();
      final updated = s.copyWith(soundEnabled: false, darkMode: false);
      expect(updated.soundEnabled, isFalse);
      expect(updated.darkMode, isFalse);
      expect(updated.musicEnabled, isTrue); // unchanged
    });
  });

  // ── LeaderboardEntry ─────────────────────────────────────────────────────

  group('LeaderboardEntry', () {
    test('toMap and fromMap roundtrip preserves values', () {
      final original = LeaderboardEntry(
        playerName: 'Alice',
        score: 420,
        date: DateTime(2025, 6, 15),
        difficulty: Difficulty.easy,
      );

      final restored = LeaderboardEntry.fromMap(original.toMap());

      expect(restored.playerName, 'Alice');
      expect(restored.score, 420);
      expect(restored.difficulty, Difficulty.easy);
      expect(restored.date.year, 2025);
    });

    test('fromMap handles missing values gracefully', () {
      final entry = LeaderboardEntry.fromMap({});
      expect(entry.playerName, 'Player');
      expect(entry.score, 0);
    });
  });
}
