import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/shelly_script_template.dart';
import '../utils/version_utils.dart';

/// Base URL for fetching remote template updates.
///
/// Override for debug/testing with mock server:
///   flutter run --dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:8085
///
/// Default: GitHub raw content URL for production use.
const String _remoteManifestBaseUrl = String.fromEnvironment(
  'SCRIPT_UPDATE_BASE_URL',
  defaultValue: 'https://raw.githubusercontent.com/tost11/the-solar-app/main/assets/script_templates',
);

/// Service for loading and managing Shelly script templates
///
/// Supports two-tier template system:
/// - Asset templates (bundled, read-only)
/// - User templates (imported, editable)
///
/// User templates can override asset templates with same ID+version.
/// Remote updates are fetched from GitHub repository on user request.
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

  /// Load asset templates from bundled files (folder-based structure)
  ///
  /// Structure: assets/script_templates/{template-id}/versions.json
  ///            assets/script_templates/{template-id}/{template-id}_v{version}.json
  static Future<List<ShellyScriptTemplate>> _loadAssetTemplates() async {
    final templates = <ShellyScriptTemplate>[];

    try {
      // Try to load asset manifest to find all template files
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter for script_templates JSON files in subdirectories
      // Exclude manifest.json and versions.json files
      final templateFiles = manifestMap.keys
          .where((key) =>
              key.startsWith('assets/script_templates/') &&
              key.endsWith('.json') &&
              !key.endsWith('manifest.json') &&
              !key.endsWith('versions.json') &&
              key.split('/').length == 4) // Only files in subdirectories
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
    } catch (e) {
      // AssetManifest.json not found - fallback to loading via local manifest
      print('Warning: AssetManifest.json not found, using fallback template loading: $e');
      await _loadAssetTemplatesFallback(templates);
    }

    return templates;
  }

  /// Fallback loading method using the bundled manifest.json
  ///
  /// Used when AssetManifest.json is not available (e.g., Linux desktop builds).
  static Future<void> _loadAssetTemplatesFallback(
    List<ShellyScriptTemplate> templates,
  ) async {
    try {
      // Load our own manifest.json
      final manifestString = await rootBundle.loadString(
        'assets/script_templates/manifest.json',
      );
      final manifest = json.decode(manifestString) as Map<String, dynamic>;
      final templateEntries = manifest['templates'] as List<dynamic>;

      for (final entry in templateEntries) {
        final templateId = entry['id'] as String;

        // Load versions.json for this template
        try {
          final versionsString = await rootBundle.loadString(
            'assets/script_templates/$templateId/versions.json',
          );
          final versionsData = json.decode(versionsString) as Map<String, dynamic>;
          final versions = versionsData['versions'] as List<dynamic>;

          // Load each version file
          for (final versionEntry in versions) {
            final fileName = versionEntry['fileName'] as String;
            final filePath = 'assets/script_templates/$templateId/$fileName';

            try {
              final jsonString = await rootBundle.loadString(filePath);
              final jsonData = json.decode(jsonString) as Map<String, dynamic>;
              final template = ShellyScriptTemplate.fromJson(
                jsonData,
                source: TemplateSource.asset,
              );
              templates.add(template);
            } catch (e) {
              print('Could not load template $filePath: $e');
            }
          }
        } catch (e) {
          print('Could not load versions.json for $templateId: $e');
        }
      }
    } catch (e) {
      print('Error loading manifest.json fallback: $e');
    }
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
    if (!VersionUtils.isValidSemanticVersion(template.version)) {
      throw Exception(
        'Template version "${template.version}" is not a valid semantic version (expected X.Y.Z)',
      );
    }
    if (template.sourceCode.isEmpty) {
      throw Exception('Template source code is required');
    }

    // Validate parameters have required sub-fields
    for (final param in template.parameters) {
      if (param.name.isEmpty) {
        throw Exception(
          'Template "${template.id}": Parameter has empty name',
        );
      }
      if (param.label.isEmpty) {
        throw Exception(
          'Template "${template.id}": Parameter "${param.name}" has empty label',
        );
      }
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

  // ===== Remote Update Methods =====

  /// Fetch the global manifest from the remote repository.
  ///
  /// Returns parsed manifest data or null if fetch fails.
  /// Manifest contains list of all templates with their latest versions.
  static Future<Map<String, dynamic>?> fetchRemoteManifest() async {
    try {
      final response = await http.get(
        Uri.parse('$_remoteManifestBaseUrl/manifest.json'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Failed to fetch remote manifest: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching remote manifest: $e');
      return null;
    }
  }

  /// Fetch the versions.json for a specific template from remote repository.
  ///
  /// [updatePath] is the base URL for the template folder.
  /// Returns parsed versions data or null if fetch fails.
  static Future<Map<String, dynamic>?> fetchRemoteVersionManifest(
    String updatePath,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$updatePath/versions.json'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Failed to fetch remote versions.json from $updatePath: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching remote versions.json from $updatePath: $e');
      return null;
    }
  }

  /// Download a specific template version from remote repository.
  ///
  /// [updatePath] is the base URL for the template folder.
  /// [fileName] is the template JSON filename (e.g., "script-watchdog_v1-1-1.json").
  /// Returns the parsed template or null if download fails.
  static Future<ShellyScriptTemplate?> downloadRemoteTemplate(
    String updatePath,
    String fileName,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$updatePath/$fileName'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ShellyScriptTemplate.fromJson(
          jsonData,
          source: TemplateSource.user,
        );
      }
      print('Failed to download template $fileName from $updatePath: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error downloading template $fileName from $updatePath: $e');
      return null;
    }
  }

  /// Check for available remote updates for all templates.
  ///
  /// Fetches the remote manifest and compares with locally available versions.
  /// Returns a list of [RemoteUpdateInfo] for templates with newer versions available.
  /// Returns null if the remote manifest could not be fetched (network error).
  static Future<List<RemoteUpdateInfo>?> checkForRemoteUpdates() async {
    final manifest = await fetchRemoteManifest();
    if (manifest == null) return null;

    final remoteTemplates = manifest['templates'] as List<dynamic>?;
    if (remoteTemplates == null) return null;

    // Ensure local templates are loaded
    await loadTemplates();

    final updates = <RemoteUpdateInfo>[];

    for (final entry in remoteTemplates) {
      final templateId = entry['id'] as String;
      final remoteLatestVersion = entry['latestVersion'] as String;
      final updatePath = entry['updatePath'] as String;

      // Get local latest version
      final localVersions = _cachedTemplatesByIdVersion?[templateId];
      final localLatestVersion = localVersions?.isNotEmpty == true
          ? localVersions!.first.version
          : null;

      // Compare versions
      if (localLatestVersion == null ||
          VersionUtils.compareVersions(remoteLatestVersion, localLatestVersion) > 0) {
        updates.add(RemoteUpdateInfo(
          templateId: templateId,
          localVersion: localLatestVersion,
          remoteVersion: remoteLatestVersion,
          updatePath: updatePath,
        ));
      }
    }

    return updates;
  }

  /// Download and install a remote template update.
  ///
  /// Fetches the versions.json, finds the target version,
  /// downloads the template, and imports it as a user template.
  /// Returns the imported template or null on failure.
  static Future<ShellyScriptTemplate?> installRemoteUpdate(
    RemoteUpdateInfo updateInfo,
  ) async {
    // Fetch versions.json to get the filename for the latest version
    final versionsData = await fetchRemoteVersionManifest(updateInfo.updatePath);
    if (versionsData == null) return null;

    final versions = versionsData['versions'] as List<dynamic>?;
    if (versions == null || versions.isEmpty) return null;

    // Find the target version entry
    String? targetFileName;
    for (final v in versions) {
      if (v['version'] == updateInfo.remoteVersion) {
        targetFileName = v['fileName'] as String?;
        break;
      }
    }

    if (targetFileName == null) {
      print('Could not find fileName for version ${updateInfo.remoteVersion}');
      return null;
    }

    // Download the template
    final template = await downloadRemoteTemplate(
      updateInfo.updatePath,
      targetFileName,
    );
    if (template == null) return null;

    // Import as user template (overrides existing)
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(template.toJson());
      final imported = await importTemplate(jsonString, overrideExisting: true);
      return imported;
    } catch (e) {
      print('Error importing remote template: $e');
      return null;
    }
  }

  /// Get user-imported templates that have an updatePath and are NOT built-in (asset) templates.
  ///
  /// Returns only the latest version per template ID.
  /// Excludes templates that also exist as asset templates (those are handled by the manifest check).
  static Future<List<ShellyScriptTemplate>> getCustomUpdatableTemplates() async {
    await loadTemplates();
    if (_cachedTemplatesByIdVersion == null) return [];

    final result = <ShellyScriptTemplate>[];

    for (final entry in _cachedTemplatesByIdVersion!.entries) {
      final versions = entry.value;
      // Skip if any version is an asset template (built-in, handled by manifest)
      final hasAssetVersion = versions.any((t) => t.source == TemplateSource.asset);
      if (hasAssetVersion) continue;

      // Only include if latest version has an updatePath
      final latest = versions.first; // sorted newest first
      if (latest.updatePath != null) {
        result.add(latest);
      }
    }
    return result;
  }

  /// Check for update of a single template using its own updatePath.
  ///
  /// Fetches the template's versions.json from its updatePath,
  /// finds the highest available version, and compares with the local version.
  /// Returns [RemoteUpdateInfo] if an update is available, null if up-to-date or on error.
  static Future<RemoteUpdateInfo?> checkForSingleTemplateUpdate(
    ShellyScriptTemplate template,
  ) async {
    if (template.updatePath == null) return null;

    final versionsData = await fetchRemoteVersionManifest(template.updatePath!);
    if (versionsData == null) return null;

    final versions = versionsData['versions'] as List<dynamic>?;
    if (versions == null || versions.isEmpty) return null;

    // Find latest version in remote versions.json
    String? latestRemoteVersion;
    for (final v in versions) {
      final ver = v['version'] as String?;
      if (ver == null) continue;
      if (!VersionUtils.isValidSemanticVersion(ver)) continue;
      if (latestRemoteVersion == null ||
          VersionUtils.compareVersions(ver, latestRemoteVersion) > 0) {
        latestRemoteVersion = ver;
      }
    }

    if (latestRemoteVersion == null) return null;
    if (VersionUtils.compareVersions(latestRemoteVersion, template.version) <= 0) {
      return null; // up-to-date
    }

    return RemoteUpdateInfo(
      templateId: template.id,
      localVersion: template.version,
      remoteVersion: latestRemoteVersion,
      updatePath: template.updatePath!,
    );
  }
}

/// Information about a remotely available template update
class RemoteUpdateInfo {
  /// Template ID
  final String templateId;

  /// Currently installed local version (null if not installed locally)
  final String? localVersion;

  /// Latest available remote version
  final String remoteVersion;

  /// Base URL for fetching the template files
  final String updatePath;

  const RemoteUpdateInfo({
    required this.templateId,
    required this.localVersion,
    required this.remoteVersion,
    required this.updatePath,
  });

  /// Whether this is a new template (not installed locally)
  bool get isNewTemplate => localVersion == null;

  @override
  String toString() =>
      'RemoteUpdateInfo($templateId: ${localVersion ?? "not installed"} -> $remoteVersion)';
}
