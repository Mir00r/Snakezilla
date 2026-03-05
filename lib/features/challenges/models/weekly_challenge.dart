/// A single step in a weekly challenge ladder.
class WeeklyChallengeStep {
  final int step;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final int coinReward;
  final int xpReward;

  const WeeklyChallengeStep({
    required this.step,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    required this.coinReward,
    this.xpReward = 0,
  });
}

/// Weekly challenge with a ladder of escalating steps.
class WeeklyChallenge {
  final String id;
  final String title;
  final String emoji;
  final List<WeeklyChallengeStep> steps;
  final String finalRewardType; // 'skin', 'pet', 'coins'
  final String finalRewardId;
  final int finalCoinReward;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.emoji,
    required this.steps,
    this.finalRewardType = 'coins',
    this.finalRewardId = '',
    this.finalCoinReward = 500,
  });
}

/// Generates weekly challenges based on the current week.
class WeeklyChallenges {
  WeeklyChallenges._();

  static final _templates = [
    WeeklyChallenge(
      id: 'score_master',
      title: 'Score Master',
      emoji: '🎯',
      steps: const [
        WeeklyChallengeStep(
          step: 1,
          title: 'Warm Up',
          description: 'Score 300 in a single game',
          emoji: '🌟',
          target: 300,
          coinReward: 30,
        ),
        WeeklyChallengeStep(
          step: 2,
          title: 'Getting Hot',
          description: 'Score 700 in a single game',
          emoji: '🔥',
          target: 700,
          coinReward: 60,
        ),
        WeeklyChallengeStep(
          step: 3,
          title: 'On Fire',
          description: 'Score 1500 in a single game',
          emoji: '💥',
          target: 1500,
          coinReward: 100,
        ),
        WeeklyChallengeStep(
          step: 4,
          title: 'Master',
          description: 'Reach a 10x combo',
          emoji: '👑',
          target: 10,
          coinReward: 150,
          xpReward: 200,
        ),
      ],
      finalRewardType: 'skin',
      finalRewardId: 'golden',
      finalCoinReward: 500,
    ),
    WeeklyChallenge(
      id: 'survival_king',
      title: 'Survival King',
      emoji: '💀',
      steps: const [
        WeeklyChallengeStep(
          step: 1,
          title: 'Survivor',
          description: 'Play 5 games',
          emoji: '🎮',
          target: 5,
          coinReward: 25,
        ),
        WeeklyChallengeStep(
          step: 2,
          title: 'Fighter',
          description: 'Defeat 5 AI snakes',
          emoji: '⚔️',
          target: 5,
          coinReward: 50,
        ),
        WeeklyChallengeStep(
          step: 3,
          title: 'Champion',
          description: 'Grow snake to 25 segments',
          emoji: '🐍',
          target: 25,
          coinReward: 80,
        ),
        WeeklyChallengeStep(
          step: 4,
          title: 'King',
          description: 'Win 3 Battle Royales',
          emoji: '👑',
          target: 3,
          coinReward: 150,
          xpReward: 300,
        ),
      ],
      finalRewardType: 'pet',
      finalRewardId: 'crystal_owl',
      finalCoinReward: 600,
    ),
    WeeklyChallenge(
      id: 'gold_rush',
      title: 'Gold Fever',
      emoji: '🪙',
      steps: const [
        WeeklyChallengeStep(
          step: 1,
          title: 'Prospector',
          description: 'Collect 20 gold coins',
          emoji: '🪙',
          target: 20,
          coinReward: 30,
        ),
        WeeklyChallengeStep(
          step: 2,
          title: 'Miner',
          description: 'Earn 200 coins from games',
          emoji: '💰',
          target: 200,
          coinReward: 60,
        ),
        WeeklyChallengeStep(
          step: 3,
          title: 'Tycoon',
          description: 'Collect 5 power-ups in one game',
          emoji: '⚡',
          target: 5,
          coinReward: 100,
        ),
        WeeklyChallengeStep(
          step: 4,
          title: 'Mogul',
          description: 'Score 2000 total across games',
          emoji: '🏆',
          target: 2000,
          coinReward: 200,
          xpReward: 400,
        ),
      ],
      finalRewardType: 'coins',
      finalRewardId: '',
      finalCoinReward: 800,
    ),
  ];

  /// Returns the challenge for the current week (rotates through templates).
  static WeeklyChallenge current() {
    final weekNumber =
        DateTime.now().difference(DateTime(2024, 1, 1)).inDays ~/ 7;
    return _templates[weekNumber % _templates.length];
  }

  /// Returns all challenge templates.
  static List<WeeklyChallenge> get all => _templates;
}
