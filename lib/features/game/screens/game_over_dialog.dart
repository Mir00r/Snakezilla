import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../../leaderboard/models/leaderboard_entry.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../social/screens/share_card_screen.dart';
import '../models/game_mode.dart';
import '../providers/game_provider.dart';

/// Animated Game Over dialog shown as a modal overlay.
///
/// Features:
/// * Scale + fade entrance animation
/// * Score summary with "NEW HIGH SCORE" banner when applicable
/// * Coins earned, combo stats, game mode display
/// * Achievement unlock notification
/// * Player name input for the leaderboard
/// * MENU / RETRY action buttons
Future<void> showGameOverDialog(
  BuildContext context,
  WidgetRef ref,
  int score,
  int highScore, {
  int coinsEarned = 0,
  int maxCombo = 0,
  int kills = 0,
  int goldCollected = 0,
  GameMode gameMode = GameMode.classic,
}) async {
  final nameController = TextEditingController(text: 'Player');

  // Check achievements after game over.
  List<String> newAchievements = [];
  try {
    final unlocked =
        ref.read(playerProfileProvider.notifier).checkAchievements();
    newAchievements = unlocked.map((a) => '${a.badge} ${a.title}').toList();
  } catch (_) {}

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 500),
    transitionBuilder: (context, a1, a2, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      );
    },
    pageBuilder: (context, _, __) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: GlassContainer(
              borderColor: AppColors.neonPink.withOpacity(0.4),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NeonText(
                      text: 'GAME OVER',
                      fontSize: 22,
                      color: AppColors.neonPink,
                      glowRadius: 25,
                    ),
                    const SizedBox(height: 8),

                    // Mode badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonPurple.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        '${gameMode.icon} ${gameMode.label}',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: AppColors.neonPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Victory banner for Battle Royale
                    if (gameMode == GameMode.battleRoyale && score > 0)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: NeonText(
                          text: '👑 VICTORY ROYALE 👑',
                          fontSize: 14,
                          color: AppColors.neonYellow,
                          glowRadius: 20,
                        ),
                      ),

                    // Score
                    NeonText(
                      text: 'Score: $score',
                      fontSize: 16,
                      color: AppColors.neonGreen,
                    ),
                    const SizedBox(height: 8),
                    if (score >= highScore && score > 0)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: NeonText(
                          text: 'NEW HIGH SCORE!',
                          fontSize: 12,
                          color: AppColors.neonYellow,
                        ),
                      ),

                    // Stats row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _StatChip(
                            icon: '💰',
                            value: '+$coinsEarned',
                            color: AppColors.neonYellow),
                        if (maxCombo > 1)
                          _StatChip(
                              icon: '🔥',
                              value: '${maxCombo}x',
                              color: AppColors.neonOrange),
                        if (kills > 0)
                          _StatChip(
                              icon: '💀',
                              value: '$kills kills',
                              color: AppColors.neonPink),
                        if (goldCollected > 0)
                          _StatChip(
                              icon: '🪙',
                              value: '$goldCollected',
                              color: const Color(0xFFFFD700)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Achievement notifications
                    if (newAchievements.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.neonYellow.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.neonYellow.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ACHIEVEMENT UNLOCKED!',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: AppColors.neonYellow,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...newAchievements.map((a) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    a,
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Player name input
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.neonGreen.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.neonGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _DialogButton(
                          label: 'MENU',
                          color: AppColors.neonBlue,
                          onTap: () {
                            _saveScore(ref, nameController.text, score);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                        _DialogButton(
                          label: 'SHARE',
                          color: AppColors.neonPurple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ShareCardScreen(
                                  score: score,
                                  maxCombo: maxCombo,
                                  kills: kills,
                                  gameMode: gameMode.label,
                                ),
                              ),
                            );
                          },
                        ),
                        _DialogButton(
                          label: 'RETRY',
                          color: AppColors.neonGreen,
                          onTap: () {
                            _saveScore(ref, nameController.text, score);
                            Navigator.of(context).pop();
                            ref.read(gameProvider.notifier).startGame();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Persists the player's score to the leaderboard if > 0.
void _saveScore(WidgetRef ref, String name, int score) {
  if (score <= 0) return;
  final difficulty = ref.read(settingsProvider).difficulty;
  ref.read(leaderboardProvider.notifier).addEntry(
        LeaderboardEntry(
          playerName: name.isEmpty ? 'Player' : name,
          score: score,
          date: DateTime.now(),
          difficulty: difficulty,
        ),
      );
}

/// Small stat chip for the game-over dialog.
class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.pressStart2p(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }
}

/// Neon-outlined button used inside the game-over dialog.
class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 12),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: color,
              shadows: [
                Shadow(color: color.withOpacity(0.6), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
