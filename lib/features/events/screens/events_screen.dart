import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_text.dart';
import '../models/seasonal_event.dart';

/// Seasonal events screen showing active and upcoming events.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = SeasonalEvents.activeEvents;

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
                        text: 'EVENTS',
                        fontSize: 16,
                        color: AppColors.neonPink,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Active events banner
              if (active.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: [
                      active.first.primaryColor.withValues(alpha: 0.2),
                      active.first.secondaryColor.withValues(alpha: 0.2),
                    ]),
                    border: Border.all(
                      color:
                          active.first.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔴', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE NOW',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: active.first.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: SeasonalEvents.all.length,
                  itemBuilder: (context, index) {
                    final event = SeasonalEvents.all[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration:
                          Duration(milliseconds: 400 + index * 120),
                      curve: Curves.easeOut,
                      builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(event: event),
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
}

class _EventCard extends StatelessWidget {
  final SeasonalEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderColor: event.isActive
          ? event.primaryColor.withValues(alpha: 0.5)
          : Colors.white12,
      child: Row(
        children: [
          // Event icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  event.primaryColor.withValues(alpha: 0.3),
                  event.secondaryColor.withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: event.isActive
                    ? event.primaryColor
                    : Colors.white24,
                width: event.isActive ? 2 : 1,
              ),
              boxShadow: event.isActive
                  ? [
                      BoxShadow(
                        color:
                            event.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child:
                  Text(event.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.name.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: event.isActive
                              ? event.primaryColor
                              : Colors.white54,
                        ),
                      ),
                    ),
                    if (event.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color:
                              event.primaryColor.withValues(alpha: 0.2),
                          border: Border.all(color: event.primaryColor),
                        ),
                        child: Text(
                          'LIVE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: event.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.description,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🎁 Special skin • 🏆 Event leaderboard • 🪙 Bonus coins',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 5,
                    color: event.isActive
                        ? event.secondaryColor
                        : Colors.white30,
                    height: 1.4,
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
