import 'dart:convert';

import '../models/shelly_script_template.dart';
import '../models/shelly_script_parameter.dart';

/// Utilities for script template processing
class ScriptTemplateUtils {
  /// Substitute parameters in source code
  ///
  /// add variables as define on start of scirpt
  /// Also replaces metadata placeholders like {{VERSION}} and {{DESCRIPTION}}.
  ///
  /// Example:
  /// ```dart
  /// final code = substituteParameters(
  ///   'let URL = "{{BACKEND_URL}}";',
  ///   template,
  ///   {'BACKEND_URL': 'http://example.com'},
  /// );
  /// // Result: 'let URL = "http://example.com";'
  /// ```
  static String substituteParameters(
    String sourceCode,
    ShellyScriptTemplate template,
    Map<String, dynamic> parameterValues,
  ) {
    String result = sourceCode;

    // Replace parameter placeholders
    parameterValues.forEach((name, value) {
      String stringValue;
      if (value is String) {
        stringValue = value;
      } else if (value is bool) {
        stringValue = value.toString();
      } else if (value is num) {
        stringValue = value.toString();
      } else {
        stringValue = value.toString();
      }

      // Replace placeholder
      result = result.replaceAll('{{$name}}', stringValue);
    });

    // Replace metadata placeholders
    result = result.replaceAll('{{VERSION}}', template.version);
    result = result.replaceAll('{{DESCRIPTION}}', template.description);
    result = result.replaceAll('{{NAME}}', template.name);

    return result;
  }

  /// Generate complete script with auto-generated parameter declarations
  ///
  /// Creates script with embedded metadata and parameter tags for extraction.
  /// Parameters are auto-generated from template definitions, source code is appended as-is.
  ///
  /// Generated format:
  /// ```javascript
  /// // @TEMPLATE_META: {"template_id":"...","version":"...","deployment_id":"..."}
  /// //version 1.0.0
  /// // Description...
  ///
  /// // --- AUTO-GENERATED PARAMETERS ---
  /// // @PARAM: BACKEND_URL
  /// let BACKEND_URL = "http://example.com";
  /// // @PARAM: INTERVAL_MS
  /// let INTERVAL_MS = 10000;
  /// // --- END AUTO-GENERATED PARAMETERS ---
  ///
  /// // ... template source code ...
  /// ```
  static String generateScript(
    ShellyScriptTemplate template,
    Map<String, dynamic> parameterValues,
    String deploymentId,
  ) {
    final buffer = StringBuffer();

    // 1. Add template metadata header
    buffer.writeln('// @TEMPLATE_META: ${jsonEncode({
      "template_id": template.id,
      "version": template.version,
      "deployment_id": deploymentId,
      "deployed_at": DateTime.now().toIso8601String(),
    })}');

    // 2. Add metadata comments
    buffer.writeln('//version ${template.version}');
    buffer.writeln('// ${template.description}');
    buffer.writeln();

    // 3. Generate parameter declarations section
    buffer.writeln('// --- AUTO-GENERATED PARAMETERS ---');

    for (final param in template.parameters) {
      final value = parameterValues[param.name];
      final formattedValue = _formatValue(value, param.type);

      // Add @PARAM tag (parameter name only, value is in next line)
      buffer.writeln('// @PARAM: ${param.name}');
      buffer.writeln('let ${param.name} = $formattedValue;');
    }

    buffer.writeln('// --- END AUTO-GENERATED PARAMETERS ---');
    buffer.writeln();

    // 4. Append template source code (no modification needed)
    buffer.write(template.sourceCode);

    return buffer.toString();
  }

  /// Format value based on parameter type for JavaScript code
  ///
  /// - Strings, URLs, device names, topics: Quoted with escaped quotes
  /// - Numbers, ports, durations: Raw number
  /// - Booleans: true/false
  static String _formatValue(dynamic value, ScriptParameterType type) {
    if (value == null) return 'null';

    switch (type) {
      case ScriptParameterType.string:
      case ScriptParameterType.url:
        // Escape quotes in string
        final escaped = value.toString().replaceAll('"', r'\"');
        return '"$escaped"';

      case ScriptParameterType.number:
      case ScriptParameterType.port:
      case ScriptParameterType.duration:
        return value.toString();

      case ScriptParameterType.boolean:
        return value.toString();
    }
  }

  /// Validate parameter values against template requirements
  ///
  /// Returns a map of parameter name -> error message.
  /// Empty map means all parameters are valid.
  ///
  /// Checks:
  /// - Required parameters are present
  /// - Values match validation patterns (regex)
  /// - Numeric values are within min/max bounds
  /// - Port numbers are in valid range (1-65535)
  /// - URLs are well-formed (for url type)
  static Map<String, String> validateParameters(
    ShellyScriptTemplate template,
    Map<String, dynamic> values,
  ) {
    final errors = <String, String>{};

    for (final param in template.parameters) {
      final value = values[param.name];

      // Check required
      if (param.required && (value == null || value.toString().isEmpty)) {
        errors[param.name] = '${param.label} ist erforderlich';
        continue;
      }

      // Skip validation if value is not provided and not required
      if (value == null) continue;

      // Type-specific validation
      switch (param.type) {
        case ScriptParameterType.number:
        case ScriptParameterType.port:
        case ScriptParameterType.duration:
          if (!_isValidNumber(value)) {
            errors[param.name] = '${param.label} muss eine Zahl sein';
            break;
          }

          final numValue = _toNumber(value);
          if (numValue == null) {
            errors[param.name] = '${param.label} muss eine gültige Zahl sein';
            break;
          }

          // Check min/max bounds
          if (param.minValue != null && numValue < param.minValue!) {
            errors[param.name] = '${param.label} muss mindestens ${param.minValue} sein';
            break;
          }
          if (param.maxValue != null && numValue > param.maxValue!) {
            errors[param.name] = '${param.label} darf höchstens ${param.maxValue} sein';
            break;
          }

          // Port-specific validation
          if (param.type == ScriptParameterType.port) {
            if (numValue < 1 || numValue > 65535) {
              errors[param.name] = '${param.label} muss zwischen 1 und 65535 liegen';
              break;
            }
          }
          break;

        case ScriptParameterType.boolean:
          if (value is! bool && value.toString().toLowerCase() != 'true' && value.toString().toLowerCase() != 'false') {
            errors[param.name] = '${param.label} muss true oder false sein';
          }
          break;

        case ScriptParameterType.url:
          final urlString = value.toString();
          if (!_isValidUrl(urlString)) {
            errors[param.name] = param.validationErrorMessage ?? '${param.label} ist keine gültige URL';
          }
          break;

        default:
          // String, topic, deviceName - check regex pattern if provided
          if (param.validationPattern != null) {
            final regex = RegExp(param.validationPattern!);
            if (!regex.hasMatch(value.toString())) {
              errors[param.name] = param.validationErrorMessage ?? '${param.label} hat ein ungültiges Format';
            }
          }
      }

      // Additional regex validation if specified
      if (param.validationPattern != null && !errors.containsKey(param.name)) {
        final regex = RegExp(param.validationPattern!);
        if (!regex.hasMatch(value.toString())) {
          errors[param.name] = param.validationErrorMessage ?? '${param.label} hat ein ungültiges Format';
        }
      }
    }

    return errors;
  }

  /// Check if value is a valid number
  static bool _isValidNumber(dynamic value) {
    if (value is num) return true;
    if (value is String) {
      return double.tryParse(value) != null;
    }
    return false;
  }

  /// Convert value to number
  static double? _toNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Check if string is a valid URL
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Get default parameter values from template
  ///
  /// Returns a map of parameter name -> default value for all parameters
  /// that have a default value defined.
  static Map<String, dynamic> getDefaultParameterValues(ShellyScriptTemplate template) {
    final defaults = <String, dynamic>{};
    for (final param in template.parameters) {
      if (param.defaultValue != null) {
        defaults[param.name] = param.defaultValue;
      }
    }
    return defaults;
  }
}
