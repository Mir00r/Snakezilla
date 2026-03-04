import '../../settings/models/settings_model.dart';

/// A single leaderboard entry recording a player's performance.
class LeaderboardEntry {
  /// Display name entered by the player.
  final String playerName;

  /// Final score achieved.
  final int score;

  /// Timestamp of when the game ended.
  final DateTime date;

  /// Difficulty level the game was played at.
  final Difficulty difficulty;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.date,
    required this.difficulty,
  });

  /// Serialises the entry for JSON / SharedPreferences storage.
  Map<String, dynamic> toMap() => {
        'playerName': playerName,
        'score': score,
        'date': date.toIso8601String(),
        'difficulty': difficulty.index,
      };

  /// Deserialises an entry from a stored map.
  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      playerName: map['playerName'] as String? ?? 'Player',
      score: map['score'] as int? ?? 0,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      difficulty: Difficulty.values[map['difficulty'] as int? ?? 1],
    );
  }
}
