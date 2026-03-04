import 'dart:math';

import 'package:flutter/material.dart';

/// A short-lived particle burst effect triggered when the snake eats food.
///
/// Spawns a ring of tiny circles that expand outward from [position]
/// and fade over 500 ms, then calls [onComplete].
class ParticleEffect extends StatefulWidget {
  /// Centre of the burst in local widget coordinates.
  final Offset position;

  /// Colour of the particles.
  final Color color;

  /// Called when the animation finishes so the parent can remove the widget.
  final VoidCallback onComplete;

  const ParticleEffect({
    super.key,
    required this.position,
    required this.color,
    required this.onComplete,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });

    // Generate 12 particles with random angles and speeds.
    _particles = List.generate(12, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30 + _random.nextDouble() * 60;
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: 2 + _random.nextDouble() * 4,
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            origin: widget.position,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Data for a single particle's trajectory.
class _Particle {
  final double dx;
  final double dy;
  final double size;

  const _Particle({required this.dx, required this.dy, required this.size});
}

/// Paints all particles at a given animation [progress] (0 → 1).
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Offset origin;
  final Color color;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.origin,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(1 - progress);
    for (final p in particles) {
      final x = origin.dx + p.dx * progress;
      final y = origin.dy + p.dy * progress;
      canvas.drawCircle(
        Offset(x, y),
        p.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
