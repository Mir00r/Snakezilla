/// Central configuration constants for Snakezilla game parameters.
///
/// All game-tuning values are centralized here for easy adjustment
/// without touching game logic code.
class GameConstants {
  GameConstants._();

  // ── Grid ───────────────────────────────────────────────────────────────────

  /// Number of horizontal cells in the game grid.
  static const int gridWidth = 20;

  /// Number of vertical cells in the game grid.
  static const int gridHeight = 20;

  // ── Speed (milliseconds per tick) ──────────────────────────────────────────

  /// Timer interval for Easy difficulty.
  static const int speedEasy = 300;

  /// Timer interval for Medium difficulty.
  static const int speedMedium = 200;

  /// Timer interval for Hard difficulty.
  static const int speedHard = 120;

  /// Minimum interval (fastest speed cap).
  static const int minSpeed = 60;

  /// Milliseconds subtracted from interval per food eaten.
  static const int speedIncrement = 5;

  // ── Snake ──────────────────────────────────────────────────────────────────

  /// Number of segments when the game starts.
  static const int initialSnakeLength = 3;

  // ── Scoring ────────────────────────────────────────────────────────────────

  /// Points awarded per food consumed.
  static const int pointsPerFood = 10;

  // ── Leaderboard ────────────────────────────────────────────────────────────

  /// Maximum entries stored in the local leaderboard.
  static const int maxLeaderboardEntries = 50;
}
