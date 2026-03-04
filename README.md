# 🐍 Snakezilla

A **production-ready Snake game** built with **Flutter**, featuring a premium neon-arcade UI, clean architecture, and full cross-platform support.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

| Category | Details |
|---|---|
| **Gameplay** | Classic snake, grid-based movement, increasing difficulty, pause/resume, restart |
| **UI/UX** | Neon arcade aesthetic, glassmorphism, animated gradient backgrounds, custom `CustomPainter` snake rendering with eyes, pulsing food orb, particle effects |
| **Themes** | Dark mode & Light mode (toggleable) |
| **Leaderboard** | Local persistence, player name entry, sorted rankings, medal styling for top 3 |
| **Settings** | Sound/music toggles, difficulty selection (Easy/Medium/Hard), boundary wrap toggle, dark mode toggle, leaderboard reset |
| **Audio** | Sound effects (eat, game over, button tap), background music loop (toggleable) |
| **Input** | Keyboard (arrow keys / WASD), swipe gestures, on-screen D-pad |
| **Responsive** | Mobile, tablet, and web layouts via `MediaQuery` & `AspectRatio` |

---

## 🏗 Architecture

The project follows **Clean Architecture** principles with **Riverpod** state management:

```
lib/
├── core/
│   ├── constants/        # Game configuration values
│   ├── theme/            # AppColors, AppTheme (dark/light)
│   └── utils/            # Responsive layout helpers
├── features/
│   ├── game/
│   │   ├── models/       # Direction, Position, GameState
│   │   ├── providers/    # GameNotifier (Riverpod StateNotifier)
│   │   ├── screens/      # GameScreen, GameOverDialog
│   │   └── widgets/      # GameBoard, SnakePainter, GameControls, ScoreDisplay
│   ├── home/
│   │   └── screens/      # HomeScreen (main menu)
│   ├── leaderboard/
│   │   ├── models/       # LeaderboardEntry
│   │   ├── providers/    # LeaderboardNotifier
│   │   └── screens/      # LeaderboardScreen
│   └── settings/
│       ├── models/       # SettingsModel, Difficulty enum
│       ├── providers/    # SettingsNotifier
│       └── screens/      # SettingsScreen
├── shared/
│   ├── services/         # AudioService, StorageService
│   └── widgets/          # GlassContainer, NeonText, AnimatedGradientBackground, ParticleEffect
└── main.dart             # Entry point with ProviderScope
```

### Key Design Decisions

- **Immutable state models** with `copyWith` for clean Riverpod diffing
- **StateNotifier** pattern for all feature providers
- **Timer.periodic** game loop with dynamic speed scaling
- **CustomPainter** for efficient canvas-based rendering (60 FPS target)
- **RepaintBoundary** isolating the game board from UI rebuilds
- **Separation of concerns**: models, providers, services, and UI are independent
- **Null safety** throughout

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10+
- Dart 3.0+

### Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd Snakezilla

# 2. Generate platform files (if not already present)
flutter create . --project-name snakezilla --org com.snakezilla

# 3. Install dependencies
flutter pub get

# 4. Add audio assets (see assets/audio/README.md)
#    Place eat.mp3, game_over.mp3, tap.mp3, bgm.mp3 in assets/audio/

# 5. Run the app
flutter run
```

### Running on Web

```bash
flutter run -d chrome
```

### Running Tests

```bash
flutter test
```

---

## 🎮 Controls

| Platform | Control | Action |
|---|---|---|
| Desktop | Arrow keys / WASD | Change direction |
| Desktop | Space | Pause / Resume |
| Mobile | Swipe | Change direction |
| Mobile | D-pad buttons | Change direction |
| All | Back button | Pause & return to menu |

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `shared_preferences` | Local persistence (settings, high score, leaderboard) |
| `audioplayers` | Sound effects & background music |
| `google_fonts` | Press Start 2P pixel font |

---

## 🎨 Visual Design

- **Neon arcade** colour palette with glowing accents
- **Glassmorphism** containers with backdrop blur
- **Animated gradient** backgrounds with smooth corner-to-corner transitions
- **Custom snake rendering**: rounded segments with head-to-tail gradient, directional eyes
- **Pulsing food orb** with radial gradient and glow
- **Particle burst** effect on food consumption
- **Animated score counter** with `TweenAnimationBuilder`
- **Press Start 2P** pixel font with multi-layered neon text shadows

---

## 🧪 Test Coverage

- **Unit tests**: Position, Direction, GameState models; GameNotifier logic (start, pause, resume, direction change, 180° prevention)
- **Widget tests**: GameBoard rendering, no-overflow verification
- **Model tests**: SettingsModel and LeaderboardEntry serialisation roundtrips

---

## 🔊 Audio Setup

The game expects these files in `assets/audio/`:

| File | Description |
|---|---|
| `eat.mp3` | Short blip when eating food |
| `game_over.mp3` | Game over jingle |
| `tap.mp3` | Button tap feedback |
| `bgm.mp3` | Looping background music |

Audio is gracefully degraded — the game works perfectly without audio assets (errors are caught silently).

---

## 🔧 Extending the Game

### Adding a new game mode

1. Add a variant to the relevant enum or create a new model
2. Create a new provider or extend `GameNotifier`
3. Add a screen/widget in `features/game/`
4. Wire it into the home menu

### Adding Firebase leaderboard

1. Add `cloud_firestore` to `pubspec.yaml`
2. Create `FirebaseLeaderboardService` implementing the same interface
3. Swap the provider in `main.dart` based on connectivity

### Adding new sound effects

1. Drop the `.mp3` file into `assets/audio/`
2. Add a play method in `AudioService`
3. Call it from the appropriate provider

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
