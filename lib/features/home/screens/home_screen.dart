import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../../shared/widgets/tutorial_overlay.dart';
import '../../achievements/screens/achievements_screen.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../../economy/screens/daily_missions_screen.dart';
import '../../economy/screens/daily_reward_screen.dart';
import '../../economy/screens/spin_wheel_screen.dart';
import '../../economy/screens/stats_screen.dart';
import '../../events/screens/events_screen.dart';
import '../../game/screens/mini_games_screen.dart';
import '../../game/screens/mode_select_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../pets/screens/pet_store_screen.dart';
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

    // Show tutorial for first-time players
    if (!profile.tutorialCompleted) {
      return TutorialOverlay(
        onComplete: () {
          ref.read(playerProfileProvider.notifier).completeTutorial();
        },
      );
    }

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

                  // ── Daily reward + Spin row ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _CompactButton(
                          emoji: '🎁',
                          label: 'REWARDS',
                          color: AppColors.neonYellow,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const DailyRewardScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CompactButton(
                          emoji: '🎰',
                          label: 'SPIN',
                          color: AppColors.neonPurple,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SpinWheelScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Main PLAY button ───────────────────────────────────
                  _MenuButton(
                    label: 'PLAY',
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.neonGreen,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ModeSelectScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Mini Games ────────────────────────────────────────
                  _MenuButton(
                    label: 'MINI GAMES',
                    icon: Icons.sports_esports_rounded,
                    color: AppColors.neonOrange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MiniGamesScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Missions ──────────────────────────────────────────
                  _MenuButton(
                    label: 'MISSIONS',
                    icon: Icons.assignment_rounded,
                    color: AppColors.neonOrange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DailyMissionsScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Second row: Pets + Events ──────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _CompactMenuButton(
                          label: 'PETS',
                          icon: Icons.pets_rounded,
                          color: const Color(0xFFFF6B9D),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PetStoreScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CompactMenuButton(
                          label: 'EVENTS',
                          icon: Icons.celebration_rounded,
                          color: const Color(0xFF00E5FF),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const EventsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Third row: Skins + Stats ──────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _CompactMenuButton(
                          label: 'SKINS',
                          icon: Icons.palette_rounded,
                          color: AppColors.neonPurple,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SkinStoreScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CompactMenuButton(
                          label: 'STATS',
                          icon: Icons.bar_chart_rounded,
                          color: const Color(0xFF64FFDA),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const StatsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Fourth row: Achievements + Leaderboard ────────────
                  Row(
                    children: [
                      Expanded(
                        child: _CompactMenuButton(
                          label: 'TROPHIES',
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.neonYellow,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AchievementsScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CompactMenuButton(
                          label: 'RANKS',
                          icon: Icons.leaderboard_rounded,
                          color: AppColors.neonOrange,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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

// ── Compact Button (emoji + label) ───────────────────────────────────────────

class _CompactButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderColor: color.withValues(alpha: 0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact Menu Button (icon + label, for side-by-side layout) ──────────────

class _CompactMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactMenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        borderColor: color.withValues(alpha: 0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
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
