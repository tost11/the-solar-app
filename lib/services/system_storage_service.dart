import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_solar_app/models/system.dart';

/// Service for persisting and retrieving systems
///
/// Uses SharedPreferences to store systems as JSON
/// Similar pattern to DeviceStorageService
class SystemStorageService {
  static const String _systemsKey = 'systems';

  /// Get all saved systems
  Future<List<System>> getAllSystems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? systemsJson = prefs.getString(_systemsKey);

    if (systemsJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(systemsJson);
      return decoded
          .map((json) => System.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading systems: $e');
      return [];
    }
  }

  /// Save or update a system
  Future<void> saveSystem(System system) async {
    final systems = await getAllSystems();

    // Update existing or add new
    final existingIndex = systems.indexWhere((s) => s.id == system.id);
    if (existingIndex != -1) {
      systems[existingIndex] = system;
    } else {
      systems.add(system);
    }

    await _saveSystems(systems);
  }

  /// Delete a system by ID
  Future<void> deleteSystem(String systemId) async {
    final systems = await getAllSystems();
    systems.removeWhere((s) => s.id == systemId);
    await _saveSystems(systems);
  }

  /// Internal: Save all systems to storage
  Future<void> _saveSystems(List<System> systems) async {
    final prefs = await SharedPreferences.getInstance();
    final systemsJson = jsonEncode(systems.map((s) => s.toJson()).toList());
    await prefs.setString(_systemsKey, systemsJson);
  }

  /// Get a single system by ID
  Future<System?> getSystemById(String systemId) async {
    final systems = await getAllSystems();
    try {
      return systems.firstWhere((s) => s.id == systemId);
    } catch (e) {
      return null;
    }
  }
}
