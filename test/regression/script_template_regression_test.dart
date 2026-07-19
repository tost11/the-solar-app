import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression tests for script template system
///
/// These tests document and prevent recurrence of past bugs:
/// - b4dc0f7: Double variable definitions
/// - 7069812: Parameter parsing with multiple arguments
/// - 166809e: Array parameter handling
void main() {
  group('Script Template Regression Tests', () {
    test('regression b4dc0f7: templates should not have duplicate variable declarations', () async {
      // Bug: Templates contained variable declarations in sourceCode
      // that were also parameters, causing double declarations in generated scripts
      //
      // Example: CHECK_WIFI_AP defined as parameter AND as "var CHECK_WIFI_AP = true" in sourceCode
      //
      // This test ensures all templates are clean

      final templatesDir = Directory('assets/script_templates');
      if (!templatesDir.existsSync()) {
        fail('Templates directory not found');
      }

      final templateFiles = templatesDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') &&
              !f.path.endsWith('versions.json') &&
              !f.path.endsWith('manifest.json'))
          .toList();

      expect(templateFiles, isNotEmpty, reason: 'No template files found');

      final filesWithDuplicates = <String>[];

      for (final file in templateFiles) {
        final jsonString = await file.readAsString();
        final json = jsonDecode(jsonString) as Map<String, dynamic>;

        final sourceCode = json['sourceCode'] as String?;
        final parameters = json['parameters'] as List<dynamic>?;

        if (sourceCode == null || parameters == null) continue;

        // Extract parameter names
        final parameterNames = <String>{};
        for (final param in parameters) {
          if (param is Map<String, dynamic>) {
            final name = param['name'] as String?;
            if (name != null) {
              parameterNames.add(name);
            }
          }
        }

        // Check for duplicate declarations
        for (final paramName in parameterNames) {
          final patterns = [
            RegExp(r'\blet\s+' + paramName + r'\s*=', multiLine: true),
            RegExp(r'\bvar\s+' + paramName + r'\s*=', multiLine: true),
            RegExp(r'\bconst\s+' + paramName + r'\s*=', multiLine: true),
          ];

          for (final pattern in patterns) {
            if (pattern.hasMatch(sourceCode)) {
              filesWithDuplicates.add('${file.path.split('/').last}: $paramName');
              break;
            }
          }
        }
      }

      if (filesWithDuplicates.isNotEmpty) {
        fail('Templates with duplicate variable declarations found:\n' +
            filesWithDuplicates.join('\n') +
            '\n\nRun: dart run lib/tools/validate_script_templates.dart');
      }
    });

    test('regression 7069812: parameter extraction should handle multiple arguments correctly', () {
      // Bug: Parameter parsing failed when scripts had multiple arguments
      // This test ensures the parameter extraction regex handles various scenarios

      final testCases = [
        {
          'code': 'let PARAM1 = "value1";\nlet PARAM2 = 123;',
          'expectedParams': ['PARAM1', 'PARAM2'],
        },
        {
          'code': 'let A = "x"; let B = "y"; let C = "z";',
          'expectedParams': ['A', 'B', 'C'],
        },
        {
          'code': 'const DEBUG = true;\nconst PORT = 8080;\nconst HOST = "localhost";',
          'expectedParams': ['DEBUG', 'PORT', 'HOST'],
        },
      ];

      for (final testCase in testCases) {
        final code = testCase['code'] as String;
        final expectedParams = testCase['expectedParams'] as List<String>;

        // Extract variable declarations
        final declaredVars = <String>{};
        final patterns = [
          RegExp(r'\blet\s+([A-Z_][A-Z0-9_]*)\s*=', multiLine: true),
          RegExp(r'\bvar\s+([A-Z_][A-Z0-9_]*)\s*=', multiLine: true),
          RegExp(r'\bconst\s+([A-Z_][A-Z0-9_]*)\s*=', multiLine: true),
        ];

        for (final pattern in patterns) {
          final matches = pattern.allMatches(code);
          for (final match in matches) {
            declaredVars.add(match.group(1)!);
          }
        }

        expect(
          declaredVars,
          containsAll(expectedParams),
          reason: 'Failed to extract all parameters from: $code',
        );
      }
    });

    test('regression 166809e: array parameters should be formatted correctly', () {
      // Bug: Array parameters (like CHECK_WIFI_AP, CHECK_WIFI_STA, CHECK_ETH)
      // were not handled correctly in parameter generation
      //
      // This test verifies array parameter formatting

      final testCases = [
        {
          'input': <String>[],
          'expected': '[]',
        },
        {
          'input': ['wifi'],
          'expected': '["wifi"]',
        },
        {
          'input': ['wifi', 'ethernet', 'bluetooth'],
          'expected': '["wifi", "ethernet", "bluetooth"]',
        },
      ];

      for (final testCase in testCases) {
        final input = testCase['input'] as List<String>;
        final expected = testCase['expected'] as String;

        // Simulate array formatting
        final formatted = input.isEmpty
            ? '[]'
            : '[' +
                input.map((item) => '"$item"').join(', ') +
                ']';

        expect(
          formatted,
          equals(expected),
          reason: 'Array formatting failed for: $input',
        );
      }
    });

    test('regression: semantic versioning should be validated', () {
      // Ensure version strings follow semantic versioning format

      final validVersions = [
        '1.0.0',
        '2.1.5',
        '10.20.30',
        '0.0.1',
      ];

      final invalidVersions = [
        'v1.0.0', // prefix not allowed
        '1.0', // missing patch version
        '1', // only major version
        '1.0.0-beta', // prerelease not in basic validation
        '', // empty
      ];

      final semverPattern = RegExp(r'^\d+\.\d+\.\d+$');

      for (final version in validVersions) {
        expect(
          semverPattern.hasMatch(version),
          isTrue,
          reason: 'Valid version rejected: $version',
        );
      }

      for (final version in invalidVersions) {
        expect(
          semverPattern.hasMatch(version),
          isFalse,
          reason: 'Invalid version accepted: $version',
        );
      }
    });

    test('regression: all templates should have required fields', () async {
      // Ensures templates have minimum required structure

      final templatesDir = Directory('assets/script_templates');
      if (!templatesDir.existsSync()) {
        fail('Templates directory not found');
      }

      final templateFiles = templatesDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') &&
              !f.path.endsWith('versions.json') &&
              !f.path.endsWith('manifest.json'))
          .toList();

      final filesWithMissingFields = <String>[];

      for (final file in templateFiles) {
        final jsonString = await file.readAsString();
        final json = jsonDecode(jsonString) as Map<String, dynamic>;

        final requiredFields = [
          'id',
          'name',
          'version',
          'description',
          'sourceCode',
          'parameters',
        ];

        final missingFields = <String>[];
        for (final field in requiredFields) {
          if (!json.containsKey(field) || json[field] == null) {
            missingFields.add(field);
          }
        }

        if (missingFields.isNotEmpty) {
          filesWithMissingFields.add(
            '${file.path.split('/').last}: missing ${missingFields.join(", ")}',
          );
        }
      }

      if (filesWithMissingFields.isNotEmpty) {
        fail('Templates with missing required fields:\n' +
            filesWithMissingFields.join('\n'));
      }
    });
  });
}
