import 'dart:math';

/// Represents a friend (simulated locally - no backend).
class GameFriend {
  final String id;
  final String name;
  final String emoji;
  final int highScore;
  final int level;
  final String rankEmoji;
  final bool isOnline;
  final DateTime lastActive;

  const GameFriend({
    required this.id,
    required this.name,
    required this.emoji,
    required this.highScore,
    required this.level,
    required this.rankEmoji,
    required this.isOnline,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'highScore': highScore,
        'level': level,
        'rankEmoji': rankEmoji,
        'isOnline': isOnline,
        'lastActive': lastActive.millisecondsSinceEpoch,
      };

  factory GameFriend.fromMap(Map<String, dynamic> map) => GameFriend(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] as String? ?? '🐍',
        highScore: map['highScore'] as int? ?? 0,
        level: map['level'] as int? ?? 1,
        rankEmoji: map['rankEmoji'] as String? ?? '🥉',
        isOnline: map['isOnline'] as bool? ?? false,
        lastActive: DateTime.fromMillisecondsSinceEpoch(
            map['lastActive'] as int? ?? 0),
      );
}

/// Gift item that players can send to friends.
class GiftItem {
  final String id;
  final String name;
  final String emoji;
  final String type; // 'coins', 'xp', 'skin_fragment', 'mystery_box'
  final int value;
  final int cost; // cost to send

  const GiftItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.value,
    required this.cost,
  });
}

/// Activity feed entry.
class ActivityEntry {
  final String friendName;
  final String friendEmoji;
  final String action;
  final String detail;
  final DateTime time;

  const ActivityEntry({
    required this.friendName,
    required this.friendEmoji,
    required this.action,
    required this.detail,
    required this.time,
  });
}

/// Simulated social data for local play.
class SocialData {
  static final _random = Random();

  static const _names = [
    'SnakeKing',
    'NeonSlither',
    'CobraVenom',
    'VyperStrike',
    'ScaleHunter',
    'FangBoss',
    'RattleStar',
    'SerpentLord',
    'AdderPro',
    'MambaMax',
    'PythonPete',
    'BoaBlaster',
    'SideWinder',
    'KingCobra',
    'GreenMamba',
  ];

  static const _emojis = [
    '🐍', '🐉', '🦎', '🐊', '🦕', '🐢', '🐲', '🦖',
  ];

  static const _rankEmojis = ['🥉', '🥈', '🥇', '💎', '💠', '👑'];

  /// Generate a list of fake friends for local simulation.
  static List<GameFriend> generateFriends(int count) {
    final shuffled = List.of(_names)..shuffle(_random);
    return List.generate(min(count, shuffled.length), (i) {
      final level = _random.nextInt(40) + 1;
      final rankIdx = (level / 10).floor().clamp(0, _rankEmojis.length - 1);
      return GameFriend(
        id: 'friend_$i',
        name: shuffled[i],
        emoji: _emojis[_random.nextInt(_emojis.length)],
        highScore: _random.nextInt(3000) + 100,
        level: level,
        rankEmoji: _rankEmojis[rankIdx],
        isOnline: _random.nextBool(),
        lastActive: DateTime.now().subtract(
          Duration(minutes: _random.nextInt(1440)),
        ),
      );
    });
  }

  /// Generate fake activity feed.
  static List<ActivityEntry> generateFeed(List<GameFriend> friends) {
    final actions = [
      ('scored', () => '${_random.nextInt(2000) + 100} points'),
      ('reached', () => 'Level ${_random.nextInt(30) + 1}'),
      ('unlocked', () => 'a new skin'),
      ('won', () => 'a tournament match'),
      ('completed', () => 'a weekly challenge'),
      ('prestiged', () => 'to tier ${_random.nextInt(3) + 1}'),
      ('defeated', () => '${_random.nextInt(8) + 1} AI snakes'),
    ];

    final feed = <ActivityEntry>[];
    for (int i = 0; i < min(10, friends.length * 2); i++) {
      final friend = friends[_random.nextInt(friends.length)];
      final action = actions[_random.nextInt(actions.length)];
      feed.add(ActivityEntry(
        friendName: friend.name,
        friendEmoji: friend.emoji,
        action: action.$1,
        detail: action.$2(),
        time: DateTime.now().subtract(
          Duration(minutes: _random.nextInt(720)),
        ),
      ));
    }
    feed.sort((a, b) => b.time.compareTo(a.time));
    return feed;
  }

  /// Available gifts to send.
  static const List<GiftItem> gifts = [
    GiftItem(
      id: 'gift_coins_50',
      name: '50 Coins',
      emoji: '💰',
      type: 'coins',
      value: 50,
      cost: 25,
    ),
    GiftItem(
      id: 'gift_coins_200',
      name: '200 Coins',
      emoji: '💎',
      type: 'coins',
      value: 200,
      cost: 100,
    ),
    GiftItem(
      id: 'gift_xp_100',
      name: '100 XP Boost',
      emoji: '⚡',
      type: 'xp',
      value: 100,
      cost: 50,
    ),
    GiftItem(
      id: 'gift_mystery',
      name: 'Mystery Box',
      emoji: '🎁',
      type: 'mystery_box',
      value: 1,
      cost: 75,
    ),
  ];
}
