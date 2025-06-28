# SimpanNow - Personal Finance Companion

A comprehensive personal financial management application built with Flutter, designed to help users track their expenses, manage income, and build better financial habits.

## Overview

SimpanNow provides an intuitive platform for managing your personal finances with real-time transaction tracking, financial summaries, and secure cloud synchronization. The app features a modern, responsive design that works seamlessly across web and mobile platforms.

## Screenshots

*Screenshots coming soon - currently focusing on core functionality development*

## Features

### Core Functionality
- **User Authentication**
  - Secure email/password registration and login
  - "Remember me" functionality with persistent sessions
  - Password visibility toggle for better UX
  - Comprehensive error handling and user feedback

- **Transaction Management** ✨
  - Add income and expense transactions with categories
  - Real-time transaction tracking and history
  - Interactive transaction list with edit/delete capabilities
  - Predefined categories with emoji icons (Food 🍕, Transport 🚗, etc.)
  - Transaction filtering and search functionality

- **Financial Dashboard** ✨
  - Live financial summary with total balance calculation
  - Real-time income, expense, and balance tracking
  - Visual financial overview cards
  - Automatic balance updates based on transactions

- **User Profile Management**
  - Customizable username and profile settings
  - Profile viewing and editing capabilities
  - Secure user data synchronization with Firebase

- **UI/UX Excellence**
  - Responsive design optimized for web and mobile
  - Dark/light mode support with smooth transitions
  - Intuitive navigation with drawer and tab-based interface
  - Loading states and error handling throughout the app
  - Modern Material Design 3 styling

### Technical Features
- **Real-time Data Synchronization**
  - Cloud Firestore integration for instant updates
  - Offline capability with automatic sync when online
  - Stream-based UI updates for real-time user experience

- **Security & Performance**
  - Firebase Authentication with secure credential management
  - Firestore security rules for data protection
  - Optimized state management with Provider pattern
  - Input validation and sanitization

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
│   ├── services/           # Core business logic services
│   │   ├── auth_service.dart       # User authentication
│   │   ├── user_service.dart       # User profile management
│   │   ├── transaction_service.dart # Transaction CRUD operations
│   │   ├── theme_service.dart      # Theme management
│   │   └── firebase_service.dart   # Firebase configuration
│   └── utils/              # Utility functions and helpers
├── data/
│   └── models/             # Data models and entities
│       ├── user_model.dart         # User data structure
│       ├── transaction_model.dart  # Transaction data structure
│       └── financial_summary_model.dart # Financial summary calculations
└── ui/
    ├── components/         # Reusable UI components
    │   └── navigation/     # Navigation components
    ├── features/           # Feature-specific UI elements
    │   ├── transactions/   # Transaction-related widgets
    │   └── dark_mode_toggle.dart # Theme switching
    ├── screens/            # Main application screens
    │   ├── auth/          # Authentication screens
    │   ├── home/          # Home dashboard
    │   └── profile/       # User profile screens
    └── app_theme.dart     # Global theme configuration
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
   - **Important**: This file contains sensitive credentials and is gitignored for security

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
    - `email` (string) - User's email address
    - `username` (string, optional) - Display name
    - `createdAt` (timestamp) - Account creation date

- `users/{userId}/transactions` - User's financial transactions
  - Document ID: Auto-generated transaction ID
  - Fields:
    - `id` (string) - Transaction identifier
    - `userId` (string) - Reference to user
    - `title` (string) - Transaction description
    - `amount` (number) - Transaction amount
    - `type` (string) - "INCOME" or "EXPENSE"
    - `category` (string) - Transaction category
    - `description` (string, optional) - Additional notes
    - `createdAt` (timestamp) - Transaction date

### Security Rules
- Users can only access their own data
- Authentication required for all operations
- Transaction data is isolated per user

## Upcoming Features 🚀
- **Advanced Analytics**
  - Spending pattern analysis and insights
  - Monthly/yearly financial reports
  - Category-wise expense breakdown charts

- **Budgeting Tools**
  - Budget creation and management
  - Budget vs actual spending comparisons
  - Savings goal tracking

- **Enhanced User Experience**
  - Export transaction data (CSV, PDF)
  - Recurring transaction templates
  - Custom category creation
  - Transaction search and filtering
  - Notification system for budget alerts

## Contributing

We welcome contributions to SimpanNow! Please follow these guidelines:

### Development Setup
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing code style and patterns
4. Add tests for new functionality when applicable
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style
- Follow Dart/Flutter best practices
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

### Security
- Never commit Firebase configuration files
- Follow security best practices for user data
- Validate all user inputs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ using Flutter & Firebase**

*SimpanNow - Making personal finance management simple and accessible for everyone.*