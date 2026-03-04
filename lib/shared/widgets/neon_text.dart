import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text widget with a multi-layered neon glow effect.
///
/// Renders the [text] using the *Press Start 2P* pixel font with
/// three shadow layers of decreasing opacity to simulate a
/// luminous neon tube.
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final double glowRadius;
  final TextAlign textAlign;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = const Color(0xFF39FF14),
    this.glowRadius = 20,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.pressStart2p(
        fontSize: fontSize,
        color: color,
        shadows: glowRadius > 0
            ? [
                Shadow(
                    color: color.withOpacity(0.8), blurRadius: glowRadius),
                Shadow(
                    color: color.withOpacity(0.5),
                    blurRadius: glowRadius * 2),
                Shadow(
                    color: color.withOpacity(0.3),
                    blurRadius: glowRadius * 3),
              ]
            : null,
      ),
    );
  }
}
