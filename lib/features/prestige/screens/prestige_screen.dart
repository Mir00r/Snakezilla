import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/prestige.dart';

/// Prestige reset screen showing current multipliers, preview of next tier,
/// and confirmation workflow.
class PrestigeScreen extends ConsumerWidget {
  const PrestigeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final currentPrestige = profile.prestigeLevel;
    final tier = PrestigeSystem.tierFor(currentPrestige);
    final nextTier = currentPrestige < PrestigeSystem.tiers.length - 1
        ? PrestigeSystem.tiers[currentPrestige + 1]
        : null;
    final canPrestige =
        PrestigeSystem.canPrestige(profile.level, currentPrestige);

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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: NeonText(
                        text: 'PRESTIGE',
                        fontSize: 14,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Current prestige badge
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) =>
                            Transform.scale(scale: 0.5 + 0.5 * value, child: child),
                        child: Column(
                          children: [
                            Text(tier.emoji,
                                style: const TextStyle(fontSize: 60)),
                            const SizedBox(height: 8),
                            NeonText(
                              text: tier.title.toUpperCase(),
                              fontSize: 12,
                              color: tier.color,
                              glowRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Current multipliers
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderColor: tier.color.withValues(alpha: 0.3),
                        child: Column(
                          children: [
                            Text(
                              'CURRENT BONUSES',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                _MultiplierBadge(
                                  label: 'COINS',
                                  value: '${tier.coinMultiplier}x',
                                  color: AppColors.neonYellow,
                                ),
                                _MultiplierBadge(
                                  label: 'XP',
                                  value: '${tier.xpMultiplier}x',
                                  color: AppColors.neonBlue,
                                ),
                              ],
                            ),
                            if (tier.specialReward.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                '🎁 ${tier.specialReward}',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 7,
                                  color: tier.color,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Next prestige preview
                      if (nextTier != null) ...[
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderColor: nextTier.color.withValues(alpha: 0.3),
                          child: Column(
                            children: [
                              Text(
                                'NEXT PRESTIGE',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 8,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(nextTier.emoji,
                                  style: const TextStyle(fontSize: 36)),
                              const SizedBox(height: 8),
                              Text(
                                nextTier.title,
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 9,
                                  color: nextTier.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _MultiplierBadge(
                                    label: 'COINS',
                                    value: '${nextTier.coinMultiplier}x',
                                    color: AppColors.neonYellow,
                                  ),
                                  _MultiplierBadge(
                                    label: 'XP',
                                    value: '${nextTier.xpMultiplier}x',
                                    color: AppColors.neonBlue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '🎁 ${nextTier.specialReward}',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 7,
                                  color: nextTier.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // What you keep / lose
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _InfoBox(
                              title: 'YOU KEEP',
                              emoji: '✅',
                              items: PrestigeSystem.keptOnPrestige,
                              color: AppColors.neonGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoBox(
                              title: 'YOU LOSE',
                              emoji: '❌',
                              items: PrestigeSystem.lostOnPrestige,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Prestige button
                      if (nextTier != null)
                        GestureDetector(
                          onTap: canPrestige
                              ? () => _confirmPrestige(context, ref)
                              : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: canPrestige
                                  ? LinearGradient(
                                      colors: [
                                        nextTier.color,
                                        nextTier.color.withValues(alpha: 0.6),
                                      ],
                                    )
                                  : null,
                              color: canPrestige
                                  ? null
                                  : Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: canPrestige
                                    ? nextTier.color
                                    : Colors.white24,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                canPrestige
                                    ? 'PRESTIGE NOW ${nextTier.emoji}'
                                    : 'REACH LEVEL ${PrestigeSystem.minLevelToPrestige}',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 9,
                                  color: canPrestige
                                      ? Colors.black
                                      : Colors.white38,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // All prestige tiers
                      Text(
                        'ALL PRESTIGE TIERS',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...PrestigeSystem.tiers.skip(1).map((t) {
                        final isUnlocked = currentPrestige >= t.level;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isUnlocked
                                ? t.color.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.02),
                            border: Border.all(
                              color: isUnlocked
                                  ? t.color.withValues(alpha: 0.3)
                                  : Colors.white10,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(t.emoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 7,
                                        color: isUnlocked
                                            ? t.color
                                            : Colors.white30,
                                      ),
                                    ),
                                    Text(
                                      '${t.coinMultiplier}x coins · ${t.xpMultiplier}x XP',
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 6,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUnlocked)
                                Icon(Icons.check_circle,
                                    color: t.color, size: 18)
                              else
                                const Icon(Icons.lock_outline,
                                    color: Colors.white24, size: 18),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
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

  void _confirmPrestige(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          '⚡ PRESTIGE UP?',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: AppColors.neonPurple,
          ),
        ),
        content: Text(
          'Your level & coins will reset, but you\'ll earn permanent multiplier boosts!',
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.pressStart2p(
                  fontSize: 7, color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(playerProfileProvider.notifier).prestige();
              Navigator.pop(ctx);
            },
            child: Text(
              'PRESTIGE! ✨',
              style: GoogleFonts.pressStart2p(
                  fontSize: 7, color: AppColors.neonPurple),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ───────────────────────────────────────────────────────────

class _MultiplierBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MultiplierBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(fontSize: 6, color: Colors.white38),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: GoogleFonts.pressStart2p(fontSize: 10, color: color),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String emoji;
  final List<String> items;
  final Color color;

  const _InfoBox({
    required this.title,
    required this.emoji,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $title',
            style: GoogleFonts.pressStart2p(fontSize: 7, color: color),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $item',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 6, color: Colors.white54),
                ),
              )),
        ],
      ),
    );
  }
}
