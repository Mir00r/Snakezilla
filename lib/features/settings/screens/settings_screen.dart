import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';

/// Settings screen for configuring game preferences.
///
/// All changes are persisted automatically via [SettingsNotifier].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
                        text: 'SETTINGS',
                        fontSize: 18,
                        color: AppColors.neonBlue,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Body ──────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.volume_up,
                        label: 'Sound Effects',
                        trailing: Switch(
                          value: settings.soundEnabled,
                          onChanged: (_) => notifier.toggleSound(),
                          activeColor: AppColors.neonGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.music_note,
                        label: 'Music',
                        trailing: Switch(
                          value: settings.musicEnabled,
                          onChanged: (_) => notifier.toggleMusic(),
                          activeColor: AppColors.neonGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.dark_mode,
                        label: 'Dark Mode',
                        trailing: Switch(
                          value: settings.darkMode,
                          onChanged: (_) => notifier.toggleDarkMode(),
                          activeColor: AppColors.neonGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.all_inclusive,
                        label: 'Boundary Wrap',
                        trailing: Switch(
                          value: settings.boundaryWrap,
                          onChanged: (_) => notifier.toggleBoundaryWrap(),
                          activeColor: AppColors.neonGreen,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Difficulty selector
                      _DifficultySelector(
                        current: settings.difficulty,
                        onChanged: notifier.setDifficulty,
                      ),
                      const SizedBox(height: 24),

                      // Reset leaderboard
                      _ResetLeaderboardButton(ref: ref),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final Difficulty current;
  final ValueChanged<Difficulty> onChanged;

  const _DifficultySelector({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIFFICULTY',
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: AppColors.neonBlue,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Difficulty.values.map((d) {
              final isSelected = current == d;
              return GestureDetector(
                onTap: () => onChanged(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? AppColors.neonGreen.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.neonGreen : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    d.label,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color:
                          isSelected ? AppColors.neonGreen : Colors.white54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ResetLeaderboardButton extends StatelessWidget {
  final WidgetRef ref;

  const _ResetLeaderboardButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.darkCard,
            title: const Text('Reset Leaderboard?',
                style: TextStyle(color: Colors.white)),
            content: const Text(
              'This will permanently delete all saved scores.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Reset',
                    style: TextStyle(color: AppColors.neonPink)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          ref.read(leaderboardProvider.notifier).clear();
        }
      },
      child: GlassContainer(
        borderColor: AppColors.neonPink.withOpacity(0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline,
                color: AppColors.neonPink.withOpacity(0.8), size: 20),
            const SizedBox(width: 12),
            Text(
              'RESET LEADERBOARD',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: AppColors.neonPink.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
