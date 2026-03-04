import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../achievements/screens/achievements_screen.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../../game/screens/mode_select_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../skins/screens/skin_store_screen.dart';

/// Landing screen with the Snakezilla main menu.
///
/// Features:
/// * Neon title with snake emoji
/// * Player level / coin display
/// * Daily reward claim button
/// * Menu buttons: PLAY, SKINS, ACHIEVEMENTS, LEADERBOARD, SETTINGS
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Title ──────────────────────────────────────────────
                  const NeonText(
                    text: 'SNAKEZILLA',
                    fontSize: 28,
                    color: AppColors.neonGreen,
                    glowRadius: 30,
                  ),
                  const SizedBox(height: 6),
                  const Text('🐍', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),

                  // ── Player info bar ────────────────────────────────────
                  _PlayerInfoBar(
                    level: profile.level,
                    xpInLevel: profile.xpInLevel,
                    coins: profile.coins,
                  ),
                  const SizedBox(height: 12),

                  // ── Daily reward ───────────────────────────────────────
                  _DailyRewardButton(ref: ref),
                  const SizedBox(height: 20),

                  // ── Menu buttons ───────────────────────────────────────
                  _MenuButton(
                    label: 'PLAY',
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.neonGreen,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ModeSelectScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'SKINS',
                    icon: Icons.palette_rounded,
                    color: AppColors.neonPurple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SkinStoreScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'ACHIEVEMENTS',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.neonYellow,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AchievementsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'LEADERBOARD',
                    icon: Icons.leaderboard_rounded,
                    color: AppColors.neonOrange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_rounded,
                    color: AppColors.neonBlue,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Player Info Bar ──────────────────────────────────────────────────────────

class _PlayerInfoBar extends StatelessWidget {
  final int level;
  final int xpInLevel;
  final int coins;

  const _PlayerInfoBar({
    required this.level,
    required this.xpInLevel,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderColor: AppColors.neonGreen.withOpacity(0.2),
      child: Row(
        children: [
          // Level
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.neonGreen, width: 2),
              color: AppColors.neonGreen.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                '$level',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: AppColors.neonGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // XP progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEVEL $level',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: AppColors.neonGreen.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: xpInLevel / 100,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.neonGreen),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.neonYellow.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💰', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: AppColors.neonYellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Reward Button ──────────────────────────────────────────────────────

class _DailyRewardButton extends StatelessWidget {
  final WidgetRef ref;

  const _DailyRewardButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final profile = ref.watch(playerProfileProvider);
    final canClaim = profile.lastDailyRewardDay < today;

    return GestureDetector(
      onTap: canClaim
          ? () {
              ref.read(playerProfileProvider.notifier).claimDailyReward();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '💰 +50 coins claimed!',
                    style: GoogleFonts.pressStart2p(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: AppColors.darkCard,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : null,
      child: AnimatedOpacity(
        opacity: canClaim ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 300),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderColor: canClaim
              ? AppColors.neonYellow.withOpacity(0.4)
              : Colors.white12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(
                canClaim ? 'CLAIM DAILY REWARD' : 'CLAIMED TODAY',
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: canClaim
                      ? AppColors.neonYellow
                      : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu button with press animation ─────────────────────────────────────────

class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GlassContainer(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          borderColor: widget.color.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 24),
              const SizedBox(width: 14),
              Text(
                widget.label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 11,
                  color: widget.color,
                  shadows: [
                    Shadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 10,
                    ),
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
