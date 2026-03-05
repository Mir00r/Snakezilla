import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../models/daily_reward.dart';
import '../providers/player_profile_provider.dart';

/// 7-day daily reward calendar with animated chest opening.
class DailyRewardScreen extends ConsumerStatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  ConsumerState<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends ConsumerState<DailyRewardScreen>
    with TickerProviderStateMixin {
  bool _claimedNow = false;
  late AnimationController _chestController;
  late AnimationController _confettiController;
  late Animation<double> _chestBounce;
  late List<_ConfettiParticle> _confetti;
  int? _claimedDay;

  @override
  void initState() {
    super.initState();
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chestBounce = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _chestController, curve: Curves.elasticOut),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _confetti = List.generate(
      30,
      (_) => _ConfettiParticle.random(Random()),
    );
  }

  @override
  void dispose() {
    _chestController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  int _getCurrentStreak(int lastClaimDay) {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    if (lastClaimDay >= today) return -1; // Already claimed
    final diff = today - lastClaimDay;
    if (diff == 1) {
      // Consecutive day - continue streak
      final profile = ref.read(playerProfileProvider);
      return (profile.dailyStreak % 7);
    }
    // Streak broken, start from day 0
    return 0;
  }

  void _claimReward(int dayIndex) {
    final reward = DailyRewardCalendar.schedule[dayIndex];
    ref.read(playerProfileProvider.notifier).claimDailyRewardV2(dayIndex);
    HapticFeedback.heavyImpact();
    setState(() {
      _claimedNow = true;
      _claimedDay = dayIndex;
    });
    _chestController.forward(from: 0);
    _confettiController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final canClaim = profile.lastDailyRewardDay < today;
    final currentDay = canClaim ? (profile.dailyStreak % 7) : -1;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.neonGreen),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'DAILY REWARDS',
                        fontSize: 14,
                        color: AppColors.neonYellow,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Streak display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonYellow.withValues(alpha: 0.1),
                      AppColors.neonOrange.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.neonYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'STREAK: ${profile.dailyStreak} DAYS',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: AppColors.neonOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 7-day grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final reward = DailyRewardCalendar.schedule[index];
                    final isToday = canClaim && index == currentDay;
                    final isPast = index < (profile.dailyStreak % 7) ||
                        (!canClaim && index <= (profile.dailyStreak - 1) % 7);
                    final justClaimed = _claimedNow && _claimedDay == index;

                    return _RewardCard(
                      reward: reward,
                      isToday: isToday,
                      isPast: isPast && !isToday,
                      justClaimed: justClaimed,
                      chestBounce: _chestBounce,
                      onClaim: isToday && !_claimedNow
                          ? () => _claimReward(index)
                          : null,
                    );
                  },
                ),
              ),

              // Confetti overlay
              if (_claimedNow)
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _confetti,
                        progress: _confettiController.value,
                      ),
                      size: const Size(double.infinity, 100),
                    );
                  },
                ),

              // Claimed message
              if (_claimedNow && _claimedDay != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: NeonText(
                    text:
                        '+${DailyRewardCalendar.schedule[_claimedDay!].coins} COINS!',
                    fontSize: 16,
                    color: AppColors.neonYellow,
                    glowRadius: 20,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    canClaim
                        ? 'Tap today\'s reward to claim!'
                        : 'Come back tomorrow!',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: Colors.white38,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final DailyRewardDay reward;
  final bool isToday;
  final bool isPast;
  final bool justClaimed;
  final Animation<double> chestBounce;
  final VoidCallback? onClaim;

  const _RewardCard({
    required this.reward,
    required this.isToday,
    required this.isPast,
    required this.justClaimed,
    required this.chestBounce,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isToday
        ? AppColors.neonYellow
        : isPast
            ? AppColors.neonGreen.withValues(alpha: 0.3)
            : Colors.white12;

    return GestureDetector(
      onTap: onClaim,
      child: GlassContainer(
        padding: const EdgeInsets.all(8),
        borderColor: borderColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DAY ${reward.day}',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: isToday
                    ? AppColors.neonYellow
                    : isPast
                        ? AppColors.neonGreen
                        : Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            if (justClaimed)
              AnimatedBuilder(
                animation: chestBounce,
                builder: (context, child) {
                  return Transform.scale(
                    scale: chestBounce.value,
                    child: child,
                  );
                },
                child: Text(reward.emoji,
                    style: const TextStyle(fontSize: 28)),
              )
            else
              Text(
                isPast ? '✅' : reward.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            const SizedBox(height: 4),
            Text(
              '+${reward.coins}',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: isToday
                    ? AppColors.neonYellow
                    : Colors.white54,
              ),
            ),
            if (reward.bonusItem != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+ BONUS',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 5,
                    color: AppColors.neonPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Confetti ────────────────────────────────────────────────────────────────

class _ConfettiParticle {
  final double x, angle, speed, size;
  final Color color;

  const _ConfettiParticle({
    required this.x,
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  factory _ConfettiParticle.random(Random rng) {
    const colors = [
      AppColors.neonGreen,
      AppColors.neonPink,
      AppColors.neonBlue,
      AppColors.neonYellow,
      AppColors.neonOrange,
      AppColors.neonPurple,
    ];
    return _ConfettiParticle(
      x: rng.nextDouble(),
      angle: rng.nextDouble() * pi * 2,
      speed: 0.5 + rng.nextDouble(),
      size: 3 + rng.nextDouble() * 4,
      color: colors[rng.nextInt(colors.length)],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final t = progress;
      final x = p.x * size.width + sin(p.angle + t * pi * 4) * 30;
      final y = t * size.height * p.speed * 2;
      paint.color = p.color.withValues(alpha: 1 - t);
      canvas.drawCircle(Offset(x, y), p.size * (1 - t * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
