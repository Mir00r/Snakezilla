import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/direction.dart';
import '../providers/game_provider.dart';

/// On-screen D-pad directional controls for mobile gameplay.
///
/// Buttons are arranged in a cross pattern. Each tap triggers
/// haptic feedback and queues a direction change in [GameNotifier].
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dirButton(Direction.up, Icons.keyboard_arrow_up),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dirButton(Direction.left, Icons.keyboard_arrow_left),
            const SizedBox(width: 64),
            dirButton(Direction.right, Icons.keyboard_arrow_right),
          ],
        ),
        const SizedBox(height: 4),
        dirButton(Direction.down, Icons.keyboard_arrow_down),
      ],
    );
  }
}
