/// All available game modes in Snakezilla.
///
/// Each mode has distinct rules, win/loss conditions, and UI overlays.
enum GameMode {
  classic('Classic', '🎮', 'Classic endless snake gameplay'),
  timeAttack('Time Attack', '⏱️', 'Score big before time runs out'),
  survival('Survival', '💀', 'Stay alive as hazards close in'),
  aiBattle('AI Battle', '🤖', 'Compete against a smart AI snake');

  /// Display label for menus.
  final String label;

  /// Emoji icon for headers.
  final String icon;

  /// Short description for mode-select UI.
  final String description;

  const GameMode(this.label, this.icon, this.description);
}

/// Time options for Time Attack mode.
enum TimeAttackDuration {
  short60(60, '60s'),
  medium120(120, '120s'),
  long180(180, '180s');

  final int seconds;
  final String label;
  const TimeAttackDuration(this.seconds, this.label);
}
