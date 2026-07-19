# Custom Template Update Testing

Test fixtures for verifying the custom script template update flow (Tab "Eigene" in the Skript-Updates screen).

## Overview

These templates are designed to be manually imported into the app via the template import screen. Once imported, they can be checked for updates using the "Eigene" tab in the Script Updates screen.

The existing mock server (`script-templates-mock`, port 8085) automatically generates a newer version (`9999.1.HHMMSS`) for these templates on every container start, so an update is always available.

## Prerequisites

- Docker and Docker Compose installed
- Flutter development environment set up

## Setup

### 1. Start the mock server

```bash
cd docker
docker-compose up -d script-templates-mock
```

The server will:
- Serve official templates from `assets/script_templates/` (with auto-bumped versions)
- Serve custom test templates from `test/fixtures/custom_templates/` (with auto-bumped versions)
- Custom templates are NOT listed in `manifest.json` (they won't appear in the "Offizielle" tab)

### 2. Verify the mock server is running

```bash
# Check official templates
curl http://localhost:8085/manifest.json

# Check custom templates
curl http://localhost:8085/custom-hello-world/versions.json
```

The `custom-hello-world/versions.json` response should show two versions:
- `9999.1.XXXXXX` (auto-generated, always newer)
- `1.0.0` (the base version)

### 3. Run the Flutter app with mock server

```bash
flutter run -d linux --dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:8085
```

## Testing the Custom Update Flow

### Step 1: Import the test template

1. Copy the content of `custom-hello-world/custom-hello-world_v1-0-0.json`
2. In the app, navigate to: Shelly device > Scripts > Templates > Import
3. Paste the JSON content
4. Click "Importieren"

The template "Custom Hello World" (v1.0.0) should now appear in your template list.

### Step 2: Check for updates

1. Open the settings drawer (hamburger menu)
2. Click "Skript-Updates prufen"
3. Switch to the **"Eigene"** tab
4. You should see "Custom Hello World" listed with version 1.0.0 and the source URL

### Step 3: Trigger update check

1. Click the **"Prufen"** button next to "Custom Hello World"
2. The app fetches `http://localhost:8085/custom-hello-world/versions.json`
3. It finds version `9999.1.XXXXXX` which is newer than `1.0.0`
4. A green update notification appears showing the available version

### Step 4: Install the update

1. Click **"Aktualisieren"**
2. The app downloads and installs the new template version
3. A success indicator (green checkmark) should appear

### Step 5: Verify

- The template version in your local storage should now be `9999.1.XXXXXX`
- Clicking "Prufen" again should show "Aktuell" (up to date) — until the container is restarted (which generates a new timestamp-based version)

## Template: custom-hello-world

A minimal test template that prints a message on a timer.

**Parameters:**
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| MESSAGE | string | yes | "Hello World" | Text to print to the console |
| INTERVAL_MS | duration | yes | 5000 | Timer interval in milliseconds |

**What the generated script does:**
- Defines a `printMessage()` function that prints `MESSAGE`
- Sets up a repeating timer at `INTERVAL_MS` interval
- Calls `printMessage()` once immediately

## How the Mock Server Handles Custom Templates

The `prepare-mocks.sh` script (in `docker/mockserver/script-templates/`) has two processing loops:

1. **Loop 1 (official):** Processes all templates listed in `manifest.json`, generates newer versions, updates the manifest
2. **Loop 2 (custom):** Scans for template directories NOT in `manifest.json` (copied from `/custom-templates`), applies the same version-bump logic but does NOT add them to the manifest

This means:
- Official templates appear in Tab 1 ("Offizielle") — auto-checked against `manifest.json`
- Custom templates appear in Tab 2 ("Eigene") — manually checked per-template via their `updatePath`

## Adding More Custom Test Templates

To add a new custom test template:

1. Create a new directory: `test/fixtures/custom_templates/{template-id}/`
2. Add a `versions.json` file listing the initial version
3. Add the template JSON file (e.g., `{template-id}_v1-0-0.json`)
4. Set `updatePath` to `http://localhost:8085/{template-id}` in the template JSON
5. Rebuild the mock server: `docker-compose up -d --build script-templates-mock`

The mock server will automatically detect the new template and generate a newer version for it.

## Troubleshooting

### Template doesn't appear in "Eigene" tab
- Ensure the template was imported successfully (check template list)
- Ensure the template has a non-null `updatePath` field in the JSON
- Ensure the template `id` is not the same as any built-in (asset) template

### "Prufen" shows network error
- Verify the mock server is running: `curl http://localhost:8085/custom-hello-world/versions.json`
- Verify the app was started with `--dart-define=SCRIPT_UPDATE_BASE_URL=http://localhost:8085`
- Check that the template's `updatePath` matches the mock server URL

### Update check shows "Aktuell" (no update available)
- The mock server may have been restarted after you installed the update (generating the same or older timestamp)
- Restart the container: `docker-compose restart script-templates-mock`
- The new timestamp-based version will always be newer than any previously installed version
