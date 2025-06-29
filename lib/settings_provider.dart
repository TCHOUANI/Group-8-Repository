// lib/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persisting settings

class SettingsProvider with ChangeNotifier {
  bool _voiceAlerts = false;

  bool get voiceAlerts => _voiceAlerts;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _voiceAlerts = prefs.getBool('voiceAlerts') ?? false;
    notifyListeners();
  }

  Future<void> setVoiceAlerts(bool value) async {
    _voiceAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceAlerts', value);
    notifyListeners();
  }
}