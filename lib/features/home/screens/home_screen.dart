import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../game/screens/game_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../settings/screens/settings_screen.dart';

/// Landing screen with the Snakezilla main menu.
///
/// Provides animated menu buttons for Play, Leaderboard, and Settings.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                  const SizedBox(height: 8),
                  const Text('🐍', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 48),

                  // ── Menu buttons ───────────────────────────────────────
                  _MenuButton(
                    label: 'PLAY',
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.neonGreen,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const GameScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: 'LEADERBOARD',
                    icon: Icons.leaderboard_rounded,
                    color: AppColors.neonYellow,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
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
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          borderColor: widget.color.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(width: 16),
              Text(
                widget.label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 14,
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
