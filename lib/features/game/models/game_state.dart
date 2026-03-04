import 'dart:math';

import '../../../core/constants/game_constants.dart';
import 'direction.dart';
import 'food_type.dart';
import 'game_mode.dart';
import 'position.dart';

/// The high-level status of a game session.
enum GameStatus { idle, countdown, playing, paused, gameOver }

/// Active power-up effect currently applied to the snake.
class ActiveEffect {
  final FoodType type;
  final DateTime expiresAt;

  const ActiveEffect({required this.type, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Immutable snapshot of the entire game state at a single point in time.
///
/// All mutations go through [copyWith] to preserve immutability,
/// which enables clean state-management diffing in Riverpod.
class GameState {
  /// Ordered list of positions from head (index 0) to tail.
  final List<Position> snake;

  /// Current food item on the board (includes type + position).
  final FoodItem foodItem;

  /// Legacy accessor for food position (used by painter / collision).
  Position get food => foodItem.position;

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

  /// Current game mode.
  final GameMode gameMode;

  /// Current combo multiplier streak.
  final int combo;

  /// Highest combo achieved this game.
  final int maxCombo;

  /// Coins collected this game session.
  final int coinsEarned;

  /// Time remaining in Time Attack (seconds, -1 = unlimited).
  final int timeRemaining;

  /// Obstacle positions (Survival / Adventure modes).
  final List<Position> obstacles;

  /// AI snake body positions (AI Battle mode).
  final List<Position> aiSnake;

  /// AI snake movement direction.
  final Direction aiDirection;

  /// Active power-up effects.
  final List<ActiveEffect> activeEffects;

  /// Countdown value (3, 2, 1) before game starts.
  final int countdownValue;

  /// Whether screen shake is currently active.
  final bool screenShake;

  const GameState({
    required this.snake,
    required this.foodItem,
    required this.direction,
    this.bufferedDirection,
    required this.score,
    required this.highScore,
    required this.status,
    required this.speed,
    required this.boundaryWrap,
    this.gameMode = GameMode.classic,
    this.combo = 0,
    this.maxCombo = 0,
    this.coinsEarned = 0,
    this.timeRemaining = -1,
    this.obstacles = const [],
    this.aiSnake = const [],
    this.aiDirection = Direction.right,
    this.activeEffects = const [],
    this.countdownValue = 3,
    this.screenShake = false,
  });

  /// Factory that creates the starting state with the snake centred on
  /// the grid and food placed at a random non-overlapping position.
  factory GameState.initial({
    int highScore = 0,
    int speed = GameConstants.speedMedium,
    bool boundaryWrap = false,
    GameMode gameMode = GameMode.classic,
    int timeRemaining = -1,
  }) {
    final centerX = GameConstants.gridWidth ~/ 2;
    final centerY = GameConstants.gridHeight ~/ 2;

    // Snake grows leftward from the centre.
    final snake = List<Position>.generate(
      GameConstants.initialSnakeLength,
      (i) => Position(centerX - i, centerY),
    );

    final foodPos = _randomFood(snake, const []);

    // AI snake spawns in the opposite quadrant.
    final aiSnake = gameMode == GameMode.aiBattle
        ? List<Position>.generate(
            GameConstants.initialSnakeLength,
            (i) => Position(centerX + i, centerY - 4),
          )
        : <Position>[];

    return GameState(
      snake: snake,
      foodItem: FoodItem(position: foodPos, type: FoodType.normal),
      direction: Direction.right,
      score: 0,
      highScore: highScore,
      status: GameStatus.idle,
      speed: speed,
      boundaryWrap: boundaryWrap,
      gameMode: gameMode,
      timeRemaining: timeRemaining,
      aiSnake: aiSnake,
      aiDirection: Direction.left,
    );
  }

  /// Generates a random food [Position] that does not overlap.
  static Position _randomFood(
      List<Position> snake, List<Position> obstacles) {
    final random = Random();
    Position food;
    do {
      food = Position(
        random.nextInt(GameConstants.gridWidth),
        random.nextInt(GameConstants.gridHeight),
      );
    } while (snake.contains(food) || obstacles.contains(food));
    return food;
  }

  /// Checks if any active effect of [type] is still alive.
  bool hasEffect(FoodType type) {
    return activeEffects.any((e) => e.type == type && !e.isExpired);
  }

  /// Returns the current score multiplier based on combos and effects.
  int get scoreMultiplier {
    int mul = 1;
    if (hasEffect(FoodType.rainbow)) mul *= 2;
    if (combo >= 3) mul += 1;
    if (combo >= 5) mul += 1;
    return mul;
  }

  /// Returns a copy of this state with the given fields replaced.
  GameState copyWith({
    List<Position>? snake,
    FoodItem? foodItem,
    Direction? direction,
    Direction? Function()? bufferedDirection,
    int? score,
    int? highScore,
    GameStatus? status,
    int? speed,
    bool? boundaryWrap,
    GameMode? gameMode,
    int? combo,
    int? maxCombo,
    int? coinsEarned,
    int? timeRemaining,
    List<Position>? obstacles,
    List<Position>? aiSnake,
    Direction? aiDirection,
    List<ActiveEffect>? activeEffects,
    int? countdownValue,
    bool? screenShake,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      foodItem: foodItem ?? this.foodItem,
      direction: direction ?? this.direction,
      bufferedDirection: bufferedDirection != null
          ? bufferedDirection()
          : this.bufferedDirection,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      speed: speed ?? this.speed,
      boundaryWrap: boundaryWrap ?? this.boundaryWrap,
      gameMode: gameMode ?? this.gameMode,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      obstacles: obstacles ?? this.obstacles,
      aiSnake: aiSnake ?? this.aiSnake,
      aiDirection: aiDirection ?? this.aiDirection,
      activeEffects: activeEffects ?? this.activeEffects,
      countdownValue: countdownValue ?? this.countdownValue,
      screenShake: screenShake ?? this.screenShake,
    );
  }
}
