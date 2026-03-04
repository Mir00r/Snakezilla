import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../leaderboard/models/leaderboard_entry.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/game_provider.dart';

/// Animated Game Over dialog shown as a modal overlay.
///
/// Features:
/// * Scale + fade entrance animation
/// * Score summary with "NEW HIGH SCORE" banner when applicable
/// * Player name input for the leaderboard
/// * MENU / RETRY action buttons
Future<void> showGameOverDialog(
  BuildContext context,
  WidgetRef ref,
  int score,
  int highScore,
) async {
  final nameController = TextEditingController(text: 'Player');

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const NeonText(
                    text: 'GAME OVER',
                    fontSize: 22,
                    color: AppColors.neonPink,
                    glowRadius: 25,
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 12),

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
                          Navigator.of(context).pop(); // close dialog
                          Navigator.of(context).pop(); // back to home
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
