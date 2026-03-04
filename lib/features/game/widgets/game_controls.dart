import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/direction.dart';
import '../providers/game_provider.dart';

/// On-screen D-pad directional controls for mobile gameplay.
///
/// Buttons are arranged in a cross pattern with a BOOST button in the centre.
/// Each tap triggers haptic feedback and queues a direction change in [GameNotifier].
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final gameState = ref.watch(gameProvider);

    Widget dirButton(Direction dir, IconData icon) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            notifier.changeDirection(dir);
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.darkCard.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonGreen.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.neonGreen, size: 28),
          ),
        ),
      );
    }

    // Boost button: hold to boost, glow when active.
    Widget boostButton() {
      final canBoost = gameState.snake.length > 4;
      final boosting = gameState.isBoosting;
      final boostColor = boosting
          ? AppColors.neonOrange
          : (canBoost ? AppColors.neonYellow : Colors.grey);

      return GestureDetector(
        onTapDown: canBoost ? (_) => notifier.startBoost() : null,
        onTapUp: (_) => notifier.stopBoost(),
        onTapCancel: () => notifier.stopBoost(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: boosting
                ? boostColor.withOpacity(0.3)
                : AppColors.darkCard.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: boostColor.withOpacity(boosting ? 0.8 : 0.3),
              width: boosting ? 2 : 1,
            ),
            boxShadow: boosting
                ? [
                    BoxShadow(
                      color: boostColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: boostColor,
            size: 24,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dirButton(Direction.up, Icons.keyboard_arrow_up),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dirButton(Direction.left, Icons.keyboard_arrow_left),
            const SizedBox(width: 4),
            boostButton(),
            const SizedBox(width: 4),
            dirButton(Direction.right, Icons.keyboard_arrow_right),
          ],
        ),
        const SizedBox(height: 4),
        dirButton(Direction.down, Icons.keyboard_arrow_down),
      ],
    );
  }
}
