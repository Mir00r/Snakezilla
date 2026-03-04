import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/storage_service.dart';
import '../../achievements/models/achievement.dart';
import '../../skins/models/snake_skin.dart';
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
    state = state.copyWith(coins: state.coins + amount);
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
