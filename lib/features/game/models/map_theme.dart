import 'package:flutter/material.dart';

/// Visual themes for the game arena.
///
/// Each theme defines colours for the grid, background, food glow,
/// and decorative accents, giving the game variety and replayability.
class MapTheme {
  final String id;
  final String name;
  final String emoji;
  final Color backgroundColor;
  final Color gridLineColor;
  final Color borderGlowColor;
  final Color accentColor;
  final List<Color> gradientColors;

  const MapTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.backgroundColor,
    required this.gridLineColor,
    required this.borderGlowColor,
    required this.accentColor,
    required this.gradientColors,
  });
}

/// Master catalogue of arena themes.
class MapThemes {
  MapThemes._();

  static const neonNight = MapTheme(
    id: 'neon_night',
    name: 'Neon Night',
    emoji: '🌃',
    backgroundColor: Color(0xFF0A0E21),
    gridLineColor: Color(0x15FFFFFF),
    borderGlowColor: Color(0xFF39FF14),
    accentColor: Color(0xFF39FF14),
    gradientColors: [Color(0xFF0A0E21), Color(0xFF1A1F36), Color(0xFF0A0E21)],
  );

  static const oceanDepth = MapTheme(
    id: 'ocean_depth',
    name: 'Ocean Depth',
    emoji: '🌊',
    backgroundColor: Color(0xFF001B3A),
    gridLineColor: Color(0x1500BCD4),
    borderGlowColor: Color(0xFF00BCD4),
    accentColor: Color(0xFF00E5FF),
    gradientColors: [Color(0xFF001B3A), Color(0xFF003366), Color(0xFF001B3A)],
  );

  static const toxicJungle = MapTheme(
    id: 'toxic_jungle',
    name: 'Toxic Jungle',
    emoji: '🌿',
    backgroundColor: Color(0xFF0D1F0D),
    gridLineColor: Color(0x1576FF03),
    borderGlowColor: Color(0xFF76FF03),
    accentColor: Color(0xFFAEEA00),
    gradientColors: [Color(0xFF0D1F0D), Color(0xFF1B3A1B), Color(0xFF0D1F0D)],
  );

  static const lavaCave = MapTheme(
    id: 'lava_cave',
    name: 'Lava Cave',
    emoji: '🌋',
    backgroundColor: Color(0xFF1A0A00),
    gridLineColor: Color(0x15FF6D00),
    borderGlowColor: Color(0xFFFF6D00),
    accentColor: Color(0xFFFF3D00),
    gradientColors: [Color(0xFF1A0A00), Color(0xFF331400), Color(0xFF1A0A00)],
  );

  static const galaxyVoid = MapTheme(
    id: 'galaxy_void',
    name: 'Galaxy Void',
    emoji: '🌌',
    backgroundColor: Color(0xFF0D0033),
    gridLineColor: Color(0x15B388FF),
    borderGlowColor: Color(0xFFB388FF),
    accentColor: Color(0xFFE040FB),
    gradientColors: [Color(0xFF0D0033), Color(0xFF1A0066), Color(0xFF0D0033)],
  );

  static const arcticFrost = MapTheme(
    id: 'arctic_frost',
    name: 'Arctic Frost',
    emoji: '🧊',
    backgroundColor: Color(0xFF0A1929),
    gridLineColor: Color(0x1580DEEA),
    borderGlowColor: Color(0xFF80DEEA),
    accentColor: Color(0xFF00BCD4),
    gradientColors: [Color(0xFF0A1929), Color(0xFF0D2137), Color(0xFF0A1929)],
  );

  static const List<MapTheme> all = [
    neonNight,
    oceanDepth,
    toxicJungle,
    lavaCave,
    galaxyVoid,
    arcticFrost,
  ];

  static MapTheme fromId(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => neonNight);
  }
}
