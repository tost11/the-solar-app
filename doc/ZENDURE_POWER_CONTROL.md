# Zendure Power Control - Zero-Export Automation

Detailed documentation for the Zendure Power Control script template for automatic zero-export/nulleinspeisung control.

## Overview

Automatically balance Zendure power station output/input based on real-time grid measurements from Shelly EM3 for zero-export operation.

### Purpose

This template implements a zero-export control loop that:
- **Monitors** grid power via Shelly EM3 measurements
- **Adjusts** Zendure output to balance home consumption
- **Charges** from grid excess when solar production exceeds consumption
- **Protects** battery by respecting SOC limits and bypass mode

### Use Cases

- **Zero-Export/Nulleinspeisung**: Prevent exporting solar energy to the grid
- **Battery Optimization**: Automatically charge/discharge based on grid conditions
- **Grid Independence**: Maximize self-consumption without manual intervention

## Hardware Requirements

- **Shelly EM3**: Three-phase energy meter measuring grid connection
- **Zendure Power Station**: Supported models (ACE 1500, SolarFlow, HUB, etc.)
- **Network Connection**: Both devices accessible via WiFi/LAN

## Available Variants

### 1. IP/WiFi Version (`zendure_power_control_ip_v1.json`)
- For Zendure devices connected to home WiFi network
- Uses HTTP API for control commands
- Requires Zendure IP address

### 2. MAC/Bluetooth Version (`zendure_power_control_mac_v1.json`)
- For Zendure devices using Bluetooth (not on home WiFi)
- Uses Bluetooth Low Energy for communication
- Requires Zendure MAC address

## Parameters Reference

### Zendure Connection

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| **HOST** (IP version) | string | Yes | IP address of Zendure power station |
| **MAC_ADDRESS** (MAC version) | string | Yes | Bluetooth MAC address of Zendure |
| **SERIAL** | string | Yes | Zendure serial number (e.g., "ABCD1234") |

*Auto-populated from device list if Zendure device exists*

### Power Limits

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| **MAX_POWER** | number | 800 | 0-800 | Maximum discharge power (output to home) in Watts |
| **MAX_POWER_REVERSE** | number | 1000 | 0-2400 | Maximum charge power (input from grid) in Watts |
| **REVERSE** | boolean | true | - | Enable charging from grid excess |

### Discharge Control (Inverter Mode)

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| **STARTUP_POWER** | number | 30 | 0-100 | Minimum grid consumption to start discharging (W) |
| **STOP_POWER** | number | 10 | 0-100 | Minimum discharge power before stopping (W) |

**Explanation**: Prevents frequent on/off cycling by using hysteresis.
- If Zendure is OFF and grid consumption > STARTUP_POWER → Start discharging
- If Zendure is ON and discharge power < STOP_POWER → Stop discharging

### Charge Control (Grid Charging Mode)

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| **REVERSE_STARTUP_POWER** | number | 30 | 0-100 | Minimum grid export to start charging (W) |
| **REVERSE_STOP_POWER** | number | 10 | 0-100 | Minimum charge power before stopping (W) |

**Explanation**: Similar hysteresis for charging mode.
- If Zendure is OFF and grid export > REVERSE_STARTUP_POWER → Start charging
- If Zendure is ON and charge power < REVERSE_STOP_POWER → Stop charging

### Advanced Control (Expert Mode)

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| **INTERVAL_RUN_MAIN_SCRIPT** | number | 5 | 1-60 | Main control loop interval (seconds) |
| **INTERVAL_CHECK_ZENDURE_STATUS** | number | 30 | 10-300 | Status check interval (seconds) |
| **INTERVAL_DEVICE_OFFLINE** | number | 60 | 30-600 | Offline detection timeout (seconds) |
| **DEBUG** | boolean | false | - | Enable detailed logging |

## How Zero-Export Works

### 1. Shelly EM3 Measurement
Script reads `total_act_power` from Shelly's status handler:
- **Positive value** = Importing from grid (consumption > production)
- **Negative value** = Exporting to grid (production > consumption)

### 2. Power Calculation
Script calculates required Zendure adjustment:
```
combined_limit = shelly_power + current_zendure_power
```

### 3. Mode Selection
- If `combined_limit ≥ 0` → **Discharge Mode** (AC output)
- If `combined_limit < 0` and `REVERSE` enabled → **Charge Mode** (AC input)

### 4. Hysteresis & Protection
- Apply startup/stop thresholds to prevent oscillation
- Respect battery SOC limits (min/max)
- Handle bypass mode (Zendure in pass-through)

### 5. HTTP Control
Send command to Zendure:
```json
POST http://{HOST}/properties/write
{
  "sn": "ABCD1234",
  "properties": {
    "acMode": 2,
    "outputLimit": 150,
    "inputLimit": 0
  }
}
```

## Configuration Examples

### Basic Zero-Export Setup

Minimal configuration for simple zero-export:
```
HOST: 192.168.1.100
SERIAL: ABC12345
MAX_POWER: 800
MAX_POWER_REVERSE: 0
REVERSE: false
STARTUP_POWER: 30
STOP_POWER: 10
```

This setup:
- Only discharges to home (no charging)
- Starts discharging at 30W grid consumption
- Stops when discharge drops below 10W

### Bidirectional Zero-Export

Full bidirectional control with charging:
```
HOST: 192.168.1.100
SERIAL: ABC12345
MAX_POWER: 800
MAX_POWER_REVERSE: 1000
REVERSE: true
STARTUP_POWER: 30
STOP_POWER: 10
REVERSE_STARTUP_POWER: 30
REVERSE_STOP_POWER: 10
```

This setup:
- Discharges to cover consumption
- Charges from solar excess
- 30W hysteresis for both modes

## Deployment Guide

### Step 1: Prepare Devices

1. **Install Shelly EM3**:
   - Connect to grid measurement point (after main breaker)
   - Configure three-phase monitoring
   - Ensure WiFi connectivity

2. **Setup Zendure**:
   - **WiFi Version**: Connect Zendure to home network, note IP address
   - **Bluetooth Version**: Note MAC address from Zendure app

3. **Add to The Solar App**:
   - Scan and add both Shelly EM3 and Zendure to device list
   - Verify both devices show as connected

### Step 2: Deploy Script

1. Open **Shelly EM3** device in The Solar App
2. Menu → "Scripts" → "From Template"
3. Select **"Zendure Power Control"** template
4. Choose variant (IP or MAC)
5. Configure parameters:
   - Most fields auto-populate from your Zendure device
   - Adjust power limits based on your setup
   - Use defaults for advanced parameters initially
6. Tap **"Vorschau"** to review generated code
7. Tap **"Installieren"** to deploy

### Step 3: Monitor & Tune

1. **Initial Monitoring** (first 24 hours):
   - Watch grid power in Shelly EM3
   - Verify Zendure responds to commands
   - Check for oscillation (rapid on/off switching)

2. **Fine-Tuning**:
   - If oscillating: Increase startup/stop gap
   - If slow response: Decrease `INTERVAL_RUN_MAIN_SCRIPT`
   - If battery drains too fast: Lower `MAX_POWER`
   - If not charging enough: Increase `MAX_POWER_REVERSE`

3. **Enable DEBUG** if issues occur:
   - Update script parameters
   - Set `DEBUG: true`
   - Check Shelly logs for detailed messages

## Troubleshooting

### Script Won't Start

**Symptoms**: Script shows as stopped, won't enable

**Possible Causes**:
- Zendure device not reachable from Shelly
- Invalid IP address or MAC address
- Shelly EM3 not reporting power data

**Solutions**:
1. Verify Zendure connectivity:
   ```bash
   # From Shelly's web terminal
   curl http://{ZENDURE_IP}/properties/report
   ```
2. Check Shelly EM3 data:
   - Menu → Device → Status → Check `total_act_power`
3. Review Shelly logs for error messages

### Frequent On/Off Switching

**Symptoms**: Zendure rapidly switches between on/off states

**Causes**:
- Startup/stop thresholds too close
- Control loop too fast
- Power fluctuations

**Solutions**:
1. Increase hysteresis gap:
   ```
   STARTUP_POWER: 50
   STOP_POWER: 15
   ```
2. Slow down control loop:
   ```
   INTERVAL_RUN_MAIN_SCRIPT: 10
   ```
3. Add smoothing (requires custom template modification)

### Zendure Not Responding

**Symptoms**: Script runs but Zendure doesn't change output

**Causes**:
- Network connectivity issues
- Zendure in bypass mode
- Incorrect serial number

**Solutions**:
1. Enable DEBUG and check logs
2. Verify Zendure serial number matches device
3. Check Zendure bypass status:
   - Bypass mode disables automation
   - Script will wait until bypass is cleared
4. Test manual HTTP command:
   ```bash
   curl -X POST http://{HOST}/properties/write \
     -H "Content-Type: application/json" \
     -d '{"sn":"ABC12345","properties":{"outputLimit":100}}'
   ```

### Battery Protection

**Symptoms**: Script stops working when battery is low/high

**Cause**: Battery SOC limits reached

**Explanation**: This is **normal behavior**:
- Script automatically stops discharging when `SOC < minSOC + 2%`
- Script automatically stops charging when `SOC > maxSOC - 2%`
- When SOC returns to safe range, automation resumes

**No action needed** - this protects your battery from over-discharge/overcharge.

## Advanced Topics

### Understanding the Control Algorithm

The script implements a proportional control loop with hysteresis:

1. **Read Shelly Power**: Get current grid import/export
2. **Calculate Target**: Determine how much Zendure should output/input to reach zero grid
3. **Apply Hysteresis**: Only change if power delta exceeds thresholds
4. **Send Command**: Update Zendure limit via HTTP
5. **Wait**: Sleep for `INTERVAL_RUN_MAIN_SCRIPT` seconds
6. **Repeat**: Go to step 1


## Related Documentation

- [Shelly Script Automation Guide](SHELLY_SCRIPT_AUTOMATION.md) - General script template usage
- [Zendure API Documentation](https://github.com/Zendure/zenSDK) - Official Zendure SDK
- [Shelly Scripting Documentation](https://shelly-api-docs.shelly.cloud/gen2/Scripts/Tutorial) - Shelly Gen2/3 scripting

---

**Made with ☀️ for a sustainable energy future**
