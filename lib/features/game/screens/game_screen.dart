import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../models/direction.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/game_controls.dart';
import '../widgets/score_display.dart';
import 'game_over_dialog.dart';

/// Main game screen containing the board, score HUD, and controls.
///
/// Supports:
/// * Keyboard input (arrows / WASD + Space to pause)
/// * Swipe gestures for mobile
/// * On-screen D-pad buttons
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _gameOverShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGame();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // ── Keyboard handling ──────────────────────────────────────────────────────

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final notifier = ref.read(gameProvider.notifier);

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
        notifier.changeDirection(Direction.up);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        notifier.changeDirection(Direction.down);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        notifier.changeDirection(Direction.left);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        notifier.changeDirection(Direction.right);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
        final status = ref.read(gameProvider).status;
        if (status == GameStatus.playing) {
          notifier.pauseGame();
        } else if (status == GameStatus.paused) {
          notifier.resumeGame();
        }
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Show game-over dialog once.
    if (gameState.status == GameStatus.gameOver && !_gameOverShown) {
      _gameOverShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameOverDialog(
            context, ref, gameState.score, gameState.highScore);
      });
    } else if (gameState.status != GameStatus.gameOver) {
      _gameOverShown = false;
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: GestureDetector(
              // Swipe controls
              onVerticalDragUpdate: (d) {
                if (d.delta.dy < -5) {
                  ref
                      .read(gameProvider.notifier)
                      .changeDirection(Direction.up);
                } else if (d.delta.dy > 5) {
                  ref
                      .read(gameProvider.notifier)
                      .changeDirection(Direction.down);
                }
              },
              onHorizontalDragUpdate: (d) {
                if (d.delta.dx < -5) {
                  ref
                      .read(gameProvider.notifier)
                      .changeDirection(Direction.left);
                } else if (d.delta.dx > 5) {
                  ref
                      .read(gameProvider.notifier)
                      .changeDirection(Direction.right);
                }
              },
              child: Column(
                children: [
                  _buildTopBar(context, gameState),
                  const SizedBox(height: 8),
                  ScoreDisplay(
                    score: gameState.score,
                    highScore: gameState.highScore,
                  ),
                  const SizedBox(height: 12),
                  const Expanded(child: Center(child: GameBoard())),
                  const SizedBox(height: 12),
                  const GameControls(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top bar with back button and pause/resume toggle.
  Widget _buildTopBar(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.neonGreen),
            onPressed: () {
              ref.read(gameProvider.notifier).pauseGame();
              Navigator.of(context).pop();
            },
          ),
          if (gameState.status == GameStatus.playing)
            IconButton(
              icon: const Icon(Icons.pause, color: AppColors.neonGreen),
              onPressed: () => ref.read(gameProvider.notifier).pauseGame(),
            )
          else if (gameState.status == GameStatus.paused)
            IconButton(
              icon:
                  const Icon(Icons.play_arrow, color: AppColors.neonGreen),
              onPressed: () =>
                  ref.read(gameProvider.notifier).resumeGame(),
            ),
        ],
      ),
    );
  }
}
