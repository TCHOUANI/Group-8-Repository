// lib/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: Colors.white,
      fontFamily: 'Roboto',
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: Colors.grey[800],
      colorScheme: const ColorScheme.dark(), // Ensure dark theme color scheme
      fontFamily: 'Roboto',
    );
  }

  void _loadThemePreference() {
    // Implement loading from SharedPreferences if you want theme persistence
    _isDarkMode = false; // Default to light mode for now
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}