# SimpanNow - Advanced Personal Finance Companion

A sophisticated personal financial management application built with Flutter, featuring intelligent monthly tracking, advanced analytics, and comprehensive financial insights.

## 🚀 Overview

SimpanNow transforms personal finance management with **monthly summaries**, **account management**, and **growth tracking** and many more. The app automatically captures your financial journey, providing deep insights into spending patterns, wealth growth, and financial health trends.

## 📈 Advanced Features

### Monthly Summaries ✨
- **Dual-Percentage Analytics**:
  - **Flow %**: Monthly cash flow as percentage of starting net worth (shows spending/earning impact)
  - **Growth %**: Actual wealth change month-over-month (shows real financial progress)

### Account Management ✨
- **Multiple Account Types**: Savings, Spending, Investment, Cash, E-Wallet with smart categorization
- **Real-time Balance Tracking**: Instant updates with transaction integration
- **Visual Distribution Analysis**: Interactive breakdowns with percentage allocations
- **Net Worth Calculation**: Comprehensive wealth tracking across all accounts

### Transaction System ✨
- **Smart Account Linking**: Transactions automatically update linked account balances
- **Category Management**: Predefined categories with emoji icons (Food 🍕, Transport 🚗, etc.)
- **Real-time Processing**: Instant transaction recording with immediate balance updates
- **Edit/Delete**: Proper balance recalculation when modifying historical transactions
- **Historical Impact Tracking**: Understanding how past transactions affect current financial state

### Interactive Financial Dashboard ✨
- **Live Current Month Summary**: Real-time income, expenses, and net flow tracking
- **Visual Progress Indicators**: Color-coded bars showing income vs expense ratios
- **Expandable Historical Trends**: Month-by-month analysis with detailed breakdowns
- **Interactive Legend System**: Built-in help dialogs explaining all metrics and calculations

- **User Profile Management**
### User Experience Excellence ✨
- **Interactive Help System**: Built-in legend dialogs for all financial metrics with color-coded explanations
- **Responsive Design**: Optimized for web and mobile with smooth transitions
- **Dark/Light Mode Support**: Seamless theme switching with user preference persistence
- **Intuitive Navigation**: Drawer and tab-based interface with logical information hierarchy
- **Modern Material Design 3**: Beautiful, accessible UI following Google's latest design principles

## 📊 Understanding Your Financial Data

### Key Metrics Explained

**Flow Percentage** 🟢
- Shows monthly cash flow impact relative to your starting wealth
- Formula: `(Monthly Net Flow ÷ Starting Net Worth) × 100`
- Example: -RM 4.90 from RM 4,003.32 = -0.12% flow

**Growth Percentage** 🔵  
- Shows actual wealth change month-over-month
- Formula: `((End Net Worth - Start Net Worth) ÷ Start Net Worth) × 100`
- Example: RM 6,499.17 from RM 3,998.42 = +62.54% growth

**Net Worth Calculation** 💰
- Sum of all account balances across all account types
- Real-time updates with every transaction
- Historical reconstruction for trend analysis

## 🛠️ Technologies & Architecture

### Core Technologies
- **Flutter & Dart** - Cross-platform UI framework with native performance
- **Firebase Ecosystem**:
  - **Authentication** - Secure user management with email/password
  - **Firestore** - Real-time NoSQL database with offline sync
  - **Security Rules** - Comprehensive data protection and access control
- **Provider** - Efficient state management with reactive UI updates
- **Font Awesome Flutter** - Rich icon library integration
- **Shared Preferences** - Local storage for user settings and preferences
- **Intl** - Internationalization and date formatting

### Advanced Architecture
- **Service-Oriented Design**: Clean separation of business logic and UI components
- **Stream-Based Reactivity**: Real-time data flow with automatic UI updates
- **Historical Data Processing**: Intelligent background calculation of financial trends
- **Error-Resilient Design**: Comprehensive error handling with graceful degradation

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

*SimpanNow - Making personal finance management simple and accessible for everyone.*
