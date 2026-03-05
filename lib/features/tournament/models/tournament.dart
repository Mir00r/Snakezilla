import 'dart:math';

/// A tournament entry representing a player's best score.
class TournamentEntry {
  final String playerName;
  final int score;
  final DateTime date;

  const TournamentEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'playerName': playerName,
        'score': score,
        'date': date.millisecondsSinceEpoch,
      };

  factory TournamentEntry.fromMap(Map<String, dynamic> map) {
    return TournamentEntry(
      playerName: map['playerName'] as String? ?? 'Player',
      score: map['score'] as int? ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(
          map['date'] as int? ?? 0),
    );
  }
}

/// Tournament types with different schedules and rules.
enum TournamentType {
  daily('Daily', '🏅', 3, 'Best of 3 attempts'),
  weekly('Weekly', '🏆', 10, 'Best of 10 attempts'),
  special('Special Event', '👑', 5, 'Limited time event');

  final String label;
  final String emoji;
  final int maxAttempts;
  final String description;

  const TournamentType(
      this.label, this.emoji, this.maxAttempts, this.description);
}

/// A tournament instance.
class Tournament {
  final String id;
  final String title;
  final TournamentType type;
  final int coinPrize;
  final int xpPrize;
  final List<TournamentEntry> leaderboard;
  final int attemptsUsed;

  const Tournament({
    required this.id,
    required this.title,
    required this.type,
    this.coinPrize = 500,
    this.xpPrize = 200,
    this.leaderboard = const [],
    this.attemptsUsed = 0,
  });

  bool get hasAttempts => attemptsUsed < type.maxAttempts;

  Tournament copyWith({
    List<TournamentEntry>? leaderboard,
    int? attemptsUsed,
  }) {
    return Tournament(
      id: id,
      title: title,
      type: type,
      coinPrize: coinPrize,
      xpPrize: xpPrize,
      leaderboard: leaderboard ?? this.leaderboard,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
    );
  }
}

/// Generates simulated tournament opponents with controlled skill levels.
class TournamentAI {
  TournamentAI._();

  static final _names = [
    'NeonViper', 'CyberSnake', 'PixelDragon', 'GlowWorm',
    'TurboSnek', 'NightCrawler', 'VenomKing', 'ScaleRunner',
    'CoilMaster', 'FangStrike', 'HissQueen', 'SlitherPro',
    'ViperX', 'SnakeBoss', 'ZigZag99', 'CobraCool',
  ];

  /// Generates fake opponents for the leaderboard.
  static List<TournamentEntry> generateOpponents(int count, int difficulty) {
    final rng = Random(DateTime.now().day * 7 + difficulty);
    final names = List.of(_names)..shuffle(rng);
    return List.generate(count, (i) {
      final baseScore = (difficulty + 1) * 100;
      final variance = rng.nextInt(baseScore);
      return TournamentEntry(
        playerName: names[i % names.length],
        score: baseScore + variance,
        date: DateTime.now(),
      );
    });
  }
}

/// Active tournaments manager.
class Tournaments {
  Tournaments._();

  static Tournament daily() {
    final day = DateTime.now().day;
    return Tournament(
      id: 'daily_$day',
      title: 'Daily Sprint',
      type: TournamentType.daily,
      coinPrize: 300,
      xpPrize: 100,
    );
  }

  static Tournament weekly() {
    final week =
        DateTime.now().difference(DateTime(2024, 1, 1)).inDays ~/ 7;
    return Tournament(
      id: 'weekly_$week',
      title: 'Weekly Championship',
      type: TournamentType.weekly,
      coinPrize: 1000,
      xpPrize: 500,
    );
  }

  static Tournament? special() {
    // Special tournament during specific periods
    final month = DateTime.now().month;
    if (month == 12) {
      return const Tournament(
        id: 'xmas_2024',
        title: 'Holiday Tournament',
        type: TournamentType.special,
        coinPrize: 2000,
        xpPrize: 800,
      );
    }
    return null;
  }
}
