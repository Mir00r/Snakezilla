/// Immutable representation of a cell coordinate on the game grid.
class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  /// Returns a new [Position] offset by `(dx, dy)`.
  Position move(int dx, int dy) => Position(x + dx, y + dy);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Position($x, $y)';
}
