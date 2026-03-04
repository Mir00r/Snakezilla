import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/neon_text.dart';
import '../models/direction.dart';
import '../models/game_mode.dart';
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
/// * Cinematic countdown overlay (3…2…1…GO!)
/// * Combo indicator
/// * Time Attack timer
/// * Screen shake on bomb pickup
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _gameOverShown = false;

  // Screen shake
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGame();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
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

    // Trigger screen shake.
    if (gameState.screenShake && !_shakeController.isAnimating) {
      _shakeController.forward(from: 0);
    }

    // Show game-over dialog once.
    if (gameState.status == GameStatus.gameOver && !_gameOverShown) {
      _gameOverShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameOverDialog(
          context,
          ref,
          gameState.score,
          gameState.highScore,
          coinsEarned: gameState.coinsEarned,
          maxCombo: gameState.maxCombo,
          gameMode: gameState.gameMode,
        );
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
              child: Stack(
                children: [
                  // Main game content
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shake = _shakeAnimation.value;
                      final rng = Random();
                      return Transform.translate(
                        offset: shake > 0
                            ? Offset(
                                (rng.nextDouble() - 0.5) * shake,
                                (rng.nextDouble() - 0.5) * shake,
                              )
                            : Offset.zero,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        _buildTopBar(context, gameState),
                        const SizedBox(height: 4),
                        _buildHUD(gameState),
                        const SizedBox(height: 8),
                        const Expanded(child: Center(child: GameBoard())),
                        const SizedBox(height: 12),
                        const GameControls(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Countdown overlay
                  if (gameState.status == GameStatus.countdown)
                    _CountdownOverlay(value: gameState.countdownValue),

                  // Paused overlay
                  if (gameState.status == GameStatus.paused)
                    _PausedOverlay(
                      onResume: () =>
                          ref.read(gameProvider.notifier).resumeGame(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Combined HUD showing score, combo, timer, and mode info.
  Widget _buildHUD(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Score row
          ScoreDisplay(
            score: gameState.score,
            highScore: gameState.highScore,
          ),
          const SizedBox(height: 6),
          // Mode-specific HUD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Combo indicator
              if (gameState.combo > 1)
                _HUDBadge(
                  label: 'COMBO',
                  value: '${gameState.combo}x',
                  color: AppColors.neonOrange,
                ),

              // Game mode badge
              _HUDBadge(
                label: gameState.gameMode.label.toUpperCase(),
                value: gameState.gameMode.icon,
                color: AppColors.neonPurple,
              ),

              // Timer for Time Attack
              if (gameState.gameMode == GameMode.timeAttack)
                _HUDBadge(
                  label: 'TIME',
                  value: '${gameState.timeRemaining}s',
                  color: gameState.timeRemaining <= 10
                      ? AppColors.neonPink
                      : AppColors.neonBlue,
                ),

              // Coins earned
              if (gameState.coinsEarned > 0)
                _HUDBadge(
                  label: 'COINS',
                  value: '+${gameState.coinsEarned}',
                  color: AppColors.neonYellow,
                ),

              // Food type indicator
              if (gameState.foodItem.type != gameState.foodItem.type)
                _HUDBadge(
                  label: gameState.foodItem.type.label,
                  value: gameState.foodItem.type.emoji,
                  color: gameState.foodItem.type.color,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Top bar with back button and pause/resume toggle.
  Widget _buildTopBar(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          // Active effects display
          Row(
            children: gameState.activeEffects
                .where((e) => !e.isExpired)
                .map((e) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: e.type.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: e.type.color, width: 1),
                        ),
                        child: Text(
                          e.type.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ))
                .toList(),
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
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── HUD Badge ────────────────────────────────────────────────────────────────

class _HUDBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HUDBadge({
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
            fontSize: 6,
            color: color.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: color,
            shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)],
          ),
        ),
      ],
    );
  }
}

// ── Countdown Overlay ────────────────────────────────────────────────────────

class _CountdownOverlay extends StatelessWidget {
  final int value;
  const _CountdownOverlay({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(value),
          tween: Tween(begin: 2.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: NeonText(
                text: value > 0 ? '$value' : 'GO!',
                fontSize: 64,
                color: value > 0 ? AppColors.neonYellow : AppColors.neonGreen,
                glowRadius: 40,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Paused Overlay ───────────────────────────────────────────────────────────

class _PausedOverlay extends StatelessWidget {
  final VoidCallback onResume;
  const _PausedOverlay({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        color: Colors.black54,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonText(
                text: 'PAUSED',
                fontSize: 32,
                color: AppColors.neonBlue,
                glowRadius: 30,
              ),
              SizedBox(height: 16),
              NeonText(
                text: 'Tap to resume',
                fontSize: 12,
                color: AppColors.textSecondary,
                glowRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
