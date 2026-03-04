import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/storage_service.dart';
import '../../settings/models/settings_model.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/direction.dart';
import '../models/game_state.dart';
import '../models/position.dart';

/// Central game-logic controller.
///
/// Drives the game loop via [Timer.periodic], manages snake movement,
/// collision detection, scoring, speed scaling, and audio cues.
class GameNotifier extends StateNotifier<GameState> {
  Timer? _gameTimer;
  final AudioService _audio;
  final StorageService _storage;
  final Random _random = Random();
  final Ref _ref;

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

  /// Initialises (or restarts) the game.
  void startGame() {
    final settings = _ref.read(settingsProvider);
    final speed = _speedForDifficulty(settings.difficulty);

    state = GameState.initial(
      highScore: state.highScore,
      speed: speed,
      boundaryWrap: settings.boundaryWrap,
    ).copyWith(status: GameStatus.playing);

    _startTimer();
    _audio.startMusic();
  }

  /// Pauses a running game.
  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    _gameTimer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  /// Resumes from a paused state.
  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
  }

  /// Queues a direction change for the next tick.
  ///
  /// 180° reversals (e.g. right → left) are silently ignored to prevent
  /// the snake from colliding with itself on the very next tick.
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

    // 1. Resolve direction.
    final direction = state.bufferedDirection ?? state.direction;

    // 2. Calculate new head position.
    final head = state.snake.first;
    final offset = direction.offset;
    var newHead = head.move(offset.dx, offset.dy);

    // 3. Handle boundaries.
    if (state.boundaryWrap) {
      // Dart's `%` can return negative values — wrap properly.
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

    // 4. Self-collision check.
    final willEat = newHead == state.food;
    // If food will be eaten the tail does NOT shrink, so check the full body.
    final bodyToCheck = willEat
        ? state.snake
        : state.snake.sublist(0, state.snake.length - 1);

    if (bodyToCheck.contains(newHead)) {
      _gameOver();
      return;
    }

    // 5. Build new snake body.
    final newSnake = [newHead, ...state.snake];
    if (!willEat) {
      newSnake.removeLast();
    }

    // 6. Handle scoring & speed.
    int newScore = state.score;
    int newSpeed = state.speed;
    Position newFood = state.food;

    if (willEat) {
      newScore += GameConstants.pointsPerFood;
      newSpeed = (state.speed - GameConstants.speedIncrement)
          .clamp(GameConstants.minSpeed, state.speed);
      newFood = _generateFood(newSnake);
      _audio.playEat();

      // Restart timer if speed changed.
      if (newSpeed != state.speed) {
        _gameTimer?.cancel();
        state = state.copyWith(
          snake: newSnake,
          food: newFood,
          direction: direction,
          bufferedDirection: () => null,
          score: newScore,
          speed: newSpeed,
        );
        _startTimer();
        return;
      }
    }

    // 7. Commit state.
    state = state.copyWith(
      snake: newSnake,
      food: newFood,
      direction: direction,
      bufferedDirection: () => null,
      score: newScore,
      speed: newSpeed,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _gameOver() {
    _gameTimer?.cancel();
    _audio.playGameOver();
    _audio.stopMusic();

    int newHighScore = state.highScore;
    if (state.score > state.highScore) {
      newHighScore = state.score;
      _storage.saveHighScore(newHighScore);
    }

    state = state.copyWith(
      status: GameStatus.gameOver,
      highScore: newHighScore,
    );
  }

  /// Returns a random [Position] that does not overlap the [snake].
  Position _generateFood(List<Position> snake) {
    Position food;
    do {
      food = Position(
        _random.nextInt(GameConstants.gridWidth),
        _random.nextInt(GameConstants.gridHeight),
      );
    } while (snake.contains(food));
    return food;
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: state.speed),
      (_) => _tick(),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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
