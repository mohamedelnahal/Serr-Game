# 🕵️‍♂️ Serr - The Ultimate Social Deduction Game

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

<div align="center">
  <img src="assets/icon.png" alt="Serr Game Icon" width="200"/>
  
  **A thrilling social deduction game where secrets hide in plain sight**
</div>

---

## 🎮 Game Concept

**Serr** (Arabic for "Secret") is an engaging multiplayer social deduction game designed for 3+ players. Inspired by classic party games like Mafia and Spyfall, Serr creates moments of suspense, laughter, and strategic thinking.

### How It Works

1. **Setup**: Players gather around a device and select a topic (e.g., "Animals", "Countries", "Professions")
2. **Role Assignment**: 
   - Most players become **Citizens** and receive a secret word from the chosen topic
   - One or more players become **Spies** who don't know the word
3. **The Challenge**: 
   - **Citizens** must identify the spy through discussion without revealing the secret word
   - **Spies** must blend in and deduce the word by listening carefully
4. **Victory**: 
   - Citizens win by correctly identifying all spies
   - Spies win by guessing the secret word or remaining undetected

### What Makes Serr Special

- **Scratch Card Reveal**: Each player privately reveals their role through an interactive scratch-off card
- **Customizable Topics**: Create your own topic categories or import from text files
- **Cloud Sync**: Share topics across devices via Firebase
- **Bilingual Support**: Seamlessly switch between Arabic and English
- **Beautiful UI**: Stunning light and dark themes with smooth animations

---

## ✨ Features

### 🎯 Core Gameplay
- **Dynamic Role Assignment**: Automatic spy/citizen distribution based on player count
- **Interactive Card Reveal**: Scratch-off mechanic for private role viewing
- **Flexible Player Count**: Support for 3 to unlimited players
- **Customizable Spy Count**: Adjust difficulty by changing the number of spies

### 🌍 Localization & Accessibility
- **Bilingual Interface**: Full support for **English** and **Arabic**
- **RTL Support**: Proper right-to-left layout for Arabic
- **Dynamic Language Switching**: Change language on-the-fly from settings

### 🎨 Design & Themes
- **Light & Dark Modes**: Beautifully crafted themes with gold accents
- **Responsive Design**: Optimized for phones and tablets
- **Custom Typography**: Google Fonts (Cairo) for elegant text rendering
- **Smooth Animations**: Polished transitions and micro-interactions

### 📂 Topic Management
- **Offline Storage**: Topics saved locally using Hive database
- **Cloud Synchronization**: Fetch and sync topics via Firebase Firestore
- **Import from Files**: Upload custom topics from `.txt` files
- **CRUD Operations**: Create, read, update, and delete topics easily
- **Dot-Separated Format**: Simple text file format (word1.word2.word3)

### 💾 Data Persistence
- **Player Profiles**: Save player names and avatars locally
- **Settings Memory**: Theme and language preferences persist across sessions
- **Offline-First**: Play without internet connection

### 🎭 User Experience
- **Animated Splash Screen**: Professional app launch experience
- **Custom App Icon**: Distinctive launcher icon
- **Intuitive Navigation**: Clean, user-friendly interface
- **Visual Feedback**: Clear indicators for game states and player turns

---

## 🛠️ Technologies & Architecture

### **Languages**
- **Dart** `^3.5.0` - Primary programming language
- **Kotlin** - Android native integration
- **Swift** - iOS native integration (future support)

### **Framework**
- **Flutter** `^3.5.0` - Cross-platform UI framework
  - Material Design components
  - Cupertino widgets for iOS-style elements

### **State Management**
- **Flutter Bloc** `^9.1.1` - Predictable state management
  - `GameCubit` - Manages game logic and player states
  - `ThemeCubit` - Handles theme switching
- **Equatable** `^2.0.7` - Value equality for state objects

### **Backend & Database**
- **Firebase Core** `^4.3.0` - Firebase SDK initialization
- **Cloud Firestore** `^6.1.1` - NoSQL cloud database for topic sync
- **Hive** `^2.2.3` - Fast, lightweight local database
  - `hive_flutter` `^1.1.0` - Flutter integration
  - `hive_generator` `^2.0.1` - Code generation for type adapters

### **UI & Design**
- **Google Fonts** `^6.3.0` - Custom typography (Cairo font family)
- **Scratcher** `^2.5.0` - Interactive scratch card widget
- **Custom Gradient Backgrounds** - Visually stunning backdrops

### **Utilities**
- **Intl** `^0.19.0` - Internationalization and localization
- **Flutter Localizations** - Built-in localization support
- **Path Provider** `^2.1.5` - Access to device file system
- **File Picker** `^6.0.0` - Import topics from files
- **Image Picker** `^1.1.2` - Custom player avatars

### **Development Tools**
- **Flutter Lints** `^4.0.0` - Recommended linting rules
- **Build Runner** `^2.4.13` - Code generation
- **Flutter Launcher Icons** `^0.13.1` - Generate app icons

### **Architecture Pattern**
- **Feature-First Structure** - Modular, scalable organization
- **BLoC Pattern** - Separation of business logic and UI
- **Repository Pattern** - Data abstraction layer (Hive + Firestore)

---

## 📁 Project Structure

```
lib/
├── core/                    # Shared utilities and models
│   ├── models/             # Data models (Player, Topic)
│   └── constants/          # App-wide constants
├── features/               # Feature modules
│   ├── game/              # Game logic and screens
│   │   ├── cubit/         # Game state management
│   │   ├── game_screen.dart
│   │   ├── game_setup_screen.dart
│   │   └── topic_management_screen.dart
│   ├── home/              # Home screen
│   ├── settings/          # Settings and theme management
│   └── splash/            # Splash screen
├── l10n/                  # Localization files
│   ├── app_ar.arb        # Arabic translations
│   └── app_en.arb        # English translations
└── main.dart             # Application entry point

assets/
├── icon.png              # App launcher icon
├── splash_logo.png       # Splash screen logo
├── background.png        # Light theme background
├── dark_background.png   # Dark theme background
├── card_front.png        # Scratch card front
└── card_back.png         # Scratch card back
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `^3.5.0` or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Account** (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohamedelnahal/Serr-Game.git
   cd Serr-Game
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional - for cloud sync)
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add your Android/iOS app to the project
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Enable Firestore Database in Firebase Console

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS (requires macOS):**
```bash
flutter build ios --release
```

---

## 🎯 How to Play

1. **Launch the app** and tap "Start Game"
2. **Add players** by entering their names (minimum 3 players)
3. **Select a topic** from the list or create a custom one
4. **Choose spy count** (recommended: 1 spy per 5-7 players)
5. **Start the game** - each player takes turns viewing their role
6. **Scratch the card** to reveal your secret word or spy status
7. **Discuss and deduce** - citizens find spies, spies guess the word
8. **Declare victory** when spies are caught or the word is guessed!

---

## 🌐 Localization

The app supports **English** and **Arabic** with full localization:

- All UI text is translated
- RTL layout for Arabic
- Localized date/time formats
- Language can be changed in Settings

To add a new language:
1. Create `app_XX.arb` in `lib/l10n/` (XX = language code)
2. Add translations for all keys from `app_en.arb`
3. Add locale to `supportedLocales` in `main.dart`
4. Run `flutter pub get` to generate localization files

---

## 🤝 Contributing

Contributions are welcome! Whether it's bug fixes, new features, or translations, your help makes Serr better.

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write meaningful commit messages
- Test on both light and dark themes
- Ensure RTL layout works for Arabic
- Update documentation for new features

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` file for more information.

---

## 👨‍💻 Author

**Mohamed Elnahal**
- GitHub: [@mohamedelnahal](https://github.com/mohamedelnahal)

---

## 🙏 Acknowledgments

- Inspired by classic social deduction games (Mafia, Spyfall, Werewolf)
- Built with ❤️ using Flutter and Firebase
- Special thanks to the Flutter community for amazing packages

---

<div align="center">
  
  **Enjoy the game! May the best detective win! 🕵️‍♂️**
  
  ⭐ Star this repo if you like the project!
  
</div>
