import 'package:flutter/material.dart';

/// Seasonal/limited-time event definitions.
class SeasonalEvent {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final int startMonth;
  final int endMonth;
  final String specialSkinId;

  const SeasonalEvent({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.startMonth,
    required this.endMonth,
    required this.specialSkinId,
  });

  bool get isActive {
    final now = DateTime.now().month;
    if (startMonth <= endMonth) {
      return now >= startMonth && now <= endMonth;
    }
    // Wraps around year end (e.g., Dec-Jan)
    return now >= startMonth || now <= endMonth;
  }
}

/// All seasonal events in the game.
class SeasonalEvents {
  SeasonalEvents._();

  static const halloween = SeasonalEvent(
    id: 'halloween',
    name: 'Halloween Havoc',
    emoji: '🎃',
    description: 'Spooky treats and ghostly snakes!',
    primaryColor: Color(0xFFFF6D00),
    secondaryColor: Color(0xFF7B1FA2),
    startMonth: 10,
    endMonth: 10,
    specialSkinId: 'halloween_ghost',
  );

  static const christmas = SeasonalEvent(
    id: 'christmas',
    name: 'Winter Wonderland',
    emoji: '🎄',
    description: 'Festive rewards and candy cane trails!',
    primaryColor: Color(0xFFE53935),
    secondaryColor: Color(0xFF43A047),
    startMonth: 12,
    endMonth: 1,
    specialSkinId: 'christmas_candy',
  );

  static const lunar = SeasonalEvent(
    id: 'lunar',
    name: 'Lunar New Year',
    emoji: '🐲',
    description: 'Golden dragons and lucky coins!',
    primaryColor: Color(0xFFFFD700),
    secondaryColor: Color(0xFFE53935),
    startMonth: 1,
    endMonth: 2,
    specialSkinId: 'lunar_dragon',
  );

  static const summer = SeasonalEvent(
    id: 'summer',
    name: 'Summer Splash',
    emoji: '🏖️',
    description: 'Beach vibes and tropical rewards!',
    primaryColor: Color(0xFF00BCD4),
    secondaryColor: Color(0xFFFFC107),
    startMonth: 6,
    endMonth: 8,
    specialSkinId: 'summer_tropical',
  );

  static const spring = SeasonalEvent(
    id: 'spring',
    name: 'Spring Bloom',
    emoji: '🌸',
    description: 'Flowers bloom and bonuses grow!',
    primaryColor: Color(0xFFF48FB1),
    secondaryColor: Color(0xFF81C784),
    startMonth: 3,
    endMonth: 5,
    specialSkinId: 'spring_blossom',
  );

  static const List<SeasonalEvent> all = [
    halloween,
    christmas,
    lunar,
    summer,
    spring,
  ];

  /// Returns currently active events (if any).
  static List<SeasonalEvent> get activeEvents =>
      all.where((e) => e.isActive).toList();
}
