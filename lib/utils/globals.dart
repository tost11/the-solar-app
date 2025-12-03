import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global application settings and state
class Globals {
  // ValueNotifier allows widgets to listen for changes
  static final ValueNotifier<bool> expertModeNotifier = ValueNotifier<bool>(false);

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

  /// Initialize all global settings
  static Future<void> initialize() async {
    await loadExpertMode();
  }
}
