import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/storage_service.dart';
import '../../achievements/models/achievement.dart';
import '../../game/models/game_world.dart';
import '../../pets/models/companion_pet.dart';
import '../../skins/models/snake_skin.dart';
import '../models/daily_reward.dart';
import '../models/player_profile.dart';

const _kProfileKey = 'snakezilla_player_profile';

/// Manages the player economy, progression, and cosmetics.
///
/// All mutations auto-persist via [SharedPreferences].
class PlayerProfileNotifier extends StateNotifier<PlayerProfile> {
  final StorageService _storage;

  PlayerProfileNotifier(this._storage) : super(_loadProfile(_storage));

  static PlayerProfile _loadProfile(StorageService storage) {
    try {
      final raw = storage.prefs.getString(_kProfileKey);
      if (raw == null) return const PlayerProfile();
      return PlayerProfile.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerProfile();
    }
  }

  // ── Coins ──────────────────────────────────────────────────────────────────

  /// Awards [amount] coins (from score, combos, achievements, daily reward).
  void addCoins(int amount) {
    state = state.copyWith(
      coins: state.coins + amount,
      totalCoinsEarned: state.totalCoinsEarned + amount,
    );
    _updateTitle();
    _persist();
  }

  /// Spends [amount] coins. Returns `true` if successful.
  bool spendCoins(int amount) {
    if (state.coins < amount) return false;
    state = state.copyWith(coins: state.coins - amount);
    _persist();
    return true;
  }

  // ── XP ─────────────────────────────────────────────────────────────────────

  void addXp(int amount) {
    state = state.copyWith(xp: state.xp + amount);
    _updateTitle();
    _persist();
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  /// Called after each game to update aggregate statistics.
  void recordGame({
    required int score,
    required int combo,
    required int snakeLength,
    bool aiWin = false,
  }) {
    state = state.copyWith(
      totalGames: state.totalGames + 1,
      totalScore: state.totalScore + score,
      highestCombo:
          combo > state.highestCombo ? combo : state.highestCombo,
      longestSnake:
          snakeLength > state.longestSnake ? snakeLength : state.longestSnake,
      aiWins: aiWin ? state.aiWins + 1 : state.aiWins,
    );

    // Award coins: 1 coin per 10 points.
    addCoins((score / 10).floor());
    addXp((score / 5).floor());
  }

  // ── Achievements ───────────────────────────────────────────────────────────

  /// Unlocks an achievement by [id] and awards its rewards.
  /// Returns `true` if newly unlocked.
  bool unlockAchievement(Achievement achievement) {
    if (state.unlockedAchievements.contains(achievement.id)) return false;
    final updated = {...state.unlockedAchievements, achievement.id};
    state = state.copyWith(unlockedAchievements: updated);
    addCoins(achievement.coinReward);
    addXp(achievement.xpReward);
    return true;
  }

  /// Checks all achievements and unlocks any that are newly satisfied.
  /// Returns a list of newly unlocked achievements.
  List<Achievement> checkAchievements() {
    final newlyUnlocked = <Achievement>[];

    for (final a in Achievements.all) {
      if (state.unlockedAchievements.contains(a.id)) continue;
      if (_isSatisfied(a)) {
        unlockAchievement(a);
        newlyUnlocked.add(a);
      }
    }
    return newlyUnlocked;
  }

  bool _isSatisfied(Achievement a) {
    switch (a.id) {
      case 'score_100':
        return state.totalScore >= 100;
      case 'score_500':
        return state.totalScore >= 500;
      case 'score_1000':
        return state.totalScore >= 1000;
      case 'play_10':
        return state.totalGames >= 10;
      case 'play_50':
        return state.totalGames >= 50;
      case 'no_wall':
        // Checked externally after a wall-dodge game.
        return false;
      case 'unlock_3_skins':
        return state.unlockedSkins.length >= 3;
      case 'beat_ai_5':
        return state.aiWins >= 5;
      case 'combo_5':
        return state.highestCombo >= 5;
      case 'long_snake':
        return state.longestSnake >= 30;
      default:
        return false;
    }
  }

  // ── Skins ──────────────────────────────────────────────────────────────────

  /// Purchases and unlocks a skin. Returns `true` on success.
  bool purchaseSkin(SnakeSkin skin) {
    if (state.unlockedSkins.contains(skin.id)) return true;
    if (!spendCoins(skin.price)) return false;
    final updated = {...state.unlockedSkins, skin.id};
    state = state.copyWith(unlockedSkins: updated);
    _persist();
    return true;
  }

  /// Equips an already-unlocked skin.
  void equipSkin(String skinId) {
    if (!state.unlockedSkins.contains(skinId)) return;
    state = state.copyWith(equippedSkinId: skinId);
    _persist();
  }

  // ── Daily Reward ───────────────────────────────────────────────────────────

  /// Claims the daily reward (50 coins). Returns `true` if successful.
  bool claimDailyReward() {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    if (state.lastDailyRewardDay >= today) return false;
    state = state.copyWith(lastDailyRewardDay: today);
    addCoins(50);
    return true;
  }

  // ── Enhanced Daily Rewards (7‑day calendar) ────────────────────────────────

  /// Claims a specific day's reward from the 7‑day calendar.
  bool claimDailyRewardV2(int dayIndex) {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    if (state.lastDailyRewardDay >= today) return false;

    final schedule = DailyRewardCalendar.schedule;
    if (dayIndex < 0 || dayIndex >= schedule.length) return false;

    final reward = schedule[dayIndex];
    final yesterday = today - 1;
    final isConsecutive = state.lastDailyRewardDay == yesterday;

    state = state.copyWith(
      lastDailyRewardDay: today,
      dailyStreak: isConsecutive ? state.dailyStreak + 1 : 1,
    );
    addCoins(reward.coins);
    addXp(20); // Bonus XP for logging in
    return true;
  }

  // ── Spin Wheel ─────────────────────────────────────────────────────────────

  /// Returns true if the player can spin today.
  bool get canSpin {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    return state.lastSpinDay < today;
  }

  /// Marks the spin as used today.
  void claimSpinReward() {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    state = state.copyWith(lastSpinDay: today);
    _persist();
  }

  // ── Companion Pets ─────────────────────────────────────────────────────────

  /// Purchases a pet. Returns `true` on success.
  bool purchasePet(CompanionPet pet) {
    if (state.unlockedPets.contains(pet.id)) return true;
    if (!spendCoins(pet.price)) return false;
    final updated = {...state.unlockedPets, pet.id};
    state = state.copyWith(unlockedPets: updated);
    _persist();
    return true;
  }

  /// Equips a pet (pass null to unequip).
  void equipPet(String? petId) {
    if (petId != null && !state.unlockedPets.contains(petId)) return;
    state = state.copyWith(equippedPetId: petId ?? '');
    _persist();
  }

  // ── Game Worlds ────────────────────────────────────────────────────────────

  /// Purchases a world. Returns `true` on success.
  bool purchaseWorld(GameWorld world) {
    if (state.unlockedWorlds.contains(world.id)) return true;
    if (state.level < world.unlockLevel) return false;
    if (!spendCoins(world.price)) return false;
    final updated = {...state.unlockedWorlds, world.id};
    state = state.copyWith(unlockedWorlds: updated);
    _persist();
    return true;
  }

  /// Equips a world theme.
  void equipWorld(String worldId) {
    if (!state.unlockedWorlds.contains(worldId)) return;
    state = state.copyWith(equippedWorldId: worldId);
    _persist();
  }

  // ── Tutorial ───────────────────────────────────────────────────────────────

  void completeTutorial() {
    state = state.copyWith(tutorialCompleted: true);
    _persist();
  }

  // ── Rank Points ────────────────────────────────────────────────────────────

  /// Awards rank points (from game results).
  void addRankPoints(int amount) {
    state = state.copyWith(rankPoints: state.rankPoints + amount);
    _persist();
  }

  // ── Prestige ───────────────────────────────────────────────────────────────

  /// Performs a prestige reset: resets coins/XP/streak, increments prestige.
  void prestige() {
    if (state.prestigeLevel >= 5) return;
    state = state.copyWith(
      prestigeLevel: state.prestigeLevel + 1,
      coins: 0,
      xp: 0,
      dailyStreak: 0,
      rankPoints: 0,
      tournamentAttemptsToday: 0,
      weeklyStepCompleted: 0,
    );
    _persist();
  }

  // ── Weekly Challenge ───────────────────────────────────────────────────────

  /// Advances the weekly step counter. Returns true if advanced.
  bool advanceWeeklyStep() {
    final currentWeek = _currentISOWeek();
    // Reset if new week
    if (state.weeklyResetWeek != currentWeek) {
      state = state.copyWith(
        weeklyStepCompleted: 0,
        weeklyResetWeek: currentWeek,
      );
    }
    state = state.copyWith(
        weeklyStepCompleted: state.weeklyStepCompleted + 1);
    _persist();
    return true;
  }

  int _currentISOWeek() {
    final now = DateTime.now();
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    return ((dayOfYear - now.weekday + 10) / 7).floor();
  }

  // ── Tournament ─────────────────────────────────────────────────────────────

  /// Uses a tournament attempt. Returns true if successful.
  bool useTournamentAttempt() {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    if (state.lastTournamentDay != today) {
      state = state.copyWith(
        tournamentAttemptsToday: 1,
        lastTournamentDay: today,
      );
    } else {
      state = state.copyWith(
          tournamentAttemptsToday: state.tournamentAttemptsToday + 1);
    }
    _persist();
    return true;
  }

  // ── Comeback Reward ────────────────────────────────────────────────────────

  void claimComebackReward(int coins, int xp) {
    state = state.copyWith(comebackRewardClaimed: true);
    addCoins(coins);
    addXp(xp);
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  void trackSession() {
    state = state.copyWith(
        analyticsSessionCount: state.analyticsSessionCount + 1);
    _persist();
  }

  // ── Last Game Mode ─────────────────────────────────────────────────────────

  void setLastGameMode(String mode) {
    state = state.copyWith(lastGameMode: mode);
    _persist();
  }

  // ── Title progression ──────────────────────────────────────────────────────

  void _updateTitle() {
    final lvl = state.level;
    String title;
    if (lvl >= 50) {
      title = 'Snake God';
    } else if (lvl >= 40) {
      title = 'Snake Legend';
    } else if (lvl >= 30) {
      title = 'Snake Master';
    } else if (lvl >= 20) {
      title = 'Snake Champion';
    } else if (lvl >= 15) {
      title = 'Snake Veteran';
    } else if (lvl >= 10) {
      title = 'Snake Expert';
    } else if (lvl >= 5) {
      title = 'Snake Apprentice';
    } else {
      title = 'Snake Rookie';
    }
    if (title != state.playerTitle) {
      state = state.copyWith(playerTitle: title);
    }
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  void _persist() {
    _storage.prefs.setString(_kProfileKey, jsonEncode(state.toMap()));
  }
}

/// Riverpod provider for the player profile.
final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfile>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PlayerProfileNotifier(storage);
});
