# SimpanNow

**SimpanNow** is a personal finance management application built using **Flutter**. It helps users manage their finances by providing features like user authentication, data storage, and analytics. The app is integrated with **Firebase** for backend services and supports both web and mobile platforms.

## Features

- **User Authentication**: Secure login and registration using Firebase Authentication.
- **User Data Management**: Store and retrieve user-specific data using Firestore.
- **Theming**: Supports light and dark themes.
- **Cross-Platform**: Works on Android, iOS, and Web.
- **Responsive UI**: Designed for a seamless user experience across devices.

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Analytics)
- **State Management**: Provider
- **UI Libraries**: Font Awesome, FlutterToast, SpinKit

## Getting Started

### Prerequisites

- Install [Flutter](https://flutter.dev/docs/get-started/install).
- Set up Firebase for your project:
  - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files.
  - Configure Firebase hosting for web.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/simpannow.git
   cd simpannow
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Firebase Configuration

Ensure Firebase is properly configured in your project:
- Update `firebase_options.dart` with your Firebase project details.
- Modify `firebase.json` for hosting and emulator settings.

### Setup Instructions

1. Copy the `firebase_service.example.dart` file to `firebase_service.dart`:
   ```bash
   cp lib/core/services/firebase_service.example.dart lib/core/services/firebase_service.dart
   ```

2. Replace the placeholder values in `firebase_service.dart` with your Firebase project configuration:
   - `YOUR_GOOGLE_API_KEY`
   - `YOUR_AUTH_DOMAIN`
   - `YOUR_PROJECT_ID`
   - `YOUR_STORAGE_BUCKET`
   - `YOUR_MESSAGING_SENDER_ID`
   - `YOUR_APP_ID`
   - `YOUR_MEASUREMENT_ID`

3. Ensure `firebase_service.dart` is not committed to the repository by verifying it is listed in `.gitignore`.

4. Run the application as usual:
   ```bash
   flutter run
   ```

### Folder Structure

```
simpannow/
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── lib/                    # Main application code
│   ├── core/               # Core services (e.g., Auth, Firebase)
│   ├── ui/                 # UI components and screens
│   ├── data/               # Data models
│   ├── features/           # Additional features (e.g., theming)
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Flutter dependencies
├── firebase.json           # Firebase hosting configuration
└── README.md               # Project documentation
```

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature-name"
   ```
4. Push to your branch:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

For questions or support, please contact:
- **Email**: your-email@example.com
- **GitHub**: [your-username](https://github.com/your-username)

## Status

This project is a work in progress. More features and updates are coming soon. Stay tuned!
