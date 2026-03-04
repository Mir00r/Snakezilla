import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'shared/services/audio_service.dart';
import 'shared/services/storage_service.dart';

/// Application entry point.
///
/// Initialises SharedPreferences and AudioService before mounting the
/// widget tree inside a [ProviderScope] with concrete overrides.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silence audioplayers console noise (format errors for missing/stub assets).
  AudioLogger.logLevel = AudioLogLevel.none;

  // Lock to portrait on mobile (no-op on web / desktop).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise persistence.
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Initialise audio.
  final audioService = AudioService();
  await audioService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        audioServiceProvider.overrideWithValue(audioService),
      ],
      child: const SnakezillaApp(),
    ),
  );
}

/// Root widget. Watches [settingsProvider] to toggle dark/light theme.
class SnakezillaApp extends ConsumerWidget {
  const SnakezillaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Snakezilla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
