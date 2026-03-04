import 'package:flutter_test/flutter_test.dart';

import 'package:snakezilla/core/constants/game_constants.dart';
import 'package:snakezilla/features/game/models/direction.dart';
import 'package:snakezilla/features/game/models/game_state.dart';
import 'package:snakezilla/features/game/models/position.dart';

void main() {
  // ── Position ─────────────────────────────────────────────────────────────

  group('Position', () {
    test('equality compares x and y', () {
      expect(const Position(3, 5), const Position(3, 5));
      expect(const Position(3, 5), isNot(const Position(5, 3)));
    });

    test('hash codes are identical for equal positions', () {
      expect(const Position(1, 2).hashCode, const Position(1, 2).hashCode);
    });

    test('move returns a new position offset by dx/dy', () {
      const pos = Position(5, 5);
      expect(pos.move(1, 0), const Position(6, 5));
      expect(pos.move(0, -1), const Position(5, 4));
      expect(pos.move(-3, 2), const Position(2, 7));
    });

    test('toString includes coordinates', () {
      expect(const Position(7, 8).toString(), 'Position(7, 8)');
    });
  });

  // ── Direction ────────────────────────────────────────────────────────────

  group('Direction', () {
    test('opposite returns the reverse direction', () {
      expect(Direction.up.opposite, Direction.down);
      expect(Direction.down.opposite, Direction.up);
      expect(Direction.left.opposite, Direction.right);
      expect(Direction.right.opposite, Direction.left);
    });

    test('offset returns correct unit vector records', () {
      expect(Direction.up.offset, (dx: 0, dy: -1));
      expect(Direction.down.offset, (dx: 0, dy: 1));
      expect(Direction.left.offset, (dx: -1, dy: 0));
      expect(Direction.right.offset, (dx: 1, dy: 0));
    });
  });

  // ── GameState ────────────────────────────────────────────────────────────

  group('GameState', () {
    test('initial state creates snake in centre of grid', () {
      final state = GameState.initial();

      expect(state.snake.length, GameConstants.initialSnakeLength);
      expect(state.status, GameStatus.idle);
      expect(state.score, 0);
      expect(state.direction, Direction.right);
    });

    test('initial food does not overlap the snake', () {
      // Run multiple times to increase confidence (randomised).
      for (int i = 0; i < 50; i++) {
        final state = GameState.initial();
        expect(state.snake.contains(state.food), isFalse,
            reason: 'Food should never spawn on a snake segment');
      }
    });

    test('copyWith preserves unchanged fields', () {
      final state = GameState.initial(highScore: 42);
      final updated = state.copyWith(score: 100);

      expect(updated.score, 100);
      expect(updated.highScore, 42);
      expect(updated.snake, state.snake);
      expect(updated.direction, state.direction);
      expect(updated.status, state.status);
    });

    test('copyWith can explicitly set bufferedDirection to null', () {
      final state = GameState.initial()
          .copyWith(bufferedDirection: () => Direction.up);
      expect(state.bufferedDirection, Direction.up);

      final cleared = state.copyWith(bufferedDirection: () => null);
      expect(cleared.bufferedDirection, isNull);
    });

    test('initial state respects supplied parameters', () {
      final state = GameState.initial(
        highScore: 500,
        speed: 100,
        boundaryWrap: true,
      );

      expect(state.highScore, 500);
      expect(state.speed, 100);
      expect(state.boundaryWrap, isTrue);
    });
  });
}
