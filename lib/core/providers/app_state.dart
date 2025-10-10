import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('fa', 'IR');
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  AppState() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme preference
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      
      // Load locale preference
      final languageCode = prefs.getString('language_code') ?? 'fa';
      final countryCode = prefs.getString('country_code') ?? 'IR';
      _locale = Locale(languageCode, countryCode);
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_mode', mode.index);
      } catch (e) {
        debugPrint('Error saving theme preference: $e');
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language_code', locale.languageCode);
        await prefs.setString('country_code', locale.countryCode ?? '');
      } catch (e) {
        debugPrint('Error saving locale preference: $e');
      }
    }
  }
}