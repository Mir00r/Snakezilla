import 'package:flutter/material.dart';

/// Player rank in the competitive league system.
enum PlayerRank {
  bronze('Bronze', '🥉', Color(0xFFCD7F32), 0),
  silver('Silver', '🥈', Color(0xFFC0C0C0), 500),
  gold('Gold', '🥇', Color(0xFFFFD700), 1500),
  platinum('Platinum', '💎', Color(0xFF00E5FF), 3000),
  diamond('Diamond', '💠', Color(0xFF64B5F6), 5000),
  master('Master', '👑', Color(0xFFFF6D00), 8000);

  final String label;
  final String emoji;
  final Color color;
  final int requiredPoints;

  const PlayerRank(this.label, this.emoji, this.color, this.requiredPoints);

  /// Returns the next rank, or null if already at max.
  PlayerRank? get nextRank {
    final idx = PlayerRank.values.indexOf(this);
    if (idx >= PlayerRank.values.length - 1) return null;
    return PlayerRank.values[idx + 1];
  }

  /// Points needed to reach next rank, or 0 if at max.
  int get pointsToNext {
    final next = nextRank;
    if (next == null) return 0;
    return next.requiredPoints - requiredPoints;
  }
}

/// Derives rank from rank points.
class RankSystem {
  RankSystem._();

  /// Gets the current rank for the given rank points.
  static PlayerRank rankForPoints(int points) {
    PlayerRank result = PlayerRank.bronze;
    for (final rank in PlayerRank.values) {
      if (points >= rank.requiredPoints) {
        result = rank;
      } else {
        break;
      }
    }
    return result;
  }

  /// Points earned from a game based on score and mode.
  static int pointsFromGame({
    required int score,
    required int combo,
    required bool win,
  }) {
    int points = (score / 10).floor();
    if (combo >= 5) points += 5;
    if (combo >= 10) points += 10;
    if (win) points += 20;
    return points;
  }

  /// Progress within current rank (0.0 to 1.0).
  static double progressInRank(int points) {
    final rank = rankForPoints(points);
    final next = rank.nextRank;
    if (next == null) return 1.0;
    final rangeStart = rank.requiredPoints;
    final rangeEnd = next.requiredPoints;
    return (points - rangeStart) / (rangeEnd - rangeStart);
  }
}
