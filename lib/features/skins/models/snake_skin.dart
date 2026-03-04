import 'package:flutter/material.dart';

/// Cosmetic snake skin definitions.
///
/// Each skin defines its head, body, and tail colours, plus glow properties.
/// Skins are unlocked via the economy/achievement system.
class SnakeSkin {
  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Short flavour text.
  final String description;

  /// Head segment colour.
  final Color headColor;

  /// Mid-body colour (gradient interpolated head → tail).
  final Color bodyColor;

  /// Tail-end colour.
  final Color tailColor;

  /// Glow effect colour (applied via MaskFilter).
  final Color glowColor;

  /// Radius of the glow blur.
  final double glowRadius;

  /// Price in coins (0 = free / unlocked by default).
  final int price;

  /// Whether this skin cycles its hue over time (rainbow effect).
  final bool animated;

  /// Optional emoji badge shown in the store.
  final String badge;

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.headColor,
    required this.bodyColor,
    required this.tailColor,
    required this.glowColor,
    this.glowRadius = 8.0,
    this.price = 0,
    this.animated = false,
    this.badge = '',
  });
}

/// Master catalogue of all available skins.
class SnakeSkins {
  SnakeSkins._();

  static const neon = SnakeSkin(
    id: 'neon',
    name: 'Neon Classic',
    description: 'The original electric green.',
    headColor: Color(0xFF39FF14),
    bodyColor: Color(0xFF2ECC40),
    tailColor: Color(0xFF1B7A2B),
    glowColor: Color(0xFF39FF14),
    price: 0,
    badge: '🟢',
  );

  static const fire = SnakeSkin(
    id: 'fire',
    name: 'Inferno',
    description: 'Burning hot gradient.',
    headColor: Color(0xFFFF4500),
    bodyColor: Color(0xFFFF8C00),
    tailColor: Color(0xFF8B0000),
    glowColor: Color(0xFFFF6600),
    glowRadius: 12.0,
    price: 500,
    animated: true,
    badge: '🔥',
  );

  static const cyber = SnakeSkin(
    id: 'cyber',
    name: 'Cyber Punk',
    description: 'Neon purple cyber aesthetic.',
    headColor: Color(0xFFBF00FF),
    bodyColor: Color(0xFF8A2BE2),
    tailColor: Color(0xFF4B0082),
    glowColor: Color(0xFFBF00FF),
    glowRadius: 10.0,
    price: 750,
    badge: '💜',
  );

  static const rainbow = SnakeSkin(
    id: 'rainbow',
    name: 'Rainbow',
    description: 'Ever-shifting colour spectrum.',
    headColor: Color(0xFFFF0000),
    bodyColor: Color(0xFF00FF00),
    tailColor: Color(0xFF0000FF),
    glowColor: Color(0xFFFFFFFF),
    glowRadius: 10.0,
    price: 1000,
    animated: true,
    badge: '🌈',
  );

  static const metallic = SnakeSkin(
    id: 'metallic',
    name: 'Chrome',
    description: 'Polished metallic finish.',
    headColor: Color(0xFFE0E0E0),
    bodyColor: Color(0xFFB0B0B0),
    tailColor: Color(0xFF707070),
    glowColor: Color(0xFFFFFFFF),
    glowRadius: 6.0,
    price: 600,
    badge: '⚙️',
  );

  static const ice = SnakeSkin(
    id: 'ice',
    name: 'Frost Bite',
    description: 'Sub-zero icy blues.',
    headColor: Color(0xFF00F5FF),
    bodyColor: Color(0xFF00CED1),
    tailColor: Color(0xFF008B8B),
    glowColor: Color(0xFF00F5FF),
    glowRadius: 10.0,
    price: 800,
    badge: '❄️',
  );

  // ── New animal & themed skins ──────────────────────────────────────────

  static const panda = SnakeSkin(
    id: 'panda',
    name: 'Panda',
    description: 'Cuddly black and white.',
    headColor: Color(0xFFFFFFFF),
    bodyColor: Color(0xFF303030),
    tailColor: Color(0xFF1A1A1A),
    glowColor: Color(0xFFE0E0E0),
    glowRadius: 6.0,
    price: 400,
    badge: '🐼',
  );

  static const dragon = SnakeSkin(
    id: 'dragon',
    name: 'Dragon Scale',
    description: 'Ancient fire-breathing beast.',
    headColor: Color(0xFFFF6F00),
    bodyColor: Color(0xFFC62828),
    tailColor: Color(0xFF4E342E),
    glowColor: Color(0xFFFF6F00),
    glowRadius: 14.0,
    price: 1200,
    animated: true,
    badge: '🐉',
  );

  static const lava = SnakeSkin(
    id: 'lava',
    name: 'Molten Lava',
    description: 'Fresh from the volcano core.',
    headColor: Color(0xFFFFEA00),
    bodyColor: Color(0xFFFF6D00),
    tailColor: Color(0xFFBF360C),
    glowColor: Color(0xFFFF6D00),
    glowRadius: 12.0,
    price: 900,
    animated: true,
    badge: '🌋',
  );

  static const ocean = SnakeSkin(
    id: 'ocean',
    name: 'Deep Ocean',
    description: 'Mysterious abyssal blue.',
    headColor: Color(0xFF00E5FF),
    bodyColor: Color(0xFF0277BD),
    tailColor: Color(0xFF01579B),
    glowColor: Color(0xFF00E5FF),
    glowRadius: 10.0,
    price: 700,
    badge: '🌊',
  );

  static const golden = SnakeSkin(
    id: 'golden',
    name: 'Golden King',
    description: 'Pure gold royalty.',
    headColor: Color(0xFFFFD700),
    bodyColor: Color(0xFFFFC107),
    tailColor: Color(0xFFFF8F00),
    glowColor: Color(0xFFFFD700),
    glowRadius: 12.0,
    price: 1500,
    animated: true,
    badge: '👑',
  );

  static const galaxy = SnakeSkin(
    id: 'galaxy',
    name: 'Cosmic Nebula',
    description: 'Born from the stars.',
    headColor: Color(0xFFE040FB),
    bodyColor: Color(0xFF7C4DFF),
    tailColor: Color(0xFF304FFE),
    glowColor: Color(0xFFE040FB),
    glowRadius: 14.0,
    price: 2000,
    animated: true,
    badge: '🌌',
  );

  /// All skins in display order.
  static const List<SnakeSkin> all = [
    neon, fire, cyber, rainbow, metallic, ice,
    panda, dragon, lava, ocean, golden, galaxy,
  ];

  /// Looks up a skin by its [id]. Falls back to [neon].
  static SnakeSkin fromId(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => neon);
  }
}
