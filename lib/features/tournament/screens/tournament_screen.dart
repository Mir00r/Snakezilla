import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../../game/models/game_mode.dart';
import '../../game/providers/game_provider.dart';
import '../../game/screens/game_screen.dart';
import '../models/tournament.dart';

/// Tournament hub showing daily, weekly, and special tournaments.
class TournamentScreen extends ConsumerWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = Tournaments.daily();
    final weekly = Tournaments.weekly();
    final special = Tournaments.special();
    final profile = ref.watch(playerProfileProvider);

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
                        text: 'TOURNAMENTS',
                        fontSize: 14,
                        color: AppColors.neonPink,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _TournamentCard(
                      tournament: daily,
                      rank: _simulateRank(profile.totalScore, 1),
                      onPlay: () => _launchTournament(context, ref),
                    ),
                    const SizedBox(height: 16),
                    _TournamentCard(
                      tournament: weekly,
                      rank: _simulateRank(profile.totalScore, 2),
                      onPlay: () => _launchTournament(context, ref),
                    ),
                    if (special != null) ...[
                      const SizedBox(height: 16),
                      _TournamentCard(
                        tournament: special,
                        rank: _simulateRank(profile.totalScore, 3),
                        onPlay: () => _launchTournament(context, ref),
                        isSpecial: true,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Fake leaderboard
                    _TournamentLeaderboard(
                      playerScore: profile.totalScore ~/ max(1, profile.totalGames),
                      playerName: profile.playerTitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _simulateRank(int totalScore, int difficulty) {
    if (totalScore == 0) return 0;
    final avgScore = totalScore ~/ 10;
    final opponents = TournamentAI.generateOpponents(20, difficulty);
    int rank = 1;
    for (final o in opponents) {
      if (o.score > avgScore) rank++;
    }
    return rank;
  }

  void _launchTournament(BuildContext context, WidgetRef ref) {
    ref.read(gameLaunchConfigProvider.notifier).state =
        const GameLaunchConfig(mode: GameMode.classic);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final int rank;
  final VoidCallback onPlay;
  final bool isSpecial;

  const _TournamentCard({
    required this.tournament,
    required this.rank,
    required this.onPlay,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSpecial ? AppColors.neonYellow : AppColors.neonPink;

    return GlassContainer(
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tournament.type.emoji,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSpecial)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.neonYellow.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          'LIMITED TIME',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: AppColors.neonYellow,
                          ),
                        ),
                      ),
                    Text(
                      tournament.title.toUpperCase(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tournament.type.description,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Prize + Rank row
          Row(
            children: [
              _PrizeBadge(
                emoji: '💰',
                value: '${tournament.coinPrize}',
                color: AppColors.neonYellow,
              ),
              const SizedBox(width: 8),
              _PrizeBadge(
                emoji: '⭐',
                value: '${tournament.xpPrize} XP',
                color: AppColors.neonBlue,
              ),
              const Spacer(),
              if (rank > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: Text(
                    'Rank #$rank',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: rank <= 3
                          ? AppColors.neonYellow
                          : Colors.white54,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Play button
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '⚔️ ENTER TOURNAMENT',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrizeBadge extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;

  const _PrizeBadge({
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentLeaderboard extends StatelessWidget {
  final int playerScore;
  final String playerName;

  const _TournamentLeaderboard({
    required this.playerScore,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final opponents = TournamentAI.generateOpponents(10, 2);
    final all = [
      TournamentEntry(
        playerName: 'You ($playerName)',
        score: playerScore,
        date: DateTime.now(),
      ),
      ...opponents,
    ]..sort((a, b) => b.score.compareTo(a.score));

    return GlassContainer(
      borderColor: Colors.white12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 LEADERBOARD',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: AppColors.neonPink,
            ),
          ),
          const SizedBox(height: 12),
          ...all.take(10).toList().asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            final isPlayer = entry.playerName.startsWith('You');
            final medal = idx == 0
                ? '🥇'
                : idx == 1
                    ? '🥈'
                    : idx == 2
                        ? '🥉'
                        : '  ';

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isPlayer
                    ? AppColors.neonGreen.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child:
                        Text(medal, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 20,
                    child: Text(
                      '#${idx + 1}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.playerName,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: isPlayer
                            ? AppColors.neonGreen
                            : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.score}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: isPlayer
                          ? AppColors.neonGreen
                          : Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
