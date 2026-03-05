/// Immutable player profile holding economy, progression, and stats data.
///
/// Persisted via [StorageService] as a JSON map.
class PlayerProfile {
  /// In-game currency balance.
  final int coins;

  /// Total experience points earned.
  final int xp;

  /// Derived player level (100 XP per level).
  int get level => (xp / 100).floor() + 1;

  /// XP progress within the current level (0–99).
  int get xpInLevel => xp % 100;

  /// Total number of games played.
  final int totalGames;

  /// Cumulative score across all games.
  final int totalScore;

  /// All-time highest combo streak.
  final int highestCombo;

  /// Longest snake length ever achieved.
  final int longestSnake;

  /// Number of AI battles won.
  final int aiWins;

  /// IDs of unlocked achievements.
  final Set<String> unlockedAchievements;

  /// IDs of purchased / unlocked skins.
  final Set<String> unlockedSkins;

  /// ID of the currently equipped skin.
  final String equippedSkinId;

  /// Day index of the last daily reward claim (days since epoch).
  final int lastDailyRewardDay;

  // ── New fields ───────────────────────────────────────────────────────────

  /// Current consecutive daily-login streak.
  final int dailyStreak;

  /// Day index of the last spin-wheel spin.
  final int lastSpinDay;

  /// IDs of unlocked companion pets.
  final Set<String> unlockedPets;

  /// ID of the currently equipped pet (null = none).
  final String? equippedPetId;

  /// Display title below player name.
  final String playerTitle;

  /// Lifetime coins earned (never decreases).
  final int totalCoinsEarned;

  /// IDs of unlocked game worlds.
  final Set<String> unlockedWorlds;

  /// ID of the currently equipped world theme.
  final String equippedWorldId;

  /// Whether the tutorial has been completed.
  final bool tutorialCompleted;

  // ── Phase 4: Viral Growth & Retention ─────────────────────────────────────

  /// Rank points for competitive league.
  final int rankPoints;

  /// Prestige level (0 = not prestiged).
  final int prestigeLevel;

  /// Current weekly challenge step completed (0-based).
  final int weeklyStepCompleted;

  /// ISO week number when weekly step was last reset.
  final int weeklyResetWeek;

  /// Tournament attempts used today.
  final int tournamentAttemptsToday;

  /// Day index of last tournament attempt.
  final int lastTournamentDay;

  /// Whether a comeback reward has been claimed this session.
  final bool comebackRewardClaimed;

  /// Total sessions tracked for analytics.
  final int analyticsSessionCount;

  /// Last game mode played (for retention AI recommendations).
  final String lastGameMode;

  const PlayerProfile({
    this.coins = 0,
    this.xp = 0,
    this.totalGames = 0,
    this.totalScore = 0,
    this.highestCombo = 0,
    this.longestSnake = 0,
    this.aiWins = 0,
    this.unlockedAchievements = const {},
    this.unlockedSkins = const {'neon'},
    this.equippedSkinId = 'neon',
    this.lastDailyRewardDay = 0,
    this.dailyStreak = 0,
    this.lastSpinDay = 0,
    this.unlockedPets = const {'robot_drone'},
    this.equippedPetId,
    this.playerTitle = 'Snake Rookie',
    this.totalCoinsEarned = 0,
    this.unlockedWorlds = const {'neon_city'},
    this.equippedWorldId = 'neon_city',
    this.tutorialCompleted = false,
    this.rankPoints = 0,
    this.prestigeLevel = 0,
    this.weeklyStepCompleted = 0,
    this.weeklyResetWeek = 0,
    this.tournamentAttemptsToday = 0,
    this.lastTournamentDay = 0,
    this.comebackRewardClaimed = false,
    this.analyticsSessionCount = 0,
    this.lastGameMode = 'classic',
  });

  PlayerProfile copyWith({
    int? coins,
    int? xp,
    int? totalGames,
    int? totalScore,
    int? highestCombo,
    int? longestSnake,
    int? aiWins,
    Set<String>? unlockedAchievements,
    Set<String>? unlockedSkins,
    String? equippedSkinId,
    int? lastDailyRewardDay,
    int? dailyStreak,
    int? lastSpinDay,
    Set<String>? unlockedPets,
    String? equippedPetId,
    String? playerTitle,
    int? totalCoinsEarned,
    Set<String>? unlockedWorlds,
    String? equippedWorldId,
    bool? tutorialCompleted,
    int? rankPoints,
    int? prestigeLevel,
    int? weeklyStepCompleted,
    int? weeklyResetWeek,
    int? tournamentAttemptsToday,
    int? lastTournamentDay,
    bool? comebackRewardClaimed,
    int? analyticsSessionCount,
    String? lastGameMode,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      highestCombo: highestCombo ?? this.highestCombo,
      longestSnake: longestSnake ?? this.longestSnake,
      aiWins: aiWins ?? this.aiWins,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      equippedSkinId: equippedSkinId ?? this.equippedSkinId,
      lastDailyRewardDay: lastDailyRewardDay ?? this.lastDailyRewardDay,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastSpinDay: lastSpinDay ?? this.lastSpinDay,
      unlockedPets: unlockedPets ?? this.unlockedPets,
      equippedPetId: equippedPetId ?? this.equippedPetId,
      playerTitle: playerTitle ?? this.playerTitle,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,
      equippedWorldId: equippedWorldId ?? this.equippedWorldId,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      rankPoints: rankPoints ?? this.rankPoints,
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      weeklyStepCompleted: weeklyStepCompleted ?? this.weeklyStepCompleted,
      weeklyResetWeek: weeklyResetWeek ?? this.weeklyResetWeek,
      tournamentAttemptsToday:
          tournamentAttemptsToday ?? this.tournamentAttemptsToday,
      lastTournamentDay: lastTournamentDay ?? this.lastTournamentDay,
      comebackRewardClaimed:
          comebackRewardClaimed ?? this.comebackRewardClaimed,
      analyticsSessionCount:
          analyticsSessionCount ?? this.analyticsSessionCount,
      lastGameMode: lastGameMode ?? this.lastGameMode,
    );
  }

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'coins': coins,
        'xp': xp,
        'totalGames': totalGames,
        'totalScore': totalScore,
        'highestCombo': highestCombo,
        'longestSnake': longestSnake,
        'aiWins': aiWins,
        'unlockedAchievements': unlockedAchievements.toList(),
        'unlockedSkins': unlockedSkins.toList(),
        'equippedSkinId': equippedSkinId,
        'lastDailyRewardDay': lastDailyRewardDay,
        'dailyStreak': dailyStreak,
        'lastSpinDay': lastSpinDay,
        'unlockedPets': unlockedPets.toList(),
        'equippedPetId': equippedPetId,
        'playerTitle': playerTitle,
        'totalCoinsEarned': totalCoinsEarned,
        'unlockedWorlds': unlockedWorlds.toList(),
        'equippedWorldId': equippedWorldId,
        'tutorialCompleted': tutorialCompleted,
        'rankPoints': rankPoints,
        'prestigeLevel': prestigeLevel,
        'weeklyStepCompleted': weeklyStepCompleted,
        'weeklyResetWeek': weeklyResetWeek,
        'tournamentAttemptsToday': tournamentAttemptsToday,
        'lastTournamentDay': lastTournamentDay,
        'comebackRewardClaimed': comebackRewardClaimed,
        'analyticsSessionCount': analyticsSessionCount,
        'lastGameMode': lastGameMode,
      };

  /// Deserialises from a stored map with safe defaults.
  factory PlayerProfile.fromMap(Map<String, dynamic> map) {
    return PlayerProfile(
      coins: map['coins'] as int? ?? 0,
      xp: map['xp'] as int? ?? 0,
      totalGames: map['totalGames'] as int? ?? 0,
      totalScore: map['totalScore'] as int? ?? 0,
      highestCombo: map['highestCombo'] as int? ?? 0,
      longestSnake: map['longestSnake'] as int? ?? 0,
      aiWins: map['aiWins'] as int? ?? 0,
      unlockedAchievements: (map['unlockedAchievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      unlockedSkins: (map['unlockedSkins'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {'neon'},
      equippedSkinId: map['equippedSkinId'] as String? ?? 'neon',
      lastDailyRewardDay: map['lastDailyRewardDay'] as int? ?? 0,
      dailyStreak: map['dailyStreak'] as int? ?? 0,
      lastSpinDay: map['lastSpinDay'] as int? ?? 0,
      unlockedPets: (map['unlockedPets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {'robot_drone'},
      equippedPetId: map['equippedPetId'] as String?,
      playerTitle: map['playerTitle'] as String? ?? 'Snake Rookie',
      totalCoinsEarned: map['totalCoinsEarned'] as int? ?? 0,
      unlockedWorlds: (map['unlockedWorlds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {'neon_city'},
      equippedWorldId: map['equippedWorldId'] as String? ?? 'neon_city',
      tutorialCompleted: map['tutorialCompleted'] as bool? ?? false,
      rankPoints: map['rankPoints'] as int? ?? 0,
      prestigeLevel: map['prestigeLevel'] as int? ?? 0,
      weeklyStepCompleted: map['weeklyStepCompleted'] as int? ?? 0,
      weeklyResetWeek: map['weeklyResetWeek'] as int? ?? 0,
      tournamentAttemptsToday:
          map['tournamentAttemptsToday'] as int? ?? 0,
      lastTournamentDay: map['lastTournamentDay'] as int? ?? 0,
      comebackRewardClaimed:
          map['comebackRewardClaimed'] as bool? ?? false,
      analyticsSessionCount:
          map['analyticsSessionCount'] as int? ?? 0,
      lastGameMode: map['lastGameMode'] as String? ?? 'classic',
    );
  }
}
