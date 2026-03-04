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
  final String mapThemeId;

  const GameLaunchConfig({
    this.mode = GameMode.classic,
    this.timeAttackSeconds = 60,
    this.mapThemeId = 'neonNight',
  });
}

/// Provider that holds the launch configuration set from the mode-select screen.
final gameLaunchConfigProvider = StateProvider<GameLaunchConfig>(
  (_) => const GameLaunchConfig(),
);

/// Central game-logic controller.
///
/// Drives the game loop via [Timer.periodic], manages snake movement,
/// collision detection, scoring, speed scaling, combo system, AI opponents,
/// special food effects, boost mechanic, death pellets, battle royale
/// shrinking boundary, gold rush mode, and countdown sequence.
class GameNotifier extends StateNotifier<GameState> {
  Timer? _gameTimer;
  Timer? _countdownTimer;
  Timer? _clockTimer;
  Timer? _shrinkTimer;
  final AudioService _audio;
  final StorageService _storage;
  final Random _random = Random();
  final Ref _ref;
  int _comboTimer = 0;
  int _killFeedClearTimer = 0;

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

    int timeRemaining = -1;
    if (gameMode == GameMode.timeAttack) {
      timeRemaining = config.timeAttackSeconds;
    } else if (gameMode == GameMode.goldRush) {
      timeRemaining = 60;
    } else if (gameMode == GameMode.battleRoyale) {
      timeRemaining = 90;
    }

    _comboTimer = 0;
    _killFeedClearTimer = 0;
    _cancelAllTimers();

    state = GameState.initial(
      highScore: state.highScore,
      speed: speed,
      boundaryWrap: settings.boundaryWrap,
      gameMode: gameMode,
      timeRemaining: timeRemaining,
      mapThemeId: config.mapThemeId,
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

      // Start clock for timed modes.
      if (state.gameMode == GameMode.timeAttack ||
          state.gameMode == GameMode.goldRush ||
          state.gameMode == GameMode.battleRoyale) {
        _startClock();
      }
      // Spawn initial obstacles for Survival.
      if (state.gameMode == GameMode.survival) {
        _spawnObstacles(3);
      }
      // Start boundary shrink for Battle Royale.
      if (state.gameMode == GameMode.battleRoyale) {
        _startBoundaryShrink();
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
    _shrinkTimer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  /// Resumes from a paused state.
  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
    if (state.timeRemaining > 0) {
      _startClock();
    }
    if (state.gameMode == GameMode.battleRoyale) {
      _startBoundaryShrink();
    }
  }

  /// Queues a direction change for the next tick.
  void changeDirection(Direction newDirection) {
    if (state.status != GameStatus.playing) return;
    final current = state.bufferedDirection ?? state.direction;
    if (newDirection == current.opposite) return;
    state = state.copyWith(bufferedDirection: () => newDirection);
  }

  /// Activates speed boost (slither.io style — snake shrinks while boosting).
  void startBoost() {
    if (state.status != GameStatus.playing) return;
    if (state.snake.length <= 4) return;
    state = state.copyWith(isBoosting: true);
  }

  /// Deactivates speed boost.
  void stopBoost() {
    if (!state.isBoosting) return;
    state = state.copyWith(isBoosting: false, boostTickCounter: 0);
  }

  // ── Game Loop ──────────────────────────────────────────────────────────────

  /// Called every [speed] milliseconds to advance the simulation one step.
  void _tick() {
    if (state.status != GameStatus.playing) return;

    // Expire active effects.
    final liveEffects =
        state.activeEffects.where((e) => !e.isExpired).toList();

    // Kill feed clearing.
    if (state.killFeed.isNotEmpty) {
      _killFeedClearTimer++;
      if (_killFeedClearTimer > 15) {
        state = state.copyWith(killFeed: []);
        _killFeedClearTimer = 0;
      }
    }

    // Compute effective speed.
    int effectiveSpeed = state.speed;
    if (liveEffects.any((e) => e.type == FoodType.freeze)) {
      effectiveSpeed = (effectiveSpeed * 1.8).round();
    } else if (state.isBoosting) {
      effectiveSpeed = (effectiveSpeed * 0.5).round();
    } else if (liveEffects.any((e) => e.type == FoodType.speedBoost)) {
      effectiveSpeed = (effectiveSpeed * 0.65).round();
    }

    // 1. Resolve direction.
    final direction = state.bufferedDirection ?? state.direction;

    // 2. Calculate new head position.
    final head = state.snake.first;
    final offset = direction.offset;
    var newHead = head.move(offset.dx, offset.dy);

    final hasShield = liveEffects.any((e) => e.type == FoodType.shield);
    final hasGhost = liveEffects.any((e) => e.type == FoodType.ghost);

    // 3. Handle boundaries.
    if (hasGhost || state.boundaryWrap) {
      final wrappedX = ((newHead.x % GameConstants.gridWidth) +
              GameConstants.gridWidth) %
          GameConstants.gridWidth;
      final wrappedY = ((newHead.y % GameConstants.gridHeight) +
              GameConstants.gridHeight) %
          GameConstants.gridHeight;
      newHead = Position(wrappedX, wrappedY);
    } else {
      if (state.gameMode == GameMode.battleRoyale) {
        final cx = GameConstants.gridWidth ~/ 2;
        final cy = GameConstants.gridHeight ~/ 2;
        final br = state.boundaryRadius;
        if (newHead.x < cx - br ||
            newHead.x > cx + br ||
            newHead.y < cy - br ||
            newHead.y > cy + br) {
          if (!hasShield) {
            _gameOver();
            return;
          }
        }
      } else if (newHead.x < 0 ||
          newHead.x >= GameConstants.gridWidth ||
          newHead.y < 0 ||
          newHead.y >= GameConstants.gridHeight) {
        if (!hasShield) {
          _gameOver();
          return;
        }
        final wrappedX = ((newHead.x % GameConstants.gridWidth) +
                GameConstants.gridWidth) %
            GameConstants.gridWidth;
        final wrappedY = ((newHead.y % GameConstants.gridHeight) +
                GameConstants.gridHeight) %
            GameConstants.gridHeight;
        newHead = Position(wrappedX, wrappedY);
      }
    }

    // 4. Obstacle collision.
    if (!hasShield && !hasGhost && state.obstacles.contains(newHead)) {
      _gameOver();
      return;
    }

    // 5. Self-collision check.
    final willEat = newHead == state.food;
    final bodyToCheck = willEat
        ? state.snake
        : state.snake.sublist(0, state.snake.length - 1);

    if (!hasShield && !hasGhost && bodyToCheck.contains(newHead)) {
      _gameOver();
      return;
    }

    // 6. AI collision check.
    for (final ai in state.aiSnakes) {
      if (ai.contains(newHead)) {
        if (!hasShield) {
          _gameOver();
          return;
        }
      }
    }

    // 7. Build new snake body.
    final newSnake = [newHead, ...state.snake];

    // Check death pellet eating.
    bool ateDeathPellet = false;
    var newDeathPellets = List<Position>.from(state.deathPellets);
    if (newDeathPellets.contains(newHead)) {
      ateDeathPellet = true;
      newDeathPellets.remove(newHead);
    }

    // Check gold coin eating (Gold Rush).
    bool ateGold = false;
    var newGoldCoins = List<Position>.from(state.goldCoins);
    int newGoldCollected = state.goldCollected;
    if (newGoldCoins.contains(newHead)) {
      ateGold = true;
      newGoldCoins.remove(newHead);
      newGoldCollected++;
    }

    if (!willEat && !ateDeathPellet && !ateGold) {
      newSnake.removeLast();
    }

    // Boost shrink: lose 1 tail segment every 3 boost ticks.
    int newBoostTick = state.boostTickCounter;
    if (state.isBoosting && newSnake.length > 4) {
      newBoostTick++;
      if (newBoostTick >= 3) {
        newSnake.removeLast();
        newBoostTick = 0;
      }
    }
    bool stillBoosting = state.isBoosting;
    if (stillBoosting && newSnake.length <= 4) {
      stillBoosting = false;
      newBoostTick = 0;
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
    var newKillFeed = List<String>.from(state.killFeed);

    if (ateDeathPellet) {
      newScore += 5;
      newCoins += 1;
      _audio.playEat();
    }

    if (ateGold) {
      newScore += 25;
      newCoins += 5;
      _audio.playEat();
      if (state.gameMode == GameMode.goldRush) {
        final p = _randomFreePosition(newSnake, state.obstacles);
        if (p != null) newGoldCoins.add(p);
      }
    }

    if (willEat) {
      final foodType = state.foodItem.type;

      if (_comboTimer > 0) {
        newCombo++;
      } else {
        newCombo = 1;
      }
      _comboTimer = 8;
      if (newCombo > newMaxCombo) newMaxCombo = newCombo;

      final multiplier = state.scoreMultiplier;
      newScore += foodType.basePoints * multiplier;

      switch (foodType) {
        case FoodType.speedBoost:
        case FoodType.freeze:
        case FoodType.rainbow:
        case FoodType.magnet:
        case FoodType.shield:
        case FoodType.ghost:
          newEffects.add(ActiveEffect(
            type: foodType,
            expiresAt: DateTime.now().add(foodType.duration),
          ));
        case FoodType.coinBonus:
          newCoins += 10;
        case FoodType.bomb:
          if (newSnake.length > 3) {
            final removeCount = min(3, newSnake.length - 3);
            newSnake.removeRange(
                newSnake.length - removeCount, newSnake.length);
          }
          triggerShake = true;
        case FoodType.goldCoin:
          newCoins += 5;
          newGoldCollected++;
        case FoodType.normal:
          break;
      }

      newSpeed = (state.speed - GameConstants.speedIncrement)
          .clamp(GameConstants.minSpeed, state.speed);

      newFoodItem = _generateFoodItem(newSnake, state.obstacles);
      _audio.playEat();
      newCoins += (foodType.basePoints * multiplier / 10).floor();
    }

    // Magnet effect: move food toward snake head.
    if (newEffects.any((e) => e.type == FoodType.magnet && !e.isExpired)) {
      final fPos = newFoodItem.position;
      final sHead = newSnake.first;
      int fx = fPos.x;
      int fy = fPos.y;
      if (fx < sHead.x) fx++;
      if (fx > sHead.x) fx--;
      if (fy < sHead.y) fy++;
      if (fy > sHead.y) fy--;
      newFoodItem = newFoodItem.copyWith(position: Position(fx, fy));
    }

    if (_comboTimer > 0) {
      _comboTimer--;
    } else if (state.combo > 0) {
      newCombo = 0;
    }

    // 9. Multi-AI snake movement.
    var newAiSnakes = List<List<Position>>.from(
        state.aiSnakes.map((s) => List<Position>.from(s)));
    var newAiDirs = List<Direction>.from(state.aiDirections);
    int newKills = state.kills;

    if (state.aiSnakes.isNotEmpty) {
      for (int i = newAiSnakes.length - 1; i >= 0; i--) {
        if (newAiSnakes[i].isEmpty) continue;

        final aiResult = _moveAI(
          newAiSnakes[i],
          newAiDirs[i],
          state.food,
          newSnake,
          state.obstacles,
          newDeathPellets,
          i,
          newAiSnakes,
        );
        newAiSnakes[i] = aiResult.$1;
        newAiDirs[i] = aiResult.$2;

        final aiHead =
            newAiSnakes[i].isNotEmpty ? newAiSnakes[i].first : null;
        if (aiHead != null && newSnake.contains(aiHead)) {
          newKills++;
          _addDeathPellets(newAiSnakes[i], newDeathPellets);
          newKillFeed.add('You eliminated Snake #${i + 1}!');
          _killFeedClearTimer = 0;
          newAiSnakes[i] = [];
          triggerShake = true;
        }

        if (aiHead != null) {
          for (int j = 0; j < newAiSnakes.length; j++) {
            if (j == i || newAiSnakes[j].isEmpty) continue;
            if (newAiSnakes[j].contains(aiHead)) {
              _addDeathPellets(newAiSnakes[i], newDeathPellets);
              newKillFeed.add('Snake #${j + 1} eliminated #${i + 1}');
              _killFeedClearTimer = 0;
              newAiSnakes[i] = [];
              break;
            }
          }
        }

        if (aiHead != null && aiHead == newFoodItem.position) {
          newFoodItem = _generateFoodItem(newSnake, state.obstacles);
        }

        if (aiHead != null && newDeathPellets.contains(aiHead)) {
          newDeathPellets.remove(aiHead);
        }
      }

      if (state.gameMode == GameMode.battleRoyale) {
        final aliveAIs = newAiSnakes.where((s) => s.isNotEmpty).length;
        if (aliveAIs == 0) {
          newScore += 100;
          newKillFeed.add('🏆 VICTORY ROYALE!');
        }
      }
    }

    // 10. Survival mode: spawn obstacles periodically.
    List<Position> newObstacles = state.obstacles;
    if (state.gameMode == GameMode.survival && willEat) {
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
        aiSnakes: newAiSnakes,
        aiDirections: newAiDirs,
        obstacles: newObstacles,
        isBoosting: stillBoosting,
        boostTickCounter: newBoostTick,
        kills: newKills,
        deathPellets: newDeathPellets,
        goldCoins: newGoldCoins,
        goldCollected: newGoldCollected,
        killFeed: newKillFeed,
      );
      _gameTimer = Timer.periodic(
        Duration(
            milliseconds:
                effectiveSpeed.clamp(GameConstants.minSpeed, 500)),
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
      aiSnakes: newAiSnakes,
      aiDirections: newAiDirs,
      obstacles: newObstacles,
      isBoosting: stillBoosting,
      boostTickCounter: newBoostTick,
      kills: newKills,
      deathPellets: newDeathPellets,
      goldCoins: newGoldCoins,
      goldCollected: newGoldCollected,
      killFeed: newKillFeed,
    );

    if (triggerShake) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) state = state.copyWith(screenShake: false);
      });
    }
  }

  // ── AI Logic ───────────────────────────────────────────────────────────────

  /// Smart AI: moves toward food, avoids walls/obstacles/other snakes.
  (List<Position>, Direction) _moveAI(
    List<Position> aiSnake,
    Direction aiDir,
    Position food,
    List<Position> playerSnake,
    List<Position> obstacles,
    List<Position> deathPellets,
    int aiIndex,
    List<List<Position>> allAiSnakes,
  ) {
    if (aiSnake.isEmpty) return (aiSnake, aiDir);

    final head = aiSnake.first;

    // Prefer death pellets if nearby (within 5 cells).
    Position target = food;
    if (deathPellets.isNotEmpty) {
      Position? closestPellet;
      int closestDist = 999;
      for (final p in deathPellets) {
        final d = (p.x - head.x).abs() + (p.y - head.y).abs();
        if (d < closestDist && d <= 5) {
          closestDist = d;
          closestPellet = p;
        }
      }
      if (closestPellet != null) target = closestPellet;
    }

    // Build collision set.
    final avoid = <Position>{...playerSnake, ...obstacles};
    for (int j = 0; j < allAiSnakes.length; j++) {
      if (j != aiIndex) avoid.addAll(allAiSnakes[j]);
    }
    avoid.addAll(aiSnake.skip(1));

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
      if (avoid.contains(next)) continue;
      final dist = (next.x - target.x).abs() + (next.y - target.y).abs();
      candidates[d] = dist;
    }

    if (candidates.isEmpty) {
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

    final aiAte = nextHead == food || deathPellets.contains(nextHead);
    final newAiSnake = [nextHead, ...aiSnake];
    if (!aiAte) newAiSnake.removeLast();

    return (newAiSnake, bestDir);
  }

  /// Converts a dead AI's body to death pellets (every other segment).
  void _addDeathPellets(
      List<Position> deadSnake, List<Position> pellets) {
    for (int i = 0; i < deadSnake.length; i += 2) {
      pellets.add(deadSnake[i]);
    }
  }

  // ── Clock ──────────────────────────────────────────────────────────────────

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

  // ── Battle Royale: Shrinking Boundary ──────────────────────────────────────

  void _startBoundaryShrink() {
    _shrinkTimer?.cancel();
    _shrinkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (state.status != GameStatus.playing) return;
      final newRadius = (state.boundaryRadius - 1).clamp(3, 10);
      state = state.copyWith(boundaryRadius: newRadius);

      final cx = GameConstants.gridWidth ~/ 2;
      final cy = GameConstants.gridHeight ~/ 2;
      final updatedAi = List<List<Position>>.from(
          state.aiSnakes.map((s) => List<Position>.from(s)));
      final newPellets = List<Position>.from(state.deathPellets);
      final newFeed = List<String>.from(state.killFeed);
      bool changed = false;

      for (int i = 0; i < updatedAi.length; i++) {
        if (updatedAi[i].isEmpty) continue;
        final aiHead = updatedAi[i].first;
        if (aiHead.x < cx - newRadius ||
            aiHead.x > cx + newRadius ||
            aiHead.y < cy - newRadius ||
            aiHead.y > cy + newRadius) {
          _addDeathPellets(updatedAi[i], newPellets);
          newFeed.add('Storm eliminated Snake #${i + 1}');
          updatedAi[i] = [];
          changed = true;
        }
      }
      if (changed) {
        state = state.copyWith(
          aiSnakes: updatedAi,
          deathPellets: newPellets,
          killFeed: newFeed,
        );
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
      isBoosting: false,
    );
  }

  FoodItem _generateFoodItem(
      List<Position> snake, List<Position> obstacles) {
    final pos = _generateFood(snake, obstacles);
    final type = state.gameMode == GameMode.classic && state.score < 50
        ? FoodType.normal
        : FoodType.randomWeighted(_random);
    return FoodItem(position: pos, type: type);
  }

  Position _generateFood(List<Position> snake, List<Position> obstacles) {
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
    _shrinkTimer?.cancel();
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
