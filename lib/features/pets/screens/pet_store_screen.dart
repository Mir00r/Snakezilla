import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../economy/providers/player_profile_provider.dart';
import '../models/companion_pet.dart';

/// Pet store screen for purchasing and equipping companion pets.
class PetStoreScreen extends ConsumerWidget {
  const PetStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                        text: 'PET COMPANIONS',
                        fontSize: 13,
                        color: AppColors.neonPink,
                      ),
                    ),
                    // Coin balance
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neonYellow.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.coins}',
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
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: CompanionPets.all.length,
                  itemBuilder: (context, index) {
                    final pet = CompanionPets.all[index];
                    final isOwned =
                        profile.unlockedPets.contains(pet.id);
                    final isEquipped = profile.equippedPetId == pet.id;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 300 + index * 100),
                      builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PetCard(
                          pet: pet,
                          isOwned: isOwned,
                          isEquipped: isEquipped,
                          canAfford: profile.coins >= pet.price,
                          onTap: () {
                            if (isEquipped) {
                              // Unequip
                              ref
                                  .read(playerProfileProvider.notifier)
                                  .equipPet(null);
                            } else if (isOwned) {
                              ref
                                  .read(playerProfileProvider.notifier)
                                  .equipPet(pet.id);
                              HapticFeedback.mediumImpact();
                            } else {
                              _showPurchaseDialog(
                                  context, ref, pet, profile.coins);
                            }
                          },
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

  void _showPurchaseDialog(
      BuildContext context, WidgetRef ref, CompanionPet pet, int balance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${pet.emoji} ${pet.name}',
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: pet.color,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pet.description,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${pet.ability.label}: ${pet.ability.description}',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: AppColors.neonPurple,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Price: ${pet.price} coins',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: balance >= pet.price
                    ? AppColors.neonYellow
                    : AppColors.neonPink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style:
                    GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white38)),
          ),
          if (balance >= pet.price)
            TextButton(
              onPressed: () {
                ref.read(playerProfileProvider.notifier).purchasePet(pet);
                HapticFeedback.heavyImpact();
                Navigator.pop(ctx);
              },
              child: Text('BUY',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 8, color: AppColors.neonGreen)),
            ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final CompanionPet pet;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback onTap;

  const _PetCard({
    required this.pet,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderColor: isEquipped
            ? pet.glowColor
            : isOwned
                ? pet.color.withValues(alpha: 0.3)
                : Colors.white12,
        child: Row(
          children: [
            // Pet avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: pet.color.withValues(alpha: 0.15),
                border: Border.all(
                  color: isEquipped
                      ? pet.glowColor
                      : pet.color.withValues(alpha: 0.3),
                  width: isEquipped ? 2 : 1,
                ),
                boxShadow: isEquipped
                    ? [
                        BoxShadow(
                          color: pet.glowColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child:
                    Text(pet.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: isOwned ? pet.color : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.ability.label,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: AppColors.neonPurple.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Status
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: pet.glowColor.withValues(alpha: 0.2),
                  border: Border.all(color: pet.glowColor),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: pet.glowColor,
                  ),
                ),
              )
            else if (isOwned)
              Text(
                'TAP TO\nEQUIP',
                style: GoogleFonts.pressStart2p(
                  fontSize: 6,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canAfford
                        ? AppColors.neonYellow.withValues(alpha: 0.3)
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      '${pet.price}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: canAfford
                            ? AppColors.neonYellow
                            : Colors.white38,
                      ),
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
