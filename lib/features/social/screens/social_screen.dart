import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/social.dart';

/// Friends & Social hub with friend list, activity feed, and gift sending.
class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<GameFriend> _friends;
  late List<ActivityEntry> _feed;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _friends = SocialData.generateFriends(10);
    _feed = SocialData.generateFeed(_friends);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.neonGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'SOCIAL',
                        fontSize: 14,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.neonPurple,
                labelColor: AppColors.neonPurple,
                unselectedLabelColor: Colors.white38,
                labelStyle:
                    GoogleFonts.pressStart2p(fontSize: 7),
                tabs: const [
                  Tab(text: 'FRIENDS'),
                  Tab(text: 'FEED'),
                  Tab(text: 'GIFTS'),
                ],
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _FriendsTab(friends: _friends),
                    _FeedTab(feed: _feed),
                    _GiftsTab(friends: _friends),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Friends Tab ──────────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  final List<GameFriend> friends;
  const _FriendsTab({required this.friends});

  @override
  Widget build(BuildContext context) {
    final online = friends.where((f) => f.isOnline).toList();
    final offline = friends.where((f) => !f.isOnline).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (online.isNotEmpty) ...[
          Text(
            'ONLINE (${online.length})',
            style: GoogleFonts.pressStart2p(
                fontSize: 7, color: AppColors.neonGreen),
          ),
          const SizedBox(height: 8),
          ...online.map((f) => _FriendTile(friend: f, isOnline: true)),
          const SizedBox(height: 16),
        ],
        Text(
          'OFFLINE (${offline.length})',
          style: GoogleFonts.pressStart2p(
              fontSize: 7, color: Colors.white38),
        ),
        const SizedBox(height: 8),
        ...offline.map((f) => _FriendTile(friend: f, isOnline: false)),
      ],
    );
  }
}

class _FriendTile extends StatelessWidget {
  final GameFriend friend;
  final bool isOnline;

  const _FriendTile({required this.friend, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: isOnline
              ? AppColors.neonGreen.withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Text(friend.emoji, style: const TextStyle(fontSize: 28)),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonGreen,
                      border: Border.all(
                          color: const Color(0xFF1A1A2E), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      friend.name,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(friend.rankEmoji,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Lv.${friend.level} · High: ${friend.highScore}',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          // Challenge button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⚔️ Challenge sent to ${friend.name}!',
                    style: GoogleFonts.pressStart2p(fontSize: 7),
                  ),
                  backgroundColor: const Color(0xFF1A1A2E),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: AppColors.neonOrange.withValues(alpha: 0.5)),
              ),
              child: Text(
                '⚔️',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feed Tab ─────────────────────────────────────────────────────────────────

class _FeedTab extends StatelessWidget {
  final List<ActivityEntry> feed;
  const _FeedTab({required this.feed});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feed.length,
      itemBuilder: (context, index) {
        final entry = feed[index];
        final ago = DateTime.now().difference(entry.time);
        String timeStr;
        if (ago.inMinutes < 60) {
          timeStr = '${ago.inMinutes}m ago';
        } else {
          timeStr = '${ago.inHours}h ago';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.friendEmoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.pressStart2p(
                            fontSize: 7, color: Colors.white70),
                        children: [
                          TextSpan(
                            text: entry.friendName,
                            style: const TextStyle(
                                color: AppColors.neonPurple),
                          ),
                          TextSpan(text: ' ${entry.action} '),
                          TextSpan(
                            text: entry.detail,
                            style: const TextStyle(
                                color: AppColors.neonYellow),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: GoogleFonts.pressStart2p(
                          fontSize: 6, color: Colors.white30),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Gifts Tab ────────────────────────────────────────────────────────────────

class _GiftsTab extends ConsumerWidget {
  final List<GameFriend> friends;
  const _GiftsTab({required this.friends});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'SEND A GIFT',
          style: GoogleFonts.pressStart2p(
              fontSize: 8, color: Colors.white54),
        ),
        const SizedBox(height: 12),
        ...SocialData.gifts.map((gift) {
          final canAfford = profile.coins >= gift.cost;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: canAfford
                    ? AppColors.neonYellow.withValues(alpha: 0.3)
                    : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Text(gift.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.name,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cost: ${gift.cost} coins',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: canAfford
                      ? () {
                          ref
                              .read(playerProfileProvider.notifier)
                              .spendCoins(gift.cost);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${gift.emoji} Sent ${gift.name} to a friend!',
                                style:
                                    GoogleFonts.pressStart2p(fontSize: 7),
                              ),
                              backgroundColor: const Color(0xFF1A1A2E),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: canAfford
                          ? AppColors.neonGreen.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: canAfford
                            ? AppColors.neonGreen
                            : Colors.white24,
                      ),
                    ),
                    child: Text(
                      'SEND',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: canAfford
                            ? AppColors.neonGreen
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
        // Incoming gifts (simulated)
        Text(
          'INCOMING GIFTS',
          style: GoogleFonts.pressStart2p(
              fontSize: 8, color: Colors.white54),
        ),
        const SizedBox(height: 12),
        _IncomingGift(
          fromName: friends.isNotEmpty ? friends.first.name : 'Player',
          giftEmoji: '💰',
          giftName: '50 Coins',
          onClaim: () {
            ref.read(playerProfileProvider.notifier).addCoins(50);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '💰 Claimed 50 coins!',
                  style: GoogleFonts.pressStart2p(fontSize: 7),
                ),
                backgroundColor: const Color(0xFF1A1A2E),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _IncomingGift extends StatelessWidget {
  final String fromName;
  final String giftEmoji;
  final String giftName;
  final VoidCallback onClaim;

  const _IncomingGift({
    required this.fromName,
    required this.giftEmoji,
    required this.giftName,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.neonYellow.withValues(alpha: 0.3),
      child: Row(
        children: [
          Text(giftEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  giftName,
                  style: GoogleFonts.pressStart2p(
                      fontSize: 8, color: AppColors.neonYellow),
                ),
                Text(
                  'From $fromName',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 6, color: Colors.white38),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClaim,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [AppColors.neonYellow, AppColors.neonOrange],
                ),
              ),
              child: Text(
                'CLAIM',
                style: GoogleFonts.pressStart2p(
                    fontSize: 7, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
