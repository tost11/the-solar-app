# Architecture & Development Guide

This document provides detailed information about The Solar App's architecture, design patterns, and development guidelines.

## Architecture

### Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: StatefulWidget (standard Flutter)
- **Local Storage**: shared_preferences
- **UI Design**: Material Design 3
- **Bluetooth**: flutter_blue_plus
- **Networking**: http, network_info_plus, lan_scanner, bonsoir

### Project Structure

```
lib/
├── constants/           # Bluetooth UUIDs, command constants
├── models/             # Device models organized by brand
│   └── devices/
│      └── manufactureres/
│          ├── shelly/
│          ├── deyesun/
│          ├── kostal/
│          ├── opendtu/
│          └── zendure/
├── screens/            # UI screens
│   └── configuration/  # Device configuration screens
├── services/           # Business logic and communication
│   └── devices/        # Device-specific services by brand
├── utils/              # Utilities (dialog, messages, auth)
└── widgets/            # Reusable UI components
```

### Design Patterns

#### Generic Template Pattern
The app uses generic templates to eliminate code duplication across device implementations:

- **GenericBluetoothDevice<TService, TImpl>**: Base for Bluetooth devices
  - Automatic service setup and BLE connection handling
  - Used by Zendure BLE, Shelly BLE devices

- **GenericWiFiDevice<TService, TImpl>**: Base for WiFi/network devices without authentication
  - Includes `DeviceWifiMixin` for IP/hostname/port management
  - Used by Zendure WiFi devices

- **GenericWiFiAuthDevice<TService, TImpl>**: Base for WiFi/network devices with authentication
  - Extends GenericWiFiDevice with `DeviceAuthenticationMixin` for username/password
  - Used by OpenDTU, DeyeSun, Shelly WiFi devices, Kostal devices

#### Device Implementation Pattern
- **DeviceImplementation**: Base class defining device-specific behavior
  - `getMenuItems()`: Device menu actions
  - `getDataFields()`: Data display fields with extractors
  - `getControlItems()`: UI controls (switches, sliders)
  - `getCustomSections()`: Custom UI widgets (optional)
  - `sendCommand()`: Device-specific command handling
- **Shared Implementations**: Single implementation class used by both Bluetooth and WiFi variants
  - Example: `ZendureDeviceImplementation` serves both `BluetoothZendureDevice` and `WiFiZendureDevice`

#### Other Patterns
- **Factory Pattern**: `DeviceFactory` for device instantiation
- **Mixin Pattern**: `DeviceWifiMixin`, `DeviceAuthenticationMixin` for reusable functionality
- **Service Layer**: Thin transport wrappers (HTTP, BLE, Modbus, WebSocket)
- **Device Layer**: Business logic and command orchestration

## Development

### Protobuf Code Generation

The Hoymiles device integration uses Protocol Buffers (protobuf) for communication. If you need to regenerate the Dart protobuf files from source `.proto` files, follow these steps:

#### Prerequisites

Install the protobuf compiler and Dart plugin:

```bash
# Install protoc compiler (if not already installed)
# On Ubuntu/Debian:
sudo apt-get install protobuf-compiler

# Install Dart protobuf plugin
flutter pub global activate protoc_plugin

# Add the Dart plugin to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$PATH:$HOME/.pub-cache/bin"
```

#### Generate Dart Protobuf Files

The `.proto` source files are included in the repository at `lib/models/devices/hoymiles/protobuf/proto/`.

From the project root directory, regenerate the Dart files:

```bash
#my current version was broken so use older one
dart pub global activate protoc_plugin 21.1.2

protoc \
  --dart_out=lib/models/devices/manufacturers/hoymiles/protobuf \
  --proto_path=lib/models/devices/manufacturers/hoymiles/protobuf/proto \
  RealDataNew.proto \
  GetConfig.proto \
  NetworkInfo.proto
```

#### When to Regenerate

Regenerate the protobuf files when:
- Updating to a new version of the hoymiles-wifi reference implementation
- The protobuf message definitions change upstream
- After upgrading the `protobuf` package version in `pubspec.yaml`

**Note**: Generated files may contain analyzer warnings (e.g., `$_clearField` method issues) - these are cosmetic and don't affect functionality.

### Code Style

- Use `DialogUtils.executeWithLoading()` for async operations
- Use `MessageUtils` for user feedback (errors, success, warnings)
- Follow Flutter/Dart style guidelines
