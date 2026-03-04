import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../models/leaderboard_entry.dart';
import '../providers/leaderboard_provider.dart';

/// Leaderboard screen displaying sorted player scores.
///
/// The top 3 entries receive special medal styling and a stronger
/// neon glow to highlight champions.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardProvider);

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
                        text: 'LEADERBOARD',
                        fontSize: 16,
                        color: AppColors.neonYellow,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Body
              if (entries.isEmpty)
                const Expanded(
                  child: Center(
                    child: NeonText(
                      text: 'No scores yet!\nPlay a game first.',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      glowRadius: 0,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + index * 80),
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
                        child: _LeaderboardTile(
                          entry: entries[index],
                          rank: index + 1,
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

// ── Private widgets ──────────────────────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _LeaderboardTile({required this.entry, required this.rank});

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppColors.neonYellow;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.white54;
    }
  }

  String get _rankIcon {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderColor: isTop3 ? _rankColor.withOpacity(0.4) : null,
        child: Row(
          children: [
            // Rank badge
            SizedBox(
              width: 40,
              child: isTop3
                  ? Text(_rankIcon, style: const TextStyle(fontSize: 20))
                  : Text(
                      _rankIcon,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: _rankColor,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Name & difficulty / date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.playerName,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 11,
                      color: isTop3 ? _rankColor : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.difficulty.label}  •  ${_formatDate(entry.date)}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Score
            NeonText(
              text: entry.score.toString(),
              fontSize: 14,
              color: isTop3 ? _rankColor : AppColors.neonGreen,
              glowRadius: isTop3 ? 15 : 5,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
