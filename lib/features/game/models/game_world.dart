import 'package:flutter/material.dart';

/// Dynamic game worlds with unique visual themes, particle systems,
/// and environmental effects.
class GameWorld {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color backgroundColor;
  final Color gridLineColor;
  final Color borderGlowColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final WorldParticleType particleType;
  final Color particleColor;
  final int unlockLevel;
  final int price;

  const GameWorld({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.backgroundColor,
    required this.gridLineColor,
    required this.borderGlowColor,
    required this.accentColor,
    required this.gradientColors,
    required this.particleType,
    required this.particleColor,
    this.unlockLevel = 1,
    this.price = 0,
  });
}

/// Types of ambient particles for each world.
enum WorldParticleType {
  none,
  lightBeams,
  fireflies,
  snow,
  lavaEmbers,
  bubbles,
  stars,
}

/// Master catalogue of game worlds.
class GameWorlds {
  GameWorlds._();

  static const neonCity = GameWorld(
    id: 'neon_city',
    name: 'Neon Cyber City',
    emoji: '🌃',
    description: 'Futuristic glowing grid with moving light beams',
    backgroundColor: Color(0xFF0A0E21),
    gridLineColor: Color(0x15FFFFFF),
    borderGlowColor: Color(0xFF39FF14),
    accentColor: Color(0xFF39FF14),
    gradientColors: [Color(0xFF0A0E21), Color(0xFF1A1F36), Color(0xFF0A0E21)],
    particleType: WorldParticleType.lightBeams,
    particleColor: Color(0xFF39FF14),
    unlockLevel: 1,
    price: 0,
  );

  static const jungle = GameWorld(
    id: 'jungle',
    name: 'Jungle Adventure',
    emoji: '🌳',
    description: 'Animated plants with floating fireflies',
    backgroundColor: Color(0xFF0D1F0D),
    gridLineColor: Color(0x1576FF03),
    borderGlowColor: Color(0xFF76FF03),
    accentColor: Color(0xFFAEEA00),
    gradientColors: [Color(0xFF0D1F0D), Color(0xFF1B3A1B), Color(0xFF0D1F0D)],
    particleType: WorldParticleType.fireflies,
    particleColor: Color(0xFFFFEB3B),
    unlockLevel: 3,
    price: 200,
  );

  static const iceWorld = GameWorld(
    id: 'ice_world',
    name: 'Ice World',
    emoji: '❄',
    description: 'Snow particles and frozen landscape',
    backgroundColor: Color(0xFF0A1929),
    gridLineColor: Color(0x1580DEEA),
    borderGlowColor: Color(0xFF80DEEA),
    accentColor: Color(0xFF00BCD4),
    gradientColors: [Color(0xFF0A1929), Color(0xFF0D2137), Color(0xFF0A1929)],
    particleType: WorldParticleType.snow,
    particleColor: Color(0xCCFFFFFF),
    unlockLevel: 5,
    price: 400,
  );

  static const volcano = GameWorld(
    id: 'volcano',
    name: 'Volcano World',
    emoji: '🌋',
    description: 'Lava cracks with floating embers',
    backgroundColor: Color(0xFF1A0A00),
    gridLineColor: Color(0x15FF6D00),
    borderGlowColor: Color(0xFFFF6D00),
    accentColor: Color(0xFFFF3D00),
    gradientColors: [Color(0xFF1A0A00), Color(0xFF331400), Color(0xFF1A0A00)],
    particleType: WorldParticleType.lavaEmbers,
    particleColor: Color(0xFFFF6D00),
    unlockLevel: 8,
    price: 600,
  );

  static const ocean = GameWorld(
    id: 'ocean',
    name: 'Ocean World',
    emoji: '🌊',
    description: 'Water ripple effects and bubble particles',
    backgroundColor: Color(0xFF001B3A),
    gridLineColor: Color(0x1500BCD4),
    borderGlowColor: Color(0xFF00BCD4),
    accentColor: Color(0xFF00E5FF),
    gradientColors: [Color(0xFF001B3A), Color(0xFF003366), Color(0xFF001B3A)],
    particleType: WorldParticleType.bubbles,
    particleColor: Color(0x8800E5FF),
    unlockLevel: 10,
    price: 800,
  );

  static const galaxy = GameWorld(
    id: 'galaxy',
    name: 'Galaxy Void',
    emoji: '🌌',
    description: 'Twinkling stars in deep space',
    backgroundColor: Color(0xFF0D0033),
    gridLineColor: Color(0x15B388FF),
    borderGlowColor: Color(0xFFB388FF),
    accentColor: Color(0xFFE040FB),
    gradientColors: [Color(0xFF0D0033), Color(0xFF1A0066), Color(0xFF0D0033)],
    particleType: WorldParticleType.stars,
    particleColor: Color(0xFFFFFFFF),
    unlockLevel: 15,
    price: 1200,
  );

  static const List<GameWorld> all = [
    neonCity,
    jungle,
    iceWorld,
    volcano,
    ocean,
    galaxy,
  ];

  static GameWorld fromId(String id) {
    return all.firstWhere((w) => w.id == id, orElse: () => neonCity);
  }
}
