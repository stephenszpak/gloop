# Reality Anchor 🛡️

A Flutter mobile app designed for kids aged 4-8 to learn media literacy through a fun "real vs fake" game.

## 🎯 Features

- **Parent Login System** - Secure access for parents to manage children's profiles
- **Child Profile Management** - Multiple child profiles with progress tracking
- **Interactive Mission System** - Engaging "real vs fake" image challenges
- **Progress Tracking** - Detailed stats, achievements, and accuracy rates
- **Animated UI** - Child-friendly animations and transitions
- **Theme Support** - Light/Dark mode with automatic system preference detection
- **Offline Capability** - Mock data for development and testing

## 📱 Screens

1. **Parent Login** - Email/password authentication
2. **Child Selection** - Choose which child is playing
3. **Mission Screen** - Present image with real/fake question
4. **Results Screen** - Show correct answer with explanation
5. **Progress Screen** - Display child's stats and achievements

## 🏗️ Architecture

- **State Management**: Riverpod for reactive state management
- **Navigation**: GoRouter for declarative routing
- **HTTP**: Built-in http package for API calls
- **Theming**: Material 3 design with custom child-friendly colors
- **Animations**: Custom animations for engaging user experience

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── mission.dart             # Mission data model
│   └── child_profile.dart       # Child profile model
├── providers/
│   └── app_providers.dart       # Riverpod state providers
├── router/
│   └── app_router.dart          # Navigation configuration
├── screens/
│   ├── parent_login_screen.dart # Parent authentication
│   ├── child_profile_screen.dart# Child selection
│   ├── mission_screen.dart      # Game interface
│   ├── result_screen.dart       # Results and explanations
│   └── progress_screen.dart     # Stats and achievements
├── services/
│   └── api_service.dart         # API communication
└── theme/
    └── app_theme.dart           # Material 3 theming
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.0+
- Dart SDK 3.0.0+

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Development Setup

The app includes mock data for development, so no backend is required to test the functionality.

## 🎨 Design Principles

- **Child-Friendly**: Large buttons, playful fonts, emoji usage
- **Accessibility**: High contrast, clear typography, intuitive navigation
- **Educational**: Clear explanations, positive reinforcement
- **Safe**: Parent-controlled access, age-appropriate content

## 🔧 Configuration

### API Integration

Update `lib/services/api_service.dart` with your actual API endpoints:

```dart
static const String baseUrl = 'https://your-api.com';
```

### Fonts

Replace placeholder font files in `assets/fonts/` with actual Comic Neue font files from Google Fonts.

## 📊 State Management

The app uses Riverpod providers for:

- `selectedChildProvider` - Currently playing child
- `childProfilesProvider` - All child profiles and progress
- `currentMissionProvider` - Active mission state
- `missionTimerProvider` - Mission completion timing

## 🎯 Future Enhancements

- Real backend API integration
- Additional game modes (video, audio, text)
- Parental dashboard with detailed analytics
- Multiplayer challenges between children
- Adaptive difficulty based on performance
- Push notifications for mission reminders

## 📄 License

This project is licensed under the MIT License.