import 'dart:convert';
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

  // Auto script update
  static final ValueNotifier<bool> autoScriptUpdateNotifier = ValueNotifier<bool>(false);

  /// Get current auto script update state
  static bool get autoScriptUpdate => autoScriptUpdateNotifier.value;

  /// Set auto script update state and persist it
  static Future<void> setAutoScriptUpdate(bool value) async {
    autoScriptUpdateNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_script_update', value);
  }

  /// Load auto script update state from persistent storage
  static Future<void> loadAutoScriptUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    autoScriptUpdateNotifier.value = prefs.getBool('auto_script_update') ?? false;
  }

  // Debug logging settings
  static final ValueNotifier<String> logLevelNotifier = ValueNotifier<String>('info');
  static final ValueNotifier<Map<String, String>> categoryLogLevelsNotifier = 
      ValueNotifier<Map<String, String>>({});

  /// Default category log levels for fresh installations
  static const Map<String, String> _defaultCategoryLevels = {
    'bluetooth': 'default',
    'network': 'default',
    'device': 'default',
    'storage': 'default',
    'crypto': 'default',
    'ui': 'default',
    'system': 'default',
  };

  /// Get current global log level
  static String get logLevel => logLevelNotifier.value;

  /// Get per-category log levels
  /// Map format: {'bluetooth': 'default', 'network': 'verbose', 'system': 'info', ...}
  static Map<String, String> get categoryLogLevels => categoryLogLevelsNotifier.value;

  /// Set global log level and persist it
  static Future<void> setLogLevel(String level) async {
    logLevelNotifier.value = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('log_level', level);
  }

  /// Set category log levels and persist them
  static Future<void> setCategoryLogLevels(Map<String, String> levels) async {
    categoryLogLevelsNotifier.value = levels;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_log_levels', jsonEncode(levels));
  }

  /// Load debug settings from persistent storage
  /// Includes migration from old Set-based format to new Map-based format
  static Future<void> loadDebugSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load global level (unchanged)
    logLevelNotifier.value = prefs.getString('log_level') ?? 'info';
    
    // Try loading new format first
    final categoryLevelsJson = prefs.getString('category_log_levels');
    
    if (categoryLevelsJson != null) {
      // New format exists - use it
      try {
        categoryLogLevelsNotifier.value = Map<String, String>.from(
          jsonDecode(categoryLevelsJson)
        );
      } catch (e) {
        // Corrupted JSON - fallback to defaults
        categoryLogLevelsNotifier.value = Map<String, String>.from(_defaultCategoryLevels);
      }
    } else {
      // Check for old format (migration path)
      final oldCategories = prefs.getStringList('enabled_log_categories');
      
      if (oldCategories != null) {
        // MIGRATION: Convert old Set format to new Map format
        // Old: enabled → 'default', disabled → 'none'
        final migratedLevels = <String, String>{};
        
        for (final cat in ['bluetooth', 'network', 'device', 'storage', 'crypto', 'ui', 'system']) {
          migratedLevels[cat] = oldCategories.contains(cat) ? 'default' : 'none';
        }
        
        categoryLogLevelsNotifier.value = migratedLevels;
        
        // Save in new format and clean up old key
        await prefs.setString('category_log_levels', jsonEncode(migratedLevels));
        await prefs.remove('enabled_log_categories');
      } else {
        // Fresh install - use defaults and persist them
        categoryLogLevelsNotifier.value = Map<String, String>.from(_defaultCategoryLevels);
        await prefs.setString('category_log_levels', jsonEncode(_defaultCategoryLevels));
      }
    }
  }

  /// Initialize all global settings
  static Future<void> initialize() async {
    await loadExpertMode();
    await loadLanguage();
    await loadAutoScriptUpdate();
    await loadDebugSettings();
  }
}
