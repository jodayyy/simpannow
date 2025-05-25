# SimpanNow - Personal Finance Companion

## 🚧 Work in Progress 🚧

SimpanNow is currently under active development. The core authentication system and user profile management are functional, but many features are still being implemented.

## Overview

SimpanNow is a personal financial management application designed to help users track their expenses, manage budgets, and improve their financial habits.

## Features

### Currently Implemented
- **User Authentication**
  - Email/password registration and login
  - "Remember me" functionality
  - Password visibility toggle

- **User Profile Management**
  - Username customization
  - Profile viewing and editing

- **UI/UX**
  - Responsive design for various screen sizes
  - Dark mode support with easy toggle
  - Intuitive navigation with side drawer and bottom tabs

### Coming Soon
- **Transaction Tracking**
  - Add, edit, and categorize expenses and income
  - Transaction history and search

- **Budgeting Tools**
  - Create and manage budgets
  - Visual budget reports

- **Financial Insights**
  - Spending patterns analysis
  - Savings recommendations

## Technologies Used

- **Flutter & Dart** - Cross-platform UI framework
- **Firebase**
  - Authentication for user management
  - Firestore for data storage
  - Analytics for usage metrics
- **Provider** - State management
- **Font Awesome Flutter** - Icon pack integration
- **Shared Preferences** - Local storage for user settings
- **Flutter Toast** - User notifications

## Project Structure

```
lib/
├── core/
│   └── services/      # Core services (auth, user, Firebase)
├── data/
│   └── models/        # Data models
└── ui/
    ├── components/    # Reusable UI components
    ├── features/      # Feature-specific UI elements
    ├── screens/       # Main app screens
    └── app_theme.dart # Theme configuration
```

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter plugins
- Firebase account

### Firebase Setup

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password
3. Set up Firestore Database
4. Download the Firebase configuration files:
   - For Android: `google-services.json` to `android/app/`
   - For iOS: `GoogleService-Info.plist` to `ios/Runner/`
5. Create your Firebase service file:
   - Copy `lib/core/services/firebase_service.example.dart` to `lib/core/services/firebase_service.dart`
   - Replace the placeholder values in `firebase_service.dart` with your own Firebase project configuration
   - This file is gitignored to protect your Firebase credentials

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/simpannow.git
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase (as described above)

4. Run the app
   ```bash
   flutter run
   ```

## Firestore Database Structure

### Collections
- `users` - User profile information
  - Document ID: User UID
  - Fields:
    - email (string)
    - username (string, optional)
    - createdAt (timestamp)

## Contributing

As this project is still in development, contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.