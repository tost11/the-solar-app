import 'dart:convert';
import 'dart:io';

/// Validation tool for Shelly script templates
///
/// Usage: dart run lib/tools/validate_script_templates.dart [path_to_templates]
///
/// Validates script templates for common issues:
/// - Duplicate variable declarations (parameters also declared in sourceCode)
/// - Missing parameter definitions for uppercase variables
/// - Unused parameters
/// - Invalid semantic versioning
///
/// This tool should be run before importing new templates from zendure-shelly-tools
/// to catch issues early.
void main(List<String> args) async {
  final String templatesPath = args.isNotEmpty
      ? args[0]
      : 'assets/script_templates';

  print('🔍 Validating script templates in: $templatesPath\n');

  final directory = Directory(templatesPath);
  if (!directory.existsSync()) {
    print('❌ Error: Directory not found: $templatesPath');
    exit(1);
  }

  final templateFiles = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.json') &&
          !f.path.endsWith('versions.json') &&
          !f.path.endsWith('manifest.json'))
      .toList();

  if (templateFiles.isEmpty) {
    print('⚠️  Warning: No JSON template files found');
    exit(0);
  }

  int totalTemplates = 0;
  int templatesWithIssues = 0;
  final Map<String, List<ValidationIssue>> issuesByFile = {};

  for (final file in templateFiles) {
    totalTemplates++;
    final fileName = file.path.split('/').last;

    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final issues = validateTemplate(json, fileName);
      if (issues.isNotEmpty) {
        templatesWithIssues++;
        issuesByFile[fileName] = issues;
      }
    } catch (e) {
      print('❌ Error parsing $fileName: $e');
      templatesWithIssues++;
    }
  }

  // Print results
  if (issuesByFile.isEmpty) {
    print('✅ All $totalTemplates templates validated successfully!');
    exit(0);
  }

  // Print issues
  for (final entry in issuesByFile.entries) {
    print('❌ ${entry.key}:');
    for (final issue in entry.value) {
      print('   ${issue.severity == IssueSeverity.error ? "ERROR" : "WARNING"}: ${issue.message}');
      if (issue.suggestion != null) {
        print('   💡 Suggestion: ${issue.suggestion}');
      }
    }
    print('');
  }

  print('📊 Summary: $templatesWithIssues template(s) with issues out of $totalTemplates total');
  exit(templatesWithIssues > 0 ? 1 : 0);
}

/// Validate a single template
List<ValidationIssue> validateTemplate(Map<String, dynamic> json, String fileName) {
  final issues = <ValidationIssue>[];

  // Extract fields
  final id = json['id'] as String?;
  final version = json['version'] as String?;
  final sourceCode = json['sourceCode'] as String?;
  final parameters = json['parameters'] as List<dynamic>?;

  // Validate required fields
  if (id == null || id.isEmpty) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.error,
      message: 'Missing or empty "id" field',
    ));
  }

  if (version == null || version.isEmpty) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.error,
      message: 'Missing or empty "version" field',
    ));
  } else if (!_isValidSemanticVersion(version)) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.error,
      message: 'Invalid semantic version: "$version" (expected format: X.Y.Z)',
    ));
  }

  if (sourceCode == null || sourceCode.isEmpty) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.error,
      message: 'Missing or empty "sourceCode" field',
    ));
    return issues; // Can't do further validation without sourceCode
  }

  if (parameters == null) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.warning,
      message: 'Missing "parameters" field',
    ));
    return issues;
  }

  // Build parameter map
  final parameterNames = <String>{};
  for (final param in parameters) {
    if (param is Map<String, dynamic>) {
      final name = param['name'] as String?;
      if (name != null) {
        parameterNames.add(name);
      }
    }
  }

  // Check for duplicate variable declarations in sourceCode
  final duplicateDeclarations = _findDuplicateVariableDeclarations(
    sourceCode,
    parameterNames,
  );

  for (final varName in duplicateDeclarations) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.error,
      message: 'Duplicate declaration for parameter "$varName" found in sourceCode',
      suggestion: 'Remove "let $varName = ..." or "var $varName = ..." or "const $varName = ..." from sourceCode. '
          'Parameters are auto-injected during script generation.',
    ));
  }

  // Check for uppercase variables in sourceCode that don't have parameter definitions
  final undefinedVariables = _findUndefinedUppercaseVariables(
    sourceCode,
    parameterNames,
  );

  for (final varName in undefinedVariables) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.warning,
      message: 'Uppercase variable "$varName" used in sourceCode but not defined as parameter',
      suggestion: 'Add a parameter definition for "$varName" or use lowercase variable name if it\'s a local variable',
    ));
  }

  // Check for unused parameters
  final unusedParameters = _findUnusedParameters(sourceCode, parameterNames);

  for (final paramName in unusedParameters) {
    issues.add(ValidationIssue(
      severity: IssueSeverity.warning,
      message: 'Parameter "$paramName" is defined but never used in sourceCode',
      suggestion: 'Remove unused parameter or add it to the sourceCode',
    ));
  }

  return issues;
}

/// Find duplicate variable declarations in sourceCode
///
/// Returns parameter names that are also declared in sourceCode with let/var/const
Set<String> _findDuplicateVariableDeclarations(
  String sourceCode,
  Set<String> parameterNames,
) {
  final duplicates = <String>{};

  for (final paramName in parameterNames) {
    // Check for various declaration patterns
    final patterns = [
      RegExp(r'\blet\s+' + paramName + r'\s*=', multiLine: true),
      RegExp(r'\bvar\s+' + paramName + r'\s*=', multiLine: true),
      RegExp(r'\bconst\s+' + paramName + r'\s*=', multiLine: true),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(sourceCode)) {
        duplicates.add(paramName);
        break;
      }
    }
  }

  return duplicates;
}

/// Find uppercase variables used in sourceCode but not defined as parameters
///
/// Excludes common JavaScript globals and Shelly API names
Set<String> _findUndefinedUppercaseVariables(
  String sourceCode,
  Set<String> parameterNames,
) {
  final undefinedVars = <String>{};

  // Known globals and API names to exclude
  final knownGlobals = {
    'Shelly',
    'Timer',
    'Script',
    'JSON',
    'Math',
    'Date',
    'Array',
    'Object',
    'String',
    'Number',
    'Boolean',
    'RegExp',
    'Error',
    'NaN',
    'Infinity',
    'undefined',
    'HTTP',
    'WiFi',
    'Eth',
    'Ethernet',
    'BLE',
  };

  // Find all uppercase identifiers (at least 2 chars, all uppercase with optional underscores/numbers)
  final uppercasePattern = RegExp(r'\b([A-Z][A-Z0-9_]+)\b');
  final matches = uppercasePattern.allMatches(sourceCode);

  for (final match in matches) {
    final varName = match.group(1)!;

    // Skip if it's a known parameter, global, or too short
    if (parameterNames.contains(varName) ||
        knownGlobals.contains(varName) ||
        varName.length < 2) {
      continue;
    }

    undefinedVars.add(varName);
  }

  return undefinedVars;
}

/// Find parameters that are defined but never used in sourceCode
Set<String> _findUnusedParameters(String sourceCode, Set<String> parameterNames) {
  final unusedParams = <String>{};

  for (final paramName in parameterNames) {
    // Check if parameter name appears anywhere in sourceCode (as identifier)
    final pattern = RegExp(r'\b' + paramName + r'\b');

    if (!pattern.hasMatch(sourceCode)) {
      unusedParams.add(paramName);
    }
  }

  return unusedParams;
}

/// Validate semantic versioning format (X.Y.Z)
bool _isValidSemanticVersion(String version) {
  final semverPattern = RegExp(r'^\d+\.\d+\.\d+$');
  return semverPattern.hasMatch(version);
}

/// Represents a validation issue
class ValidationIssue {
  final IssueSeverity severity;
  final String message;
  final String? suggestion;

  ValidationIssue({
    required this.severity,
    required this.message,
    this.suggestion,
  });
}

enum IssueSeverity {
  error,
  warning,
}
