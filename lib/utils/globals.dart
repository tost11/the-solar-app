import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global application settings and state
class Globals {
  // ValueNotifier allows widgets to listen for changes
  static final ValueNotifier<bool> expertModeNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<Locale> languageNotifier = ValueNotifier<Locale>(const Locale('de'));

  /// Get current expert mode state
  /// This getter maintains backward compatibility with existing code
  static bool get expertMode => expertModeNotifier.value;

  /// Set expert mode state and persist it
  /// Automatically notifies all listeners when value changes
  static Future<void> setExpertMode(bool value) async {
    expertModeNotifier.value = value;  // This triggers all listeners
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('expert_mode', value);
  }

  /// Load expert mode state from persistent storage
  static Future<void> loadExpertMode() async {
    final prefs = await SharedPreferences.getInstance();
    expertModeNotifier.value = prefs.getBool('expert_mode') ?? false;
  }

  /// Set language and persist it
  /// Automatically notifies all listeners when value changes
  static Future<void> setLanguage(String languageCode) async {
    languageNotifier.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  /// Load language state from persistent storage
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'de';
    languageNotifier.value = Locale(languageCode);
  }

  /// Initialize all global settings
  static Future<void> initialize() async {
    await loadExpertMode();
    await loadLanguage();
  }
}
