import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../models/direction.dart';
import '../models/position.dart';

/// Custom painter that renders the snake, food, and grid on a [Canvas].
///
/// Design notes:
/// * The snake is drawn as rounded-rect segments with a head-to-tail
///   gradient from bright neon green to a deeper emerald.
/// * The head features two eyes whose pupils shift with the direction.
/// * Food renders as a pulsing, glowing pink orb with a white highlight.
/// * Grid lines are subtle and semi-transparent.
class SnakePainter extends CustomPainter {
  /// Ordered list of body segment positions (head first).
  final List<Position> snake;

  /// Current food position.
  final Position food;

  /// Current movement direction (used for eye orientation).
  final Direction direction;

  /// A 0 → 1 animation value driving the food pulse effect.
  final double foodPulse;

  /// Whether to use dark-mode colours.
  final bool isDarkMode;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.direction,
    required this.foodPulse,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / GameConstants.gridWidth;
    final cellH = size.height / GameConstants.gridHeight;

    _drawGrid(canvas, size, cellW, cellH);
    _drawFood(canvas, cellW, cellH);
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

  // ── Food ───────────────────────────────────────────────────────────────────

  void _drawFood(Canvas canvas, double cellW, double cellH) {
    final center = Offset(
      food.x * cellW + cellW / 2,
      food.y * cellH + cellH / 2,
    );
    final baseRadius = min(cellW, cellH) * 0.35;
    final pulseRadius = baseRadius * (1.0 + 0.15 * sin(foodPulse * pi * 2));

    // Outer glow
    canvas.drawCircle(
      center,
      pulseRadius * 1.6,
      Paint()
        ..color = AppColors.foodGlow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Solid core with radial gradient
    canvas.drawCircle(
      center,
      pulseRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.food, AppColors.food.withOpacity(0.7)],
        ).createShader(
            Rect.fromCircle(center: center, radius: pulseRadius)),
    );

    // Highlight dot (upper-left)
    canvas.drawCircle(
      center + Offset(-pulseRadius * 0.25, -pulseRadius * 0.25),
      pulseRadius * 0.2,
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  // ── Snake ──────────────────────────────────────────────────────────────────

  void _drawSnake(Canvas canvas, double cellW, double cellH) {
    if (snake.isEmpty) return;

    final segmentCount = snake.length;

    // Draw from tail to head so the head layer is on top.
    for (int i = segmentCount - 1; i >= 0; i--) {
      final pos = snake[i];
      final inset = 1.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pos.x * cellW + inset,
          pos.y * cellH + inset,
          cellW - inset * 2,
          cellH - inset * 2,
        ),
        Radius.circular(min(cellW, cellH) * 0.3),
      );

      // Gradient colour: bright head → dark tail.
      final t = segmentCount > 1 ? i / (segmentCount - 1) : 0.0;
      final color =
          Color.lerp(AppColors.snakeHead, AppColors.snakeTail, t)!;

      // Head glow effect
      if (i == 0) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = AppColors.snakeHead.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // Body segment
      canvas.drawRRect(rect, Paint()..color = color);

      // Eyes on the head
      if (i == 0) {
        _drawEyes(canvas, pos, cellW, cellH);
      }
    }
  }

  // ── Eyes ────────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, Position head, double cellW, double cellH) {
    final cx = head.x * cellW + cellW / 2;
    final cy = head.y * cellH + cellH / 2;
    final eyeRadius = min(cellW, cellH) * 0.1;
    final pupilRadius = eyeRadius * 0.55;
    final eyeOffset = min(cellW, cellH) * 0.18;

    late Offset leftEye, rightEye;
    late Offset pupilShift;

    switch (direction) {
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
        old.foodPulse != foodPulse ||
        old.direction != direction;
  }
}
