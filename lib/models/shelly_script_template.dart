import 'shelly_script_parameter.dart';

/// Template for a Shelly script with configurable parameters
///
/// Templates exist ONLY in the app (for script creation).
/// Final scripts are stored ON THE SHELLY DEVICE (in compiled form).
/// This is a deployment helper system to simplify script creation.
class ShellyScriptTemplate {
  /// Unique template ID (e.g., "influx-reporter-v1")
  final String id;

  /// Display name shown in UI
  final String name;

  /// Template version (semantic versioning)
  final String version;

  /// Description shown in template selection
  final String description;

  /// Compatible Shelly device models (e.g., ["Plug S Gen3", "Plus 1PM"])
  final List<String> compatibleDevices;

  /// Required device manufacturers for this script to work
  /// Script will only be shown if user has all required devices
  /// Example: ["zendure", "opendtu"] - script integrates both devices
  /// Empty list means no device requirements (Shelly-only script)
  final List<String> requiredDevices;

  /// Script source code with parameter placeholders
  /// Placeholders format: {{PARAMETER_NAME}}
  final String sourceCode;

  /// List of configurable parameters
  final List<ScriptParameter> parameters;

  /// Script author (optional)
  final String? author;

  /// Tags for categorization (e.g., ["monitoring", "automation"])
  final List<String> tags;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  ShellyScriptTemplate({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.compatibleDevices,
    required this.requiredDevices,
    required this.sourceCode,
    required this.parameters,
    this.author,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ShellyScriptTemplate from JSON
  factory ShellyScriptTemplate.fromJson(Map<String, dynamic> json) {
    return ShellyScriptTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      compatibleDevices: (json['compatibleDevices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      requiredDevices: (json['requiredDevices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sourceCode: json['sourceCode'] as String,
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) => ScriptParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      author: json['author'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'description': description,
      'compatibleDevices': compatibleDevices,
      'requiredDevices': requiredDevices,
      'sourceCode': sourceCode,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      if (author != null) 'author': author,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ShellyScriptTemplate(id: $id, name: $name, version: $version, parameters: ${parameters.length})';
  }
}
