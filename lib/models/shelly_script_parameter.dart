import 'parameter_source_config.dart';

/// Enumeration of parameter types for script template parameters
enum ScriptParameterType {
  /// Text input
  string,

  /// Numeric input (int/double)
  number,

  /// URL input with validation
  url,

  /// Port number (1-65535)
  port,

  /// Toggle switch
  boolean,

  /// Time duration (seconds, milliseconds)
  duration,

  /// Array of strings
  stringArray,
}

/// Configurable parameter for a script template
///
/// Defines a single parameter that can be configured by the user
/// before deploying a script template to a Shelly device.
class ScriptParameter {
  /// Parameter name in source code (e.g., "BACKEND_URL")
  final String name;

  /// Display label in UI (e.g., "Backend Server URL")
  final String label;

  /// Localized label translations (language code -> translation)
  final Map<String, String>? labelLng;

  /// Parameter description/help text
  final String description;

  /// Localized description translations (language code -> translation)
  final Map<String, String>? descriptionLng;

  /// Parameter data type
  final ScriptParameterType type;

  /// Default value (optional)
  final dynamic defaultValue;

  /// Whether parameter is required
  final bool required;

  /// Validation regex pattern (optional)
  final String? validationPattern;

  /// Error message for validation failure
  final String? validationErrorMessage;

  /// Minimum value (for number types)
  final double? minValue;

  /// Maximum value (for number types)
  final double? maxValue;

  /// Placeholder text for input field
  final String? placeholder;

  /// Whether this parameter is an advanced option (hidden by default)
  final bool advancedOption;

  /// Source configuration for auto-resolving parameter values from devices
  final ParameterSourceConfig? sourceConfig;

  ScriptParameter({
    required this.name,
    required this.label,
    this.labelLng,
    required this.description,
    this.descriptionLng,
    required this.type,
    this.defaultValue,
    required this.required,
    this.validationPattern,
    this.validationErrorMessage,
    this.minValue,
    this.maxValue,
    this.placeholder,
    this.advancedOption = false,
    this.sourceConfig,
  });

  /// Create a ScriptParameter from JSON
  factory ScriptParameter.fromJson(Map<String, dynamic> json) {
    return ScriptParameter(
      name: json['name'] as String,
      label: json['label'] as String,
      labelLng: json['label_lng'] != null
          ? Map<String, String>.from(json['label_lng'] as Map)
          : null,
      description: json['description'] as String,
      descriptionLng: json['description_lng'] != null
          ? Map<String, String>.from(json['description_lng'] as Map)
          : null,
      type: _parseParameterType(json['type'] as String),
      defaultValue: json['defaultValue'],
      required: json['required'] as bool? ?? false,
      validationPattern: json['validationPattern'] as String?,
      validationErrorMessage: json['validationErrorMessage'] as String?,
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      placeholder: json['placeholder'] as String?,
      advancedOption: json['advancedOption'] as bool? ?? false,
      sourceConfig: json['sourceConfig'] != null
          ? ParameterSourceConfig.fromJson(json['sourceConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      if (labelLng != null) 'label_lng': labelLng,
      'description': description,
      if (descriptionLng != null) 'description_lng': descriptionLng,
      'type': type.name,
      'defaultValue': defaultValue,
      'required': required,
      if (validationPattern != null) 'validationPattern': validationPattern,
      if (validationErrorMessage != null) 'validationErrorMessage': validationErrorMessage,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (placeholder != null) 'placeholder': placeholder,
      'advancedOption': advancedOption,
      if (sourceConfig != null) 'sourceConfig': sourceConfig!.toJson(),
    };
  }

  /// Parse parameter type from string
  static ScriptParameterType _parseParameterType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'string':
        return ScriptParameterType.string;
      case 'number':
        return ScriptParameterType.number;
      case 'url':
        return ScriptParameterType.url;
      case 'port':
        return ScriptParameterType.port;
      case 'boolean':
        return ScriptParameterType.boolean;
      case 'duration':
        return ScriptParameterType.duration;
      case 'stringarray':
        return ScriptParameterType.stringArray;
      default:
        return ScriptParameterType.string;
    }
  }

  @override
  String toString() {
    return 'ScriptParameter(name: $name, label: $label, type: $type, required: $required)';
  }
}
