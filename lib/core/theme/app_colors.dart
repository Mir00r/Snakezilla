import 'package:flutter/material.dart';

/// Neon-arcade colour palette for Snakezilla.
///
/// All colour values are centralised here so the entire visual identity
/// can be updated from a single file.
class AppColors {
  AppColors._();

  // ── Primary neon accent colours ────────────────────────────────────────────

  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonBlue = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonOrange = Color(0xFFFF6600);

  // ── Dark theme surfaces ────────────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF0A0E21);
  static const Color darkSurface = Color(0xFF1A1F36);
  static const Color darkCard = Color(0xFF222847);

  // ── Light theme surfaces ───────────────────────────────────────────────────

  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE8ECF4);

  // ── Snake colours ──────────────────────────────────────────────────────────

  static const Color snakeHead = neonGreen;
  static const Color snakeBody = Color(0xFF2ECC40);
  static const Color snakeTail = Color(0xFF1B7A2B);

  // ── Food colours ───────────────────────────────────────────────────────────

  static const Color food = neonPink;
  static const Color foodGlow = Color(0x66FF1493);

  // ── Text colours ───────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textDark = Color(0xFF1A1F36);

  // ── Grid colours ───────────────────────────────────────────────────────────

  static const Color gridLine = Color(0x1AFFFFFF);
  static const Color gridLineDark = Color(0x1A000000);

  // ── Gradient presets ───────────────────────────────────────────────────────

  static const List<Color> backgroundGradientDark = [
    Color(0xFF0A0E21),
    Color(0xFF1A1044),
    Color(0xFF0A0E21),
  ];

  static const List<Color> backgroundGradientLight = [
    Color(0xFFE8ECF4),
    Color(0xFFD5DFEF),
    Color(0xFFE8ECF4),
  ];

  static const List<Color> snakeGradient = [
    neonGreen,
    Color(0xFF2ECC40),
    Color(0xFF1B7A2B),
  ];
}
