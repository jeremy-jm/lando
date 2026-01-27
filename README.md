<div align="center">
  <img src="https://github.com/jeremy-jm/lando/blob/master/assets/images/logo.png?raw=true" height="256" alt="Lando Logo">
  
  # Lando Dictionary
  
  #### 🚀 A clean, ad-free translation software that integrates multiple translation services
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)](https://flutter.dev)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-lightgrey)](https://flutter.dev)
  
  **English** | [简体中文](README_zh.md)
</div>

---

## 📖 About

**Lando** is a free, open-source translation dictionary application that aggregates commonly used translation services without any advertisements. Built with Flutter, it provides a clean and fast user experience for quick word lookups.

### Why Lando?

The author was frustrated with startup ads on mobile translation apps. When searching for words frequently and briefly, the actual lookup takes only a few seconds, but opening the software often means waiting through at least 5 seconds of ads. That's why Lando was created - a completely free, ad-free alternative.

---

## ✨ Features

- 🚫 **No Ads** - Completely ad-free experience
- 🌍 **Multi-language Support** - Supports 7 languages (English, Chinese, Japanese, Hindi, Indonesian, Portuguese, Russian)
- 🎨 **Modern UI** - Material Design 3 with dark/light theme support
- 🔍 **Multiple Translation Services** - Currently integrates Youdao; Bing, Google, and AI translation tools coming soon
- 📱 **Cross-platform** - Works on iOS, Android, macOS, Windows, and Linux
- ⚡ **Fast & Lightweight** - Quick word lookups without unnecessary bloat
- 🔖 **History & Favorites** - Save your translation history and favorite words
- 🔊 **Pronunciation** - Multiple pronunciation services (System TTS, Youdao, Baidu, Bing, Google, Apple)
- ⌨️ **Global Hotkeys** - Quick access with customizable hotkeys (macOS/Windows/Linux)

---

## 🛠️ Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Stable | Fully tested |
| Android | ✅ Stable | Fully tested |
| macOS | ✅ Stable | Fully tested |
| Windows | 🚧 In Development | Under active development |
| Linux | 🚧 In Development | Under active development |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.5.0)
- Dart SDK (>=3.5.0)
- Platform-specific development tools:
  - **iOS**: Xcode
  - **Android**: Android Studio
  - **macOS**: Xcode Command Line Tools
  - **Windows**: Visual Studio with C++ support
  - **Linux**: GCC, CMake

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jeremy-jm/lando.git
   cd lando
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   
   # For macOS
   flutter run -d macos
   
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux
   ```

### Building for Production

```bash
# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release

# Build macOS
flutter build macos --release

# Build Windows
flutter build windows --release

# Build Linux
flutter build linux --release
```

---

## 📱 Screenshots

> Screenshots coming soon...

---

## 🏗️ Project Structure

```
lando/
├── lib/
│   ├── features/          # Feature modules
│   │   ├── home/          # Home & translation
│   │   ├── dictionary/    # Dictionary view
│   │   ├── me/            # Settings & profile
│   │   └── shared/        # Shared components
│   ├── l10n/              # Localization files
│   ├── models/            # Data models
│   ├── network/           # Network layer
│   ├── routes/            # App routing
│   ├── services/          # Business services
│   ├── storage/           # Local storage
│   └── theme/             # Theme configuration
├── test/                  # Test files
└── assets/                # Images, fonts, etc.
```

---

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/models/query_history_item_test.dart
```

See [TESTING.md](TESTING.md) for more details.

---

## 🤝 Contributing

Contributions are welcome! If you're interested in contributing:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Areas for Contribution

- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation improvements
- 🎨 UI/UX enhancements
- 🌍 Additional language support
- 🔧 Integration with more translation services

If you have ideas or suggestions, please open an issue to discuss them!

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Thanks to all the translation service providers
- Thanks to the Flutter community
- Thanks to all contributors and users

---

## 📧 Contact

- **Issues**: [GitHub Issues](https://github.com/jeremy-jm/lando/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jeremy-jm/lando/discussions)

---

<div align="center">
  Made with ❤️ using Flutter
</div>
