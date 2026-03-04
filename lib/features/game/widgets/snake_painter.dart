import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../skins/models/snake_skin.dart';
import '../models/direction.dart';
import '../models/food_type.dart';
import '../models/position.dart';

/// Custom painter that renders the snake, food, obstacles, AI snake,
/// and grid on a [Canvas].
///
/// Supports:
/// * Skin-based snake colours with glow effects
/// * Multiple food types with unique visuals
/// * Obstacle blocks (Survival mode)
/// * AI opponent snake (AI Battle mode)
class SnakePainter extends CustomPainter {
  final List<Position> snake;
  final Position food;
  final FoodType foodType;
  final Direction direction;
  final double foodPulse;
  final bool isDarkMode;
  final SnakeSkin skin;
  final List<Position> obstacles;
  final List<Position> aiSnake;
  final Direction aiDirection;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.foodType,
    required this.direction,
    required this.foodPulse,
    required this.isDarkMode,
    required this.skin,
    this.obstacles = const [],
    this.aiSnake = const [],
    this.aiDirection = Direction.right,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / GameConstants.gridWidth;
    final cellH = size.height / GameConstants.gridHeight;

    _drawGrid(canvas, size, cellW, cellH);
    _drawObstacles(canvas, cellW, cellH);
    _drawFood(canvas, cellW, cellH);
    if (aiSnake.isNotEmpty) {
      _drawAISnake(canvas, cellW, cellH);
    }
    _drawSnake(canvas, cellW, cellH);
  }

  // ── Grid ───────────────────────────────────────────────────────────────────

  void _drawGrid(Canvas canvas, Size size, double cellW, double cellH) {
    final paint = Paint()
      ..color = isDarkMode ? AppColors.gridLine : AppColors.gridLineDark
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

  // ── Obstacles ──────────────────────────────────────────────────────────────

  void _drawObstacles(Canvas canvas, double cellW, double cellH) {
    for (final obs in obstacles) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          obs.x * cellW + 1,
          obs.y * cellH + 1,
          cellW - 2,
          cellH - 2,
        ),
        Radius.circular(min(cellW, cellH) * 0.15),
      );

      // Glow
      canvas.drawRRect(
        rect,
        Paint()
          ..color = const Color(0xFFFF4444).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Solid block
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B0000),
              const Color(0xFFCC3333),
            ],
          ).createShader(rect.outerRect),
      );

      // Hazard pattern (X)
      final cx = obs.x * cellW + cellW / 2;
      final cy = obs.y * cellH + cellH / 2;
      final s = min(cellW, cellH) * 0.2;
      final xPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - s, cy - s), Offset(cx + s, cy + s), xPaint);
      canvas.drawLine(Offset(cx + s, cy - s), Offset(cx - s, cy + s), xPaint);
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

    // Outer glow
    canvas.drawCircle(
      center,
      pulseRadius * 1.6,
      Paint()
        ..color = color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Solid core with radial gradient
    canvas.drawCircle(
      center,
      pulseRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0.7)],
        ).createShader(
            Rect.fromCircle(center: center, radius: pulseRadius)),
    );

    // Special effects per food type
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
      case FoodType.normal:
        // Highlight dot (upper-left)
        canvas.drawCircle(
          center + Offset(-pulseRadius * 0.25, -pulseRadius * 0.25),
          pulseRadius * 0.2,
          Paint()..color = Colors.white.withOpacity(0.6),
        );
    }
  }

  void _drawSpeedLines(
      Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final y = center.dy - radius + (i * radius * 0.8);
      canvas.drawLine(
        Offset(center.dx - radius * 1.5, y),
        Offset(center.dx - radius * 0.8, y),
        paint,
      );
    }
  }

  void _drawIceCrystals(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      canvas.drawLine(
        center,
        center + Offset(cos(angle) * radius * 1.2, sin(angle) * radius * 1.2),
        paint,
      );
    }
  }

  void _drawCoinShine(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()..color = Colors.white.withOpacity(0.4),
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.15, -radius * 0.15),
      radius * 0.2,
      Paint()..color = Colors.white.withOpacity(0.7),
    );
  }

  void _drawRainbowRing(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 1.3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = SweepGradient(
          colors: const [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple,
            Colors.red,
          ],
        ).createShader(
            Rect.fromCircle(center: center, radius: radius * 1.3)),
    );
  }

  void _drawBombFuse(Canvas canvas, Offset center, double radius) {
    // Spark on top
    final sparks = Paint()
      ..color = AppColors.neonYellow.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final fuseTop = center + Offset(radius * 0.3, -radius * 0.9);
    canvas.drawCircle(fuseTop, radius * 0.15, sparks);
    canvas.drawLine(
      center + Offset(0, -radius * 0.5),
      fuseTop,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..strokeWidth = 1.5,
    );
  }

  // ── Snake ──────────────────────────────────────────────────────────────────

  void _drawSnake(Canvas canvas, double cellW, double cellH) {
    if (snake.isEmpty) return;

    final segmentCount = snake.length;

    for (int i = segmentCount - 1; i >= 0; i--) {
      final pos = snake[i];
      const inset = 1.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pos.x * cellW + inset,
          pos.y * cellH + inset,
          cellW - inset * 2,
          cellH - inset * 2,
        ),
        Radius.circular(min(cellW, cellH) * 0.3),
      );

      // Gradient colour from skin: bright head → dark tail.
      final t = segmentCount > 1 ? i / (segmentCount - 1) : 0.0;
      final color = Color.lerp(skin.headColor, skin.tailColor, t)!;

      // Head glow effect
      if (i == 0) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = skin.glowColor.withOpacity(0.3)
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, skin.glowRadius),
        );
      }

      // Body segment
      canvas.drawRRect(rect, Paint()..color = color);

      // Eyes on the head
      if (i == 0) {
        _drawEyes(canvas, pos, cellW, cellH, direction);
      }
    }
  }

  // ── AI Snake ───────────────────────────────────────────────────────────────

  void _drawAISnake(Canvas canvas, double cellW, double cellH) {
    if (aiSnake.isEmpty) return;

    final segmentCount = aiSnake.length;
    const headColor = Color(0xFFFF1493);
    const tailColor = Color(0xFF8B0050);

    for (int i = segmentCount - 1; i >= 0; i--) {
      final pos = aiSnake[i];
      const inset = 1.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pos.x * cellW + inset,
          pos.y * cellH + inset,
          cellW - inset * 2,
          cellH - inset * 2,
        ),
        Radius.circular(min(cellW, cellH) * 0.3),
      );

      final t = segmentCount > 1 ? i / (segmentCount - 1) : 0.0;
      final color = Color.lerp(headColor, tailColor, t)!;

      if (i == 0) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = headColor.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      canvas.drawRRect(rect, Paint()..color = color);

      if (i == 0) {
        _drawEyes(canvas, pos, cellW, cellH, aiDirection);
      }
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
        old.aiSnake != aiSnake;
  }
}
