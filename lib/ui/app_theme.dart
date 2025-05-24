import 'package:flutter/material.dart';

class AppTheme {
  // Define dynamic colors
  static Color getPrimaryColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFFF2E403) : const Color(0xFF323232);
  static Color getSecondaryColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF00F0FF) : const Color(0xFFF2E403);
  static Color getBackgroundColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF323232) : Colors.white;

  // Dynamic theme configuration
  static ThemeData getThemeData(bool isDarkMode) {
    final primaryColor = getPrimaryColor(isDarkMode);
    final secondaryColor = getSecondaryColor(isDarkMode);
    final backgroundColor = getBackgroundColor(isDarkMode);

    return ThemeData(
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        background: backgroundColor,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: primaryColor,
        onBackground: primaryColor,
        onError: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: primaryColor,
          fontSize: 28,
        ),
        bodyLarge: TextStyle(
          color: primaryColor,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDarkMode ? const Color(0xFF323232) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        iconColor: primaryColor,
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
        labelStyle: TextStyle(color: primaryColor, fontSize: 16),
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}
