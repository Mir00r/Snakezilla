import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/achievement.dart';

/// Achievements screen showing all available achievements and unlock status.
///
/// Locked achievements are greyed out; unlocked ones show their badge
/// in full colour with a neon glow border.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final unlockedCount = profile.unlockedAchievements.length;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
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
                        text: 'ACHIEVEMENTS',
                        fontSize: 14,
                        color: AppColors.neonYellow,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Progress bar ───────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$unlockedCount / ${Achievements.all.length}',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: AppColors.neonYellow,
                          ),
                        ),
                        Text(
                          '${(unlockedCount / Achievements.all.length * 100).round()}%',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: unlockedCount / Achievements.all.length,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.neonYellow),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Achievement list ───────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: Achievements.all.length,
                  itemBuilder: (context, index) {
                    final achievement = Achievements.all[index];
                    final isUnlocked = profile.unlockedAchievements
                        .contains(achievement.id);

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 300 + index * 80),
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AchievementTile(
                          achievement: achievement,
                          isUnlocked: isUnlocked,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Achievement Tile ─────────────────────────────────────────────────────────

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: isUnlocked
          ? AppColors.neonYellow.withOpacity(0.4)
          : Colors.white12,
      child: Row(
        children: [
          // Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppColors.neonYellow.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: isUnlocked
                    ? AppColors.neonYellow.withOpacity(0.5)
                    : Colors.white12,
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppColors.neonYellow.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                achievement.badge,
                style: TextStyle(
                  fontSize: 20,
                  color: isUnlocked ? null : Colors.white24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: isUnlocked ? Colors.white : Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnlocked
                        ? Colors.white70
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Reward
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 3),
                  Text(
                    '${achievement.coinReward}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: isUnlocked
                          ? AppColors.neonYellow
                          : Colors.white30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (isUnlocked)
                Icon(Icons.check_circle,
                    color: AppColors.neonGreen, size: 16)
              else
                Icon(Icons.lock, color: Colors.white24, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
