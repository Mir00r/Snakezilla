import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snakezilla/features/game/models/direction.dart';
import 'package:snakezilla/features/game/models/game_state.dart';
import 'package:snakezilla/features/game/providers/game_provider.dart';
import 'package:snakezilla/shared/services/audio_service.dart';
import 'package:snakezilla/shared/services/storage_service.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    // Provide empty SharedPreferences for the test run.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final audio = AudioService();

    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        audioServiceProvider.overrideWithValue(audio),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // ── Tests ────────────────────────────────────────────────────────────────

  test('initial state is idle', () {
    final state = container.read(gameProvider);
    expect(state.status, GameStatus.idle);
  });

  test('startGame transitions to playing status', () {
    container.read(gameProvider.notifier).startGame();
    expect(container.read(gameProvider).status, GameStatus.playing);
  });

  test('pauseGame transitions to paused', () {
    container.read(gameProvider.notifier).startGame();
    container.read(gameProvider.notifier).pauseGame();
    expect(container.read(gameProvider).status, GameStatus.paused);
  });

  test('resumeGame transitions back to playing', () {
    final notifier = container.read(gameProvider.notifier);
    notifier.startGame();
    notifier.pauseGame();
    notifier.resumeGame();
    expect(container.read(gameProvider).status, GameStatus.playing);
  });

  test('changeDirection rejects 180° reversal', () {
    container.read(gameProvider.notifier).startGame();
    // Default direction is right → left should be rejected.
    container.read(gameProvider.notifier).changeDirection(Direction.left);
    expect(container.read(gameProvider).bufferedDirection, isNull);
  });

  test('changeDirection accepts perpendicular direction', () {
    container.read(gameProvider.notifier).startGame();
    container.read(gameProvider.notifier).changeDirection(Direction.up);
    expect(container.read(gameProvider).bufferedDirection, Direction.up);
  });

  test('changeDirection is ignored when game is not playing', () {
    // Game starts idle.
    container.read(gameProvider.notifier).changeDirection(Direction.up);
    expect(container.read(gameProvider).bufferedDirection, isNull);
  });

  test('pauseGame is no-op when game is not playing', () {
    container.read(gameProvider.notifier).pauseGame();
    expect(container.read(gameProvider).status, GameStatus.idle);
  });

  test('startGame resets score to zero', () {
    final notifier = container.read(gameProvider.notifier);
    notifier.startGame();
    expect(container.read(gameProvider).score, 0);
  });
}
