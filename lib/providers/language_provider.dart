 import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Language provider for managing app language
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');
  SharedPreferences? _prefs;

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  void changeLanguage(String languageCode) {
    switch (languageCode) {
      case 'English':
        _currentLocale = const Locale('en', '');
        break;
      case 'Français':
        _currentLocale = const Locale('fr', '');
        break;
      case 'Pidgin':
        _currentLocale = const Locale('pcm', '');
        break;
      default:
        _currentLocale = const Locale('en', '');
    }
    _saveLanguagePreference(languageCode);
    notifyListeners();
  }

  void _loadLanguagePreference() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedLanguage = _prefs?.getString('selectedLanguage');
    if (savedLanguage != null) {
      changeLanguage(savedLanguage);
    }
  }

  void _saveLanguagePreference(String language) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('selectedLanguage', language);
  }
}