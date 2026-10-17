# Shelly Mock Server

Docker-based mock HTTP servers for testing Shelly device integration without physical hardware.

## Quick Start

```bash
cd docker
docker-compose up -d
```

## Available Endpoints

Gen2/Gen3 servers (EM1, EM3, Plug, PM1) support both GET and POST requests to JSON-RPC endpoints. The Shelly 1 PM mock (Gen1) uses the plain Shelly Gen1 HTTP API:

| Device | Port | Model | Endpoints |
|--------|------|-------|-----------|
| EM1 | 15001 | S3EM-002CXCEU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| EM3 | 15002 | SPEM-003CEBEU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| Plug | 15003 | SNPL-00112EU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| PM1 | 15004 | S3PM-002CXCEU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| Shelly 1 PM | 15006 | SNSW-001A15EU | `/shelly`, `/status`, `/relay/0`, `/settings` (Gen1 HTTP API) |
| Shelly 3EM | 15007 | SHEM-3 | `/shelly`, `/status`, `/relay/0`, `/settings` (Gen1 HTTP API, 3-phase `emeters` + `total_power`) |
| Shelly EM | 15008 | SHEM-1 | `/shelly`, `/status`, `/settings`, `/relay/0` (Gen1 HTTP API, 2× `emeters` CTs + contactor relay) |
| Shelly 4Pro | 15009 | S4PM-00X8CEU | `/shelly`, `/status`, `/relay/0..3`, `/settings` (Gen1 HTTP API, 4 relays, no metering) |
| Script Templates | 15005 | - | `/manifest.json`, `/{id}/versions.json`, `/{id}/{file}.json` |

## Testing Examples

### Test Status Endpoint
```bash
curl http://localhost:15001/rpc/Shelly.GetStatus
curl -X POST http://localhost:15001/rpc/Shelly.GetStatus \
  -H "Content-Type: application/json" \
  -d '{"id": 1, "method": "Shelly.GetStatus"}'
```

### Test Device Info
```bash
curl http://localhost:15002/rpc/Shelly.GetDeviceInfo
```

### Test All Devices
```bash
# EM1
curl http://localhost:15001/rpc/Shelly.GetDeviceInfo | jq .

# EM3
curl http://localhost:15002/rpc/Shelly.GetStatus | jq .

# Plug
curl http://localhost:15003/rpc/Shelly.GetStatus | jq .
```

### Test Shelly 1 PM (Gen1 HTTP API, no JSON-RPC)
```bash
# Device identification (no auth required, used for discovery)
curl http://localhost:15006/shelly | jq .

# Status (dynamic: power/meters/tmp change per call)
curl http://localhost:15006/status | jq .

# Relay state + control
curl http://localhost:15006/relay/0 | jq .
curl "http://localhost:15006/relay/0?turn=on" | jq .
curl "http://localhost:15006/relay/0?turn=off" | jq .

# Settings
curl http://localhost:15006/settings | jq .
```

### Test Shelly 3EM (Gen1 HTTP API, 3-phase energy meter)
```bash
# Device identification (type=SHEM-3, used to select the 3EM implementation)
curl http://localhost:15007/shelly | jq .

# Status (dynamic: 3 x emeters {power,pf,current,voltage,total,total_returned} + total_power)
curl http://localhost:15007/status | jq .

# Contactor relay state + control
curl http://localhost:15007/relay/0 | jq .
curl "http://localhost:15007/relay/0?turn=on" | jq .
curl "http://localhost:15007/relay/0?turn=off" | jq .

# Settings
curl http://localhost:15007/settings | jq .
```

### Test Shelly EM (Gen1 HTTP API, single-phase energy meter)
```bash
# Device identification (type=SHEM-1, cosmetic only - UI is derived from /status)
curl http://localhost:15008/shelly | jq .

# Status (dynamic: 2 emeters {power,pf,current,voltage,total,total_returned} + relays[contactors], no total_power)
curl http://localhost:15008/status | jq .

# Contactor state / control
curl "http://localhost:15008/relay/0?turn=on" | jq .

# Settings
curl http://localhost:15008/settings | jq .
```

### Test Shelly 4Pro (Gen1 HTTP API, 4 relays, no metering)
```bash
# Device identification (type=S4PM-00X8CEU, cosmetic - UI derived from /status)
curl http://localhost:15009/shelly | jq .

# Status (4 x relays with varied states; no meters/tmp)
curl http://localhost:15009/status | jq .

# Relay state + control (4 channels)
curl "http://localhost:15009/relay/1?turn=on" | jq .
curl "http://localhost:15009/relay/2?turn=off" | jq .
curl http://localhost:15009/relay/3 | jq .

# Settings
curl http://localhost:15009/settings | jq .
```

## Integration with Flutter App

Update your app to use the mock servers:

1. **Network Discovery**: Point network scanner to `localhost:15001-15003`
2. **Device Connection**: Configure device with mock server IP/port
3. **Testing**: Run app against mock servers for development

Example in device configuration:
```dart
final device = ShellyWifiDevice(
  netIpAddress: '127.0.0.1',  // or 'localhost'
  netPort: 15001,              // EM1 mock server
  // ... other params
);
```

## Management

```bash
# Start all servers
docker-compose up -d

# View logs
docker-compose logs -f

# View logs for specific device
docker-compose logs -f shelly-em1

# Check container status
docker-compose ps

# Stop servers
docker-compose down

# Restart specific service
docker-compose restart shelly-em1
```

## Response Data

Mock servers serve responses from the expectation files in `mockserver/expectations/`:
- `em1_expectations.json` → EM1 device responses
- `em3_expectations.json` → EM3 device responses
- `plug_expectations.json` → Plug device responses
- `pm1_expectations.json` → PM1 device responses
- `shelly1_expectations.json` → Shelly 1 PM (Gen1) device responses
- `shelly3em_expectations.json` → Shelly 3EM (Gen1) device responses
- `shellyem_expectations.json` → Shelly EM (Gen1, single-phase) device responses
- `shelly4pro_expectations.json` → Shelly 4Pro (Gen1, 4 relays) device responses

All MAC addresses, IPs, and SSIDs have been anonymized.

### Gotchas when writing expectation files (MockServer 5.11.2)

Three non-obvious rules, all learned the hard way — see `shelly1_expectations.json` / `shelly3em_expectations.json` for working examples:

1. **`queryStringParameters` values must be arrays of regexes.** Write `["^true$"]`, not the object form `{"matches": "^true$"}`. The object form is rejected ("incorrect expectation json format") and the expectation never loads.
2. **In JavaScript response templates, read query params from `request.queryStringParameters`** (not `request.queryParameters`, which is `undefined`). Values are arrays, so index with `[0]`: `request.queryStringParameters.ssid[0]`.
3. **Specific `?param=` templates need `priority: 100`** to beat a same-path static catch-all. Without it, `GET /settings?eco_mode_enabled=false` matches the no-query `GET /settings` reader and returns the full config instead of the small echo stub.

## Architecture

Each device runs in its own MockServer container with:
- Official `mockserver/mockserver:5.11.2` Docker image
- Expectation-based JSON configuration
- Port mapping: container port 1080 → host ports 15001-15004, 15006-15009
- Automatic restart on failure
- Built-in MockServer dashboard

## MockServer Dashboard

Each MockServer instance has a dashboard for viewing requests and expectations:
- EM1: http://localhost:15001/mockserver/dashboard
- EM3: http://localhost:15002/mockserver/dashboard
- Plug: http://localhost:15003/mockserver/dashboard
- PM1: http://localhost:15004/mockserver/dashboard
- Shelly 1 PM: http://localhost:15006/mockserver/dashboard
- Shelly 3EM: http://localhost:15007/mockserver/dashboard
- Shelly EM: http://localhost:15008/mockserver/dashboard
- Shelly 4Pro: http://localhost:15009/mockserver/dashboard

## Troubleshooting

**Port conflicts:**
```bash
# Check if ports are in use
lsof -i :15001
lsof -i :15002
lsof -i :15003
  lsof -i :15004
  lsof -i :15006
  lsof -i :15007
  lsof -i :15008
  lsof -i :15009

  # Change ports in docker-compose.yml if needed
```

**Container issues:**
```bash
# Check container status
docker-compose ps

# View detailed logs
docker-compose logs --tail=100 shelly-em1

# Restart specific service
docker-compose restart shelly-em1
```

**Network issues:**
```bash
# Test from host
curl http://localhost:15001/mockserver/status

# Verify expectations loaded
curl http://localhost:15001/mockserver/expectation
```

**Verify JSON responses:**
```bash
# Should return device info
curl http://localhost:15001/rpc/Shelly.GetDeviceInfo | jq .

# Should return status with em1:0, em1:1, etc.
curl http://localhost:15001/rpc/Shelly.GetStatus | jq .
```

## Device Details

### EM1 (S3EM-002CXCEU) - Port 15001
- **Type**: Single-phase energy meter Gen3
- **Modules**: `em1:0`, `em1:1`, `em1data:0`, `em1data:1`, `switch:0`
- **Features**: 2-channel energy metering, active/apparent power, power factor, frequency, integrated switch

### EM3 (SPEM-003CEBEU) - Port 15002
- **Type**: Three-phase energy meter Pro 3EM
- **Modules**: `em:0`, `emdata:0`, `temperature:0`
- **Features**: Per-phase measurements (a/b/c), total power, energy totals, temperature sensor

### Plug (SNPL-00112EU) - Port 15003
- **Type**: Smart plug Plus Plug S
- **Modules**: `switch:0`
- **Features**: Power monitoring, temperature, energy totals, on/off control

### PM1 (S3PM-002CXCEU) - Port 15004
- **Type**: Power meter Gen3
- **Modules**: `pm1:0`
- **Features**: Voltage, current, active power, frequency, energy totals (active and return)

### Shelly 1 PM (SNSW-001A15EU) - Port 15006
- **Type**: Relay switch with power metering (Gen1)
- **API**: Plain HTTP with query parameters (NOT JSON-RPC like Gen2/Gen3)
  - `GET /shelly` - device identification: `type`, `mac`, `auth`, `fw`, `longid` (no auth required, discovery endpoint)
  - `GET /status` - flat status object: `relays[]` (ison, timer, source), `meters[]` (power, total, counters), `inputs[]`, `tmp` (tC/tF), `wifi_sta`, `uptime` etc.
  - `GET /relay/0?turn=on|off|toggle` - relay control, returns channel state
  - `GET /settings` - device configuration (hostname, relay config, max_power)
  - `GET /reboot` - reboot the device, returns `{"ok":true}`
- **Features**: Relay on/off, power metering (power, energy total, per-minute counters), internal temperature
- **Note**: Mock is stateless - `/relay/0?turn=off` returns `ison: false` in its response, but `/status` always reports the relay as on

### Shelly 3EM (SHEM-3) - Port 15007
- **Type**: 3-phase DIN-rail energy meter (Gen1), 3x 120A CT clamps + 10A contactor
- **API**: Plain HTTP with query parameters (Gen1, same family as Shelly 1 PM)
  - `GET /shelly` - device identification: `type` = `SHEM-3` (cosmetic; the UI is derived from the `/status` payload), `mac`, `auth`, `fw`
  - `GET /status` - `relays[]` (1 contactor), `emeters[]` (3 phases: power, pf, current, voltage, total, total_returned), `total_power` (sum of phases), `fs_mounted`
  - `GET /relay/0?turn=on|off` - contactor control, returns channel state
  - `GET /settings` - configuration (relays, emeters, led_status_disable, login, wifi)
- **Features**: Per-phase power/voltage/current/power-factor, per-phase energy import/export, total power, contactor on/off
- **Note**: Unlike the Gen2 EM mock (port 15002, JSON-RPC `em:0`), the Gen1 3EM reports an `emeters` array + `total_power` over plain HTTP

### Shelly EM (SHEM-1) - Port 15008
- **Type**: Single-phase DIN-rail energy meter (Gen1), 2x CT clamps (shared phase) + built-in contactor
- **API**: Plain HTTP with query parameters (Gen1, same family as Shelly 3EM)
  - `GET /shelly` - device identification: `type` = `SHEM-1` (cosmetic; the UI is derived from the `/status` payload), `mac`, `auth`, `fw`
  - `GET /status` - 2-entry `emeters[]` array (power, pf, current, voltage, total, total_returned) + a `relays[]` entry for the contactor; **no** `total_power`
  - `GET /relay/0?turn=on|off` - contactor control, returns channel state
  - `GET /settings` - configuration (relays, emeters, led_status_disable, login, wifi)
- **Features**: Two-CT power/voltage/current/power-factor, two-CT energy import/export, contactor on/off
- **Note**: Same Gen1 payload-driven implementation as the 3EM (one `ShellyV1DeviceImplementation`); the app renders two "Phase" categories + a "Schalter 1" main-power switch. Device power is the sum of both CTs (the two clamps share a phase). Unlike the 3EM there is no `total_power`, so no totals row.

### Shelly 4Pro (S4PM-00X8CEU) - Port 15009
- **Type**: 4-channel relay device (Gen1), 4x 16A relays, **no** power metering
- **API**: Plain HTTP with query parameters (Gen1, same family as Shelly 1 PM)
  - `GET /shelly` - device identification: `type` = `S4PM-00X8CEU` (cosmetic; the UI is derived from the `/status` payload), `mac`, `auth`, `fw`
  - `GET /status` - 4-entry `relays[]` array (mock states: on/off/on/off), `wifi_sta`; **no** `meters`, **no** `tmp`
  - `GET /relay/{0,1,2,3}?turn=on|off` - per-channel control, returns channel state
  - `GET /settings` - configuration (4 relays, names, led_status_disable, login, wifi)
- **Features**: 4 independent relay toggles + 4 status fields
- **Note**: Tests the multi-relay path — the same payload-driven `ShellyV1DeviceImplementation` loops over `relays.length`, so all 4 channels render with no device-specific code. The mock is stateless (a `?turn=off` response returns `ison: false`, but `/status` keeps its fixed varied states)

## Script Template Update Mock Server - Port 15005

A mock server for testing the script template update feature. On startup, it automatically generates a newer version of every template (with a timestamp-based version `9999.1.HHMMSS`) so the app always shows updates available.

### How It Works

1. Container starts and copies all templates from `assets/script_templates/`
2. For each template, reads `versions.json` and finds the latest version
3. Creates a copy with version `9999.1.HHMMSS` (always newer than any real version)
4. Updates `versions.json` and `manifest.json` to include the new version
5. Serves all files via nginx on port 80 (mapped to host port 15005)

### Usage with Flutter App

```bash
# Start mock server
cd docker
docker-compose up -d script-templates-mock

# Run Flutter app with mock URL
flutter run --dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:15005

# Or for a specific platform
flutter run -d linux --dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:15005
```

### Testing Endpoints

```bash
# Check manifest (should show latestVersion: 9999.1.HHMMSS)
curl http://localhost:15005/manifest.json | jq .

# Check versions for a specific template
curl http://localhost:15005/script-watchdog/versions.json | jq .

# Download a specific template
curl http://localhost:15005/test-script/test-script_v2-0-0.json | jq .id,.version

# Verify auto-generated version exists
curl http://localhost:15005/test-script/ 2>/dev/null | grep "v9999"
```

### Rebuilding After Template Changes

If you modify templates in `assets/script_templates/`, restart the container to regenerate:

```bash
docker-compose restart script-templates-mock

# Or rebuild from scratch
docker-compose up -d --build script-templates-mock
```

### Architecture

- **Image**: nginx:alpine + jq + bash
- **Startup**: Custom script generates mock data, then starts nginx
- **Port**: Container port 80 → host port 15005
- **Volume**: `../assets/script_templates` mounted read-only as `/templates`
- **Version format**: `9999.1.HHMMSS` (unique per container restart)

## Notes

- MockServer image is ~200MB per container (~1000MB total for 5 Shelly containers, shared image)
- Script Templates mock uses nginx:alpine (~40MB)
- All expectation files are mounted read-only
- Automatic restart on failure for reliability
- 50ms response delay configured to simulate network latency (Shelly mocks only)
- Supports GET and POST methods (method: ".*" in expectations)
