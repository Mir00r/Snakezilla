import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted-glass (glassmorphism) container used across the Snakezilla UI.
///
/// Applies a [BackdropFilter] blur behind a semi-transparent surface with
/// a thin border, creating the characteristic glass-pane look.
class GlassContainer extends StatelessWidget {
  /// The widget displayed inside the glass pane.
  final Widget child;

  /// Corner radius of the container.
  final double borderRadius;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  /// Strength of the background blur (sigma).
  final double blur;

  /// Optional override for the border colour.
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.blur = 10,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.4)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
