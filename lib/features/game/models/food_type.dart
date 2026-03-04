import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'position.dart';

/// Types of special food items with unique effects, visuals, and sounds.
enum FoodType {
  /// Standard food – plain score bonus.
  normal(
    label: 'Apple',
    emoji: '🍎',
    basePoints: 10,
    color: AppColors.neonPink,
    spawnWeight: 50,
    duration: Duration.zero,
  ),

  /// Grants a temporary speed boost.
  speedBoost(
    label: 'Speed Boost',
    emoji: '🔥',
    basePoints: 15,
    color: AppColors.neonOrange,
    spawnWeight: 10,
    duration: Duration(seconds: 5),
  ),

  /// Freezes game speed for a brief period.
  freeze(
    label: 'Freeze',
    emoji: '❄️',
    basePoints: 10,
    color: AppColors.neonBlue,
    spawnWeight: 8,
    duration: Duration(seconds: 4),
  ),

  /// Awards bonus coins.
  coinBonus(
    label: 'Coin Bonus',
    emoji: '💰',
    basePoints: 5,
    color: AppColors.neonYellow,
    spawnWeight: 8,
    duration: Duration.zero,
  ),

  /// Score multiplier for a short window.
  rainbow(
    label: 'Rainbow Combo',
    emoji: '🌈',
    basePoints: 20,
    color: AppColors.neonPurple,
    spawnWeight: 4,
    duration: Duration(seconds: 6),
  ),

  /// Shrinks the snake by removing tail segments.
  bomb(
    label: 'Bomb',
    emoji: '💣',
    basePoints: 0,
    color: Color(0xFFFF4444),
    spawnWeight: 3,
    duration: Duration.zero,
  ),

  /// Attracts nearby food toward the snake head.
  magnet(
    label: 'Magnet',
    emoji: '🧲',
    basePoints: 10,
    color: Color(0xFFFF1744),
    spawnWeight: 5,
    duration: Duration(seconds: 6),
  ),

  /// Temporary invincibility — ignore self-collision & obstacles.
  shield(
    label: 'Shield',
    emoji: '🛡️',
    basePoints: 5,
    color: Color(0xFF00E5FF),
    spawnWeight: 4,
    duration: Duration(seconds: 5),
  ),

  /// Pass through walls and own body.
  ghost(
    label: 'Ghost',
    emoji: '👻',
    basePoints: 10,
    color: Color(0xFFB388FF),
    spawnWeight: 3,
    duration: Duration(seconds: 5),
  ),

  /// Gold coin: used only in Gold Rush mode, worth big bonus.
  goldCoin(
    label: 'Gold',
    emoji: '🪙',
    basePoints: 25,
    color: Color(0xFFFFD700),
    spawnWeight: 0, // manually spawned in Gold Rush
    duration: Duration.zero,
  );

  /// UI display name.
  final String label;

  /// Emoji used in popups / HUD.
  final String emoji;

  /// Base score value (before multipliers).
  final int basePoints;

  /// Primary colour for rendering & glow.
  final Color color;

  /// Relative spawn probability weight (higher = more common).
  final int spawnWeight;

  /// How long the power-up effect lasts (Duration.zero = instant).
  final Duration duration;

  const FoodType({
    required this.label,
    required this.emoji,
    required this.basePoints,
    required this.color,
    required this.spawnWeight,
    required this.duration,
  });

  /// Selects a random [FoodType] using weighted probability.
  static FoodType randomWeighted([Random? rng]) {
    final random = rng ?? Random();
    final totalWeight = FoodType.values.fold(0, (s, f) => s + f.spawnWeight);
    var roll = random.nextInt(totalWeight);
    for (final food in FoodType.values) {
      roll -= food.spawnWeight;
      if (roll < 0) return food;
    }
    return FoodType.normal;
  }
}

/// An active food item placed on the grid.
class FoodItem {
  final Position position;
  final FoodType type;

  const FoodItem({required this.position, required this.type});

  FoodItem copyWith({Position? position, FoodType? type}) {
    return FoodItem(
      position: position ?? this.position,
      type: type ?? this.type,
    );
  }
}
