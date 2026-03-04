import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neon_text.dart';

/// Displays the current score and high score side by side.
///
/// Each value uses a [TweenAnimationBuilder] so digits count up smoothly
/// whenever the score changes.
class ScoreDisplay extends StatelessWidget {
  final int score;
  final int highScore;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ScoreColumn(
          label: 'SCORE',
          value: score,
          color: AppColors.neonGreen,
        ),
        _ScoreColumn(
          label: 'HIGH',
          value: highScore,
          color: AppColors.neonYellow,
        ),
      ],
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: color.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 400),
          builder: (context, animatedValue, _) {
            return NeonText(
              text: animatedValue.toString().padLeft(4, '0'),
              fontSize: 20,
              color: color,
              glowRadius: 15,
            );
          },
        ),
      ],
    );
  }
}
