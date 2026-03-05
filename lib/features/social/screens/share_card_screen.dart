import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';

/// Share card generator for viral sharing moments.
/// Generates a visual "brag card" showing game stats.
class ShareCardScreen extends ConsumerWidget {
  final int score;
  final int maxCombo;
  final int kills;
  final String gameMode;

  const ShareCardScreen({
    super.key,
    required this.score,
    required this.maxCombo,
    this.kills = 0,
    this.gameMode = 'Classic',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.neonGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'SHARE',
                        fontSize: 14,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Share card preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ShareCard(
                  playerName: profile.playerTitle,
                  level: profile.level,
                  score: score,
                  maxCombo: maxCombo,
                  kills: kills,
                  gameMode: gameMode,
                  highScore: profile.totalScore > 0
                      ? (profile.totalScore ~/ profile.totalGames)
                      : 0,
                ),
              ),
              const SizedBox(height: 24),

              // Share buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShareButton(
                        icon: Icons.copy_rounded,
                        label: 'COPY',
                        color: AppColors.neonBlue,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '📋 Stats copied to clipboard!',
                                style:
                                    GoogleFonts.pressStart2p(fontSize: 7),
                              ),
                              backgroundColor: const Color(0xFF1A1A2E),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShareButton(
                        icon: Icons.share_rounded,
                        label: 'SHARE',
                        color: AppColors.neonGreen,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🚀 Sharing coming soon!',
                                style:
                                    GoogleFonts.pressStart2p(fontSize: 7),
                              ),
                              backgroundColor: const Color(0xFF1A1A2E),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Challenge text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderColor: AppColors.neonOrange.withValues(alpha: 0.3),
                  child: Column(
                    children: [
                      Text(
                        '🔥 CHALLENGE TEXT',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: AppColors.neonOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'I scored $score in Snakezilla ($gameMode mode)! '
                        '${maxCombo > 3 ? "Hit a ${maxCombo}x combo! " : ""}'
                        '${kills > 0 ? "Eliminated $kills snakes! " : ""}'
                        'Can you beat me? 🐍⚡',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6,
                          color: Colors.white54,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

// ── Share Card Widget ────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final String playerName;
  final int level;
  final int score;
  final int maxCombo;
  final int kills;
  final String gameMode;
  final int highScore;

  const _ShareCard({
    required this.playerName,
    required this.level,
    required this.score,
    required this.maxCombo,
    required this.kills,
    required this.gameMode,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0D2B),
            Color(0xFF1A1A3E),
            Color(0xFF0D0D2B),
          ],
        ),
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          const NeonText(
            text: 'SNAKEZILLA',
            fontSize: 16,
            color: AppColors.neonGreen,
            glowRadius: 20,
          ),
          const SizedBox(height: 4),
          const Text('🐍', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),

          // Mode badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.neonPurple.withValues(alpha: 0.2),
              border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.4)),
            ),
            child: Text(
              gameMode.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: AppColors.neonPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Score
          Text(
            '$score',
            style: GoogleFonts.pressStart2p(
              fontSize: 28,
              color: AppColors.neonGreen,
              shadows: [
                Shadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.5),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          Text(
            'POINTS',
            style: GoogleFonts.pressStart2p(
                fontSize: 7, color: Colors.white38),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBadge(
                  emoji: '🔥', value: '${maxCombo}x', label: 'COMBO'),
              if (kills > 0)
                _StatBadge(
                    emoji: '💀', value: '$kills', label: 'KILLS'),
              _StatBadge(
                  emoji: '⭐', value: 'Lv.$level', label: 'LEVEL'),
            ],
          ),
          const SizedBox(height: 16),

          // Player info
          Text(
            playerName,
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: AppColors.neonYellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatBadge({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
              fontSize: 10, color: Colors.white),
        ),
        Text(
          label,
          style: GoogleFonts.pressStart2p(
              fontSize: 5, color: Colors.white38),
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.pressStart2p(fontSize: 8, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
