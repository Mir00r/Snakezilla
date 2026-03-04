/// Enumerates the available difficulty levels.
///
/// Each level maps to a different timer interval in
/// [GameConstants] (speedEasy / speedMedium / speedHard).
enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  /// Human-readable label for UI display.
  final String label;
  const Difficulty(this.label);
}

/// Immutable settings model persisted across sessions.
///
/// Serialisable to/from a [Map] for SharedPreferences storage.
class SettingsModel {
  final bool soundEnabled;
  final bool musicEnabled;
  final Difficulty difficulty;
  final bool darkMode;
  final bool boundaryWrap;

  const SettingsModel({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.difficulty = Difficulty.medium,
    this.darkMode = true,
    this.boundaryWrap = false,
  });

  SettingsModel copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    Difficulty? difficulty,
    bool? darkMode,
    bool? boundaryWrap,
  }) {
    return SettingsModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      difficulty: difficulty ?? this.difficulty,
      darkMode: darkMode ?? this.darkMode,
      boundaryWrap: boundaryWrap ?? this.boundaryWrap,
    );
  }

  /// Converts settings to a JSON-compatible map for persistence.
  Map<String, dynamic> toMap() => {
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'difficulty': difficulty.index,
        'darkMode': darkMode,
        'boundaryWrap': boundaryWrap,
      };

  /// Re-creates settings from a persistence map, with safe defaults.
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      musicEnabled: map['musicEnabled'] as bool? ?? true,
      difficulty: Difficulty.values[map['difficulty'] as int? ?? 1],
      darkMode: map['darkMode'] as bool? ?? true,
      boundaryWrap: map['boundaryWrap'] as bool? ?? false,
    );
  }
}
