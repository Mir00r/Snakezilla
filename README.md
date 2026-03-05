# 🐍 Snakezilla

A **AAA-quality Snake game** built with **Flutter**, featuring premium neon-arcade visuals, snake.io mechanics, competitive systems, social features, and full cross-platform support.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Feature Overview

### 🎮 Core Gameplay
| Feature | Details |
|---|---|
| **6 Game Modes** | Classic, Time Attack, Obstacle Course, AI Duel, Battle Royale (5v1 with shrinking boundary), Gold Rush |
| **Snake Mechanics** | Boost system (hold Space), combo chains, special food effects (speed, freeze, magnet, shield, ghost, bomb, rainbow, coin bonus) |
| **AI Opponents** | Intelligent AI snakes with pathfinding, death pellet drops on kill, kill feed display |
| **Mini Games** | Tap Frenzy, Memory Match, Reaction Time — earn coins for main game |

### 💎 Progression & Economy
| Feature | Details |
|---|---|
| **Player Profile** | Level system (XP-based), lifetime stats tracking, title progression (Rookie → God) |
| **12 Snake Skins** | Neon, Inferno, Ocean, Toxic, Galaxy, Cyber, Golden, Shadow, Crimson, Crystal, Emerald, Phantom — each with unique head/tail/glow colors |
| **6 Companion Pets** | Robot Drone, Fire Spirit, Ice Fairy, Shadow Cat, Neon Butterfly, Crystal Owl — provide passive bonuses (speed, coin boost, XP boost, shield, magnet, combo) |
| **6 Game Worlds** | Neon City, Volcanic Depths, Frozen Tundra, Cyber Matrix, Enchanted Forest, Deep Ocean — each with unique colors and particle effects |
| **10 Achievements** | Score milestones, game count, AI victories, combo streaks, snake length |

### 🏆 Competitive Systems
| Feature | Details |
|---|---|
| **Rank League** | 6 ranks (Bronze → Master) based on Rank Points earned from gameplay |
| **Tournaments** | Daily, Weekly, and Special seasonal tournaments with AI opponent leaderboards |
| **Weekly Challenges** | 4-step ladder challenges that rotate weekly — complete all steps for exclusive rewards |
| **Leaderboard** | Local high-score leaderboard with difficulty filtering and medal styling |

### 🔥 Retention & Engagement
| Feature | Details |
|---|---|
| **Daily Rewards** | 7-day calendar with escalating rewards and streak tracking |
| **Daily Missions** | 3 rotating missions (score targets, game count, combo goals) with coin/XP rewards |
| **Spin Wheel** | Daily fortune wheel with 8 prize sectors |
| **Seasonal Events** | Summer Sizzle, Winter Frost, Spring Bloom, Halloween Fright — bonus coins/XP multipliers |
| **Prestige System** | Reset level for permanent coin/XP multipliers (5 prestige tiers) |
| **Smart Retention AI** | Adaptive difficulty suggestions, comeback rewards for returning players, engagement nudges |

### 🌐 Social & Viral
| Feature | Details |
|---|---|
| **Friends System** | Simulated friends list with online status, activity feed, and challenge system |
| **Gift System** | Send coins, XP boosts, and mystery boxes to friends |
| **Share Cards** | Generate visual "brag cards" with game stats for social sharing |
| **Viral Sharing** | Challenge text generation from game-over screen |

### 🎨 Visual & Audio
| Feature | Details |
|---|---|
| **Neon Arcade UI** | Glassmorphism, animated gradient backgrounds, neon glow effects |
| **Live Menu** | Floating particle animations on the home screen |
| **Camera Effects** | Dynamic zoom based on snake length, boost zoom, screen shake on bomb pickup |
| **Cosmetic Animations** | Neon pulse glow, fire boost trail, rainbow shimmer on long snakes |
| **Dynamic Music** | Intensity-adaptive background music (calm/normal/intense) that responds to gameplay |
| **Sound Effects** | Real WAV audio for eat, tap, game over, combo, and power-up events |
| **Tutorial** | Interactive first-time tutorial overlay |

---

## 🏗 Architecture

The project follows **Clean Architecture** principles with **Riverpod** state management:

```
lib/
├── core/
│   ├── constants/        # GameConstants (grid size, speeds, timers)
│   ├── theme/            # AppColors, AppTheme (dark/light)
│   └── utils/            # Responsive layout helpers
├── features/
│   ├── achievements/     # Achievement models, screens, tracking
│   ├── challenges/       # Weekly challenge ladder system
│   ├── economy/          # PlayerProfile, daily rewards, missions, stats, spin wheel
│   ├── events/           # Seasonal events system
│   ├── game/             # Core game logic, screens, widgets, replay, modes
│   ├── home/             # Home screen with live animated menu
│   ├── leaderboard/      # Local leaderboard with persistence
│   ├── pets/             # Companion pet store and equip system
│   ├── prestige/         # Prestige reset system with multipliers
│   ├── ranks/            # Competitive rank league (Bronze → Master)
│   ├── settings/         # Settings model, difficulty, toggles
│   ├── skins/            # Snake skin store and equip system
│   ├── social/           # Friends, gifts, share cards, activity feed
│   └── tournament/       # Daily/weekly/special tournaments
├── shared/
│   ├── services/         # AudioService, StorageService, RetentionAI, AnalyticsService
│   └── widgets/          # AnimatedGradientBackground, GlassContainer, NeonText, TutorialOverlay
└── main.dart             # App entry point with ProviderScope
```

### State Management
- **Riverpod** `StateNotifier` pattern for all state (game, profile, settings, leaderboard)
- Immutable models with `copyWith()` methods
- JSON serialization for `SharedPreferences` persistence
- Clean provider dependency injection via `Ref`

### Key Providers
| Provider | Purpose |
|---|---|
| `gameProvider` | Game loop, snake movement, collision, scoring |
| `playerProfileProvider` | Economy, progression, unlocks, prestige |
| `settingsProvider` | Difficulty, sound, dark mode, boundary wrap |
| `leaderboardProvider` | High score persistence and ranking |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Dart SDK 3.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/snakezilla.git
cd snakezilla

# Install dependencies
flutter pub get

# Run on web (default)
flutter run -d chrome

# Run on mobile
flutter run  # (connected device or emulator)

# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

### 🎮 Controls

| Platform | Control | Action |
|---|---|---|
| Desktop | Arrow keys / WASD | Change direction |
| Desktop | Space (hold) | Boost |
| Desktop | P / Escape | Pause/Resume |
| Mobile | Swipe | Change direction |
| Mobile | D-pad buttons | Change direction |
| Mobile | Boost button (hold) | Boost |

---

## 📱 Releasing to Google Play Store

### 1. Configure App Identity

Update `android/app/build.gradle`:

```groovy
android {
    namespace "com.yourcompany.snakezilla"
    defaultConfig {
        applicationId "com.yourcompany.snakezilla"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 2. Create a Signing Key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

### 3. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

Update `android/app/build.gradle`:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 4. Build Release App Bundle

```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --release

# APK (for direct distribution)
flutter build apk --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new application
3. Fill in **Store Listing**: title, description, screenshots, feature graphic, icon
4. Upload the `.aab` file under **Production > Create new release**
5. Set **Content rating** (complete questionnaire — select "Games" category)
6. Set **Pricing & distribution** (Free)
7. Review and **Roll out to production**

### Required Assets for Play Store
| Asset | Specification |
|---|---|
| App Icon | 512x512 PNG |
| Feature Graphic | 1024x500 PNG |
| Screenshots | Min 2, recommended 8 (phone + tablet) |
| Short Description | Max 80 characters |
| Full Description | Max 4000 characters |

---

## 🍎 Releasing to Apple App Store

### 1. Prerequisites
- macOS with Xcode 15+
- Apple Developer Account ($99/year)
- Valid provisioning profile and certificate

### 2. Configure iOS Project

Open `ios/Runner.xcworkspace` in Xcode:
1. Select the **Runner** target
2. Set **Bundle Identifier**: `com.yourcompany.snakezilla`
3. Select your **Team** (Apple Developer account)
4. Set **Deployment Target**: iOS 12.0+
5. Enable **Automatically manage signing**

### 3. Build for iOS

```bash
# Build iOS release
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release
```

### 4. Upload to App Store Connect

**Option A: Xcode**
1. Open `ios/Runner.xcworkspace`
2. Select **Product > Archive**
3. In Organizer, click **Distribute App**
4. Choose **App Store Connect > Upload**

**Option B: Command Line**
```bash
xcrun altool --upload-app --type ios \
  --file build/ios/ipa/snakezilla.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

### 5. App Store Connect Configuration

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create a new app (Category: Games > Casual)
3. Add **Screenshots** for required device sizes (6.7", 6.5", iPad 12.9")
4. Write **Description**, **Keywords**, **What's New**
5. Set **Age Rating** (4+)
6. Submit for **Review**

---

## 🌐 Web Deployment

### Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting  # Select build/web, single-page: Yes
flutter build web --release
firebase deploy --only hosting
```

### GitHub Pages

```bash
flutter build web --release --base-href "/snakezilla/"
# Push build/web contents to gh-pages branch
```

---

## 🔧 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.4.9 | State management (StateNotifier pattern) |
| `shared_preferences` | ^2.2.2 | Local persistence for profile, settings, leaderboard |
| `audioplayers` | ^5.2.1 | Sound effects and background music playback |
| `google_fonts` | ^6.1.0 | Press Start 2P pixel font for retro arcade feel |

---

## 📂 Audio Assets

Located in `assets/audio/`:

| File | Duration | Description |
|---|---|---|
| `eat.wav` | 120ms | Ascending chirp on food pickup |
| `tap.wav` | 60ms | Quick click on button press |
| `game_over.wav` | 600ms | Descending tone on death |
| `bgm.wav` | 8s loop | C-E-G arpeggio background melody |

---

## 🧪 Testing

```bash
flutter test              # Run all tests
flutter test --coverage   # Run with coverage report
```

---

## 📋 Project Stats

- **65+ Dart files** across 14 feature modules
- **6 game modes** with unique mechanics
- **12 snake skins**, **6 companion pets**, **6 game worlds**
- **10 achievements**, daily missions, weekly challenges
- **Tournaments**, rank leagues, prestige system
- **Social features**: friends, gifts, share cards
- **Smart retention AI** with adaptive difficulty
- **Full offline operation** — no backend required

---

## 📄 License

This project is licensed under the MIT License.
