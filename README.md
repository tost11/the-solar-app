# The Solar App

A privacy-focused Flutter application for managing and monitoring micro inverters and power stations.
Connect locally via Bluetooth or WiFi without any cloud services or user registration required.

## ⚠️ Disclaimer

This project is provided “as is”, without any warranty of any kind.
There is no guarantee that the implementation of the device protocols or APIs is correct or complete.
Use of this software may result in malfunction, damage, or destruction of device hardware or software.
Use on own risk.

If you use this project, it’s on you. Make sure you know what you’re doing.

## Overview

The Solar App provides direct local control and monitoring (only current values) of solar micro inverters and smart energy devices. 
Whether you're tracking your solar production, configuring device settings, or managing power limits, the app puts you in control of your energy system.
Also support for OpenDTU for easier managing of device.

### Key Features

- **Privacy First**: No login, no registration, no cloud dependency
- **Local Connection**: Connect via Bluetooth Low Energy or WiFi/LAN
- **Multi-Device Support**: Compatible with multiple brands and device types
- **Real-Time Monitoring**: Track power production, consumption, and battery levels
- **Device Configuration**: WiFi setup, power limits, access point configuration
- **Cross-Platform**: Built with Flutter for mobile (Android) and desktop support

## Currently Supported

### Platforms
- **Android** ✅ (Primary platform)
- **Linux** ✅ (No Bluetooth, Bad layout (Mobile))
- **Windows** 🚧 (Planned, never tested maby works out of the box)

### Supported Devices

#### Shelly (Bluetooth & WiFi/Network)
- **Shelly EM3**: Three-phase energy meter with current/voltage/power monitoring
- **Shelly Plus Plug**: Smart plug with power monitoring and control
- **All Others**: Setting up general settings
- **Connection Types**: Bluetooth Low Energy, WiFi/Network (HTTP JSON-RPC)
- **Features**:
  - RFC7616 Digest Authentication (SHA-256)
  - Three-phase energy monitoring (EM3) or single-phase (Plug) with voltage/current/power
  - Power control (on/off switching for Plug)
  - General settings, WiFi/AP configuration, authentication, device restart

#### DeyeSun (WiFi/Network)
- **Micro Inverters**: Solar inverters with Modbus and HTTP support
- **Connection Types**: WiFi/Network (HTTP, Modbus TCP)
- **Features**:
  - Real-time power production monitoring
  - Inverter on/off control
  - Up to 4 PV string monitoring (voltage, current, power, yield)
  - Grid AC monitoring (voltage, current, frequency)
  - Power limit configuration (percentage-based)
  - Temperature, operating time, yield tracking (daily/total)
  - Online monitoring server, WiFi/AP configuration, device restart

#### Zendure (Bluetooth & WiFi)
- **Power Stations**: Portable power stations and energy storage
- **Connection Types**: Bluetooth Low Energy, WiFi/Network (REST API)
- **Features**:
  - Battery level monitoring (SOC, pack voltage/current)
  - Power input/output tracking (solar input, home output)
  - Battery SOC limits and power limit configuration
  - WiFi/MQTT configuration (Bluetooth only)
  - Pack state and firmware version tracking

#### OpenDTU (WiFi/Network)
- **Solar Gateway**: Open-source DTU for Hoymiles micro inverters
- **Connection Types**: WiFi/Network (HTTP + WebSocket)
- **Features**:
  - Real-time multi-inverter monitoring via WebSocket
  - Per-inverter detailed data (AC/DC power, voltage, current, temperature)
  - Power limit configuration and inverter on/off control
  - Authentication, WiFi configuration, device restart
  - Expandable inverter list UI

#### Hoymiles (WiFi/Network)
- **HMS Inverters**: Standalone micro inverters with built-in WiFi (HMS-400W, HMS-800W-2T, HMS-2000DW-4T)
- **DTU Devices**: Gateway managing multiple inverters (DTU-WLite, DTU-Pro, DTU-Lite-S)
- **Connection Types**: WiFi/Network (TCP + Protobuf on port 10081)
- **Features**:
  - Real-time power production monitoring
  - Single-phase and three-phase inverter support
  - PV string monitoring (per panel voltage, current, power)
  - Grid AC monitoring (voltage, frequency, temperature)
  - Device and network configuration
  - DTU-Sticks **not** supported

#### Kostal (WiFi/Network)
- **Plenticore Inverters**: Solar inverters with Modbus TCP support
- **Connection Types**: WiFi/Network (Modbus TCP on port 1502, HTTP detection)
- **Features**:
  - Monitoring PV-Strings, AC-Power, Batterie, Power-Meter
  - Read-only monitoring (no write operations currently)

### Connection Types

- **Bluetooth Low Energy (BLE)**: Direct device connection with custom GATT protocols
- **WiFi/Network**: HTTP-based communication (REST API, JSON-RPC, legacy HTTPD)
- **WebSocket**: Real-time bidirectional communication (OpenDTU)
- **Modbus TCP**: Advanced protocol support for DeyeSun and Kostal devices
- **Protobuf over TCP**: Binary protocol for Hoymiles devices (port 10081)

## Roadmap

### Coming Soon 🚀

- **Full Home System**: Combine multiple devices into integrated solar systems
- **Persistent Configuration**: Save system setups locally or via Shelly storage
- **Additional Device Brands**: Expand support for more manufacturers
- **Automatic power limitation**: Easy set up Shelly scripts to control power of inverters from shelly power measurement devices

## Getting Started

### Prerequisites

- Flutter SDK (version 3.5.4 or higher)
- Dart SDK (^3.5.4)
- Android SDK (for Android builds)
- Physical device or emulator with Bluetooth and WiFi support

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/tost11/the-solar-app.git
   cd thesolarapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup**
   ```bash
   flutter doctor
   ```
   Ensure all required components are installed.

### Running the App

#### Android Device
```bash
# Connect your Android device via USB with USB debugging enabled
flutter run
```

#### Android Emulator
```bash
# Start an Android emulator first, then:
flutter run
```

#### Linux Desktop (Development)
```bash
flutter run -d linux
```

#### Windows Desktop (Development)
```bash
flutter run -d windows
```

### Building Release APK

```bash
# Build release APK for Android
flutter build apk --release

# The APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Permissions

The app requires several permissions for device discovery and connection:

- **Bluetooth**: BLE scanning and device connection
- **Location**: Required by Android for WiFi/BLE scanning
- **WiFi**: Network scanning and configuration
- **Network**: LAN scanning and mDNS service discovery

Permissions are requested at runtime when needed.

## Usage

### First Launch

1. **Grant Permissions**: The app will request necessary permissions on first launch
2. **Scan for Devices**: Tap the scan button to discover nearby devices
3. **Connect**: Select a device from the scan results
4. **Configure**: Set up WiFi, authentication, or other device settings
5. **Monitor**: View real-time data on the device detail screen

### Device Management

- **Add Device**: Use the scan screen to discover Bluetooth or network devices
- **Device Settings**: Tap the settings icon in device detail view
- **Authentication**: Configure username/password for devices requiring authentication
- **WiFi Configuration**: Set up device network connection
- **Power Limits**: Configure output power limits
- **Remove Device**: Long-press device in list and select delete

### Network Discovery

The app automatically scans for devices using:
- **Bluetooth**: Scans for device-specific service UUIDs
- **mDNS/Bonjour**: Discovers devices advertising `_http._tcp` service
- **LAN Scanning**: Checks local subnet IP ranges for compatible devices

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

This generates the following files in `lib/models/devices/hoymiles/protobuf/`:
- `RealDataNew.pb.dart`, `RealDataNew.pbenum.dart`, `RealDataNew.pbjson.dart`
- `GetConfig.pb.dart`, `GetConfig.pbenum.dart`, `GetConfig.pbjson.dart`
- `NetworkInfo.pb.dart`, `NetworkInfo.pbenum.dart`, `NetworkInfo.pbjson.dart`

#### When to Regenerate

Regenerate the protobuf files when:
- Updating to a new version of the hoymiles-wifi reference implementation
- The protobuf message definitions change upstream
- After upgrading the `protobuf` package version in `pubspec.yaml`

**Note**: Generated files may contain analyzer warnings (e.g., `$_clearField` method issues) - these are cosmetic and don't affect functionality.

### Code Style

- Use `DialogUtils.executeWithLoading()` for async operations
- Use arrow functions `(e) => ...` for one-line callbacks
- Use `MessageUtils` for user feedback (errors, success, warnings)
- Follow Flutter/Dart style guidelines

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow existing code patterns and architecture
4. Test thoroughly on actual devices
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is open source. License details to be added.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Bluetooth support via [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)
- Device protocol documentation:
  - [Zendure SDK](https://github.com/Zendure/zenSDK)
  - [Shelly Api/Protocol](https://shelly-api-docs.shelly.cloud/gen2/)
  - [Shelly Bluetooth Gat Protocol](https://www.shelly.com/de/blogs/documentation/kbsa-communicating-with-shelly-devices-via-bluetoo)
- Other Projects used as refference
  - [Shelly Bluetooth Protocol](https://github.com/epicRE/shelly-smart-device/blob/main/README.md)
  - [Zendure BLE Protocol](https://github.com/epicRE/zendure_ble)
  - [Shelly API Documentation](https://shelly-api-docs.shelly.cloud/)
  - [Hoymiles Protocol](https://github.com/suaveolent/hoymiles-wifi)
  - [Hoymiles Protocol](https://github.com/ohAnd/dtuGateway)
  - [Deye Sun Protocol](https://github.com/kbialek/deye-inverter-mqtt)
  - [Deye Sun and Hoymiles Protocol](https://github.com/tost11/OpenDTU-Push-Rest-API-and-Deye-Sun)

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

---

**Made with ☀️ for a sustainable energy future**
