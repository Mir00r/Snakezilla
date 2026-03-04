/// Represents the four cardinal movement directions on the game grid.
enum Direction {
  up,
  down,
  left,
  right;

  /// Returns the direction opposite to this one.
  ///
  /// Used to prevent the snake from reversing into itself.
  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  /// Returns the unit grid offset `(dx, dy)` for this direction.
  ({int dx, int dy}) get offset {
    switch (this) {
      case Direction.up:
        return (dx: 0, dy: -1);
      case Direction.down:
        return (dx: 0, dy: 1);
      case Direction.left:
        return (dx: -1, dy: 0);
      case Direction.right:
        return (dx: 1, dy: 0);
    }
  }
}
