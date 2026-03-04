import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/snake_skin.dart';

/// Skin store screen for browsing, purchasing, and equipping snake skins.
///
/// Shows a grid of skin cards, each with a preview of the head/body/tail
/// colours, the price, and buy/equip action.
class SkinStoreScreen extends ConsumerWidget {
  const SkinStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final notifier = ref.read(playerProfileProvider.notifier);

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
                        text: 'SKINS',
                        fontSize: 18,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    // Coin balance
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonYellow.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            '${profile.coins}',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 10,
                              color: AppColors.neonYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Skin Grid ──────────────────────────────────────────────
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: SnakeSkins.all.length,
                  itemBuilder: (context, index) {
                    final skin = SnakeSkins.all[index];
                    final isOwned =
                        profile.unlockedSkins.contains(skin.id);
                    final isEquipped = profile.equippedSkinId == skin.id;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 300 + index * 100),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + value * 0.2,
                            child: child,
                          ),
                        );
                      },
                      child: _SkinCard(
                        skin: skin,
                        isOwned: isOwned,
                        isEquipped: isEquipped,
                        canAfford: profile.coins >= skin.price,
                        onTap: () {
                          if (isEquipped) return;
                          if (isOwned) {
                            notifier.equipSkin(skin.id);
                            HapticFeedback.lightImpact();
                          } else {
                            _showPurchaseDialog(
                                context, ref, skin, profile.coins);
                          }
                        },
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

  void _showPurchaseDialog(
      BuildContext context, WidgetRef ref, SnakeSkin skin, int coins) {
    final canAfford = coins >= skin.price;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Purchase ${skin.name}?',
          style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SkinPreview(skin: skin, size: 60),
            const SizedBox(height: 12),
            Text(
              skin.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💰', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${skin.price}',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14,
                    color: canAfford
                        ? AppColors.neonYellow
                        : AppColors.neonPink,
                  ),
                ),
              ],
            ),
            if (!canAfford)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Not enough coins!',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 8, color: AppColors.neonPink),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.pressStart2p(
                  fontSize: 8, color: Colors.white54),
            ),
          ),
          if (canAfford)
            TextButton(
              onPressed: () {
                ref.read(playerProfileProvider.notifier).purchaseSkin(skin);
                ref.read(playerProfileProvider.notifier).equipSkin(skin.id);
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
              },
              child: Text(
                'BUY',
                style: GoogleFonts.pressStart2p(
                    fontSize: 8, color: AppColors.neonGreen),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Skin Card ────────────────────────────────────────────────────────────────

class _SkinCard extends StatelessWidget {
  final SnakeSkin skin;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isEquipped
        ? AppColors.neonGreen
        : isOwned
            ? skin.glowColor.withOpacity(0.4)
            : Colors.white24;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderColor: borderColor,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Badge
            Text(skin.badge, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),

            // Snake preview
            _SkinPreview(skin: skin, size: 40),
            const SizedBox(height: 8),

            // Name
            Text(
              skin.name,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: isEquipped ? AppColors.neonGreen : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Action / status
            if (isEquipped)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.neonGreen.withOpacity(0.2),
                ),
                child: Text(
                  'EQUIPPED',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 6, color: AppColors.neonGreen),
                ),
              )
            else if (isOwned)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: skin.glowColor.withOpacity(0.4)),
                ),
                child: Text(
                  'EQUIP',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 6, color: skin.glowColor),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    '${skin.price}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: canAfford
                          ? AppColors.neonYellow
                          : AppColors.neonPink,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Skin Preview ─────────────────────────────────────────────────────────────

class _SkinPreview extends StatelessWidget {
  final SnakeSkin skin;
  final double size;

  const _SkinPreview({required this.skin, required this.size});

  @override
  Widget build(BuildContext context) {
    final segmentSize = size * 0.28;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _segment(skin.headColor, segmentSize, true),
        const SizedBox(width: 2),
        _segment(skin.bodyColor, segmentSize, false),
        const SizedBox(width: 2),
        _segment(skin.tailColor, segmentSize, false),
      ],
    );
  }

  Widget _segment(Color color, double size, bool isHead) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: isHead
            ? [
                BoxShadow(
                  color: skin.glowColor.withOpacity(0.4),
                  blurRadius: skin.glowRadius,
                ),
              ]
            : null,
      ),
    );
  }
}
