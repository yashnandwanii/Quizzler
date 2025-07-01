# 🧠 Quizzler - The Ultimate Knowledge Challenge

<div align="center">
  <img src="assets/app_logo.png" alt="QuizMaster Logo" width="120" height="120">
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
  
  **Ignite your curiosity. Challenge your mind. Master every quiz.**
  
  *A beautifully crafted, feature-rich quiz application that transforms learning into an addictive gaming experience.*
</div>

---

## ✨ What Makes Quizzler Special?

Quizzler isn't just another quiz app—it's a **comprehensive knowledge ecosystem** designed to challenge, educate, and entertain. Built with passion using Flutter and powered by Firebase, it delivers a seamless experience across all devices while keeping your progress synchronized in the cloud.

### 🎯 **Core Philosophy**
> *"Learning should be as engaging as gaming, as competitive as sports, and as rewarding as achievement."*

---

## 🚀 Features That Set Us Apart

### 🎮 **Immersive Quiz Experience**
- **📚 Diverse Categories**: From Science & Technology to History & Arts
- **🎯 Smart Difficulty**: Adaptive questioning that grows with your knowledge
- **⏱️ Customizable Timing**: Adjust question time limits to your preference
- **💡 Intelligent Hints**: Get contextual help when you need it most
- **🎵 Audio Feedback**: Immersive sound effects for correct/incorrect answers

### 🏆 **Competitive Gaming Elements**
- **🥇 Dynamic Leaderboards**: Real-time ranking with up to 50 top players
- **🎖️ Achievement System**: 20+ unique achievements to unlock
- **💰 Coin Economy**: Earn and spend coins for hints and power-ups
- **📊 Progress Tracking**: Detailed statistics and performance analytics
- **🔄 Daily Challenges**: Fresh content that keeps you coming back

### 👤 **Personalized Experience**
- **🖼️ Profile Customization**: Upload and sync profile pictures
- **📱 Smart Settings**: Comprehensive preferences that persist across devices
- **🌓 Theme Support**: Beautiful light and dark modes
- **🌍 Multi-language**: Support for 5+ languages
- **☁️ Cloud Sync**: Your progress follows you everywhere

### 🎨 **Beautiful Design**
- **🎭 Modern UI/UX**: Clean, intuitive interface with smooth animations
- **📱 Responsive Design**: Perfect experience on phones, tablets, and beyond
- **🎨 Visual Polish**: Thoughtful animations and micro-interactions
- **♿ Accessibility**: Designed for users of all abilities

### 🤖 **AI-Powered Quiz Generation**
- **🧠 Gemini AI Integration**: Generate custom quizzes on any topic using Google's Gemini AI
- **🎯 Customizable Parameters**: Choose topic, difficulty, number of questions, and quiz style
- **📝 Intelligent Question Creation**: AI generates contextually relevant multiple-choice questions
- **⚡ Instant Generation**: Create personalized quizzes in seconds
- **🔄 Seamless Integration**: AI-generated quizzes work with all existing features (scoring, achievements, etc.)
- **🎨 Smart Formatting**: Automatic parsing and formatting of AI responses into quiz format

---

## 📱 Screenshots

<div align="center">
  <img src="docs/screenshots/home.png" alt="Home Screen" width="200">
  <img src="docs/screenshots/quiz.png" alt="Quiz Screen" width="200">
  <img src="docs/screenshots/leaderboard.png" alt="Leaderboard" width="200">
  <img src="docs/screenshots/achievements.png" alt="Achievements" width="200">
</div>

---

## 🛠️ Technical Excellence

### **Architecture & Patterns**
- **🏗️ Clean Architecture**: Separation of concerns with repository pattern
- **🔄 State Management**: Reactive programming with GetX
- **🗄️ Data Layer**: Firestore for real-time data, GetStorage for local preferences
- **🔐 Authentication**: Firebase Auth with Google Sign-In integration
- **📡 Cloud Integration**: Real-time synchronization and offline support

### **Technology Stack**
```yaml
Frontend:     Flutter 3.5.4+ (Dart)
Backend:      Firebase (Firestore, Auth, Storage)
AI:           Google Gemini AI (firebase_ai)
State Mgmt:   GetX
UI/UX:        Custom widgets with ScreenUtil
Storage:      Cloud Firestore + Local GetStorage
Auth:         Firebase Auth + Google Sign-In
```

### **Key Dependencies**
- **🎨 UI/UX**: `google_fonts`, `flutter_screenutil`, `lottie`, `confetti`
- **⚡ State**: `get`, `get_storage`
- **🔥 Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_ai`
- **🛠️ Utilities**: `image_picker`, `share_plus`, `url_launcher`, `flutter_dotenv`

---

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK 3.5.4 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase project setup

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/quizmaster.git
   cd quizzler
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart` with your configuration

4. **Environment Configuration**
   ```bash
   # Create .env file in project root
   cp .env.example .env
   ```
   
   **Add your Gemini AI API key to the .env file:**
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```
   
   **Get your Gemini API key:**
   - Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
   - Create a new API key
   - Copy it to your .env file

5. **Run the application**
   ```bash
   flutter run
   ```

### **Build for Production**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📂 Project Structure

```
lib/
├── 🎯 main.dart                    # App entry point
├── 🔧 firebase_options.dart        # Firebase configuration
├── 📁 common/                      # Shared utilities and constants
├── 🎮 controller/                  # Business logic controllers
├── 📊 model/                       # Data models and entities
├── 🗄️ repository/                  # Data access layer
├── ⚙️ services/                    # Core business services
│   ├── 🏆 achievements_service.dart
│   ├── 🎯 enhanced_category_service.dart
│   ├── 🤖 gemini_ai_service.dart      # AI quiz generation
│   ├── 📊 leaderboard_service.dart
│   ├── 🔔 notification_service.dart
│   ├── ⚙️ settings_service.dart
│   └── 📚 quiz_history_service.dart
└── 🎨 views/                       # UI components and screens
    ├── 🏠 home/                    # Home screen and widgets
    ├── 📚 categories/              # Quiz categories
    ├── 🎯 quiz/                    # Quiz gameplay
    ├── 🏆 leaderboard/             # Rankings and scores
    ├── 👤 Profile/                 # User profile
    ├── 🎖️ achievements/            # Achievement system
    ├── 📊 Results/                 # Quiz results
    ├── ⚙️ screens/                 # Settings and other screens
    └── 🧩 widgets/                 # Reusable UI components
        ├── 🤖 custom_quiz_input_card.dart      # AI quiz input
        ├── 🎯 custom_quiz_generator_screen.dart # AI quiz form
        └── 🧠 ai_quiz_screen.dart               # AI quiz gameplay
```

---

## 🔥 Advanced Features

### **🎖️ Achievement System**
Quizzler features a sophisticated achievement system that tracks:
- **📈 Progress Milestones**: First quiz, 10th quiz, 100th quiz
- **💰 Coin Collection**: Earning and spending virtual currency
- **🎯 Perfect Scores**: Achieving 100% accuracy
- **📚 Category Mastery**: Completing quizzes across different subjects
- **⚡ Speed Challenges**: Time-based achievements

### **🏆 Intelligent Leaderboard**
- **🔄 Real-time Updates**: Instant ranking changes
- **🥇 Podium Display**: Special recognition for top 3 players
- **📊 Multiple Metrics**: Score, accuracy, speed combinations
- **👥 Social Features**: Profile pictures and user recognition

### **⚙️ Comprehensive Settings**
- **🎮 Game Preferences**: Difficulty, timing, hints
- **🔊 Audio Controls**: Sound effects, vibration feedback
- **🎨 Appearance**: Themes, languages, accessibility
- **☁️ Data Management**: Backup, restore, privacy controls

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### **🐛 Bug Reports**
Found a bug? Please create an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

### **✨ Feature Requests**
Have an idea? We'd love to hear it:
- Detailed feature description
- Use case scenarios
- Mockups or examples (if applicable)

### **💻 Code Contributions**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **📖 Documentation**
Help improve our documentation:
- Fix typos or unclear instructions
- Add examples and tutorials
- Translate to other languages

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 QuizMaster Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

### **🎨 Design Inspiration**
- Material Design 3.0 principles
- iOS Human Interface Guidelines
- Modern mobile app best practices

### **📚 Educational Content**
- Open Trivia Database for quiz questions
- Community-contributed content
- Educational institutions partnerships

### **🛠️ Open Source Libraries**
Special thanks to the Flutter community and all the amazing package authors who made this project possible.

---

*Made with ❤️ by the Quizzler Team*

**⭐ If you found this project helpful, please give it a star!**

</div>
