import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';

/// Interactive tutorial overlay for first-time players.
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  static const _steps = [
    _TutorialStep(
      emoji: '🐍',
      title: 'WELCOME TO SNAKEZILLA!',
      description: 'Guide your snake to eat food and grow longer.\n'
          'Avoid hitting walls and yourself!',
      highlight: 'Swipe or use arrow keys to move',
    ),
    _TutorialStep(
      emoji: '🍎',
      title: 'EAT & GROW',
      description: 'Each food gives points and makes you longer.\n'
          'Special foods grant power-ups!',
      highlight: '⚡ Speed  🧲 Magnet  🛡️ Shield  👻 Ghost',
    ),
    _TutorialStep(
      emoji: '🔥',
      title: 'COMBOS!',
      description: 'Eat food quickly to build combos.\n'
          'Higher combos = more points!',
      highlight: 'Keep eating within 8 ticks for combo chain',
    ),
    _TutorialStep(
      emoji: '⚡',
      title: 'BOOST SPEED',
      description: 'Hold the ⚡ button or Space key to boost.\n'
          'Costs tail length but goes super fast!',
      highlight: 'Need 5+ segments to boost',
    ),
    _TutorialStep(
      emoji: '🎮',
      title: 'GAME MODES',
      description: 'Classic, Time Attack, Survival,\n'
          'AI Battle, Battle Royale, Gold Rush!',
      highlight: 'Each mode has unique challenges',
    ),
    _TutorialStep(
      emoji: '🏆',
      title: 'READY TO PLAY!',
      description: 'Earn coins to buy skins and pets.\n'
          'Complete missions for bonus rewards!',
      highlight: 'Tap to start your adventure!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() => _step++);
        _fadeController.forward();
      });
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];

    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (i) => Container(
                    width: i == _step ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _step
                          ? AppColors.neonGreen
                          : i < _step
                              ? AppColors.neonGreen.withValues(alpha: 0.4)
                              : Colors.white24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Emoji
              TweenAnimationBuilder<double>(
                key: ValueKey(_step),
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child:
                    Text(step.emoji, style: const TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 24),

              NeonText(
                text: step.title,
                fontSize: 14,
                color: AppColors.neonGreen,
                glowRadius: 15,
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  step.description,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white70,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Highlight box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  step.highlight,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: AppColors.neonGreen,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_step < _steps.length - 1)
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.neonGreen, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.neonGreen.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Text(
                        _step < _steps.length - 1
                            ? 'NEXT'
                            : 'START!',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String emoji;
  final String title;
  final String description;
  final String highlight;

  const _TutorialStep({
    required this.emoji,
    required this.title,
    required this.description,
    required this.highlight,
  });
}
