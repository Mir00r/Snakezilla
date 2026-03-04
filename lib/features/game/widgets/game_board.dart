import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../economy/providers/player_profile_provider.dart';
import '../../skins/models/snake_skin.dart';
import '../providers/game_provider.dart';
import 'snake_painter.dart';

/// The game board widget that renders the snake grid using [CustomPainter].
///
/// Wrapped in a [RepaintBoundary] so repaints are isolated from the rest
/// of the widget tree, and an [AspectRatio] so the grid is always square.
class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _foodPulse;

  @override
  void initState() {
    super.initState();
    _foodPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _foodPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final profile = ref.watch(playerProfileProvider);
    final skin = SnakeSkins.fromId(profile.equippedSkinId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: skin.glowColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedBuilder(
              animation: _foodPulse,
              builder: (context, _) {
                return CustomPaint(
                  painter: SnakePainter(
                    snake: gameState.snake,
                    food: gameState.food,
                    foodType: gameState.foodItem.type,
                    direction: gameState.direction,
                    foodPulse: _foodPulse.value,
                    isDarkMode: isDark,
                    skin: skin,
                    obstacles: gameState.obstacles,
                    aiSnake: gameState.aiSnake,
                    aiDirection: gameState.aiDirection,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
