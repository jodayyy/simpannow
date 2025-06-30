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

- **Account Management** ✨
  - Multiple account types (Savings, Spending, Investment, Cash, E-Wallet)
  - Real-time account balance tracking
  - Account overview with type-based categorization
  - Visual breakdown of account distribution
  - Net worth calculation across all accounts

- **Transaction Management** ✨
  - Add income and expense transactions with categories
  - Link transactions to specific accounts
  - Real-time transaction tracking and history
  - Interactive transaction list with edit/delete capabilities
  - Predefined categories with emoji icons (Food 🍕, Transport 🚗, etc.)
  - Transaction filtering and search functionality

- **Financial Dashboard** ✨
  - Live financial summary with net worth tracking
  - Real-time income, expense, and net flow monitoring
  - Monthly trends with percentage-based growth tracking
  - Net flow percentage relative to current net worth
  - Visual financial overview cards
  - Automatic balance updates based on transactions

- **Monthly Trends** ✨
  - Automatic monthly data capture
  - Historical net flow tracking
  - Growth percentage based on net worth
  - Month-by-month comparison
  - Visual trend indicators (positive/negative)

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
│   │   ├── account_service.dart    # Account management
│   │   ├── monthly_summary_service.dart # Monthly data tracking
│   │   ├── theme_service.dart      # Theme management
│   │   └── firebase_service.dart   # Firebase configuration
│   └── utils/              # Utility functions and helpers
├── data/
│   └── models/             # Data models and entities
│       ├── user_model.dart         # User data structure
│       ├── transaction_model.dart  # Transaction data structure
│       ├── account_model.dart      # Account data structure
│       ├── monthly_netflow_model.dart # Monthly tracking data
│       └── financial_summary_model.dart # Financial calculations
└── ui/
    ├── components/         # Reusable UI components
    │   └── navigation/     # Navigation components
    ├── features/           # Feature-specific UI elements
    │   ├── transactions/   # Transaction-related widgets
    │   ├── accounts/       # Account management widgets
    │   └── summaries/      # Financial summary widgets
    ├── screens/           # Main application screens
    │   ├── auth/          # Authentication screens
    │   ├── summary/       # Financial summary dashboard
    │   ├── accounts/      # Account management screens
    │   └── profile/       # User profile screens
    └── theme/             # Global theme configuration
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
4. Create your Firebase service file:
   - Copy `lib/core/services/firebase_service.example.dart` to `lib/core/services/firebase_service.dart`
   - Replace the placeholder values in `firebase_service.dart` with your own Firebase project configuration
   - **Important**: This file contains sensitive credentials and is gitignored for security

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/jodayyy/simpannow
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

- `users/{userId}/accounts` - User's financial accounts
  - Document ID: Auto-generated account ID
  - Fields:
    - `id` (string) - Account identifier
    - `userId` (string) - Reference to user
    - `name` (string) - Account name
    - `type` (string) - Account type (Savings, Spending, etc.)
    - `balance` (number) - Current balance
    - `description` (string, optional) - Additional notes
    - `createdAt` (timestamp) - Account creation date

- `users/{userId}/transactions` - User's financial transactions
  - Document ID: Auto-generated transaction ID
  - Fields:
    - `id` (string) - Transaction identifier
    - `userId` (string) - Reference to user
    - `accountId` (string, optional) - Reference to account
    - `title` (string) - Transaction description
    - `amount` (number) - Transaction amount
    - `type` (string) - "INCOME" or "EXPENSE"
    - `category` (string) - Transaction category
    - `description` (string, optional) - Additional notes
    - `createdAt` (timestamp) - Transaction date

- `users/{userId}/monthly_summaries` - Monthly financial data
  - Document ID: YYYY-MM format
  - Fields:
    - `year` (number) - Year of the summary
    - `month` (number) - Month number (1-12)
    - `monthName` (string) - Month name
    - `netFlow` (number) - Net income for the month
    - `netWorthChangePercentage` (number) - Growth percentage
    - `capturedAt` (timestamp) - Data capture date

### Security Rules
- Users can only access their own data
- Authentication required for all operations
- Transaction and account data is isolated per user
- Monthly summaries are automatically generated

## Upcoming Features 🚀
- **Advanced Analytics**
  - Spending pattern analysis and insights
  - Monthly/yearly financial reports
  - Category-wise expense breakdown charts
  - Account performance tracking

- **Budgeting Tools**
  - Budget creation and management
  - Budget vs actual spending comparisons
  - Savings goal tracking per account
  - Investment portfolio tracking

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