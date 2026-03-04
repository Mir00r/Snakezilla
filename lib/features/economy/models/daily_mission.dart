import 'dart:math';

/// A single daily mission with a target and reward.
class DailyMission {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int target;
  final int coinReward;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.target,
    required this.coinReward,
  });
}

/// All possible mission templates. 3 are randomly selected each day.
class DailyMissions {
  DailyMissions._();

  static const _templates = [
    DailyMission(
      id: 'score_200',
      title: 'Score Hunter',
      description: 'Score 200+ in a single game',
      emoji: '🎯',
      target: 200,
      coinReward: 30,
    ),
    DailyMission(
      id: 'play_3',
      title: 'Warm Up',
      description: 'Play 3 games today',
      emoji: '🎮',
      target: 3,
      coinReward: 20,
    ),
    DailyMission(
      id: 'eat_20',
      title: 'Hungry Snek',
      description: 'Eat 20 food items in one game',
      emoji: '🍎',
      target: 20,
      coinReward: 25,
    ),
    DailyMission(
      id: 'combo_3',
      title: 'Combo Starter',
      description: 'Reach a 3x combo',
      emoji: '🔥',
      target: 3,
      coinReward: 25,
    ),
    DailyMission(
      id: 'survive_60',
      title: 'Survivor',
      description: 'Survive 60 seconds in Survival mode',
      emoji: '💀',
      target: 60,
      coinReward: 35,
    ),
    DailyMission(
      id: 'length_15',
      title: 'Long Boi',
      description: 'Grow snake to 15 segments',
      emoji: '🐍',
      target: 15,
      coinReward: 20,
    ),
    DailyMission(
      id: 'kill_2',
      title: 'Snake Slayer',
      description: 'Defeat 2 AI snakes',
      emoji: '⚔️',
      target: 2,
      coinReward: 40,
    ),
    DailyMission(
      id: 'coins_50',
      title: 'Coin Collector',
      description: 'Earn 50 coins from games',
      emoji: '💰',
      target: 50,
      coinReward: 30,
    ),
    DailyMission(
      id: 'gold_rush',
      title: 'Gold Digger',
      description: 'Play a Gold Rush game',
      emoji: '🪙',
      target: 1,
      coinReward: 25,
    ),
    DailyMission(
      id: 'power_3',
      title: 'Power Player',
      description: 'Collect 3 power-ups in one game',
      emoji: '⚡',
      target: 3,
      coinReward: 25,
    ),
    DailyMission(
      id: 'score_500',
      title: 'Score Master',
      description: 'Score 500+ in a single game',
      emoji: '🌟',
      target: 500,
      coinReward: 50,
    ),
    DailyMission(
      id: 'battle_royale',
      title: 'Arena Fighter',
      description: 'Play a Battle Royale game',
      emoji: '👑',
      target: 1,
      coinReward: 30,
    ),
  ];

  /// Returns 3 missions for today (deterministic from day seed).
  static List<DailyMission> forToday() {
    final day = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final rng = Random(day * 7919); // prime seed for variety
    final shuffled = List<DailyMission>.from(_templates)..shuffle(rng);
    return shuffled.take(3).toList();
  }
}
