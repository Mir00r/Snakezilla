import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../skins/models/snake_skin.dart';
import '../models/direction.dart';
import '../models/food_type.dart';
import '../models/map_theme.dart';
import '../models/position.dart';

/// Custom painter that renders the snake, food, obstacles, AI snakes,
/// death pellets, gold coins, shrinking boundary, and grid on a [Canvas].
class SnakePainter extends CustomPainter {
  final List<Position> snake;
  final Position food;
  final FoodType foodType;
  final Direction direction;
  final double foodPulse;
  final bool isDarkMode;
  final SnakeSkin skin;
  final List<Position> obstacles;
  final List<List<Position>> aiSnakes;
  final List<Direction> aiDirections;
  final List<Position> deathPellets;
  final List<Position> goldCoins;
  final bool isBoosting;
  final int boundaryRadius;
  final bool showBoundary;
  final MapTheme mapTheme;

  // AI snake colour palette (up to 5 AIs).
  static const _aiColors = [
    (Color(0xFFFF1493), Color(0xFF8B0050)),
    (Color(0xFFFF6F00), Color(0xFF8B4000)),
    (Color(0xFF00E5FF), Color(0xFF006064)),
    (Color(0xFFB388FF), Color(0xFF4A148C)),
    (Color(0xFFFFD700), Color(0xFF8B6914)),
  ];

  SnakePainter({
    required this.snake,
    required this.food,
    required this.foodType,
    required this.direction,
    required this.foodPulse,
    required this.isDarkMode,
    required this.skin,
    this.obstacles = const [],
    this.aiSnakes = const [],
    this.aiDirections = const [],
    this.deathPellets = const [],
    this.goldCoins = const [],
    this.isBoosting = false,
    this.boundaryRadius = 10,
    this.showBoundary = false,
    this.mapTheme = MapThemes.neonNight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / GameConstants.gridWidth;
    final cellH = size.height / GameConstants.gridHeight;

    _drawGrid(canvas, size, cellW, cellH);
    if (showBoundary) _drawBoundary(canvas, cellW, cellH);
    _drawObstacles(canvas, cellW, cellH);
    _drawDeathPellets(canvas, cellW, cellH);
    _drawGoldCoins(canvas, cellW, cellH);
    _drawFood(canvas, cellW, cellH);
    for (int i = 0; i < aiSnakes.length; i++) {
      if (aiSnakes[i].isNotEmpty) {
        _drawAISnake(canvas, cellW, cellH, i);
      }
    }
    _drawSnake(canvas, cellW, cellH);
  }

  // ── Grid ───────────────────────────────────────────────────────────────────

  void _drawGrid(Canvas canvas, Size size, double cellW, double cellH) {
    final paint = Paint()
      ..color = mapTheme.gridLineColor
      ..strokeWidth = 0.5;

    for (int i = 0; i <= GameConstants.gridWidth; i++) {
      final x = i * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int j = 0; j <= GameConstants.gridHeight; j++) {
      final y = j * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // ── Shrinking Boundary (Battle Royale) ─────────────────────────────────────

  void _drawBoundary(Canvas canvas, double cellW, double cellH) {
    final cx = GameConstants.gridWidth ~/ 2;
    final cy = GameConstants.gridHeight ~/ 2;
    final br = boundaryRadius;

    // Red danger zone outside the safe area.
    final dangerPaint = Paint()
      ..color = const Color(0xFFFF0000).withOpacity(0.12);

    // Top danger zone.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, GameConstants.gridWidth * cellW,
          (cy - br).toDouble() * cellH),
      dangerPaint,
    );
    // Bottom danger zone.
    canvas.drawRect(
      Rect.fromLTWH(
          0,
          (cy + br + 1).toDouble() * cellH,
          GameConstants.gridWidth * cellW,
          (GameConstants.gridHeight - cy - br - 1).toDouble() * cellH),
      dangerPaint,
    );
    // Left danger zone.
    canvas.drawRect(
      Rect.fromLTWH(
          0,
          (cy - br).toDouble() * cellH,
          (cx - br).toDouble() * cellW,
          (2 * br + 1).toDouble() * cellH),
      dangerPaint,
    );
    // Right danger zone.
    canvas.drawRect(
      Rect.fromLTWH(
          (cx + br + 1).toDouble() * cellW,
          (cy - br).toDouble() * cellH,
          (GameConstants.gridWidth - cx - br - 1).toDouble() * cellW,
          (2 * br + 1).toDouble() * cellH),
      dangerPaint,
    );

    // Glowing border.
    final borderRect = Rect.fromLTWH(
      (cx - br).toDouble() * cellW,
      (cy - br).toDouble() * cellH,
      (2 * br + 1).toDouble() * cellW,
      (2 * br + 1).toDouble() * cellH,
    );
    canvas.drawRect(
      borderRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFF4444).withOpacity(0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ── Obstacles ──────────────────────────────────────────────────────────────

  void _drawObstacles(Canvas canvas, double cellW, double cellH) {
    for (final obs in obstacles) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          obs.x * cellW + 1, obs.y * cellH + 1, cellW - 2, cellH - 2),
        Radius.circular(min(cellW, cellH) * 0.15),
      );
      canvas.drawRRect(rect, Paint()
        ..color = const Color(0xFFFF4444).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawRRect(rect, Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF8B0000), Color(0xFFCC3333)],
        ).createShader(rect.outerRect));

      final cx = obs.x * cellW + cellW / 2;
      final cy = obs.y * cellH + cellH / 2;
      final s = min(cellW, cellH) * 0.2;
      final xPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - s, cy - s), Offset(cx + s, cy + s), xPaint);
      canvas.drawLine(Offset(cx + s, cy - s), Offset(cx - s, cy + s), xPaint);
    }
  }

  // ── Death Pellets ──────────────────────────────────────────────────────────

  void _drawDeathPellets(Canvas canvas, double cellW, double cellH) {
    for (final p in deathPellets) {
      final center = Offset(
        p.x * cellW + cellW / 2,
        p.y * cellH + cellH / 2,
      );
      final radius = min(cellW, cellH) * 0.2;

      // Outer glow.
      canvas.drawCircle(center, radius * 1.8, Paint()
        ..color = const Color(0xFFFF69B4).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // Core.
      canvas.drawCircle(center, radius, Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFF69B4), const Color(0xFFFF1493)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)));
    }
  }

  // ── Gold Coins ─────────────────────────────────────────────────────────────

  void _drawGoldCoins(Canvas canvas, double cellW, double cellH) {
    for (final g in goldCoins) {
      final center = Offset(
        g.x * cellW + cellW / 2,
        g.y * cellH + cellH / 2,
      );
      final radius = min(cellW, cellH) * 0.3;
      final pulseR = radius * (1.0 + 0.1 * sin(foodPulse * pi * 2));

      canvas.drawCircle(center, pulseR * 1.5, Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

      canvas.drawCircle(center, pulseR, Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFD700), const Color(0xFFFFC107)],
        ).createShader(Rect.fromCircle(center: center, radius: pulseR)));

      // Shine.
      canvas.drawCircle(
        center + Offset(-pulseR * 0.2, -pulseR * 0.2),
        pulseR * 0.25,
        Paint()..color = Colors.white.withOpacity(0.6),
      );
    }
  }

  // ── Food ───────────────────────────────────────────────────────────────────

  void _drawFood(Canvas canvas, double cellW, double cellH) {
    final center = Offset(
      food.x * cellW + cellW / 2,
      food.y * cellH + cellH / 2,
    );
    final baseRadius = min(cellW, cellH) * 0.35;
    final pulseRadius = baseRadius * (1.0 + 0.15 * sin(foodPulse * pi * 2));
    final color = foodType.color;

    canvas.drawCircle(center, pulseRadius * 1.6, Paint()
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    canvas.drawCircle(center, pulseRadius, Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: pulseRadius)));

    switch (foodType) {
      case FoodType.speedBoost:
        _drawSpeedLines(canvas, center, pulseRadius, color);
      case FoodType.freeze:
        _drawIceCrystals(canvas, center, pulseRadius);
      case FoodType.coinBonus:
        _drawCoinShine(canvas, center, pulseRadius);
      case FoodType.rainbow:
        _drawRainbowRing(canvas, center, pulseRadius);
      case FoodType.bomb:
        _drawBombFuse(canvas, center, pulseRadius);
      case FoodType.magnet:
        _drawMagnetField(canvas, center, pulseRadius);
      case FoodType.shield:
        _drawShieldBubble(canvas, center, pulseRadius);
      case FoodType.ghost:
        _drawGhostWisps(canvas, center, pulseRadius);
      case FoodType.goldCoin:
        _drawCoinShine(canvas, center, pulseRadius);
      case FoodType.normal:
        canvas.drawCircle(
          center + Offset(-pulseRadius * 0.25, -pulseRadius * 0.25),
          pulseRadius * 0.2,
          Paint()..color = Colors.white.withOpacity(0.6),
        );
    }
  }

  void _drawSpeedLines(Canvas c, Offset ct, double r, Color col) {
    final p = Paint()..color = col.withOpacity(0.6)..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final y = ct.dy - r + (i * r * 0.8);
      c.drawLine(Offset(ct.dx - r * 1.5, y), Offset(ct.dx - r * 0.8, y), p);
    }
  }

  void _drawIceCrystals(Canvas c, Offset ct, double r) {
    final p = Paint()..color = Colors.white.withOpacity(0.7)..strokeWidth = 1.0;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      c.drawLine(ct, ct + Offset(cos(angle) * r * 1.2, sin(angle) * r * 1.2), p);
    }
  }

  void _drawCoinShine(Canvas c, Offset ct, double r) {
    c.drawCircle(ct, r * 0.6, Paint()..color = Colors.white.withOpacity(0.4));
    c.drawCircle(ct + Offset(-r * 0.15, -r * 0.15), r * 0.2, Paint()..color = Colors.white.withOpacity(0.7));
  }

  void _drawRainbowRing(Canvas c, Offset ct, double r) {
    c.drawCircle(ct, r * 1.3, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 2
      ..shader = const SweepGradient(colors: [
        Colors.red, Colors.orange, Colors.yellow, Colors.green,
        Colors.blue, Colors.purple, Colors.red,
      ]).createShader(Rect.fromCircle(center: ct, radius: r * 1.3)));
  }

  void _drawBombFuse(Canvas c, Offset ct, double r) {
    final sparks = Paint()..color = AppColors.neonYellow.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final fuseTop = ct + Offset(r * 0.3, -r * 0.9);
    c.drawCircle(fuseTop, r * 0.15, sparks);
    c.drawLine(ct + Offset(0, -r * 0.5), fuseTop, Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 1.5);
  }

  void _drawMagnetField(Canvas c, Offset ct, double r) {
    // Magnetic field lines.
    final p = Paint()..color = const Color(0xFFFF1744).withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    c.drawCircle(ct, r * 1.4, p);
    c.drawCircle(ct, r * 1.8, Paint()..color = const Color(0xFFFF1744).withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 0.8);
  }

  void _drawShieldBubble(Canvas c, Offset ct, double r) {
    c.drawCircle(ct, r * 1.5, Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.15)
      ..style = PaintingStyle.fill);
    c.drawCircle(ct, r * 1.5, Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.5)
      ..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawGhostWisps(Canvas c, Offset ct, double r) {
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2 + foodPulse * pi * 2;
      final wispEnd = ct + Offset(cos(angle) * r * 1.6, sin(angle) * r * 1.6);
      c.drawLine(ct + Offset(cos(angle) * r * 0.8, sin(angle) * r * 0.8), wispEnd,
        Paint()..color = const Color(0xFFB388FF).withOpacity(0.4)..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    }
  }

  // ── Snake ──────────────────────────────────────────────────────────────────

  void _drawSnake(Canvas canvas, double cellW, double cellH) {
    if (snake.isEmpty) return;

    final segmentCount = snake.length;

    // ── Cosmetic: Neon pulse glow behind entire snake ─────────────────────
    final pulseIntensity = 0.15 + 0.1 * sin(foodPulse * pi * 2);
    for (int i = segmentCount - 1; i >= 0; i--) {
      final pos = snake[i];
      final center = Offset(
        pos.x * cellW + cellW / 2,
        pos.y * cellH + cellH / 2,
      );
      final t = segmentCount > 1 ? i / (segmentCount - 1) : 0.0;
      final color = Color.lerp(skin.headColor, skin.tailColor, t)!;
      canvas.drawCircle(
        center,
        min(cellW, cellH) * (0.6 + pulseIntensity),
        Paint()
          ..color = color.withOpacity(pulseIntensity * (1 - t * 0.7))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    for (int i = segmentCount - 1; i >= 0; i--) {
      final pos = snake[i];
      const inset = 1.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.x * cellW + inset, pos.y * cellH + inset,
            cellW - inset * 2, cellH - inset * 2),
        Radius.circular(min(cellW, cellH) * 0.3),
      );

      final t = segmentCount > 1 ? i / (segmentCount - 1) : 0.0;
      final color = Color.lerp(skin.headColor, skin.tailColor, t)!;

      if (i == 0) {
        canvas.drawRRect(rect, Paint()
          ..color = skin.glowColor.withOpacity(isBoosting ? 0.6 : 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isBoosting ? skin.glowRadius * 2 : skin.glowRadius));
      }

      // Boost trail: fire effect with fading segments.
      if (isBoosting && i > segmentCount * 0.5) {
        final trailT = (i - segmentCount * 0.5) / (segmentCount * 0.5);
        final trailOpacity = 0.4 * (1 - t);
        // Orange-to-red fire gradient
        final fireColor = Color.lerp(
          const Color(0xFFFF6B00),
          const Color(0xFFFF0040),
          trailT,
        )!;
        canvas.drawRRect(rect, Paint()
          ..color = fireColor.withOpacity(trailOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.7));
      } else {
        canvas.drawRRect(rect, Paint()..color = color);
      }

      // ── Cosmetic: Rainbow shimmer on long snakes ───────────────────────
      if (segmentCount > 15 && i > 0) {
        final shimmerPhase = (foodPulse * 4 + i * 0.15) % 1.0;
        if (shimmerPhase > 0.8) {
          final shimmerOpacity = (shimmerPhase - 0.8) / 0.2 * 0.3;
          canvas.drawRRect(rect, Paint()
            ..color = Colors.white.withOpacity(shimmerOpacity));
        }
      }

      if (i == 0) _drawEyes(canvas, pos, cellW, cellH, direction);
    }
  }

  // ── AI Snakes ──────────────────────────────────────────────────────────────

  void _drawAISnake(Canvas canvas, double cellW, double cellH, int index) {
    final aiSnake = aiSnakes[index];
    if (aiSnake.isEmpty) return;

    final colors = _aiColors[index % _aiColors.length];
    final headColor = colors.$1;
    final tailColor = colors.$2;
    final segmentCount = aiSnake.length;
    final aiDir = index < aiDirections.length
        ? aiDirections[index]
        : Direction.right;

    for (int i = segmentCount - 1; i >= 0; i--) {
      final pos = aiSnake[i];
      const inset = 1.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.x * cellW + inset, pos.y * cellH + inset,
            cellW - inset * 2, cellH - inset * 2),
        Radius.circular(min(cellW, cellH) * 0.3),
      );
      final t = segmentCount > 1 ? i / (segmentCount - 1) : 0.0;
      final color = Color.lerp(headColor, tailColor, t)!;

      if (i == 0) {
        canvas.drawRRect(rect, Paint()
          ..color = headColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }
      canvas.drawRRect(rect, Paint()..color = color);
      if (i == 0) _drawEyes(canvas, pos, cellW, cellH, aiDir);
    }
  }

  // ── Eyes ────────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, Position head, double cellW, double cellH,
      Direction dir) {
    final cx = head.x * cellW + cellW / 2;
    final cy = head.y * cellH + cellH / 2;
    final eyeRadius = min(cellW, cellH) * 0.1;
    final pupilRadius = eyeRadius * 0.55;
    final eyeOffset = min(cellW, cellH) * 0.18;

    late Offset leftEye, rightEye;
    late Offset pupilShift;

    switch (dir) {
      case Direction.up:
        leftEye = Offset(cx - eyeOffset, cy - eyeOffset * 0.5);
        rightEye = Offset(cx + eyeOffset, cy - eyeOffset * 0.5);
        pupilShift = Offset(0, -pupilRadius * 0.3);
      case Direction.down:
        leftEye = Offset(cx - eyeOffset, cy + eyeOffset * 0.5);
        rightEye = Offset(cx + eyeOffset, cy + eyeOffset * 0.5);
        pupilShift = Offset(0, pupilRadius * 0.3);
      case Direction.left:
        leftEye = Offset(cx - eyeOffset * 0.5, cy - eyeOffset);
        rightEye = Offset(cx - eyeOffset * 0.5, cy + eyeOffset);
        pupilShift = Offset(-pupilRadius * 0.3, 0);
      case Direction.right:
        leftEye = Offset(cx + eyeOffset * 0.5, cy - eyeOffset);
        rightEye = Offset(cx + eyeOffset * 0.5, cy + eyeOffset);
        pupilShift = Offset(pupilRadius * 0.3, 0);
    }

    final whitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1A1F36);

    canvas.drawCircle(leftEye, eyeRadius, whitePaint);
    canvas.drawCircle(rightEye, eyeRadius, whitePaint);
    canvas.drawCircle(leftEye + pupilShift, pupilRadius, pupilPaint);
    canvas.drawCircle(rightEye + pupilShift, pupilRadius, pupilPaint);
  }

  @override
  bool shouldRepaint(SnakePainter old) {
    return old.snake != snake ||
        old.food != food ||
        old.foodType != foodType ||
        old.foodPulse != foodPulse ||
        old.direction != direction ||
        old.skin != skin ||
        old.obstacles != obstacles ||
        old.aiSnakes != aiSnakes ||
        old.deathPellets != deathPellets ||
        old.goldCoins != goldCoins ||
        old.isBoosting != isBoosting ||
        old.boundaryRadius != boundaryRadius;
  }
}
