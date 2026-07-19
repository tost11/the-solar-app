# Shelly Mock Server

Docker-based mock HTTP servers for testing Shelly device integration without physical hardware.

## Quick Start

```bash
cd docker
docker-compose up -d
```

## Available Endpoints

All servers support both GET and POST requests to RPC endpoints:

| Device | Port | Model | Endpoints |
|--------|------|-------|-----------|
| EM1 | 8081 | S3EM-002CXCEU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| EM3 | 8082 | SPEM-003CEBEU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| Plug | 8083 | SNPL-00112EU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| PM1 | 8084 | S3PM-002CXCEU | `/rpc/Shelly.GetDeviceInfo`, `/rpc/Shelly.GetStatus` |
| Script Templates | 8085 | - | `/manifest.json`, `/{id}/versions.json`, `/{id}/{file}.json` |

## Testing Examples

### Test Status Endpoint
```bash
curl http://localhost:8081/rpc/Shelly.GetStatus
curl -X POST http://localhost:8081/rpc/Shelly.GetStatus \
  -H "Content-Type: application/json" \
  -d '{"id": 1, "method": "Shelly.GetStatus"}'
```

### Test Device Info
```bash
curl http://localhost:8082/rpc/Shelly.GetDeviceInfo
```

### Test All Devices
```bash
# EM1
curl http://localhost:8081/rpc/Shelly.GetDeviceInfo | jq .

# EM3
curl http://localhost:8082/rpc/Shelly.GetStatus | jq .

# Plug
curl http://localhost:8083/rpc/Shelly.GetStatus | jq .
```

## Integration with Flutter App

Update your app to use the mock servers:

1. **Network Discovery**: Point network scanner to `localhost:8081-8083`
2. **Device Connection**: Configure device with mock server IP/port
3. **Testing**: Run app against mock servers for development

Example in device configuration:
```dart
final device = ShellyWifiDevice(
  netIpAddress: '127.0.0.1',  // or 'localhost'
  netPort: 8081,              // EM1 mock server
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

All MAC addresses, IPs, and SSIDs have been anonymized.

## Architecture

Each device runs in its own MockServer container with:
- Official `mockserver/mockserver:5.15.0` Docker image
- Expectation-based JSON configuration
- Port mapping: container port 1080 → host ports 8081/8082/8083
- Health checks every 10 seconds
- Automatic restart on failure
- Built-in MockServer dashboard

## MockServer Dashboard

Each MockServer instance has a dashboard for viewing requests and expectations:
- EM1: http://localhost:8081/mockserver/dashboard
- EM3: http://localhost:8082/mockserver/dashboard
- Plug: http://localhost:8083/mockserver/dashboard
- PM1: http://localhost:8084/mockserver/dashboard

## Troubleshooting

**Port conflicts:**
```bash
# Check if ports are in use
lsof -i :8081
lsof -i :8082
lsof -i :8083
lsof -i :8084

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
curl http://localhost:8081/mockserver/status

# Verify expectations loaded
curl http://localhost:8081/mockserver/expectation
```

**Verify JSON responses:**
```bash
# Should return device info
curl http://localhost:8081/rpc/Shelly.GetDeviceInfo | jq .

# Should return status with em1:0, em1:1, etc.
curl http://localhost:8081/rpc/Shelly.GetStatus | jq .
```

## Device Details

### EM1 (S3EM-002CXCEU) - Port 8081
- **Type**: Single-phase energy meter Gen3
- **Modules**: `em1:0`, `em1:1`, `em1data:0`, `em1data:1`, `switch:0`
- **Features**: 2-channel energy metering, active/apparent power, power factor, frequency, integrated switch

### EM3 (SPEM-003CEBEU) - Port 8082
- **Type**: Three-phase energy meter Pro 3EM
- **Modules**: `em:0`, `emdata:0`, `temperature:0`
- **Features**: Per-phase measurements (a/b/c), total power, energy totals, temperature sensor

### Plug (SNPL-00112EU) - Port 8083
- **Type**: Smart plug Plus Plug S
- **Modules**: `switch:0`
- **Features**: Power monitoring, temperature, energy totals, on/off control

### PM1 (S3PM-002CXCEU) - Port 8084
- **Type**: Power meter Gen3
- **Modules**: `pm1:0`
- **Features**: Voltage, current, active power, frequency, energy totals (active and return)

## Script Template Update Mock Server - Port 8085

A mock server for testing the script template update feature. On startup, it automatically generates a newer version of every template (with a timestamp-based version `9999.1.HHMMSS`) so the app always shows updates available.

### How It Works

1. Container starts and copies all templates from `assets/script_templates/`
2. For each template, reads `versions.json` and finds the latest version
3. Creates a copy with version `9999.1.HHMMSS` (always newer than any real version)
4. Updates `versions.json` and `manifest.json` to include the new version
5. Serves all files via nginx on port 80 (mapped to host port 8085)

### Usage with Flutter App

```bash
# Start mock server
cd docker
docker-compose up -d script-templates-mock

# Run Flutter app with mock URL
flutter run --dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:8085

# Or for a specific platform
flutter run -d linux --dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:8085
```

### Testing Endpoints

```bash
# Check manifest (should show latestVersion: 9999.1.HHMMSS)
curl http://localhost:8085/manifest.json | jq .

# Check versions for a specific template
curl http://localhost:8085/script-watchdog/versions.json | jq .

# Download a specific template
curl http://localhost:8085/test-script/test-script_v2-0-0.json | jq .id,.version

# Verify auto-generated version exists
curl http://localhost:8085/test-script/ 2>/dev/null | grep "v9999"
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
- **Port**: Container port 80 → host port 8085
- **Volume**: `../assets/script_templates` mounted read-only as `/templates`
- **Version format**: `9999.1.HHMMSS` (unique per container restart)

## Notes

- MockServer image is ~200MB per container (~800MB total for 4 Shelly containers)
- Script Templates mock uses nginx:alpine (~40MB)
- All expectation files are mounted read-only
- Health checks ensure containers are ready before marking as "healthy"
- Automatic restart on failure for reliability
- 50ms response delay configured to simulate network latency (Shelly mocks only)
- Supports GET and POST methods (method: ".*" in expectations)
