# Shelly Device Response Dumps

This directory contains anonymized JSON response dumps from various Shelly devices, used for development and testing of the Shelly device implementation.

## Files

### Status Responses (`Shelly.GetStatus`)
- **status_em1.json** - Shelly EM Gen3 (S3EM-002CXCEU) - Single-phase energy meter with 2 channels + switch
- **status_em3.json** - Shelly Pro 3EM (SPEM-003CEBEU) - Three-phase energy meter with temperature sensor
- **statuc_plug.json** - Shelly Plus Plug S (SNPL-00112EU) - Smart plug with power monitoring
- **status_pm1.json** - Shelly PM Gen3 (S3PM-002CXCEU) - Power meter

### Config Responses (`Shelly.GetDeviceInfo`)
- **config_em1.json** - Device info for Shelly EM Gen3
- **config_em3.json** - Device info for Shelly Pro 3EM
- **config_plug.json** - Device info for Shelly Plus Plug S
- **config_pm1.json** - Device info for Shelly PM Gen3

## Anonymization

All sensitive information has been replaced with generic placeholders:
- **MAC addresses**: Replaced with placeholder values (AABBCCDDEEFF, 112233445566, 778899AABBCC, DDEEFF112233)
- **WiFi SSIDs**: Replaced with "MyNetwork"
- **WiFi BSSIDs**: Replaced with placeholder MAC addresses
- **IP addresses**: Replaced with 192.168.1.x addresses
- **IPv6 addresses**: Replaced with generic link-local addresses
- **Device IDs**: Updated to match placeholder MAC addresses

## Usage

These dumps are used by:
- Module registry configuration (`shelly_module_registry.dart`)
- Dynamic module detection testing
- Field generation validation
- Protocol documentation

## Device Module Summary

### EM1 (Single-Phase Energy Meter)
- Modules: `em1:0`, `em1:1`, `em1data:0`, `em1data:1`, `switch:0`
- Measures: voltage, current, active power, apparent power, power factor, frequency
- Energy totals per channel

### EM3 (Three-Phase Energy Meter)
- Modules: `em:0`, `emdata:0`, `temperature:0`
- Measures: per-phase voltage/current/power (a/b/c) + totals
- Energy totals per phase

### Plug S (Smart Plug)
- Modules: `switch:0`
- Measures: power, voltage, current, temperature, energy totals
- Control: on/off switching

### PM1 (Power Meter)
- Modules: `pm1:0`
- Measures: voltage, current, active power, frequency
- Energy totals: active energy and return energy
