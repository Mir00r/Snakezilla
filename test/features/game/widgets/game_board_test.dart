import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snakezilla/features/game/widgets/game_board.dart';
import 'package:snakezilla/shared/services/audio_service.dart';
import 'package:snakezilla/shared/services/storage_service.dart';

void main() {
  testWidgets('GameBoard renders without overflow errors', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final audio = AudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          audioServiceProvider.overrideWithValue(audio),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: GameBoard()),
          ),
        ),
      ),
    );

    // Let animations settle.
    await tester.pump(const Duration(milliseconds: 100));

    // Verify no rendering exceptions and the widget is present.
    expect(tester.takeException(), isNull);
    expect(find.byType(GameBoard), findsOneWidget);
  });

  testWidgets('GameBoard has an AspectRatio child', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final audio = AudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          audioServiceProvider.overrideWithValue(audio),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: GameBoard()),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AspectRatio), findsOneWidget);
  });
}
