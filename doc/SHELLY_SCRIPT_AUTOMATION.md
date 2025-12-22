# Shelly Script Automation Guide

Comprehensive guide for creating and deploying JavaScript automation scripts to Shelly devices using template-based configuration.

## Overview

### What are Shelly Script Templates?

Shelly Script Templates are pre-built JavaScript automation scripts that can be deployed directly to Shelly devices (Gen 2/3). These scripts run autonomously on the device itself, requiring no external server or cloud connection.

**Key Benefits:**
- **No Cloud Dependency**: Scripts execute locally on the Shelly device
- **Privacy-First**: All automation logic stays on your local network
- **Parameterized**: Configure scripts through a user-friendly interface without writing code
- **Reliable**: Scripts continue running even if your phone/computer is offline
- **Versioned**: Templates support semantic versioning with automatic update detection

### Template System Architecture

1. **Template Definition** (`assets/script_templates/*.json`): JSON files defining script structure, parameters, and source code
2. **Parameter Configuration**: User fills in required/optional parameters through the app UI
3. **Code Generation**: App adds parameter on top in source code
4. **Atomic Deployment**: Script uploaded with staging process and failure recovery
5. **Runtime Execution**: JavaScript executes on Shelly device using Shelly's scripting engine

## Using Script Templates

### Step 1: Navigate to Scripts

1. Open a Shelly device from your device list
2. Tap the menu button (three dots) in the top right
3. Select "Scripts" from the menu

### Step 2: Select Template

1. Tap the "Add" button (+ icon)
2. Select "From Template"
3. Browse available templates
   - Templates are filtered based on your device compatibility
   - Templates requiring other devices (e.g., Zendure) only appear if you have them in your device list

### Step 3: Configure Parameters

The parameter configuration screen shows:
- **Required Parameters**: Marked with an asterisk, must be filled
- **Optional Parameters**: Can be left at default values
- **Advanced Parameters**: Hidden by default (enable Expert Mode in settings to show)
- **Auto-Populated Fields**: Automatically filled from your existing devices (IP addresses, serial numbers)

**Parameter Configuration Tips:**
- Look for the **info icon** (ℹ️) next to parameters for detailed descriptions
- **Green checkmark**: Value auto-populated from device list
- **Orange warning**: No matching device found for auto-population
- **Search icon**: Multiple devices found, tap to select one

### Step 4: Preview or Deploy

You have two deployment options:

**Preview** (Recommended for first-time users):
1. Tap "Vorschau" (Preview)
2. Review the generated JavaScript code
3. Verify all parameters are correctly inserted
4. Tap "Installieren" to deploy

**Direct Install** (For experienced users):
1. Tap "Direkt installieren" (Direct Install)
2. Confirm the installation
3. Script is immediately deployed to the device

### Step 5: Monitor Deployment

The deployment process uses atomic staging:
1. **Creating Script**: Script created with staging name `__auto_{template}_ 0.0.0_{id}`
2. **Uploading Code**: JavaScript code uploaded to device
3. **Finalizing**: If successful, script renamed to `__auto_{template}_{version}_{id}`
4. **Enabling & Starting**: Script enabled and started automatically

**If deployment fails:**
- Script remains at version "0.0.0" with red "Fehlgeschlagen" (Failed) badge
- Error message explains what went wrong
- Tap the script to access repair options

## Available Templates

### Zendure Power Control (Zero-Export Automation)

Automatically balance Zendure power station output/input based on real-time grid measurements from Shelly EM3 for zero-export operation.

**Key Features**:
- Automatic zero-export/nulleinspeisung control
- Bidirectional operation (discharge to home, charge from excess)
- Battery SOC protection and bypass mode handling
- Two variants: IP/WiFi and MAC/Bluetooth

**Hardware Requirements**:
- Shelly EM3 (three-phase energy meter)
- Zendure Power Station (ACE 1500, SolarFlow, HUB, etc.)
- Network connection (WiFi/LAN)

**📖 For detailed documentation including parameter reference, configuration examples, deployment guide, and troubleshooting, see [ZENDURE_POWER_CONTROL.md](ZENDURE_POWER_CONTROL.md).**

## Managing Scripts

### Viewing Deployed Scripts

1. Open Shelly device → Menu → "Scripts"
2. View list of all scripts on the device:
   - **Script name**: Shows template ID, version, and deployment ID
   - **Status indicator**: Green (running), gray (stopped)
   - **Version badge**: Template version number
   - **Update badge**: Orange "Update" badge if newer template version available

### Updating Parameters

1. Tap on a script in the list
2. Select "Parameter aktualisieren" (Update Parameters)
3. Modify parameter values
4. Tap "Aktualisieren" to deploy updated script

**Note**: Script is regenerated with new parameters and re-uploaded using atomic deployment.

### Upgrading Template Versions

When a newer template version is available:
1. Script shows orange "Update verfügbar" badge
2. Tap the script
3. Select "Auf Version X.X.X upgraden"
4. Review new parameters (any new parameters are highlighted)
5. Confirm upgrade

**Atomic Upgrade Process**:
- Existing parameters are preserved
- New parameters use default values (you can customize them)
- Script transitions through staging (0.0.0) during upgrade
- On success, renamed to new version

### Troubleshooting Failed Deployments

If a script shows **red "Fehlgeschlagen" badge**:

1. **Identify the Problem**:
   - Check error message displayed during deployment
   - Common causes: network timeout, invalid parameters, Shelly device busy

2. **Repair Options**:
   - **Update Parameters**: Fix incorrect values and redeploy
   - **Reinstall**: Delete and create new script from template
   - **Check Connectivity**: Ensure Shelly device is reachable

3. **Debug Steps**:
   - Enable DEBUG parameter and check Shelly device logs
   - Verify target device (e.g., Zendure) is reachable from Shelly
   - Test HTTP endpoints manually using curl/Postman

### Deleting Scripts

1. Swipe left on script in list, or
2. Tap script → Menu → "Löschen"
3. Confirm deletion

**Note**: Deleted scripts are removed permanently from the Shelly device.

## Creating Custom Templates

### Template JSON Structure

Create a new file in `assets/script_templates/` with this structure:

```json
{
  "id": "my-template",
  "name": "My Custom Template",
  "version": "1.0.0",
  "description": "Brief description of what this script does",
  "compatibleDevices": ["SPEM", "SNPL"],
  "requiredDevices": [],
  "author": "Your Name",
  "tags": ["automation", "monitoring"],
  "parameters": [
    {
      "name": "PARAM_NAME",
      "label": "Parameter Label",
      "description": "Help text for the user",
      "type": "string",
      "required": true,
      "defaultValue": "default",
      "placeholder": "Example value"
    }
  ],
  "sourceCode": "JavaScript code",
  "createdAt": "2025-01-15T00:00:00Z",
  "updatedAt": "2025-01-15T00:00:00Z"
}
```

### Parameter Types

| Type | Description | Validation | Example |
|------|-------------|------------|---------|
| **string** | Text value | None (optional regex pattern) | "Hello World" |
| **number** | Integer value | Min/max value optional | 42 |
| **boolean** | True/false | None | true |
| **url** | HTTP/HTTPS URL | Must match URL pattern | "http://example.com" |
| **port** | Network port | 1-65535 | 8080 |
| **duration** | Time in milliseconds | Min/max value | 10000 |
| **deviceName** | Device identifier | None | "shelly-plug-kitchen" |

### Source-Based Auto-Population

Parameters can automatically pull values from existing devices in the user's device list:

```json
{
  "name": "DEVICE_IP",
  "label": "Device IP Address",
  "type": "string",
  "required": true,
  "sourceConfig": {
    "source": "device",
    "sourceProperty": "ipAddress",
    "sourceFilter": "zendure"
  }
}
```

**Source Configuration**:
- `source`: Always "device" (future: "system", "global")
- `sourceProperty`: Property to extract (`ipAddress`, `serialNumber`, `macAddress`, etc.)
- `sourceFilter`: Device manufacturer filter (`zendure`, `shelly`, `opendtu`, etc.)

**Auto-Population Behavior**:
- **0 devices**: Field empty, user must manually enter
- **1 device**: Field auto-filled with value
- **Multiple devices**: Search button appears, user selects from list

### Placeholder Syntax

```javascript
let host = "{{HOST}}";
let port = {{PORT}};
let enabled = {{ENABLE_FEATURE}};
```

**Important**: Boolean and number parameters should NOT be quoted - they're inserted as JavaScript literals.

### Advanced Parameter Options

```json
{
  "name": "ADVANCED_PARAM",
  "label": "Advanced Setting",
  "type": "number",
  "required": false,
  "defaultValue": 100,
  "minValue": 10,
  "maxValue": 1000,
  "advancedOption": true,
  "validationPattern": "^[0-9]+$",
  "validationErrorMessage": "Must be a positive number"
}
```

**Options**:
- `advancedOption`: Hide unless Expert Mode enabled
- `validationPattern`: Regex pattern for validation (string types only)
- `validationErrorMessage`: Custom error message for validation failure
- `minValue` / `maxValue`: Numeric range validation

### Template Versioning

Use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes (parameter removed/renamed, behavior changed)
- **MINOR**: New features (new optional parameters, enhanced functionality)
- **PATCH**: Bug fixes (no new parameters, same behavior)

The app automatically detects version updates and prompts users to upgrade deployed scripts.

### Testing Your Template

1. Place JSON file in `assets/script_templates/`
2. Restart the app (hot reload may not pick up asset changes)
3. Open compatible Shelly device → Scripts → From Template
4. Verify your template appears in the list
5. Test deployment with various parameter combinations
6. Check Shelly device logs for runtime errors

## Parameter Types Reference

### string

Plain text value, optionally with regex validation.

```json
{
  "name": "API_KEY",
  "type": "string",
  "required": true,
  "placeholder": "Enter your API key",
  "validationPattern": "^[A-Za-z0-9]{32}$",
  "validationErrorMessage": "API key must be 32 alphanumeric characters"
}
```

### number

Integer value with optional min/max constraints.

```json
{
  "name": "TIMEOUT",
  "type": "number",
  "defaultValue": 30,
  "minValue": 1,
  "maxValue": 300
}
```

### boolean

True/false value, rendered as a switch in UI.

```json
{
  "name": "ENABLE_NOTIFICATIONS",
  "type": "boolean",
  "defaultValue": true
}
```

### url

HTTP or HTTPS URL with automatic validation.

```json
{
  "name": "BACKEND_URL",
  "type": "url",
  "placeholder": "http://your-server:8080/api"
}
```

### port

Network port number (1-65535).

```json
{
  "name": "SERVER_PORT",
  "type": "port",
  "defaultValue": 8080
}
```

### duration

Time duration in milliseconds with optional range.

```json
{
  "name": "POLLING_INTERVAL",
  "type": "duration",
  "defaultValue": 10000,
  "minValue": 1000,
  "maxValue": 300000
}
```

**UI Rendering**: Shows "ms" suffix in input field.

### deviceName

Device identifier/name for tagging in external systems.

```json
{
  "name": "DEVICE_ID",
  "type": "deviceName",
  "placeholder": "shelly-plug-office"
}
```

## Best Practices

### Script Development

1. **Test incrementally**: Start with minimal functionality, add features gradually
2. **Use debug logging**: Add `print()` statements, enable DEBUG parameter
3. **Handle errors gracefully**: Check for null/undefined, validate responses
4. **Avoid busy loops**: Use timers instead of while loops
5. **Monitor memory**: Shelly devices have limited RAM (check `Shelly.getSystemInfo()`)

### Parameter Design

1. **Required vs Optional**: Only mark truly essential parameters as required
2. **Sensible defaults**: Provide working defaults for optional parameters
3. **Clear descriptions**: Explain what each parameter does and acceptable values
4. **Use advanced flag**: Hide complexity from basic users
5. **Auto-population**: Leverage sourceConfig to reduce manual data entry

### Performance Optimization

1. **Batch API calls**: Minimize HTTP requests in tight loops
2. **Cache values**: Store frequently accessed data in variables
3. **Debounce updates**: Use hysteresis to prevent rapid switching
4. **Timer intervals**: Balance responsiveness vs resource usage

### Security Considerations

1. **No secrets in templates**: Don't hardcode API keys or passwords
2. **Validate inputs**: Check parameter values before use
3. **HTTPS preferred**: Use HTTPS for external API calls when possible
4. **Network isolation**: Scripts run on local network, can't access external WAN by default

## Troubleshooting

### Script Won't Start

**Symptoms**: Script shows as stopped, won't enable

**Solutions**:
- Check Shelly device logs for syntax errors
- Verify all required Shelly services are enabled
- Ensure script doesn't exceed memory limits
- Try deploying a simpler test script to isolate the issue

### Script Stops Unexpectedly

**Symptoms**: Script starts but stops after some time

**Solutions**:
- Check for unhandled JavaScript exceptions
- Monitor memory usage (add periodic `print(Shelly.getSystemInfo().ram_free)`)
- Verify external devices (e.g., Zendure) remain reachable
- Check if Shelly device firmware is up to date

### Parameters Not Working

**Symptoms**: Script runs but doesn't behave as configured

**Solutions**:
- Enable DEBUG parameter to see actual values
- Check parameter names match exactly (case-sensitive)
- Verify placeholder syntax `{{PARAM_NAME}}` is correct
- Use preview mode to inspect generated code

### Auto-Population Fails

**Symptoms**: Expected device value not auto-filled

**Solutions**:
- Verify device exists in device list
- Check `sourceFilter` matches device manufacturer exactly
- Ensure device has the requested property (e.g., `ipAddress`)
- Try manually entering value to isolate auto-population vs runtime issue

## Additional Resources

- [Shelly Scripting Documentation](https://shelly-api-docs.shelly.cloud/gen2/Scripts/Tutorial)
- [Zendure API Documentation](https://github.com/Zendure/zenSDK)
- [The Solar App GitHub](https://github.com/tost11/the-solar-app)

---

**Made with ☀️ for a sustainable energy future**
