import 'package:flutter/material.dart';

/// Responsive layout utilities for adapting the UI across device sizes.
///
/// Breakpoints:
/// * Mobile:  width < 600
/// * Tablet:  600 ≤ width < 1024
/// * Desktop: width ≥ 1024
class Responsive {
  Responsive._();

  /// Returns `true` when the screen width is below 600 logical pixels.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Returns `true` for screens between 600 and 1024 logical pixels wide.
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  /// Returns `true` for screens 1024 logical pixels wide or more.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// Computes the optimal square cell size for the game grid so the board
  /// fits comfortably on any screen without overflowing.
  static double cellSize(BuildContext context, int gridSize) {
    final size = MediaQuery.of(context).size;
    final availableWidth = size.width * 0.9;
    final availableHeight = size.height * 0.55;
    final maxDimension =
        availableWidth < availableHeight ? availableWidth : availableHeight;
    return (maxDimension / gridSize).floorToDouble();
  }

  /// Linearly scales a design-time value based on the device width.
  static double scale(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return value * 0.8;
    if (width < 600) return value;
    if (width < 1024) return value * 1.2;
    return value * 1.4;
  }
}
