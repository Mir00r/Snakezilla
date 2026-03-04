/// Represents a single achievement that can be unlocked by the player.
class Achievement {
  /// Unique identifier.
  final String id;

  /// Display title.
  final String title;

  /// Description of unlock criteria.
  final String description;

  /// Emoji badge shown in the UI.
  final String badge;

  /// Coin reward granted on first unlock.
  final int coinReward;

  /// XP reward granted on first unlock.
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.badge = '🏆',
    this.coinReward = 50,
    this.xpReward = 100,
  });
}

/// Master catalogue of all achievements.
class Achievements {
  Achievements._();

  static const score100 = Achievement(
    id: 'score_100',
    title: 'Getting Started',
    description: 'Score 100 points in a single game.',
    badge: '⭐',
    coinReward: 25,
    xpReward: 50,
  );

  static const score500 = Achievement(
    id: 'score_500',
    title: 'Rising Star',
    description: 'Score 500 points in a single game.',
    badge: '🌟',
    coinReward: 75,
    xpReward: 150,
  );

  static const score1000 = Achievement(
    id: 'score_1000',
    title: 'Snake Master',
    description: 'Score 1000 points in a single game.',
    badge: '🏅',
    coinReward: 200,
    xpReward: 400,
  );

  static const play10 = Achievement(
    id: 'play_10',
    title: 'Regular Player',
    description: 'Play 10 games.',
    badge: '🎮',
    coinReward: 50,
    xpReward: 100,
  );

  static const play50 = Achievement(
    id: 'play_50',
    title: 'Dedicated',
    description: 'Play 50 games.',
    badge: '💪',
    coinReward: 150,
    xpReward: 300,
  );

  static const noWallHit = Achievement(
    id: 'no_wall',
    title: 'Wall Dodger',
    description: 'Score 200+ without hitting a wall (wrap off).',
    badge: '🛡️',
    coinReward: 100,
    xpReward: 200,
  );

  static const unlock3Skins = Achievement(
    id: 'unlock_3_skins',
    title: 'Fashionista',
    description: 'Unlock 3 different skins.',
    badge: '👗',
    coinReward: 100,
    xpReward: 200,
  );

  static const beatAI5 = Achievement(
    id: 'beat_ai_5',
    title: 'AI Slayer',
    description: 'Beat the AI opponent 5 times.',
    badge: '🤖',
    coinReward: 150,
    xpReward: 300,
  );

  static const combo5 = Achievement(
    id: 'combo_5',
    title: 'Combo King',
    description: 'Reach a 5x combo streak.',
    badge: '🔥',
    coinReward: 75,
    xpReward: 150,
  );

  static const longSnake = Achievement(
    id: 'long_snake',
    title: 'Anaconda',
    description: 'Grow your snake to 30 segments.',
    badge: '🐍',
    coinReward: 100,
    xpReward: 200,
  );

  static const List<Achievement> all = [
    score100,
    score500,
    score1000,
    play10,
    play50,
    noWallHit,
    unlock3Skins,
    beatAI5,
    combo5,
    longSnake,
  ];
}
