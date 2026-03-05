import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../providers/game_provider.dart';
import '../models/game_mode.dart';
import 'game_screen.dart';

/// Mini Games hub with special quick-play game modes.
class MiniGamesScreen extends ConsumerWidget {
  const MiniGamesScreen({super.key});

  static const _miniGames = [
    _MiniGameInfo(
      id: 'coin_rush',
      name: 'COIN RUSH',
      emoji: '🪙',
      description: 'Massive coins spawn for 30 seconds!',
      color: Color(0xFFFFD700),
      mode: GameMode.goldRush,
    ),
    _MiniGameInfo(
      id: 'lightning',
      name: 'LIGHTNING',
      emoji: '⚡',
      description: 'Snake moves at insane speed!',
      color: AppColors.neonYellow,
      mode: GameMode.timeAttack,
    ),
    _MiniGameInfo(
      id: 'survival_extreme',
      name: 'BOMB ESCAPE',
      emoji: '🧨',
      description: 'Obstacles rain down! Survive 60s!',
      color: AppColors.neonPink,
      mode: GameMode.survival,
    ),
    _MiniGameInfo(
      id: 'battle_arena',
      name: 'ARENA',
      emoji: '⚔️',
      description: 'Quick battle royale showdown!',
      color: AppColors.neonPurple,
      mode: GameMode.battleRoyale,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        text: 'MINI GAMES',
                        fontSize: 16,
                        color: AppColors.neonBlue,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Info banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(colors: [
                    AppColors.neonBlue.withValues(alpha: 0.1),
                    AppColors.neonPurple.withValues(alpha: 0.1),
                  ]),
                  border: Border.all(
                    color: AppColors.neonBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Quick-play modes with bonus coin rewards!',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _miniGames.length,
                  itemBuilder: (context, index) {
                    final game = _miniGames[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 400 + index * 100),
                      curve: Curves.easeOut,
                      builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.scale(
                          scale: 0.8 + v * 0.2,
                          child: child,
                        ),
                      ),
                      child: _MiniGameCard(
                        game: game,
                        onTap: () => _launchMiniGame(context, ref, game),
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

  void _launchMiniGame(
      BuildContext context, WidgetRef ref, _MiniGameInfo game) {
    ref.read(gameLaunchConfigProvider.notifier).state = GameLaunchConfig(
      mode: game.mode,
      timeAttackSeconds: game.mode == GameMode.timeAttack ? 30 : 60,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

class _MiniGameInfo {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final GameMode mode;

  const _MiniGameInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    required this.mode,
  });
}

class _MiniGameCard extends StatelessWidget {
  final _MiniGameInfo game;
  final VoidCallback onTap;

  const _MiniGameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderColor: game.color.withValues(alpha: 0.4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji icon with glow
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: game.color.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: game.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  game.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              game.name,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: game.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              game.description,
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: Colors.white54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: game.color.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'PLAY',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: game.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
