# SimpanNow

A simple and intuitive personal finance management app built with Flutter and Firebase.

## Overview

SimpanNow is a comprehensive personal finance tracker designed to help users manage their income, expenses, and account balances. The app provides real-time financial insights, historical data tracking, and an easy-to-use interface for managing personal finances.

## Features

- **Authentication**: Secure user registration and login with Firebase Auth
- **Transaction Management**: Add, edit, and delete income/expense transactions
- **Account Management**: Manage multiple financial accounts (savings, checking, etc.)
- **Transfer Management**: Seamlessly handle transfers between accounts.
- **Financial Summary**: Real-time overview of monthly income, expenses, and net flow
- **Historical Trends**: Track monthly financial data and growth percentages
- **Dark/Light Theme**: Toggle between dark and light modes
- **Responsive Design**: Optimized for web and mobile platforms

## Tech Stack

- **Frontend**: Flutter (Web/Mobile)
- **Backend**: Firebase (Firestore, Authentication)
- **State Management**: Provider
- **Icons**: Font Awesome Flutter

## Getting Started

### Prerequisites

- Flutter SDK (>=2.19.0 <3.0.0)
- Firebase project setup
- Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Replace the example Firebase configuration in `lib/core/services/firebase_service.dart`

4. Run the app:
   ```bash
   flutter run -d chrome  # For web
   flutter run             # For mobile
   ```

## Project Structure

```
lib/
├── core/
│   ├── services/          # Business logic and Firebase services
│   └── utils/             # Utility functions
├── data/
│   └── models/            # Data models
├── ui/
│   ├── components/        # Reusable UI components
│   ├── features/          # Feature-specific widgets
│   ├── screens/           # Application screens
│   └── theme/             # App theming
└── main.dart              # App entry point
```

## Usage

1. **Register/Login**: Create an account or log in with existing credentials
2. **Add Accounts**: Set up your financial accounts (optional)
3. **Track Transactions**: Add income and expense transactions
4. **Handle Transfers**: Transfer funds between accounts.
5. **View Summary**: Monitor your financial overview and trends
6. **Manage Data**: Edit or delete transactions as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*SimpanNow - Making personal finance management simple and accessible for everyone.*