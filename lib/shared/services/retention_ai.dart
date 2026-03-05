import 'dart:math';

/// Smart Retention AI that adjusts difficulty, suggests content,
/// and provides comeback rewards based on player behavior patterns.
class RetentionAI {
  /// Analyze player skill level (0.0 = beginner, 1.0 = expert).
  static double analyzeSkill({
    required int totalGames,
    required int totalScore,
    required int highestCombo,
    required int longestSnake,
  }) {
    if (totalGames == 0) return 0.0;

    final avgScore = totalScore / totalGames;
    final scoreSkill = (avgScore / 500).clamp(0.0, 1.0);
    final comboSkill = (highestCombo / 15).clamp(0.0, 1.0);
    final lengthSkill = (longestSnake / 40).clamp(0.0, 1.0);

    return (scoreSkill * 0.4 + comboSkill * 0.3 + lengthSkill * 0.3)
        .clamp(0.0, 1.0);
  }

  /// Get adaptive difficulty suggestion.
  static String suggestDifficulty(double skill) {
    if (skill < 0.25) return 'easy';
    if (skill < 0.6) return 'medium';
    return 'hard';
  }

  /// Calculate AI opponent count for battle royale based on skill.
  static int suggestAICount(double skill) {
    if (skill < 0.2) return 2;
    if (skill < 0.4) return 3;
    if (skill < 0.6) return 4;
    return 5;
  }

  /// Calculate comeback reward based on days away.
  static ComebackReward? calculateComebackReward({
    required int lastPlayDay,
    required int today,
    required int playerLevel,
  }) {
    final daysAway = today - lastPlayDay;
    if (daysAway < 3) return null; // No reward for < 3 days away

    if (daysAway >= 14) {
      return ComebackReward(
        title: 'Welcome Back, Legend!',
        emoji: '👑',
        coins: 500 + playerLevel * 20,
        xp: 200,
        message: 'We missed you! Here\'s a legendary comeback gift.',
      );
    } else if (daysAway >= 7) {
      return ComebackReward(
        title: 'Welcome Back!',
        emoji: '🎉',
        coins: 300 + playerLevel * 10,
        xp: 100,
        message: 'Great to see you again! Enjoy this reward.',
      );
    } else {
      return ComebackReward(
        title: 'You\'re Back!',
        emoji: '✨',
        coins: 100 + playerLevel * 5,
        xp: 50,
        message: 'Here\'s a small welcome-back bonus.',
      );
    }
  }

  /// Recommend which game mode the player should try next.
  static String recommendGameMode({
    required int totalGames,
    required double skill,
    required String lastMode,
  }) {
    if (totalGames < 3) return 'classic';

    final modes = [
      'classic',
      'timeAttack',
      'obstacle',
      'aiDuel',
      'battleRoyale',
      'goldRush',
    ];
    // Remove last played, suggest based on skill
    final available = modes.where((m) => m != lastMode).toList();

    if (skill < 0.3) {
      // Beginner: classic or time attack
      return available.firstWhere(
        (m) => m == 'classic' || m == 'timeAttack',
        orElse: () => available.first,
      );
    } else if (skill < 0.6) {
      // Intermediate: obstacle or AI duel
      return available.firstWhere(
        (m) => m == 'obstacle' || m == 'aiDuel',
        orElse: () => available.first,
      );
    } else {
      // Expert: battle royale or gold rush
      return available.firstWhere(
        (m) => m == 'battleRoyale' || m == 'goldRush',
        orElse: () => available.first,
      );
    }
  }

  /// Generate an engagement nudge message.
  static String? getEngagementNudge({
    required int totalGames,
    required int dailyStreak,
    required int coins,
    required int unlockedSkins,
  }) {
    final random = Random();
    final nudges = <String>[];

    if (dailyStreak >= 5) {
      nudges.add('🔥 ${dailyStreak}-day streak! Keep it alive!');
    }
    if (coins >= 500) {
      nudges.add('💰 You have $coins coins! Check the skin shop.');
    }
    if (totalGames % 10 == 0 && totalGames > 0) {
      nudges.add('🎮 $totalGames games played! Milestone!');
    }
    if (unlockedSkins < 3) {
      nudges.add('🎨 Unlock more skins to customize your snake!');
    }

    if (nudges.isEmpty) return null;
    return nudges[random.nextInt(nudges.length)];
  }
}

/// Comeback reward data.
class ComebackReward {
  final String title;
  final String emoji;
  final int coins;
  final int xp;
  final String message;

  const ComebackReward({
    required this.title,
    required this.emoji,
    required this.coins,
    required this.xp,
    required this.message,
  });
}
