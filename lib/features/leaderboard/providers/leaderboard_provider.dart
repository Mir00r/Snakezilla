import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../shared/services/storage_service.dart';
import '../models/leaderboard_entry.dart';

/// Manages the local leaderboard with persistence.
///
/// Entries are kept sorted by descending score and trimmed to
/// [GameConstants.maxLeaderboardEntries].
class LeaderboardNotifier extends StateNotifier<List<LeaderboardEntry>> {
  final StorageService _storage;

  LeaderboardNotifier(this._storage) : super(_storage.loadLeaderboard());

  /// Inserts a new entry, re-sorts, trims, and persists.
  Future<void> addEntry(LeaderboardEntry entry) async {
    final updated = [...state, entry]
      ..sort((a, b) => b.score.compareTo(a.score));

    state = updated.length > GameConstants.maxLeaderboardEntries
        ? updated.sublist(0, GameConstants.maxLeaderboardEntries)
        : updated;

    await _storage.saveLeaderboard(state);
  }

  /// Clears all leaderboard data from memory and disk.
  Future<void> clear() async {
    state = [];
    await _storage.clearLeaderboard();
  }
}

/// Riverpod provider for the leaderboard entry list.
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, List<LeaderboardEntry>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LeaderboardNotifier(storage);
});
