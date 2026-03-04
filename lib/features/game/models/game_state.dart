import 'dart:math';

import '../../../core/constants/game_constants.dart';
import 'direction.dart';
import 'position.dart';

/// The high-level status of a game session.
enum GameStatus { idle, playing, paused, gameOver }

/// Immutable snapshot of the entire game state at a single point in time.
///
/// All mutations go through [copyWith] to preserve immutability,
/// which enables clean state-management diffing in Riverpod.
class GameState {
  /// Ordered list of positions from head (index 0) to tail.
  final List<Position> snake;

  /// Current position of the food item.
  final Position food;

  /// The direction the snake moved on the last tick.
  final Direction direction;

  /// A direction change queued by the player, applied on the next tick.
  final Direction? bufferedDirection;

  /// Current score.
  final int score;

  /// Persisted all-time high score.
  final int highScore;

  /// Current game status.
  final GameStatus status;

  /// Milliseconds between game ticks (lower = faster).
  final int speed;

  /// Whether the snake wraps around the grid edges.
  final bool boundaryWrap;

  const GameState({
    required this.snake,
    required this.food,
    required this.direction,
    this.bufferedDirection,
    required this.score,
    required this.highScore,
    required this.status,
    required this.speed,
    required this.boundaryWrap,
  });

  /// Factory that creates the starting state with the snake centred on
  /// the grid and food placed at a random non-overlapping position.
  factory GameState.initial({
    int highScore = 0,
    int speed = GameConstants.speedMedium,
    bool boundaryWrap = false,
  }) {
    final centerX = GameConstants.gridWidth ~/ 2;
    final centerY = GameConstants.gridHeight ~/ 2;

    // Snake grows leftward from the centre.
    final snake = List<Position>.generate(
      GameConstants.initialSnakeLength,
      (i) => Position(centerX - i, centerY),
    );

    final food = _randomFood(snake);

    return GameState(
      snake: snake,
      food: food,
      direction: Direction.right,
      score: 0,
      highScore: highScore,
      status: GameStatus.idle,
      speed: speed,
      boundaryWrap: boundaryWrap,
    );
  }

  /// Generates a random food [Position] that does not overlap the [snake].
  static Position _randomFood(List<Position> snake) {
    final random = Random();
    Position food;
    do {
      food = Position(
        random.nextInt(GameConstants.gridWidth),
        random.nextInt(GameConstants.gridHeight),
      );
    } while (snake.contains(food));
    return food;
  }

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// [bufferedDirection] uses a nullable-returning closure so that `null`
  /// can be explicitly assigned (clearing the buffer).
  GameState copyWith({
    List<Position>? snake,
    Position? food,
    Direction? direction,
    Direction? Function()? bufferedDirection,
    int? score,
    int? highScore,
    GameStatus? status,
    int? speed,
    bool? boundaryWrap,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      bufferedDirection: bufferedDirection != null
          ? bufferedDirection()
          : this.bufferedDirection,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      speed: speed ?? this.speed,
      boundaryWrap: boundaryWrap ?? this.boundaryWrap,
    );
  }
}
