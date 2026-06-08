import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/shelly_script_template.dart';
import '../utils/version_utils.dart';

/// Service for loading and managing Shelly script templates
///
/// Supports two-tier template system:
/// - Asset templates (bundled, read-only)
/// - User templates (imported, editable)
///
/// User templates can override asset templates with same ID+version.
class ScriptTemplateService {
  /// Cache of loaded templates organized by ID and version
  /// Map structure: {template_id: [versions sorted newest to oldest]}
  static Map<String, List<ShellyScriptTemplate>>? _cachedTemplatesByIdVersion;

  /// Load all available script templates (assets + user)
  ///
  /// Templates are loaded from both assets/ and user directory.
  /// User templates override assets with same ID+version.
  /// Results are cached and organized by ID and version for efficient lookup.
  /// Returns a flat list of all templates (all versions).
  static Future<List<ShellyScriptTemplate>> loadTemplates() async {
    if (_cachedTemplatesByIdVersion != null) {
      // Return flat list from cache (all versions)
      return _cachedTemplatesByIdVersion!.values
          .expand((list) => list)
          .toList();
    }

    // Load asset templates
    final assetTemplates = await _loadAssetTemplates();

    // Load user templates
    final userTemplates = await loadUserTemplates();

    // Merge: user templates override assets with same ID+version
    _cachedTemplatesByIdVersion = <String, List<ShellyScriptTemplate>>{};

    // Add asset templates first
    for (final template in assetTemplates) {
      _cachedTemplatesByIdVersion!
          .putIfAbsent(template.id, () => [])
          .add(template);
    }

    // Add/override with user templates
    for (final template in userTemplates) {
      final versions = _cachedTemplatesByIdVersion!
          .putIfAbsent(template.id, () => []);

      // Remove asset template with same version if exists
      versions.removeWhere((t) =>
          t.version == template.version && t.source == TemplateSource.asset);

      versions.add(template);
    }

    // Sort each template's versions (newest first)
    for (final versions in _cachedTemplatesByIdVersion!.values) {
      VersionUtils.sortTemplatesByVersion(versions);
    }

    return _cachedTemplatesByIdVersion!.values
        .expand((list) => list)
        .toList();
  }

  /// Load asset templates from bundled files
  static Future<List<ShellyScriptTemplate>> _loadAssetTemplates() async {
    final templates = <ShellyScriptTemplate>[];

    try {
      // Try to load asset manifest to find all template files
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
          final template = ShellyScriptTemplate.fromJson(
            jsonData,
            source: TemplateSource.asset,
          );
          templates.add(template);
        } catch (e) {
          print('Error loading template from $filePath: $e');
        }
      }
    } catch (e) {//TODO find out why this is needed and fix it (manifest file is missing but it shouldn)
      // AssetManifest.json not found - fallback to known template files
      print('Warning: AssetManifest.json not found, using fallback template loading: $e');

      // Hardcoded list of known template files (update when adding new templates)
      final knownTemplates = [
        'assets/script_templates/test_script_v1.json',
        'assets/script_templates/zendure_power_control_ip_v1.json',
        'assets/script_templates/zendure_power_control_ip_v2.json',
        'assets/script_templates/zendure_power_control_ip_v2-0-1.json',
        'assets/script_templates/zendure_power_control_mac_v1.json',
        'assets/script_templates/zendure_power_control_mac_v2.json',
        'assets/script_templates/zendure_power_control_mac_v2-0-1.json',
        'assets/script_templates/zendure_power_control_find_v2.json',
        'assets/script_templates/zendure_power_control_find_v2-0-1.json',
        'assets/script_templates/zendure_online_monitoring_find_v1.json',
        'assets/script_templates/zendure_online_monitoring_find_v1-1-0.json',
        'assets/script_templates/zendure_online_monitoring_ip_v1.json',
        'assets/script_templates/zendure_online_monitoring_ip_v1-1-0.json',
        'assets/script_templates/zendure_online_monitoring_mac_v1.json',
        'assets/script_templates/zendure_online_monitoring_mac_v1-1-0.json',
        'assets/script_templates/opendtu_power_control_v1.json',
        'assets/script_templates/script_watchdog_v1.json',
      ];

      for (final filePath in knownTemplates) {
        try {
          final jsonString = await rootBundle.loadString(filePath);
          final jsonData = json.decode(jsonString) as Map<String, dynamic>;
          final template = ShellyScriptTemplate.fromJson(
            jsonData,
            source: TemplateSource.asset,
          );
          templates.add(template);
        } catch (e) {
          // Template file doesn't exist or is invalid - skip it
          print('Could not load template $filePath: $e');
        }
      }
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

  /// Get user templates directory
  static Future<Directory> _getUserTemplatesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/script_templates/user');
  }

  /// Load user templates from file system
  static Future<List<ShellyScriptTemplate>> loadUserTemplates() async {
    final templates = <ShellyScriptTemplate>[];
    final directory = await _getUserTemplatesDirectory();

    if (!await directory.exists()) {
      await directory.create(recursive: true);
      return templates;
    }

    final files = directory.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));

    for (final file in files) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final template = ShellyScriptTemplate.fromJson(
          json,
          source: TemplateSource.user,
          filePath: file.path,
        );
        templates.add(template);
      } catch (e) {
        print('Error loading user template ${file.path}: $e');
      }
    }

    return templates;
  }

  /// Save user template to file system
  static Future<void> _saveUserTemplate(ShellyScriptTemplate template) async {
    final directory = await _getUserTemplatesDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filename = '${template.id}_${template.version}.json';
    final file = File('${directory.path}/$filename');

    final json = template.toJson();
    final content = const JsonEncoder.withIndent('  ').convert(json);
    await file.writeAsString(content);
  }

  /// Import template from JSON string
  static Future<ShellyScriptTemplate> importTemplate(
    String jsonString, {
    bool overrideExisting = false,
  }) async {
    // Parse and validate JSON
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final template = ShellyScriptTemplate.fromJson(
      json,
      source: TemplateSource.user,
    );

    // Validate required fields
    if (template.id.isEmpty) {
      throw Exception('Template ID is required');
    }
    if (template.version.isEmpty) {
      throw Exception('Template version is required');
    }
    if (template.sourceCode.isEmpty) {
      throw Exception('Template source code is required');
    }

    // Check for existing templates with same ID
    if (overrideExisting) {
      // Delete ALL existing user template versions with same ID
      final allVersions = await getAllTemplateVersions(template.id);
      final userVersions = allVersions.where((t) => t.source == TemplateSource.user);

      for (final existingTemplate in userVersions) {
        try {
          await deleteUserTemplate(existingTemplate);
        } catch (e) {
          print('Warning: Failed to delete existing template version ${existingTemplate.version}: $e');
        }
      }
    } else {
      // Check for existing template with same ID+version
      final existing = await getTemplateById(template.id, version: template.version);
      if (existing != null) {
        if (existing.source == TemplateSource.user) {
          throw Exception('Template ${template.id} v${template.version} already exists');
        }
        // Allow overriding asset templates
      }
    }

    // Save to file system
    await _saveUserTemplate(template);

    // Clear cache to force reload
    clearCache();

    return template;
  }

  /// Export template to JSON string
  static String exportTemplate(ShellyScriptTemplate template) {
    final json = template.toJson();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// Delete user template
  static Future<void> deleteUserTemplate(ShellyScriptTemplate template) async {
    if (template.source != TemplateSource.user) {
      throw Exception('Cannot delete asset templates');
    }

    if (template.filePath != null) {
      final file = File(template.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    clearCache();
  }

  /// Update user template
  static Future<void> updateUserTemplate(ShellyScriptTemplate template) async {
    if (template.source != TemplateSource.user) {
      throw Exception('Cannot update asset templates');
    }

    await _saveUserTemplate(template);
    clearCache();
  }
}
