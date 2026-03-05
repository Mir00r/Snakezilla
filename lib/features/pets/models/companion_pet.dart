import 'package:flutter/material.dart';

/// Companion pets that follow the snake and provide bonuses.
class CompanionPet {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final Color glowColor;
  final int price;
  final PetAbility ability;
  final double abilityValue;

  const CompanionPet({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    required this.glowColor,
    required this.price,
    required this.ability,
    required this.abilityValue,
  });
}

/// Types of pet special abilities.
enum PetAbility {
  coinMagnet('Coin Magnet', 'Auto-collects nearby coins'),
  scoreBoost('Score Boost', 'Multiplies score earned'),
  comboExtend('Combo Extend', 'Extends combo timer'),
  shieldChance('Shield Chance', 'Chance to survive collision');

  final String label;
  final String description;
  const PetAbility(this.label, this.description);
}

/// Catalogue of all available companion pets.
class CompanionPets {
  CompanionPets._();

  static const robotDrone = CompanionPet(
    id: 'robot_drone',
    name: 'Robo Drone',
    emoji: '🤖',
    description: 'A hovering helper bot that magnetizes coins',
    color: Color(0xFF90CAF9),
    glowColor: Color(0xFF42A5F5),
    price: 0,
    ability: PetAbility.coinMagnet,
    abilityValue: 2.0, // Range in cells
  );

  static const babyDragon = CompanionPet(
    id: 'baby_dragon',
    name: 'Baby Dragon',
    emoji: '🐉',
    description: 'Breathes fire for +25% score boost',
    color: Color(0xFFEF9A9A),
    glowColor: Color(0xFFEF5350),
    price: 500,
    ability: PetAbility.scoreBoost,
    abilityValue: 1.25, // 25% bonus
  );

  static const glowFairy = CompanionPet(
    id: 'glow_fairy',
    name: 'Glow Fairy',
    emoji: '🧚',
    description: 'Magical sparkles extend combo timer by 50%',
    color: Color(0xFFCE93D8),
    glowColor: Color(0xFFAB47BC),
    price: 800,
    ability: PetAbility.comboExtend,
    abilityValue: 1.5, // 50% longer combo window
  );

  static const miniSnake = CompanionPet(
    id: 'mini_snake',
    name: 'Mini Snake',
    emoji: '🐍',
    description: 'A loyal companion with a chance to block death',
    color: Color(0xFFA5D6A7),
    glowColor: Color(0xFF66BB6A),
    price: 1200,
    ability: PetAbility.shieldChance,
    abilityValue: 0.15, // 15% chance
  );

  static const starFox = CompanionPet(
    id: 'star_fox',
    name: 'Star Fox',
    emoji: '🦊',
    description: 'Swift fox with enhanced coin collection range',
    color: Color(0xFFFFCC80),
    glowColor: Color(0xFFFFA726),
    price: 600,
    ability: PetAbility.coinMagnet,
    abilityValue: 3.0,
  );

  static const crystalOwl = CompanionPet(
    id: 'crystal_owl',
    name: 'Crystal Owl',
    emoji: '🦉',
    description: 'Wise owl grants +50% score on each food',
    color: Color(0xFF80CBC4),
    glowColor: Color(0xFF26A69A),
    price: 1500,
    ability: PetAbility.scoreBoost,
    abilityValue: 1.5,
  );

  static const List<CompanionPet> all = [
    robotDrone,
    babyDragon,
    glowFairy,
    miniSnake,
    starFox,
    crystalOwl,
  ];

  static CompanionPet? fromId(String? id) {
    if (id == null) return null;
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
