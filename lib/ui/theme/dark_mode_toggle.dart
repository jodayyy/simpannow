import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/theme_service.dart';
import 'package:simpannow/ui/theme/app_theme.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return GestureDetector(
      onTap: themeNotifier.toggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.getPrimaryColor(isDarkMode),
            width: 1,
          ),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
        child: Row(
          mainAxisAlignment:
              isDarkMode ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(
              isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
              color: AppTheme.getPrimaryColor(isDarkMode),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
