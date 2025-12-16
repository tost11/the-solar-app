import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/shelly_script_template.dart';
import '../utils/version_utils.dart';

/// Service for loading and managing Shelly script templates
///
/// Loads templates from assets/ (bundled templates).
/// Organizes templates by ID and version for efficient lookup.
/// Future enhancement: also load from local storage (downloaded templates).
class ScriptTemplateService {
  /// Cache of loaded templates organized by ID and version
  /// Map structure: {template_id: [versions sorted newest to oldest]}
  static Map<String, List<ShellyScriptTemplate>>? _cachedTemplatesByIdVersion;

  /// Load all available script templates from assets
  ///
  /// Templates are loaded from assets/script_templates/*.json
  /// Results are cached and organized by ID and version for efficient lookup.
  /// Returns a flat list of all templates (all versions).
  static Future<List<ShellyScriptTemplate>> loadTemplates() async {
    if (_cachedTemplatesByIdVersion != null) {
      // Return flat list from cache (all versions)
      return _cachedTemplatesByIdVersion!.values
          .expand((list) => list)
          .toList();
    }

    final templates = <ShellyScriptTemplate>[];

    // Load asset manifest to find all template files
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filter for script_templates JSON files
    final templateFiles = manifestMap.keys
        .where((key) => key.startsWith('assets/script_templates/') && key.endsWith('.json'))
        .toList();

    // Load each template file
    for (final filePath in templateFiles) {
      try {
        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final template = ShellyScriptTemplate.fromJson(jsonData);
        templates.add(template);
      } catch (e) {
        print('Error loading template from $filePath: $e');
      }
    }

    // Organize by ID and version
    _cachedTemplatesByIdVersion = <String, List<ShellyScriptTemplate>>{};
    for (final template in templates) {
      _cachedTemplatesByIdVersion!
          .putIfAbsent(template.id, () => [])
          .add(template);
    }

    // Sort each template's versions (newest first)
    for (final versions in _cachedTemplatesByIdVersion!.values) {
      VersionUtils.sortTemplatesByVersion(versions);
    }

    return templates;
  }

  /// Get template by ID and optional version
  ///
  /// If [version] is null, returns the latest version (newest).
  /// If [version] is specified, returns that specific version if it exists.
  ///
  /// Returns null if template ID not found or specific version not found.
  static Future<ShellyScriptTemplate?> getTemplateById(
    String id, {
    String? version,
  }) async {
    await loadTemplates(); // Ensure cache is loaded

    final versions = _cachedTemplatesByIdVersion?[id];
    if (versions == null || versions.isEmpty) return null;

    if (version == null) {
      // Return latest version (first in sorted list)
      return versions.first;
    }

    // Find specific version
    try {
      return versions.firstWhere((t) => t.version == version);
    } catch (e) {
      return null;
    }
  }

  /// Get the latest version of a template by ID
  ///
  /// Returns null if template ID not found.
  static Future<ShellyScriptTemplate?> getLatestTemplateVersion(String id) async {
    return getTemplateById(id); // Default behavior is latest
  }

  /// Get all versions of a template by ID, sorted newest to oldest
  ///
  /// Returns empty list if template ID not found.
  static Future<List<ShellyScriptTemplate>> getAllTemplateVersions(String id) async {
    await loadTemplates();
    return _cachedTemplatesByIdVersion?[id] ?? [];
  }

  /// Check if a newer version exists for a template
  ///
  /// Compares [currentVersion] with the latest available version.
  /// Returns false if template not found or if current version is already the latest.
  static Future<bool> hasNewerVersion(String id, String currentVersion) async {
    final latest = await getLatestTemplateVersion(id);
    if (latest == null) return false;
    return VersionUtils.compareVersions(latest.version, currentVersion) > 0;
  }

  /// Filter templates by required devices
  ///
  /// Returns only templates where all required devices are available.
  /// If a template has no required devices, it is always included.
  ///
  /// [availableManufacturers] - Set of device manufacturers the user has
  /// (e.g., {"shelly", "zendure", "opendtu"})
  static List<ShellyScriptTemplate> filterByRequiredDevices(
    List<ShellyScriptTemplate> templates,
    Set<String> availableManufacturers,
  ) {
    return templates.where((template) {
      // No requirements = always show
      if (template.requiredDevices.isEmpty) return true;

      // Check if user has all required devices
      return template.requiredDevices.every((required) =>
          availableManufacturers.contains(required.toLowerCase()));
    }).toList();
  }

  /// Filter templates by tags
  static List<ShellyScriptTemplate> filterByTags(
    List<ShellyScriptTemplate> templates,
    List<String> tags,
  ) {
    if (tags.isEmpty) return templates;

    return templates.where((template) {
      return tags.any((tag) => template.tags.contains(tag));
    }).toList();
  }

  /// Filter templates by compatible devices
  static List<ShellyScriptTemplate> filterByCompatibleDevice(
    List<ShellyScriptTemplate> templates,
    String deviceModel,
  ) {
    return templates.where((template) {
      return template.compatibleDevices.isEmpty ||
          template.compatibleDevices.contains(deviceModel);
    }).toList();
  }

  /// Search templates by name or description
  static List<ShellyScriptTemplate> searchTemplates(
    List<ShellyScriptTemplate> templates,
    String query,
  ) {
    if (query.isEmpty) return templates;

    final lowerQuery = query.toLowerCase();
    return templates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
          template.description.toLowerCase().contains(lowerQuery) ||
          template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Clear template cache (useful for testing or forcing reload)
  static void clearCache() {
    _cachedTemplatesByIdVersion = null;
  }

  /// Get all unique tags from templates
  static Future<List<String>> getAllTags() async {
    final templates = await loadTemplates();
    final tagSet = <String>{};
    for (final template in templates) {
      tagSet.addAll(template.tags);
    }
    return tagSet.toList()..sort();
  }
}
