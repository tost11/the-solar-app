# Script Template Testing Documentation

## Overview

This directory contains comprehensive tests for the Shelly script template system. The tests ensure that script generation, parameter validation, and template structure remain correct and prevent regression of past bugs.

## Test Structure

```
test/
├── utils/
│   ├── script_template_utils_test.dart      # Unit tests for script generation
│   └── script_parameter_extractor_test.dart # (Future) Parameter extraction tests
├── services/
│   └── script_template_service_test.dart    # (Future) Template validation tests
├── integration/
│   └── script_generation_integration_test.dart # (Future) Integration tests
├── regression/
│   └── script_template_regression_test.dart # Regression tests for known bugs
└── README.md                                 # This file
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/utils/script_template_utils_test.dart
flutter test test/regression/script_template_regression_test.dart
```

### Run Validation Tool
```bash
dart run lib/tools/validate_script_templates.dart assets/script_templates/
```

## Test Coverage

### Unit Tests (`test/utils/script_template_utils_test.dart`)

**32 tests covering:**

1. **Parameter Value Formatting** (16 tests)
   - String escaping (quotes)
   - String handling (backslashes - documented behavior)
   - Number formatting (integers, floats, negative)
   - Boolean formatting (true/false)
   - String array formatting (empty, single, multiple, with quotes)
   - Port parameters
   - Duration parameters
   - URL parameters
   - Null value handling

2. **Script Generation Structure** (7 tests)
   - Template metadata header injection
   - Version comment generation
   - Description comment generation
   - Auto-generated parameters section markers
   - @PARAM tag generation
   - Source code appending
   - Correct section ordering

3. **Parameter Validation** (9 tests)
   - Required parameter checking
   - Missing required parameters
   - Optional parameter handling
   - Port range validation (1-65535)
   - Numeric min/max value validation
   - Value within range acceptance

### Regression Tests (`test/regression/script_template_regression_test.dart`)

**5 tests covering past bugs:**

1. **Bug b4dc0f7**: Duplicate variable declarations
   - Scans ALL templates for duplicate declarations
   - Fails if parameter is also declared in sourceCode
   - Currently failing on 4 template files (expected - shows test works)

2. **Bug 7069812**: Multiple argument parameter parsing
   - Tests parameter extraction regex patterns
   - Verifies handling of multiple declarations

3. **Bug 166809e**: Array parameter handling
   - Tests string array formatting
   - Verifies empty, single, and multiple item arrays

4. **Semantic versioning validation**
   - Tests version format validation (X.Y.Z)
   - Rejects invalid version formats

5. **Required fields validation**
   - Ensures all templates have minimum required structure
   - Checks for id, name, version, description, sourceCode, parameters

## Validation Tool

### Purpose
The validation tool (`lib/tools/validate_script_templates.dart`) provides pre-import validation for templates from the [zendure-shelly-tools repository](https://github.com/tost11/zendure-shelly-tools).

### Usage
```bash
dart run lib/tools/validate_script_templates.dart [path_to_templates]
```

Default path: `assets/script_templates/`

### What It Checks

**Errors** (must fix):
- Duplicate variable declarations (parameter also declared in sourceCode)
- Missing required fields (id, name, version, sourceCode, parameters)
- Invalid semantic versioning

**Warnings** (should review):
- Uppercase variables in sourceCode without parameter definitions
- Unused parameters (defined but not referenced in sourceCode)

## Known Issues

### Current Failing Tests

**Test**: `regression b4dc0f7: templates should not have duplicate variable declarations`

**Status**: Expected failure - identifies templates that need fixing

**Affected Templates**:
1. `zendure_power_control_find_v2.json` - CHECK_WIFI_AP, CHECK_WIFI_STA, CHECK_ETH
2. `zendure_power_control_find_v2-0-1.json` - CHECK_WIFI_AP, CHECK_WIFI_STA, CHECK_ETH
3. `zendure_online_monitoring_find_v1.json` - CHECK_WIFI_AP, CHECK_WIFI_STA, CHECK_ETH
4. `zendure_online_monitoring_find_v1-1-0.json` - INTERVAL_DEVICE_OFFLINE, CHECK_WIFI_STA, CHECK_ETH

**Fix Required**: Remove duplicate `var VARIABLE_NAME = value;` declarations from sourceCode in these template JSON files. The parameters are already defined and will be auto-injected during script generation.

## Workflow for Adding New Templates

### Before Importing Scripts from zendure-shelly-tools

1. **Run Validation Tool**:
   ```bash
   dart run lib/tools/validate_script_templates.dart path/to/new/templates/
   ```

2. **Fix Errors**:
   - Remove duplicate variable declarations from sourceCode
   - Add missing parameter definitions
   - Fix version format if needed

3. **Review Warnings**:
   - Check if uppercase variables should be parameters
   - Remove unused parameters or add them to sourceCode

4. **Run Tests**:
   ```bash
   flutter test
   ```

5. **Verify**:
   - All unit tests pass
   - Regression tests pass (or only expected failures)

### Template Creation Checklist

When creating a new template:

1. ✅ Identify ALL uppercase variables in the script
2. ✅ Check validation blocks (`if(!VARIABLE)`, `if(VARIABLE <= 0)`)
3. ✅ Create parameter definition for EACH uppercase variable
4. ✅ Remove ALL `let VAR = ...` / `var VAR = ...` / `const VAR = ...` from sourceCode
5. ✅ Keep only internal variables (lowercase/camelCase) in sourceCode
6. ✅ Run validation tool to verify
7. ✅ Test with real device if possible

## Test Maintenance

### When to Update Tests

- **New parameter type added**: Add tests to `script_template_utils_test.dart`
- **Bug fixed**: Add regression test to `script_template_regression_test.dart`
- **New validation rule**: Update validation tool and add test
- **Template format changed**: Update all affected tests

### Adding New Tests

1. Follow existing test patterns
2. Use descriptive test names
3. Include regression test for any bug fix
4. Update this README with new test coverage
