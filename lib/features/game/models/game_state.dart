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

  /// Returns remaining seconds (clamped to 0).
  int get remainingSeconds =>
      expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 999);
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

  /// Time remaining in Time Attack / Gold Rush (seconds, -1 = unlimited).
  final int timeRemaining;

  /// Obstacle positions (Survival / Adventure modes).
  final List<Position> obstacles;

  /// Active power-up effects.
  final List<ActiveEffect> activeEffects;

  /// Countdown value (3, 2, 1) before game starts.
  final int countdownValue;

  /// Whether screen shake is currently active.
  final bool screenShake;

  // ── Multi-AI fields ────────────────────────────────────────────────────────

  /// Multiple AI snake bodies — legacy [aiSnake] is now `aiSnakes[0]`.
  final List<List<Position>> aiSnakes;

  /// Directions for each AI snake.
  final List<Direction> aiDirections;

  /// Legacy single-AI compatibility accessors.
  List<Position> get aiSnake =>
      aiSnakes.isNotEmpty ? aiSnakes.first : const [];
  Direction get aiDirection =>
      aiDirections.isNotEmpty ? aiDirections.first : Direction.right;

  // ── Boost ──────────────────────────────────────────────────────────────────

  /// Whether the player is currently boosting (hold-to-boost).
  final bool isBoosting;

  /// Internal tick counter for boost shrink timing.
  final int boostTickCounter;

  // ── Kill & death pellets ───────────────────────────────────────────────────

  /// Number of AI snakes eliminated this game.
  final int kills;

  /// Death pellets dropped by dead AI snakes.
  final List<Position> deathPellets;

  // ── Map theme ──────────────────────────────────────────────────────────────

  /// ID of the visual arena theme.
  final String mapThemeId;

  // ── Battle Royale ──────────────────────────────────────────────────────────

  /// Current safe-zone radius in cells (shrinks over time).
  final int boundaryRadius;

  // ── Gold Rush ──────────────────────────────────────────────────────────────

  /// Scattered gold coins for Gold Rush mode.
  final List<Position> goldCoins;

  /// Gold coins collected this session.
  final int goldCollected;

  // ── Kill Feed ──────────────────────────────────────────────────────────────

  /// Recent kill feed messages shown briefly on screen.
  final List<String> killFeed;

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
    this.activeEffects = const [],
    this.countdownValue = 3,
    this.screenShake = false,
    this.aiSnakes = const [],
    this.aiDirections = const [],
    this.isBoosting = false,
    this.boostTickCounter = 0,
    this.kills = 0,
    this.deathPellets = const [],
    this.mapThemeId = 'neonNight',
    this.boundaryRadius = 10,
    this.goldCoins = const [],
    this.goldCollected = 0,
    this.killFeed = const [],
  });

  /// Factory that creates the starting state with the snake centred on
  /// the grid and food placed at a random non-overlapping position.
  factory GameState.initial({
    int highScore = 0,
    int speed = GameConstants.speedMedium,
    bool boundaryWrap = false,
    GameMode gameMode = GameMode.classic,
    int timeRemaining = -1,
    String mapThemeId = 'neonNight',
  }) {
    final centerX = GameConstants.gridWidth ~/ 2;
    final centerY = GameConstants.gridHeight ~/ 2;

    // Snake grows leftward from the centre.
    final snake = List<Position>.generate(
      GameConstants.initialSnakeLength,
      (i) => Position(centerX - i, centerY),
    );

    final foodPos = _randomFood(snake, const []);

    // Spawn multiple AI snakes for AI Battle and Battle Royale modes.
    final needsAI = gameMode == GameMode.aiBattle ||
        gameMode == GameMode.battleRoyale;
    final aiCount = gameMode == GameMode.battleRoyale
        ? 4
        : (gameMode == GameMode.aiBattle ? 3 : 0);

    final aiSnakes = <List<Position>>[];
    final aiDirs = <Direction>[];
    if (needsAI) {
      // Spawn positions in different quadrants.
      final spawnPoints = [
        (centerX + 5, centerY - 5, Direction.left),
        (2, 2, Direction.right),
        (GameConstants.gridWidth - 3, GameConstants.gridHeight - 3,
            Direction.left),
        (2, GameConstants.gridHeight - 3, Direction.right),
      ];
      for (int i = 0; i < aiCount; i++) {
        final sp = spawnPoints[i % spawnPoints.length];
        final aiBody = List<Position>.generate(
          GameConstants.initialSnakeLength,
          (j) => Position(
            (sp.$1 + (sp.$3 == Direction.left ? j : -j))
                .clamp(0, GameConstants.gridWidth - 1),
            sp.$2,
          ),
        );
        aiSnakes.add(aiBody);
        aiDirs.add(sp.$3);
      }
    }

    // Gold Rush: scatter gold coins.
    final goldCoins = <Position>[];
    if (gameMode == GameMode.goldRush) {
      final rng = Random();
      final occupied = <Position>{...snake};
      for (int i = 0; i < 15; i++) {
        Position p;
        int attempts = 0;
        do {
          p = Position(
            rng.nextInt(GameConstants.gridWidth),
            rng.nextInt(GameConstants.gridHeight),
          );
          attempts++;
        } while (occupied.contains(p) && attempts < 200);
        goldCoins.add(p);
        occupied.add(p);
      }
    }

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
      aiSnakes: aiSnakes,
      aiDirections: aiDirs,
      mapThemeId: mapThemeId,
      boundaryRadius: gameMode == GameMode.battleRoyale ? 10 : 10,
      goldCoins: goldCoins,
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
    List<ActiveEffect>? activeEffects,
    int? countdownValue,
    bool? screenShake,
    List<List<Position>>? aiSnakes,
    List<Direction>? aiDirections,
    bool? isBoosting,
    int? boostTickCounter,
    int? kills,
    List<Position>? deathPellets,
    String? mapThemeId,
    int? boundaryRadius,
    List<Position>? goldCoins,
    int? goldCollected,
    List<String>? killFeed,
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
      activeEffects: activeEffects ?? this.activeEffects,
      countdownValue: countdownValue ?? this.countdownValue,
      screenShake: screenShake ?? this.screenShake,
      aiSnakes: aiSnakes ?? this.aiSnakes,
      aiDirections: aiDirections ?? this.aiDirections,
      isBoosting: isBoosting ?? this.isBoosting,
      boostTickCounter: boostTickCounter ?? this.boostTickCounter,
      kills: kills ?? this.kills,
      deathPellets: deathPellets ?? this.deathPellets,
      mapThemeId: mapThemeId ?? this.mapThemeId,
      boundaryRadius: boundaryRadius ?? this.boundaryRadius,
      goldCoins: goldCoins ?? this.goldCoins,
      goldCollected: goldCollected ?? this.goldCollected,
      killFeed: killFeed ?? this.killFeed,
    );
  }
}
