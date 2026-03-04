import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../economy/providers/player_profile_provider.dart';
import '../../skins/models/snake_skin.dart';
import '../models/game_mode.dart';
import '../models/map_theme.dart';
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
    final theme = MapThemes.fromId(gameState.mapThemeId);

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.borderGlowColor.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.borderGlowColor.withOpacity(0.1),
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
                    aiSnakes: gameState.aiSnakes,
                    aiDirections: gameState.aiDirections,
                    deathPellets: gameState.deathPellets,
                    goldCoins: gameState.goldCoins,
                    isBoosting: gameState.isBoosting,
                    boundaryRadius: gameState.boundaryRadius,
                    showBoundary:
                        gameState.gameMode == GameMode.battleRoyale,
                    mapTheme: theme,
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
