import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../models/game_mode.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

/// Screen for selecting a game mode before starting play.
///
/// Each mode card shows an icon, title, and description with a
/// neon-bordered glass container and entrance animation.
class ModeSelectScreen extends ConsumerStatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  ConsumerState<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends ConsumerState<ModeSelectScreen> {
  TimeAttackDuration _selectedDuration = TimeAttackDuration.short60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.neonGreen),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'SELECT MODE',
                        fontSize: 16,
                        color: AppColors.neonGreen,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Mode cards ─────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: GameMode.values.length,
                  itemBuilder: (context, index) {
                    final mode = GameMode.values[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + index * 120),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ModeCard(
                          mode: mode,
                          selectedDuration: _selectedDuration,
                          onDurationChanged: (d) {
                            setState(() => _selectedDuration = d);
                          },
                          onTap: () => _launchGame(mode),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchGame(GameMode mode) {
    // Set launch configuration.
    ref.read(gameLaunchConfigProvider.notifier).state = GameLaunchConfig(
      mode: mode,
      timeAttackSeconds: _selectedDuration.seconds,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

// ── Mode Card ────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final GameMode mode;
  final TimeAttackDuration selectedDuration;
  final ValueChanged<TimeAttackDuration> onDurationChanged;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.onTap,
  });

  Color get _accentColor {
    switch (mode) {
      case GameMode.classic:
        return AppColors.neonGreen;
      case GameMode.timeAttack:
        return AppColors.neonBlue;
      case GameMode.survival:
        return AppColors.neonOrange;
      case GameMode.aiBattle:
        return AppColors.neonPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderColor: _accentColor.withOpacity(0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mode.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeonText(
                        text: mode.label.toUpperCase(),
                        fontSize: 14,
                        color: _accentColor,
                        glowRadius: 10,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mode.description,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: _accentColor.withOpacity(0.5), size: 18),
              ],
            ),

            // Time Attack duration picker
            if (mode == GameMode.timeAttack) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: TimeAttackDuration.values.map((d) {
                  final isSelected = d == selectedDuration;
                  return GestureDetector(
                    onTap: () => onDurationChanged(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? _accentColor.withOpacity(0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? _accentColor
                              : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        d.label,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 9,
                          color: isSelected ? _accentColor : Colors.white54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
