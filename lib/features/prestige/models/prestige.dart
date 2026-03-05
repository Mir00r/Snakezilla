import 'package:flutter/material.dart';

/// Represents a prestige tier with multipliers and benefits.
class PrestigeTier {
  final int level;
  final String title;
  final String emoji;
  final Color color;
  final double coinMultiplier;
  final double xpMultiplier;
  final String specialReward;

  const PrestigeTier({
    required this.level,
    required this.title,
    required this.emoji,
    required this.color,
    required this.coinMultiplier,
    required this.xpMultiplier,
    required this.specialReward,
  });
}

/// Prestige system: reset progress for permanent multipliers.
class PrestigeSystem {
  static const int minLevelToPrestige = 20;

  static const List<PrestigeTier> tiers = [
    PrestigeTier(
      level: 0,
      title: 'No Prestige',
      emoji: '⭐',
      color: Colors.grey,
      coinMultiplier: 1.0,
      xpMultiplier: 1.0,
      specialReward: '',
    ),
    PrestigeTier(
      level: 1,
      title: 'Bronze Prestige',
      emoji: '🌟',
      color: Color(0xFFCD7F32),
      coinMultiplier: 1.2,
      xpMultiplier: 1.1,
      specialReward: 'Prestige Badge I',
    ),
    PrestigeTier(
      level: 2,
      title: 'Silver Prestige',
      emoji: '✨',
      color: Color(0xFFC0C0C0),
      coinMultiplier: 1.5,
      xpMultiplier: 1.25,
      specialReward: 'Exclusive Silver Skin',
    ),
    PrestigeTier(
      level: 3,
      title: 'Gold Prestige',
      emoji: '💫',
      color: Color(0xFFFFD700),
      coinMultiplier: 1.8,
      xpMultiplier: 1.5,
      specialReward: 'Golden Trail Effect',
    ),
    PrestigeTier(
      level: 4,
      title: 'Diamond Prestige',
      emoji: '💎',
      color: Color(0xFF00BCD4),
      coinMultiplier: 2.0,
      xpMultiplier: 1.75,
      specialReward: 'Diamond Crown Pet',
    ),
    PrestigeTier(
      level: 5,
      title: 'Legendary Prestige',
      emoji: '👑',
      color: Color(0xFFE040FB),
      coinMultiplier: 2.5,
      xpMultiplier: 2.0,
      specialReward: 'Legendary Aura',
    ),
  ];

  /// Get the tier for a given prestige level.
  static PrestigeTier tierFor(int prestige) {
    if (prestige >= tiers.length) return tiers.last;
    return tiers[prestige];
  }

  /// Whether the player can prestige given their current level.
  static bool canPrestige(int playerLevel, int currentPrestige) {
    return playerLevel >= minLevelToPrestige &&
        currentPrestige < tiers.length - 1;
  }

  /// What the player keeps after prestige.
  static const List<String> keptOnPrestige = [
    'Unlocked Skins',
    'Unlocked Pets',
    'Achievements',
    'Prestige Multipliers',
  ];

  /// What the player loses on prestige.
  static const List<String> lostOnPrestige = [
    'Current Coins',
    'XP & Level (reset to 1)',
    'Daily Streak',
    'Tournament Progress',
  ];
}
