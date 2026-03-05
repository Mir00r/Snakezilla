import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_world.dart';

/// Ambient particle overlay that renders world-specific effects
/// (fireflies, snow, embers, bubbles, stars, light beams).
class WorldParticleOverlay extends StatefulWidget {
  final GameWorld world;

  const WorldParticleOverlay({super.key, required this.world});

  @override
  State<WorldParticleOverlay> createState() => _WorldParticleOverlayState();
}

class _WorldParticleOverlayState extends State<WorldParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_AmbientParticle> _particles;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = _generateParticles();
  }

  List<_AmbientParticle> _generateParticles() {
    final count = switch (widget.world.particleType) {
      WorldParticleType.none => 0,
      WorldParticleType.lightBeams => 6,
      WorldParticleType.fireflies => 20,
      WorldParticleType.snow => 40,
      WorldParticleType.lavaEmbers => 18,
      WorldParticleType.bubbles => 15,
      WorldParticleType.stars => 30,
    };
    return List.generate(count, (_) => _AmbientParticle.random(_rng));
  }

  @override
  void didUpdateWidget(WorldParticleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.world.id != widget.world.id) {
      _particles = _generateParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.world.particleType == WorldParticleType.none) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WorldParticlePainter(
            particles: _particles,
            type: widget.world.particleType,
            color: widget.world.particleColor,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _AmbientParticle {
  double x, y, speed, size, phase;

  _AmbientParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
  });

  factory _AmbientParticle.random(Random rng) {
    return _AmbientParticle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      speed: 0.3 + rng.nextDouble() * 0.7,
      size: 1 + rng.nextDouble() * 3,
      phase: rng.nextDouble() * pi * 2,
    );
  }
}

class _WorldParticlePainter extends CustomPainter {
  final List<_AmbientParticle> particles;
  final WorldParticleType type;
  final Color color;
  final double progress;

  _WorldParticlePainter({
    required this.particles,
    required this.type,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case WorldParticleType.snow:
        _paintSnow(canvas, size);
      case WorldParticleType.fireflies:
        _paintFireflies(canvas, size);
      case WorldParticleType.lavaEmbers:
        _paintEmbers(canvas, size);
      case WorldParticleType.bubbles:
        _paintBubbles(canvas, size);
      case WorldParticleType.stars:
        _paintStars(canvas, size);
      case WorldParticleType.lightBeams:
        _paintLightBeams(canvas, size);
      case WorldParticleType.none:
        break;
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final x = (p.x + sin(t * pi * 2 + p.phase) * 0.05) * size.width;
      final y = (t) * size.height;
      paint.color = color.withValues(alpha: 0.3 + sin(t * pi) * 0.5);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  void _paintFireflies(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final t = progress + p.phase;
      final glow = (sin(t * pi * 4) + 1) / 2;
      final x = (p.x + sin(t * pi * 2) * 0.03) * size.width;
      final y = (p.y + cos(t * pi * 1.5) * 0.03) * size.height;
      paint.color = color.withValues(alpha: glow * 0.8);
      canvas.drawCircle(Offset(x, y), p.size * (1 + glow * 0.5), paint);
      // Glow halo
      paint.color = color.withValues(alpha: glow * 0.2);
      canvas.drawCircle(Offset(x, y), p.size * 4, paint);
    }
  }

  void _paintEmbers(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final t = (progress * p.speed * 0.5 + p.phase) % 1.0;
      final x = (p.x + sin(t * pi * 3 + p.phase) * 0.04) * size.width;
      final y = (1 - t) * size.height; // Rise upward
      final alpha = (1 - t) * 0.8;
      paint.color = Color.lerp(color, Colors.red, t)!.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), p.size * (1 - t * 0.5), paint);
    }
  }

  void _paintBubbles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (final p in particles) {
      final t = (progress * p.speed * 0.3 + p.phase) % 1.0;
      final x = (p.x + sin(t * pi * 2 + p.phase) * 0.06) * size.width;
      final y = (1 - t) * size.height;
      final alpha = sin(t * pi) * 0.6;
      paint.color = color.withValues(alpha: alpha);
      final r = p.size + sin(t * pi * 2) * 1;
      canvas.drawCircle(Offset(x, y), r, paint);
      // Highlight
      final fillPaint = Paint()..color = color.withValues(alpha: alpha * 0.2);
      canvas.drawCircle(Offset(x, y), r, fillPaint);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final t = progress + p.phase;
      final twinkle = (sin(t * pi * 6 * p.speed) + 1) / 2;
      paint.color = color.withValues(alpha: twinkle * 0.7 + 0.1);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * (0.5 + twinkle * 0.5),
        paint,
      );
    }
  }

  void _paintLightBeams(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final t = progress + p.phase;
      final x = (p.x + sin(t * pi * 0.5) * 0.2) * size.width;
      final alpha = (sin(t * pi * 2) + 1) / 2 * 0.08;
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(x - 15, 0, 30, size.height));
      canvas.drawRect(Rect.fromLTWH(x - 15, 0, 30, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WorldParticlePainter old) => true;
}
