import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';

/// Beautiful animated player statistics dashboard.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProfileProvider);

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
                        text: 'PLAYER STATS',
                        fontSize: 14,
                        color: AppColors.neonBlue,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Player card
                      _PlayerCard(
                        level: p.level,
                        title: p.playerTitle,
                        xp: p.xpInLevel,
                        totalGames: p.totalGames,
                      ),
                      const SizedBox(height: 16),

                      // Stats grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.3,
                        children: [
                          _AnimatedStatCard(
                            emoji: '🎮',
                            label: 'GAMES PLAYED',
                            value: p.totalGames,
                            color: AppColors.neonGreen,
                            delay: 0,
                          ),
                          _AnimatedStatCard(
                            emoji: '🏆',
                            label: 'TOTAL SCORE',
                            value: p.totalScore,
                            color: AppColors.neonYellow,
                            delay: 100,
                          ),
                          _AnimatedStatCard(
                            emoji: '🐍',
                            label: 'LONGEST SNAKE',
                            value: p.longestSnake,
                            color: AppColors.neonPurple,
                            delay: 200,
                          ),
                          _AnimatedStatCard(
                            emoji: '🔥',
                            label: 'BEST COMBO',
                            value: p.highestCombo,
                            color: AppColors.neonOrange,
                            delay: 300,
                          ),
                          _AnimatedStatCard(
                            emoji: '💰',
                            label: 'COINS EARNED',
                            value: p.totalCoinsEarned,
                            color: Color(0xFFFFD700),
                            delay: 400,
                          ),
                          _AnimatedStatCard(
                            emoji: '⚔️',
                            label: 'AI VICTORIES',
                            value: p.aiWins,
                            color: AppColors.neonPink,
                            delay: 500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress bars
                      _ProgressSection(
                        label: 'ACHIEVEMENTS',
                        current: p.unlockedAchievements.length,
                        total: 10,
                        color: AppColors.neonYellow,
                      ),
                      const SizedBox(height: 10),
                      _ProgressSection(
                        label: 'SKINS COLLECTED',
                        current: p.unlockedSkins.length,
                        total: 12,
                        color: AppColors.neonPurple,
                      ),
                      const SizedBox(height: 10),
                      _ProgressSection(
                        label: 'PETS COLLECTED',
                        current: p.unlockedPets.length,
                        total: 6,
                        color: AppColors.neonPink,
                      ),
                      const SizedBox(height: 24),
                    ],
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

// ── Player Card ──────────────────────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final int level;
  final String title;
  final int xp;
  final int totalGames;

  const _PlayerCard({
    required this.level,
    required this.title,
    required this.xp,
    required this.totalGames,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderColor: AppColors.neonGreen.withValues(alpha: 0.3),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.neonGreen, AppColors.neonBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'LV\n$level',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: AppColors.neonGreen,
                  ),
                ),
                const SizedBox(height: 6),
                // XP bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xp / 100,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.neonGreen),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$xp / 100 XP to next level',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Stat Card ───────────────────────────────────────────────────────

class _AnimatedStatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;
  final Color color;
  final int delay;

  const _AnimatedStatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(
          scale: 0.5 + v * 0.5,
          child: child,
        ),
      ),
      child: GlassContainer(
        borderColor: color.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: Duration(milliseconds: 800 + delay),
              builder: (context, v, _) => Text(
                '$v',
                style: GoogleFonts.pressStart2p(
                  fontSize: 14,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 5,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress Section ─────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final String label;
  final int current;
  final int total;
  final Color color;

  const _ProgressSection({
    required this.label,
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: color,
                ),
              ),
              Text(
                '$current / $total',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(
                begin: 0, end: total > 0 ? current / total : 0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: v,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
