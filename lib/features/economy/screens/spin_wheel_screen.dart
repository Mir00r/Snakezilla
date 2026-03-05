import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/neon_text.dart';
import '../providers/player_profile_provider.dart';

/// Spin-to-win reward wheel with dramatic animation.
class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  bool _hasResult = false;
  int _resultIndex = -1;
  final _rng = Random();

  static const _segments = [
    _WheelSegment('💰', '50 Coins', 50, AppColors.neonGreen),
    _WheelSegment('⚡', 'XP Boost', 0, AppColors.neonBlue),
    _WheelSegment('💰', '100 Coins', 100, AppColors.neonYellow),
    _WheelSegment('🧩', 'Skin Frag', 0, AppColors.neonPurple),
    _WheelSegment('💰', '25 Coins', 25, AppColors.neonOrange),
    _WheelSegment('🔥', '2x Score', 0, AppColors.neonPink),
    _WheelSegment('💰', '200 Coins', 200, Color(0xFFFFD700)),
    _WheelSegment('🛡️', 'Shield', 0, AppColors.neonBlue),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  bool get _canSpin {
    final profile = ref.read(playerProfileProvider);
    return profile.lastSpinDay <
        DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  }

  void _spin() {
    if (_isSpinning || !_canSpin) return;

    _resultIndex = _rng.nextInt(_segments.length);
    // Calculate rotation: 5 full rotations + landing angle
    final targetAngle =
        5 * 2 * pi + (_resultIndex / _segments.length) * 2 * pi;

    _spinAnimation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    setState(() {
      _isSpinning = true;
      _hasResult = false;
    });

    HapticFeedback.mediumImpact();
    _spinController.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
        _hasResult = true;
      });
      _awardPrize();
    });
  }

  void _awardPrize() {
    final segment = _segments[_resultIndex];
    ref.read(playerProfileProvider.notifier).claimSpinReward();
    if (segment.coins > 0) {
      ref.read(playerProfileProvider.notifier).addCoins(segment.coins);
    }
    if (segment.label == 'XP Boost') {
      ref.read(playerProfileProvider.notifier).addXp(50);
    }
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = _canSpin;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.neonGreen),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'LUCKY SPIN',
                        fontSize: 16,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Wheel
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating wheel
                    AnimatedBuilder(
                      animation: _spinController,
                      builder: (context, child) {
                        final angle =
                            _isSpinning ? _spinAnimation.value : 0.0;
                        return Transform.rotate(
                          angle: -angle,
                          child: child,
                        );
                      },
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _WheelPainter(segments: _segments),
                      ),
                    ),
                    // Center pointer arrow
                    Positioned(
                      top: 0,
                      child: CustomPaint(
                        size: const Size(24, 24),
                        painter: _PointerPainter(),
                      ),
                    ),
                    // Center button
                    GestureDetector(
                      onTap: canSpin && !_isSpinning ? _spin : null,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              canSpin && !_isSpinning
                                  ? AppColors.neonPurple
                                  : Colors.grey,
                              canSpin && !_isSpinning
                                  ? AppColors.neonPink
                                  : Colors.grey.shade700,
                            ],
                          ),
                          boxShadow: canSpin
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonPurple
                                        .withValues(alpha: 0.5),
                                    blurRadius: 15,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _isSpinning ? '...' : 'SPIN',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Result display
              if (_hasResult && _resultIndex >= 0) ...[
                NeonText(
                  text: 'YOU WON!',
                  fontSize: 20,
                  color: AppColors.neonYellow,
                  glowRadius: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_segments[_resultIndex].emoji} ${_segments[_resultIndex].label}',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: _segments[_resultIndex].color,
                  ),
                ),
              ] else if (!canSpin)
                Text(
                  'Come back tomorrow for a free spin!',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white38,
                  ),
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Free daily spin! Win coins, boosts, and more.',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: Colors.white30,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelSegment {
  final String emoji;
  final String label;
  final int coins;
  final Color color;
  const _WheelSegment(this.emoji, this.label, this.coins, this.color);
}

class _WheelPainter extends CustomPainter {
  final List<_WheelSegment> segments;
  _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / segments.length;
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white24;

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      paint.color = segments[i].color.withValues(alpha: 0.3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Emoji label
      final midAngle = startAngle + segmentAngle / 2;
      final labelOffset = Offset(
        center.dx + cos(midAngle) * radius * 0.65,
        center.dy + sin(midAngle) * radius * 0.65,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: segments[i].emoji,
          style: const TextStyle(fontSize: 22),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        labelOffset - Offset(tp.width / 2, tp.height / 2),
      );
    }

    // Outer ring
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
