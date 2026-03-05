import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/weekly_challenge.dart';

/// Weekly challenge ladder screen with animated milestone progression.
class WeeklyChallengeScreen extends ConsumerWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = WeeklyChallenges.current();
    final profile = ref.watch(playerProfileProvider);
    final completedStep = profile.weeklyStepCompleted;

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
                        text: 'WEEKLY CHALLENGE',
                        fontSize: 12,
                        color: AppColors.neonOrange,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Challenge header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassContainer(
                  borderColor: AppColors.neonOrange.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Text(challenge.emoji,
                          style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title.toUpperCase(),
                              style: GoogleFonts.pressStart2p(
                                fontSize: 10,
                                color: AppColors.neonOrange,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Complete all steps for the final reward!',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 6,
                                color: Colors.white54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Challenge ladder ──────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: challenge.steps.length + 1, // +1 for final reward
                  itemBuilder: (context, index) {
                    if (index < challenge.steps.length) {
                      final step = challenge.steps[index];
                      final isCompleted = completedStep > index;
                      final isCurrent = completedStep == index;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration:
                            Duration(milliseconds: 300 + index * 100),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _StepCard(
                          step: step,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                        ),
                      );
                    }

                    // Final reward card
                    final allDone =
                        completedStep >= challenge.steps.length;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _FinalRewardCard(
                        challenge: challenge,
                        unlocked: allDone,
                      ),
                    );
                  },
                ),
              ),

              // Timer
              Padding(
                padding: const EdgeInsets.all(16),
                child: _WeekTimer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step Card ────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final WeeklyChallengeStep step;
  final bool isCompleted;
  final bool isCurrent;

  const _StepCard({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isCompleted ? AppColors.neonGreen : (isCurrent ? AppColors.neonOrange : Colors.white24);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: color, size: 18)
                      : Text(
                          '${step.step}',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: color,
                          ),
                        ),
                ),
              ),
              if (step.step < 4)
                Container(
                  width: 2,
                  height: 30,
                  color: color.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: GlassContainer(
              borderColor: color.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(step.emoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.title.toUpperCase(),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 8,
                            color:
                                isCompleted ? AppColors.neonGreen : Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.neonYellow.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          '+${step.coinReward}💰',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: AppColors.neonYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '✅ COMPLETED',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Final Reward Card ────────────────────────────────────────────────────────

class _FinalRewardCard extends StatelessWidget {
  final WeeklyChallenge challenge;
  final bool unlocked;

  const _FinalRewardCard({required this.challenge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: unlocked
              ? [
                  AppColors.neonYellow.withValues(alpha: 0.2),
                  AppColors.neonOrange.withValues(alpha: 0.2),
                ]
              : [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
        ),
        border: Border.all(
          color: unlocked
              ? AppColors.neonYellow.withValues(alpha: 0.5)
              : Colors.white12,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            unlocked ? '🏆 FINAL REWARD UNLOCKED!' : '🔒 FINAL REWARD',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: unlocked ? AppColors.neonYellow : Colors.white38,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '🎁 ${challenge.finalCoinReward} Coins + ${_rewardLabel(challenge)}',
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: unlocked ? Colors.white : Colors.white38,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _rewardLabel(WeeklyChallenge c) {
    switch (c.finalRewardType) {
      case 'skin':
        return 'Exclusive Skin';
      case 'pet':
        return 'Rare Pet';
      default:
        return 'Bonus Coins';
    }
  }
}

// ── Week Timer ───────────────────────────────────────────────────────────────

class _WeekTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft = 7 - now.weekday;
    final hoursLeft = 24 - now.hour;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text(
            'Resets in ${daysLeft}d ${hoursLeft}h',
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
