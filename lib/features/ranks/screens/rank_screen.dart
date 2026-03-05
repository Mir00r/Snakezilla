import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/player_rank.dart';

/// Rank League screen showing the player's competitive rank, progress,
/// and all rank tiers.
class RankScreen extends ConsumerWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final rankPoints = profile.rankPoints;
    final currentRank = RankSystem.rankForPoints(rankPoints);
    final progress = RankSystem.progressInRank(rankPoints);
    final nextRank = currentRank.nextRank;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                        text: 'RANK LEAGUE',
                        fontSize: 14,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Current rank display
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Column(
                  children: [
                    Text(
                      currentRank.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 8),
                    NeonText(
                      text: currentRank.label.toUpperCase(),
                      fontSize: 18,
                      color: currentRank.color,
                      glowRadius: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$rankPoints RP',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress to next rank
              if (nextRank != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentRank.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            'Next: ${nextRank.label}',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: nextRank.color,
                            ),
                          ),
                          Text(
                            nextRank.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(
                                  currentRank.color),
                              minHeight: 10,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$rankPoints / ${nextRank.requiredPoints} RP',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // All ranks ladder
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: PlayerRank.values.length,
                  itemBuilder: (context, index) {
                    final rank = PlayerRank.values.reversed
                        .toList()[index]; // Show highest first
                    final isUnlocked =
                        rankPoints >= rank.requiredPoints;
                    final isCurrent = rank == currentRank;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 300 + index * 80),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 15 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isCurrent
                              ? rank.color.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.03),
                          border: Border.all(
                            color: isCurrent
                                ? rank.color.withValues(alpha: 0.6)
                                : isUnlocked
                                    ? rank.color.withValues(alpha: 0.2)
                                    : Colors.white10,
                            width: isCurrent ? 2 : 1,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color:
                                        rank.color.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              rank.emoji,
                              style: TextStyle(
                                fontSize: 24,
                                color: isUnlocked
                                    ? null
                                    : Colors.white24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rank.label.toUpperCase(),
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 9,
                                      color: isUnlocked
                                          ? rank.color
                                          : Colors.white24,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${rank.requiredPoints} RP required',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 6,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  color: rank.color
                                      .withValues(alpha: 0.2),
                                ),
                                child: Text(
                                  'YOU',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 7,
                                    color: rank.color,
                                  ),
                                ),
                              )
                            else if (isUnlocked)
                              Icon(Icons.check_circle,
                                  color: rank.color, size: 20)
                            else
                              const Icon(Icons.lock_outline,
                                  color: Colors.white24, size: 20),
                          ],
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
