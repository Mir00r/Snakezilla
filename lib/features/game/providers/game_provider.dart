import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/storage_service.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../../settings/models/settings_model.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/direction.dart';
import '../models/food_type.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/position.dart';

/// Holds the selected game mode and time-attack duration before launching.
class GameLaunchConfig {
  final GameMode mode;
  final int timeAttackSeconds;

  const GameLaunchConfig({
    this.mode = GameMode.classic,
    this.timeAttackSeconds = 60,
  });
}

/// Provider that holds the launch configuration set from the mode-select screen.
final gameLaunchConfigProvider = StateProvider<GameLaunchConfig>(
  (_) => const GameLaunchConfig(),
);

/// Central game-logic controller.
///
/// Drives the game loop via [Timer.periodic], manages snake movement,
/// collision detection, scoring, speed scaling, combo system, AI opponent,
/// special food effects, and countdown sequence.
class GameNotifier extends StateNotifier<GameState> {
  Timer? _gameTimer;
  Timer? _countdownTimer;
  Timer? _clockTimer;
  final AudioService _audio;
  final StorageService _storage;
  final Random _random = Random();
  final Ref _ref;
  int _comboTimer = 0;

  GameNotifier(this._ref, this._audio, this._storage)
      : super(
          GameState.initial(
            highScore: _storage.loadHighScore(),
            speed: _speedForDifficulty(
              _ref.read(settingsProvider).difficulty,
            ),
            boundaryWrap: _ref.read(settingsProvider).boundaryWrap,
          ),
        );

  /// Maps a [Difficulty] enum to its corresponding timer interval.
  static int _speedForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return GameConstants.speedEasy;
      case Difficulty.medium:
        return GameConstants.speedMedium;
      case Difficulty.hard:
        return GameConstants.speedHard;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Initialises (or restarts) the game with optional mode override.
  void startGame({GameMode? mode}) {
    final settings = _ref.read(settingsProvider);
    final speed = _speedForDifficulty(settings.difficulty);
    final config = _ref.read(gameLaunchConfigProvider);
    final gameMode = mode ?? config.mode;
    final timeRemaining = gameMode == GameMode.timeAttack
        ? config.timeAttackSeconds
        : -1;

    _comboTimer = 0;
    _cancelAllTimers();

    state = GameState.initial(
      highScore: state.highScore,
      speed: speed,
      boundaryWrap: settings.boundaryWrap,
      gameMode: gameMode,
      timeRemaining: timeRemaining,
    ).copyWith(status: GameStatus.countdown, countdownValue: 3);

    // Cinematic countdown: 3…2…1…GO!
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickCountdown(),
    );
    _audio.startMusic();
  }

  void _tickCountdown() {
    final next = state.countdownValue - 1;
    if (next <= 0) {
      _countdownTimer?.cancel();
      state = state.copyWith(
        status: GameStatus.playing,
        countdownValue: 0,
      );
      _startTimer();

      // Start clock for Time Attack.
      if (state.gameMode == GameMode.timeAttack) {
        _startClock();
      }
      // Spawn initial obstacles for Survival.
      if (state.gameMode == GameMode.survival) {
        _spawnObstacles(3);
      }
    } else {
      state = state.copyWith(countdownValue: next);
    }
  }

  /// Pauses a running game.
  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    _gameTimer?.cancel();
    _clockTimer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  /// Resumes from a paused state.
  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
    if (state.gameMode == GameMode.timeAttack && state.timeRemaining > 0) {
      _startClock();
    }
  }

  /// Queues a direction change for the next tick.
  void changeDirection(Direction newDirection) {
    if (state.status != GameStatus.playing) return;
    final current = state.bufferedDirection ?? state.direction;
    if (newDirection == current.opposite) return;
    state = state.copyWith(bufferedDirection: () => newDirection);
  }

  // ── Game Loop ──────────────────────────────────────────────────────────────

  /// Called every [speed] milliseconds to advance the simulation one step.
  void _tick() {
    if (state.status != GameStatus.playing) return;

    // Expire active effects.
    final liveEffects =
        state.activeEffects.where((e) => !e.isExpired).toList();

    // Compute effective speed (with freeze / speed-boost).
    int effectiveSpeed = state.speed;
    if (liveEffects.any((e) => e.type == FoodType.freeze)) {
      effectiveSpeed = (effectiveSpeed * 1.8).round(); // slower
    } else if (liveEffects.any((e) => e.type == FoodType.speedBoost)) {
      effectiveSpeed = (effectiveSpeed * 0.65).round(); // faster
    }

    // 1. Resolve direction.
    final direction = state.bufferedDirection ?? state.direction;

    // 2. Calculate new head position.
    final head = state.snake.first;
    final offset = direction.offset;
    var newHead = head.move(offset.dx, offset.dy);

    // 3. Handle boundaries.
    if (state.boundaryWrap) {
      final wrappedX = ((newHead.x % GameConstants.gridWidth) +
              GameConstants.gridWidth) %
          GameConstants.gridWidth;
      final wrappedY = ((newHead.y % GameConstants.gridHeight) +
              GameConstants.gridHeight) %
          GameConstants.gridHeight;
      newHead = Position(wrappedX, wrappedY);
    } else {
      if (newHead.x < 0 ||
          newHead.x >= GameConstants.gridWidth ||
          newHead.y < 0 ||
          newHead.y >= GameConstants.gridHeight) {
        _gameOver();
        return;
      }
    }

    // 4. Obstacle collision.
    if (state.obstacles.contains(newHead)) {
      _gameOver();
      return;
    }

    // 5. Self-collision check.
    final willEat = newHead == state.food;
    final bodyToCheck = willEat
        ? state.snake
        : state.snake.sublist(0, state.snake.length - 1);

    if (bodyToCheck.contains(newHead)) {
      _gameOver();
      return;
    }

    // 6. AI collision (only in AI Battle).
    if (state.gameMode == GameMode.aiBattle &&
        state.aiSnake.contains(newHead)) {
      _gameOver();
      return;
    }

    // 7. Build new snake body.
    final newSnake = [newHead, ...state.snake];
    if (!willEat) {
      newSnake.removeLast();
    }

    // 8. Handle scoring, combos & food effects.
    int newScore = state.score;
    int newSpeed = state.speed;
    int newCombo = state.combo;
    int newMaxCombo = state.maxCombo;
    int newCoins = state.coinsEarned;
    var newEffects = List<ActiveEffect>.from(liveEffects);
    bool triggerShake = false;
    FoodItem newFoodItem = state.foodItem;

    if (willEat) {
      final foodType = state.foodItem.type;

      // Combo system: eating quickly builds combo.
      if (_comboTimer > 0) {
        newCombo++;
      } else {
        newCombo = 1;
      }
      _comboTimer = 8; // ticks until combo resets
      if (newCombo > newMaxCombo) newMaxCombo = newCombo;

      // Calculate points with multiplier.
      final multiplier = state.scoreMultiplier;
      newScore += foodType.basePoints * multiplier;

      // Apply food-type specific effects.
      switch (foodType) {
        case FoodType.speedBoost:
        case FoodType.freeze:
        case FoodType.rainbow:
          newEffects.add(ActiveEffect(
            type: foodType,
            expiresAt: DateTime.now().add(foodType.duration),
          ));
        case FoodType.coinBonus:
          newCoins += 10;
        case FoodType.bomb:
          // Remove last 3 tail segments (don't shrink below 3).
          if (newSnake.length > 3) {
            final removeCount = min(3, newSnake.length - 3);
            newSnake.removeRange(newSnake.length - removeCount, newSnake.length);
          }
          triggerShake = true;
        case FoodType.normal:
          break;
      }

      // Speed scaling.
      newSpeed = (state.speed - GameConstants.speedIncrement)
          .clamp(GameConstants.minSpeed, state.speed);

      // Spawn new food (weighted type).
      newFoodItem = _generateFoodItem(newSnake, state.obstacles);
      _audio.playEat();

      // Coins from scoring.
      newCoins += (foodType.basePoints * multiplier / 10).floor();
    }

    // Combo decay.
    if (_comboTimer > 0) {
      _comboTimer--;
    } else if (state.combo > 0) {
      newCombo = 0;
    }

    // 9. AI snake movement.
    List<Position> newAiSnake = state.aiSnake;
    Direction newAiDir = state.aiDirection;
    if (state.gameMode == GameMode.aiBattle && state.aiSnake.isNotEmpty) {
      final aiResult = _moveAI(state.aiSnake, state.aiDirection, state.food);
      newAiSnake = aiResult.$1;
      newAiDir = aiResult.$2;
    }

    // 10. Survival mode: spawn obstacles periodically.
    List<Position> newObstacles = state.obstacles;
    if (state.gameMode == GameMode.survival && willEat) {
      // Add an obstacle every 3 foods eaten.
      final foodsEaten = (newScore / GameConstants.pointsPerFood).floor();
      if (foodsEaten > 0 && foodsEaten % 3 == 0) {
        final obs = _randomFreePosition(newSnake, newObstacles);
        if (obs != null) newObstacles = [...newObstacles, obs];
      }
    }

    // 11. Timer restart if speed changed.
    if (newSpeed != state.speed || effectiveSpeed != state.speed) {
      _gameTimer?.cancel();
      state = state.copyWith(
        snake: newSnake,
        foodItem: newFoodItem,
        direction: direction,
        bufferedDirection: () => null,
        score: newScore,
        speed: newSpeed,
        combo: newCombo,
        maxCombo: newMaxCombo,
        coinsEarned: newCoins,
        activeEffects: newEffects,
        screenShake: triggerShake,
        aiSnake: newAiSnake,
        aiDirection: newAiDir,
        obstacles: newObstacles,
      );
      _gameTimer = Timer.periodic(
        Duration(milliseconds: effectiveSpeed.clamp(GameConstants.minSpeed, 500)),
        (_) => _tick(),
      );
      return;
    }

    // 12. Commit state.
    state = state.copyWith(
      snake: newSnake,
      foodItem: newFoodItem,
      direction: direction,
      bufferedDirection: () => null,
      score: newScore,
      speed: newSpeed,
      combo: newCombo,
      maxCombo: newMaxCombo,
      coinsEarned: newCoins,
      activeEffects: newEffects,
      screenShake: triggerShake,
      aiSnake: newAiSnake,
      aiDirection: newAiDir,
      obstacles: newObstacles,
    );

    // Clear screen shake after one frame.
    if (triggerShake) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) state = state.copyWith(screenShake: false);
      });
    }
  }

  // ── AI Logic ───────────────────────────────────────────────────────────────

  /// Simple greedy AI: moves toward food, avoids walls and itself.
  (List<Position>, Direction) _moveAI(
      List<Position> aiSnake, Direction aiDir, Position food) {
    final head = aiSnake.first;

    // Try all directions, prefer heading toward food.
    final candidates = <Direction, int>{};
    for (final d in Direction.values) {
      if (d == aiDir.opposite) continue;
      final off = d.offset;
      final next = Position(
        ((head.x + off.dx.toInt()) % GameConstants.gridWidth +
                GameConstants.gridWidth) %
            GameConstants.gridWidth,
        ((head.y + off.dy.toInt()) % GameConstants.gridHeight +
                GameConstants.gridHeight) %
            GameConstants.gridHeight,
      );
      // Avoid self-collision and player collision.
      if (aiSnake.contains(next) || state.snake.contains(next)) continue;
      if (state.obstacles.contains(next)) continue;
      // Manhattan distance to food.
      final dist = (next.x - food.x).abs() + (next.y - food.y).abs();
      candidates[d] = dist;
    }

    if (candidates.isEmpty) {
      // Stuck — just keep going.
      final off = aiDir.offset;
      final nextHead = Position(
        ((head.x + off.dx.toInt()) % GameConstants.gridWidth +
                GameConstants.gridWidth) %
            GameConstants.gridWidth,
        ((head.y + off.dy.toInt()) % GameConstants.gridHeight +
                GameConstants.gridHeight) %
            GameConstants.gridHeight,
      );
      return ([nextHead, ...aiSnake]..removeLast(), aiDir);
    }

    // Pick direction with shortest distance to food.
    final bestDir = candidates.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    final off = bestDir.offset;
    final nextHead = Position(
      ((head.x + off.dx.toInt()) % GameConstants.gridWidth +
              GameConstants.gridWidth) %
          GameConstants.gridWidth,
      ((head.y + off.dy.toInt()) % GameConstants.gridHeight +
              GameConstants.gridHeight) %
          GameConstants.gridHeight,
    );

    // Check if AI ate food.
    final aiAte = nextHead == food;
    final newAiSnake = [nextHead, ...aiSnake];
    if (!aiAte) newAiSnake.removeLast();

    return (newAiSnake, bestDir);
  }

  // ── Time Attack Clock ──────────────────────────────────────────────────────

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status != GameStatus.playing) return;
      final remaining = state.timeRemaining - 1;
      if (remaining <= 0) {
        _gameOver();
      } else {
        state = state.copyWith(timeRemaining: remaining);
      }
    });
  }

  // ── Survival Obstacles ─────────────────────────────────────────────────────

  void _spawnObstacles(int count) {
    final newObs = <Position>[...state.obstacles];
    for (int i = 0; i < count; i++) {
      final p = _randomFreePosition(state.snake, newObs);
      if (p != null) newObs.add(p);
    }
    state = state.copyWith(obstacles: newObs);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _gameOver() {
    _cancelAllTimers();
    _audio.playGameOver();
    _audio.stopMusic();

    int newHighScore = state.highScore;
    if (state.score > state.highScore) {
      newHighScore = state.score;
      _storage.saveHighScore(newHighScore);
    }

    // Record game in player profile.
    try {
      _ref.read(playerProfileProvider.notifier).recordGame(
            score: state.score,
            combo: state.maxCombo,
            snakeLength: state.snake.length,
          );
      _ref.read(playerProfileProvider.notifier).addCoins(state.coinsEarned);
    } catch (_) {}

    state = state.copyWith(
      status: GameStatus.gameOver,
      highScore: newHighScore,
      screenShake: false,
    );
  }

  /// Generates a random [FoodItem] with weighted type selection.
  FoodItem _generateFoodItem(
      List<Position> snake, List<Position> obstacles) {
    final pos = _generateFood(snake, obstacles);
    final type = state.gameMode == GameMode.classic && state.score < 50
        ? FoodType.normal
        : FoodType.randomWeighted(_random);
    return FoodItem(position: pos, type: type);
  }

  /// Returns a random [Position] that does not overlap the [snake] or [obstacles].
  Position _generateFood(
      List<Position> snake, List<Position> obstacles) {
    Position food;
    int attempts = 0;
    do {
      food = Position(
        _random.nextInt(GameConstants.gridWidth),
        _random.nextInt(GameConstants.gridHeight),
      );
      attempts++;
    } while ((snake.contains(food) || obstacles.contains(food)) &&
        attempts < 500);
    return food;
  }

  /// Returns a random free position or null if grid is full.
  Position? _randomFreePosition(
      List<Position> snake, List<Position> obstacles) {
    int attempts = 0;
    while (attempts < 200) {
      final p = Position(
        _random.nextInt(GameConstants.gridWidth),
        _random.nextInt(GameConstants.gridHeight),
      );
      if (!snake.contains(p) &&
          !obstacles.contains(p) &&
          p != state.food) {
        return p;
      }
      attempts++;
    }
    return null;
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: state.speed),
      (_) => _tick(),
    );
  }

  void _cancelAllTimers() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _clockTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }
}

/// Main game state provider (auto-disposed when the game screen is removed).
final gameProvider =
    StateNotifierProvider.autoDispose<GameNotifier, GameState>((ref) {
  final audio = ref.watch(audioServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return GameNotifier(ref, audio, storage);
});
