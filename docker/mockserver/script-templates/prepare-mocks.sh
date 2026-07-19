#!/bin/bash
# prepare-mocks.sh - Script Template Update Mock Server Preparation
#
# This script runs on container startup to:
# 1. Copy all templates from /templates (mounted read-only from host assets)
# 2. For each template, generate a newer version (timestamp-based)
# 3. Update versions.json and manifest.json to reflect new versions
# 4. Update updatePath fields to point to mock server URL
# 5. Serve everything via nginx on port 80
#
# The generated versions always have version "9999.1.HHMMSS" which ensures
# they are always newer than any real template version, so the app always
# shows updates available.

set -e

TEMPLATES_SRC="/templates"
WORK_DIR="/work/templates"
TIMESTAMP=$(date +%H%M%S)
NEW_VERSION="9999.1.${TIMESTAMP}"
NEW_VERSION_HYPHENATED="9999-1-${TIMESTAMP}"

# External URL of this mock server (as seen by the Flutter app)
MOCK_SERVER_URL="${MOCK_SERVER_EXTERNAL_URL:-http://localhost:8085}"

echo "=== Script Template Mock Server Preparation ==="
echo "Timestamp: ${TIMESTAMP}"
echo "Generated version: ${NEW_VERSION}"
echo "External URL: ${MOCK_SERVER_URL}"
echo ""

# Step 1: Copy templates to writable directory
echo "[1/5] Copying templates to work directory..."
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cp -r "${TEMPLATES_SRC}/"* "${WORK_DIR}/"
echo "  Copied $(find "${WORK_DIR}" -name "*.json" | wc -l) files"

# Step 2: Parse manifest and generate new versions for each template
echo "[2/5] Generating new versions for each template..."

MANIFEST_FILE="${WORK_DIR}/manifest.json"

if [ ! -f "${MANIFEST_FILE}" ]; then
    echo "  ERROR: manifest.json not found at ${MANIFEST_FILE}"
    exit 1
fi

# Get list of template IDs from manifest
TEMPLATE_IDS=$(jq -r '.templates[].id' "${MANIFEST_FILE}")

for TEMPLATE_ID in ${TEMPLATE_IDS}; do
    TEMPLATE_DIR="${WORK_DIR}/${TEMPLATE_ID}"
    VERSIONS_FILE="${TEMPLATE_DIR}/versions.json"

    if [ ! -d "${TEMPLATE_DIR}" ] || [ ! -f "${VERSIONS_FILE}" ]; then
        echo "  WARNING: Skipping ${TEMPLATE_ID} (missing directory or versions.json)"
        continue
    fi

    # Get latest version filename
    LATEST_FILENAME=$(jq -r '.versions[0].fileName' "${VERSIONS_FILE}")
    LATEST_FILE="${TEMPLATE_DIR}/${LATEST_FILENAME}"

    if [ ! -f "${LATEST_FILE}" ]; then
        echo "  WARNING: Latest file not found for ${TEMPLATE_ID}: ${LATEST_FILENAME}"
        continue
    fi

    # Generate new filename
    NEW_FILENAME="${TEMPLATE_ID}_v${NEW_VERSION_HYPHENATED}.json"
    NEW_FILE="${TEMPLATE_DIR}/${NEW_FILENAME}"

    # Copy latest version and update version + updatePath fields
    jq --arg ver "${NEW_VERSION}" --arg url "${MOCK_SERVER_URL}/${TEMPLATE_ID}" \
        '.version = $ver | .updatePath = $url' \
        "${LATEST_FILE}" > "${NEW_FILE}"

    # Also update updatePath in existing template files
    for TEMPLATE_FILE in "${TEMPLATE_DIR}"/${TEMPLATE_ID}_v*.json; do
        if [ -f "$TEMPLATE_FILE" ] && [ "$TEMPLATE_FILE" != "$NEW_FILE" ]; then
            jq --arg url "${MOCK_SERVER_URL}/${TEMPLATE_ID}" \
                '.updatePath = $url' \
                "$TEMPLATE_FILE" > "${TEMPLATE_FILE}.tmp"
            mv "${TEMPLATE_FILE}.tmp" "$TEMPLATE_FILE"
        fi
    done

    # Prepend new version to versions.json
    jq --arg ver "${NEW_VERSION}" --arg fn "${NEW_FILENAME}" \
        '.versions = [{"version": $ver, "fileName": $fn}] + .versions' \
        "${VERSIONS_FILE}" > "${VERSIONS_FILE}.tmp"
    mv "${VERSIONS_FILE}.tmp" "${VERSIONS_FILE}"

    echo "  ${TEMPLATE_ID}: created ${NEW_FILENAME} (based on ${LATEST_FILENAME})"
done

# Step 2b: Copy and process custom test templates (not in manifest)
echo "[2b/5] Processing custom test templates..."

if [ -d "/custom-templates" ]; then
    # Copy only template subdirectories (skip README.md, nginx.conf, etc.)
    for CUSTOM_DIR in /custom-templates/*/; do
        if [ -d "$CUSTOM_DIR" ]; then
            cp -r "$CUSTOM_DIR" "${WORK_DIR}/"
        fi
    done

    # Process custom template directories not already in manifest
    for TEMPLATE_DIR in "${WORK_DIR}"/*/; do
        TEMPLATE_ID=$(basename "${TEMPLATE_DIR}")
        VERSIONS_FILE="${TEMPLATE_DIR}/versions.json"

        # Skip if already processed via manifest
        if echo "${TEMPLATE_IDS}" | grep -q "^${TEMPLATE_ID}$"; then
            continue
        fi

        # Skip if no versions.json (not a valid template directory)
        if [ ! -f "${VERSIONS_FILE}" ]; then
            continue
        fi

        # Get latest version filename
        LATEST_FILENAME=$(jq -r '.versions[0].fileName' "${VERSIONS_FILE}")
        LATEST_FILE="${TEMPLATE_DIR}/${LATEST_FILENAME}"

        if [ ! -f "${LATEST_FILE}" ]; then
            echo "  WARNING: Latest file not found for custom template ${TEMPLATE_ID}: ${LATEST_FILENAME}"
            continue
        fi

        # Generate new filename
        NEW_FILENAME="${TEMPLATE_ID}_v${NEW_VERSION_HYPHENATED}.json"
        NEW_FILE="${TEMPLATE_DIR}/${NEW_FILENAME}"

        # Copy latest version and update version + updatePath fields
        jq --arg ver "${NEW_VERSION}" --arg url "${MOCK_SERVER_URL}/${TEMPLATE_ID}" \
            '.version = $ver | .updatePath = $url' \
            "${LATEST_FILE}" > "${NEW_FILE}"

        # Update updatePath in existing template files
        for TEMPLATE_FILE in "${TEMPLATE_DIR}"/${TEMPLATE_ID}_v*.json; do
            if [ -f "$TEMPLATE_FILE" ] && [ "$TEMPLATE_FILE" != "$NEW_FILE" ]; then
                jq --arg url "${MOCK_SERVER_URL}/${TEMPLATE_ID}" \
                    '.updatePath = $url' \
                    "$TEMPLATE_FILE" > "${TEMPLATE_FILE}.tmp"
                mv "${TEMPLATE_FILE}.tmp" "$TEMPLATE_FILE"
            fi
        done

        # Prepend new version to versions.json
        jq --arg ver "${NEW_VERSION}" --arg fn "${NEW_FILENAME}" \
            '.versions = [{"version": $ver, "fileName": $fn}] + .versions' \
            "${VERSIONS_FILE}" > "${VERSIONS_FILE}.tmp"
        mv "${VERSIONS_FILE}.tmp" "${VERSIONS_FILE}"

        echo "  ${TEMPLATE_ID} (custom): created ${NEW_FILENAME} (based on ${LATEST_FILENAME})"
    done
else
    echo "  No custom templates directory found (skipping)"
fi

# Step 3: Update manifest.json with new latest versions and updatePaths
echo "[3/5] Updating manifest.json..."

jq --arg ver "${NEW_VERSION}" --arg baseUrl "${MOCK_SERVER_URL}" \
    '.templates = [.templates[] | .latestVersion = $ver | .updatePath = ($baseUrl + "/" + .id)] | .lastUpdated = (now | todate)' \
    "${MANIFEST_FILE}" > "${MANIFEST_FILE}.tmp"
mv "${MANIFEST_FILE}.tmp" "${MANIFEST_FILE}"

echo "  Updated all template entries:"
echo "    latestVersion: ${NEW_VERSION}"
echo "    updatePath: ${MOCK_SERVER_URL}/{template-id}"

# Step 4: Summary
echo "[4/5] Generated mock data summary:"
echo "  Official templates: $(echo "${TEMPLATE_IDS}" | wc -w)"
echo "  Total files: $(find "${WORK_DIR}" -name "*.json" | wc -l)"
echo "  Manifest: ${MANIFEST_FILE}"
if [ -d "/custom-templates" ]; then
    CUSTOM_COUNT=$(find "${WORK_DIR}" -maxdepth 1 -type d | while read dir; do
        id=$(basename "$dir")
        if ! echo "${TEMPLATE_IDS}" | grep -q "^${id}$"; then
            echo "$id"
        fi
    done | wc -l)
    echo "  Custom templates: ${CUSTOM_COUNT} (not in manifest)"
fi

# Step 5: Configure and start nginx
echo "[5/5] Configuring nginx..."

cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 80;
    server_name localhost;

    root /work/templates;
    autoindex on;

    location / {
        add_header Access-Control-Allow-Origin *;
        default_type application/json;
        try_files \$uri \$uri/ =404;
    }
}
EOF

echo ""
echo "=== Mock Server Ready ==="
echo "Serving on port 80 (host: ${MOCK_SERVER_URL})"
echo ""
echo "Test endpoints (official):"
echo "  curl ${MOCK_SERVER_URL}/manifest.json"
echo "  curl ${MOCK_SERVER_URL}/script-watchdog/versions.json"
echo "  curl ${MOCK_SERVER_URL}/test-script/test-script_v${NEW_VERSION_HYPHENATED}.json"
echo ""
echo "Test endpoints (custom):"
echo "  curl ${MOCK_SERVER_URL}/custom-hello-world/versions.json"
echo ""
echo "Run Flutter app with:"
echo "  flutter run --dart-define=SCRIPT_UPDATE_BASE_URL=${MOCK_SERVER_URL}"
echo ""

# Start nginx in foreground
exec nginx -g "daemon off;"
