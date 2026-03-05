/// 7-day daily reward calendar.
///
/// Each day provides escalating rewards. At day 7, the cycle resets.
class DailyRewardDay {
  final int day; // 1–7
  final String emoji;
  final String label;
  final int coins;
  final String? bonusItem; // null or e.g. 'skin_fragment', 'xp_boost'

  const DailyRewardDay({
    required this.day,
    required this.emoji,
    required this.label,
    required this.coins,
    this.bonusItem,
  });
}

/// The 7-day reward schedule.
class DailyRewardCalendar {
  DailyRewardCalendar._();

  static const List<DailyRewardDay> schedule = [
    DailyRewardDay(day: 1, emoji: '🎁', label: 'Coins', coins: 25),
    DailyRewardDay(day: 2, emoji: '💰', label: 'Coins', coins: 50),
    DailyRewardDay(
        day: 3,
        emoji: '⚡',
        label: 'Boost Pack',
        coins: 50,
        bonusItem: 'xp_boost'),
    DailyRewardDay(day: 4, emoji: '🪙', label: 'Big Coins', coins: 100),
    DailyRewardDay(
        day: 5,
        emoji: '🧩',
        label: 'Skin Fragment',
        coins: 75,
        bonusItem: 'skin_fragment'),
    DailyRewardDay(day: 6, emoji: '🏆', label: 'XP Bonus', coins: 100,
        bonusItem: 'xp_boost'),
    DailyRewardDay(
        day: 7,
        emoji: '👑',
        label: 'MEGA REWARD',
        coins: 200,
        bonusItem: 'rare_skin'),
  ];
}
