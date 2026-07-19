import 'package:flutter_test/flutter_test.dart';
import 'package:the_solar_app/models/shelly_script_parameter.dart';
import 'package:the_solar_app/models/shelly_script_template.dart';
import 'package:the_solar_app/utils/script_template_utils.dart';

void main() {
  group('ScriptTemplateUtils - Parameter Value Formatting', () {
    test('should format string parameters with quote escaping', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'SERIAL',
          label: 'Serial',
          description: 'Serial number',
          type: ScriptParameterType.string,
          required: true,
        ),
      ]);

      final params = {'SERIAL': 'ABC"123'};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let SERIAL = "ABC\\"123";'));
    });

    test('should format string parameters with backslash (current behavior: no escaping)', () {
      // Note: Current implementation does NOT escape backslashes
      // This test documents the current behavior
      // If backslash escaping is needed in the future, update _formatValue to escape backslashes
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PATH',
          label: 'Path',
          description: 'File path',
          type: ScriptParameterType.string,
          required: true,
        ),
      ]);

      final params = {'PATH': 'C:\\Users\\Test'};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      // Current behavior: backslashes are NOT escaped
      expect(result, contains('let PATH = "C:\\Users\\Test";'));
    });

    test('should format number parameters without quotes', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'MAX_POWER',
          label: 'Max Power',
          description: 'Maximum power',
          type: ScriptParameterType.number,
          required: true,
        ),
      ]);

      final params = {'MAX_POWER': 800};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let MAX_POWER = 800;'));
    });

    test('should format negative number parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'OFFSET',
          label: 'Offset',
          description: 'Value offset',
          type: ScriptParameterType.number,
          required: true,
        ),
      ]);

      final params = {'OFFSET': -50};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let OFFSET = -50;'));
    });

    test('should format float number parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'FACTOR',
          label: 'Factor',
          description: 'Multiplication factor',
          type: ScriptParameterType.number,
          required: true,
        ),
      ]);

      final params = {'FACTOR': 1.5};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let FACTOR = 1.5;'));
    });

    test('should format boolean true parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'DEBUG',
          label: 'Debug',
          description: 'Enable debug mode',
          type: ScriptParameterType.boolean,
          required: true,
        ),
      ]);

      final params = {'DEBUG': true};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let DEBUG = true;'));
    });

    test('should format boolean false parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'ENABLED',
          label: 'Enabled',
          description: 'Enable feature',
          type: ScriptParameterType.boolean,
          required: true,
        ),
      ]);

      final params = {'ENABLED': false};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let ENABLED = false;'));
    });

    test('should format empty string array', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'NETWORKS',
          label: 'Networks',
          description: 'Network list',
          type: ScriptParameterType.stringArray,
          required: true,
        ),
      ]);

      final params = {'NETWORKS': []};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let NETWORKS = [];'));
    });

    test('should format string array with single item', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'NETWORKS',
          label: 'Networks',
          description: 'Network list',
          type: ScriptParameterType.stringArray,
          required: true,
        ),
      ]);

      final params = {
        'NETWORKS': ['wifi']
      };
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let NETWORKS = ["wifi"];'));
    });

    test('should format string array with multiple items', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'NETWORKS',
          label: 'Networks',
          description: 'Network list',
          type: ScriptParameterType.stringArray,
          required: true,
        ),
      ]);

      final params = {
        'NETWORKS': ['wifi', 'ethernet', 'bluetooth']
      };
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let NETWORKS = ["wifi", "ethernet", "bluetooth"];'));
    });

    test('should format string array with items containing quotes', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'MESSAGES',
          label: 'Messages',
          description: 'Message list',
          type: ScriptParameterType.stringArray,
          required: true,
        ),
      ]);

      final params = {
        'MESSAGES': ['Hello "World"', 'Test "Value"']
      };
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let MESSAGES = ["Hello \\"World\\"", "Test \\"Value\\""];'));
    });

    test('should format port parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PORT',
          label: 'Port',
          description: 'Server port',
          type: ScriptParameterType.port,
          required: true,
        ),
      ]);

      final params = {'PORT': 8080};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let PORT = 8080;'));
    });

    test('should format duration parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'TIMEOUT',
          label: 'Timeout',
          description: 'Request timeout',
          type: ScriptParameterType.duration,
          required: true,
        ),
      ]);

      final params = {'TIMEOUT': 5000};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let TIMEOUT = 5000;'));
    });

    test('should format URL parameters with quotes', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'API_URL',
          label: 'API URL',
          description: 'API endpoint',
          type: ScriptParameterType.url,
          required: true,
        ),
      ]);

      final params = {'API_URL': 'http://example.com/api'};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let API_URL = "http://example.com/api";'));
    });

    test('should handle null values for optional string parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'OPTIONAL',
          label: 'Optional',
          description: 'Optional value',
          type: ScriptParameterType.string,
          required: false,
        ),
      ]);

      final params = {'OPTIONAL': null};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let OPTIONAL = null;'));
    });

    test('should handle null values for optional array parameters', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'OPTIONAL_LIST',
          label: 'Optional List',
          description: 'Optional list',
          type: ScriptParameterType.stringArray,
          required: false,
        ),
      ]);

      final params = {'OPTIONAL_LIST': null};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('let OPTIONAL_LIST = [];'));
    });
  });

  group('ScriptTemplateUtils - Script Generation Structure', () {
    test('should include template metadata header', () {
      final template = _createTestTemplate([]);
      final result = ScriptTemplateUtils.generateScript(template, {}, 'test-deployment-id');

      expect(result, contains('// @TEMPLATE_META:'));
      expect(result, contains('"template_id":"test-template"'));
      expect(result, contains('"version":"1.0.0"'));
      expect(result, contains('"deployment_id":"test-deployment-id"'));
      expect(result, contains('"deployed_at"'));
    });

    test('should include version comment', () {
      final template = _createTestTemplate([]);
      final result = ScriptTemplateUtils.generateScript(template, {}, 'test-id');

      expect(result, contains('//version 1.0.0'));
    });

    test('should include description comment', () {
      final template = _createTestTemplate([]);
      final result = ScriptTemplateUtils.generateScript(template, {}, 'test-id');

      expect(result, contains('// Test template description'));
    });

    test('should include auto-generated parameters section markers', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PARAM1',
          label: 'Param 1',
          description: 'First parameter',
          type: ScriptParameterType.string,
          required: true,
        ),
      ]);

      final params = {'PARAM1': 'value1'};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('// --- AUTO-GENERATED PARAMETERS ---'));
      expect(result, contains('// --- END AUTO-GENERATED PARAMETERS ---'));
    });

    test('should include @PARAM tag for each parameter', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'SERIAL',
          label: 'Serial',
          description: 'Serial number',
          type: ScriptParameterType.string,
          required: true,
        ),
        ScriptParameter(
          name: 'DEBUG',
          label: 'Debug',
          description: 'Debug mode',
          type: ScriptParameterType.boolean,
          required: true,
        ),
      ]);

      final params = {'SERIAL': 'ABC123', 'DEBUG': true};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('// @PARAM: SERIAL'));
      expect(result, contains('// @PARAM: DEBUG'));
    });

    test('should append source code after parameters', () {
      final template = _createTestTemplate(
        [
          ScriptParameter(
            name: 'VALUE',
            label: 'Value',
            description: 'Test value',
            type: ScriptParameterType.number,
            required: true,
          ),
        ],
        sourceCode: 'function test() {\n  print("Test function");\n}',
      );

      final params = {'VALUE': 42};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      expect(result, contains('function test() {'));
      expect(result, contains('print("Test function");'));
    });

    test('should maintain correct order: metadata, comments, parameters, source', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PARAM',
          label: 'Parameter',
          description: 'Test parameter',
          type: ScriptParameterType.string,
          required: true,
        ),
      ], sourceCode: 'let result = PARAM;');

      final params = {'PARAM': 'test'};
      final result = ScriptTemplateUtils.generateScript(template, params, 'test-id');

      final metadataIndex = result.indexOf('// @TEMPLATE_META:');
      final versionIndex = result.indexOf('//version');
      final paramsStartIndex = result.indexOf('// --- AUTO-GENERATED PARAMETERS ---');
      final paramsEndIndex = result.indexOf('// --- END AUTO-GENERATED PARAMETERS ---');
      final sourceIndex = result.indexOf('let result = PARAM;');

      expect(metadataIndex, lessThan(versionIndex));
      expect(versionIndex, lessThan(paramsStartIndex));
      expect(paramsStartIndex, lessThan(paramsEndIndex));
      expect(paramsEndIndex, lessThan(sourceIndex));
    });
  });

  group('ScriptTemplateUtils - Parameter Validation', () {
    test('should return error for missing required parameter', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'SERIAL',
          label: 'Serial',
          description: 'Serial number',
          type: ScriptParameterType.string,
          required: true,
        ),
      ]);

      final params = <String, dynamic>{};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isNotEmpty);
      expect(errors.containsKey('SERIAL'), isTrue);
    });

    test('should not return error for present required parameter', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'SERIAL',
          label: 'Serial',
          description: 'Serial number',
          type: ScriptParameterType.string,
          required: true,
        ),
      ]);

      final params = {'SERIAL': 'ABC123'};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isEmpty);
    });

    test('should not return error for missing optional parameter', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'OPTIONAL',
          label: 'Optional',
          description: 'Optional value',
          type: ScriptParameterType.string,
          required: false,
        ),
      ]);

      final params = <String, dynamic>{};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isEmpty);
    });

    test('should validate port range minimum', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PORT',
          label: 'Port',
          description: 'Server port',
          type: ScriptParameterType.port,
          required: true,
        ),
      ]);

      final params = {'PORT': 0};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isNotEmpty);
      expect(errors.containsKey('PORT'), isTrue);
    });

    test('should validate port range maximum', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PORT',
          label: 'Port',
          description: 'Server port',
          type: ScriptParameterType.port,
          required: true,
        ),
      ]);

      final params = {'PORT': 70000};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isNotEmpty);
      expect(errors.containsKey('PORT'), isTrue);
    });

    test('should accept valid port number', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'PORT',
          label: 'Port',
          description: 'Server port',
          type: ScriptParameterType.port,
          required: true,
        ),
      ]);

      final params = {'PORT': 8080};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isEmpty);
    });

    test('should validate numeric min value', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'POWER',
          label: 'Power',
          description: 'Power value',
          type: ScriptParameterType.number,
          required: true,
          minValue: 100,
        ),
      ]);

      final params = {'POWER': 50};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isNotEmpty);
      expect(errors.containsKey('POWER'), isTrue);
    });

    test('should validate numeric max value', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'POWER',
          label: 'Power',
          description: 'Power value',
          type: ScriptParameterType.number,
          required: true,
          maxValue: 1000,
        ),
      ]);

      final params = {'POWER': 1500};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isNotEmpty);
      expect(errors.containsKey('POWER'), isTrue);
    });

    test('should accept numeric value within range', () {
      final template = _createTestTemplate([
        ScriptParameter(
          name: 'POWER',
          label: 'Power',
          description: 'Power value',
          type: ScriptParameterType.number,
          required: true,
          minValue: 100,
          maxValue: 1000,
        ),
      ]);

      final params = {'POWER': 500};
      final errors = ScriptTemplateUtils.validateParameters(template, params);

      expect(errors, isEmpty);
    });
  });
}

ShellyScriptTemplate _createTestTemplate(
  List<ScriptParameter> parameters, {
  String sourceCode = '// Source code here',
}) {
  return ShellyScriptTemplate(
    id: 'test-template',
    name: 'Test Template',
    version: '1.0.0',
    description: 'Test template description',
    compatibleDevices: ['SPEM'],
    requiredDevices: [],
    sourceCode: sourceCode,
    parameters: parameters,
    tags: ['test'],
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2026-01-01T00:00:00Z'),
  );
}
