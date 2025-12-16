import 'dart:convert';

/// Utility class for extracting template metadata and parameters from deployed Shelly scripts
///
/// Supports the script template system by parsing embedded metadata comments
/// and parameter tags in generated script code.
class ScriptParameterExtractor {
  /// Extract template metadata from script code
  ///
  /// Looks for `// @TEMPLATE_META: {...}` comment and parses JSON
  ///
  /// Returns null if no metadata found or JSON parsing fails
  static Map<String, dynamic>? extractTemplateMetadata(String code) {
    final metaRegex = RegExp(r'// @TEMPLATE_META: ({.*})');
    final match = metaRegex.firstMatch(code);

    if (match == null) return null;

    try {
      return jsonDecode(match.group(1)!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Extract parameter values from script code
  ///
  /// Looks for `// @PARAM: NAME` tags followed by `let/const/var NAME = value;`
  ///
  /// Returns map of parameter names to their current values
  static Map<String, dynamic> extractParameters(String code) {
    final params = <String, dynamic>{};

    // Match @PARAM tag followed by let/const/var declaration on next line
    final paramRegex = RegExp(
      r'// @PARAM: (\w+)\s*\n\s*(?:let|const|var)\s+\1\s*=\s*(.+?);',
      multiLine: true,
    );

    for (final match in paramRegex.allMatches(code)) {
      final name = match.group(1)!;
      final valueStr = match.group(2)!.trim();

      // Parse value based on type
      final value = _parseValue(valueStr);
      params[name] = value;
    }

    return params;
  }

  /// Parse string value to appropriate type
  ///
  /// Handles strings (quoted), numbers, and booleans
  static dynamic _parseValue(String valueStr) {
    // Remove quotes for strings
    if (valueStr.startsWith('"') && valueStr.endsWith('"')) {
      // Unescape quotes
      return valueStr
          .substring(1, valueStr.length - 1)
          .replaceAll(r'\"', '"');
    }

    // Try parsing as number
    final numValue = num.tryParse(valueStr);
    if (numValue != null) return numValue;

    // Try parsing as boolean
    if (valueStr == 'true') return true;
    if (valueStr == 'false') return false;

    // Default to string
    return valueStr;
  }

  /// Check if script was created from template
  ///
  /// Template scripts use naming convention: `__auto_{template-id}_{version}_{deployment-id}`
  /// (Legacy: `__automatisation_{template-id}_{version}_{deployment-id}`)
  static bool isTemplateScript(String scriptName) {
    return scriptName.startsWith('__auto_') ||
           scriptName.startsWith('__automatisation_');
  }

  /// Parse script name to extract metadata
  ///
  /// Expected format: `__auto_{template-id}_{version}_{deployment-id}`
  /// (Legacy format: `__automatisation_{template-id}_{version}_{deployment-id}`)
  ///
  /// Returns null if name doesn't match template format
  static Map<String, String>? parseScriptName(String scriptName) {
    if (!isTemplateScript(scriptName)) return null;

    // Format: __auto_{template-id}_{version}_{deployment-id}
    // Legacy: __automatisation_{template-id}_{version}_{deployment-id}
    final parts = scriptName.split('_');
    if (parts.length < 5) return null;

    // NEW format: ["", "", "auto", "{template-id}", "{version}", "{deployment-id}"]
    // OLD format: ["", "", "automatisation", "{template-id}", "{version}", "{deployment-id}"]
    // Both have template_id at index 3, version at 4, deployment_id at 5+
    return {
      'template_id': parts[3],
      'version': parts[4],
      'deployment_id': parts.length > 5 ? parts[5] : parts[4],
    };
  }
}
