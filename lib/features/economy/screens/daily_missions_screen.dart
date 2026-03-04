import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../models/daily_mission.dart';

/// Screen that shows the 3 daily missions with progress and rewards.
class DailyMissionsScreen extends ConsumerWidget {
  const DailyMissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = DailyMissions.forToday();

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────
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
                        text: 'DAILY MISSIONS',
                        fontSize: 14,
                        color: AppColors.neonYellow,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Timer ──────────────────────────────────
              _ResetTimer(),

              const SizedBox(height: 16),

              // ── Mission cards ──────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + index * 150),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _MissionCard(mission: missions[index]),
                      ),
                    );
                  },
                ),
              ),

              // ── Footer tip ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Complete missions to earn bonus coins!\nNew missions appear daily.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: Colors.white38,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reset Timer ──────────────────────────────────────────────────────────────

class _ResetTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final remaining = tomorrow.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text(
            'Resets in ${hours}h ${minutes}m',
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mission Card ─────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final DailyMission mission;

  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderColor: AppColors.neonYellow.withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Emoji badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.neonYellow.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.neonYellow.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    mission.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title.toUpperCase(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mission.description,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: Colors.white54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Reward badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.neonYellow.withOpacity(0.15),
                  border: Border.all(
                    color: AppColors.neonYellow.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      '+${mission.coinReward}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: AppColors.neonYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar (visual only – placeholder 0%)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.white12,
              valueColor:
                  AlwaysStoppedAnimation(AppColors.neonYellow.withOpacity(0.7)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '0 / ${mission.target}',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
