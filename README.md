# The Solar App

🇬🇧 **English** | [🇩🇪 Deutsch](README_DE.md)

A Flutter application for Windows, Android and Linux for managing and monitoring micro inverters and power stations.
Connect locally via Bluetooth or WiFi without any cloud services or user registration required.
Supported manufacturers are [Hoymiles](#hoymiles-wifinetwork), [Deye Sun](#deyesun-wifinetwork), [Zendure](#zendure-bluetooth--wifi), [Shelly](#shelly-bluetooth--wifinetwork), [Kostal](#kostal-wifinetwork) and [OpenDTU](#opendtu-wifinetwork).

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

## Screenshots

Some screenshots to get an idea of what the app looks like:

- **[Mobile Screenshots](doc/images/mobile/README.md)** - Android app interface and features
- **[Desktop Screenshots](doc/images/desktop/README.md)** - Linux/Windows desktop interface

### Key Features

- **Privacy First**: No login, no registration, no cloud dependency
- **Local Connection**: Connect via Bluetooth Low Energy or WiFi/LAN
- **Multi-Device Support**: Compatible with multiple brands and device types
- **Real-Time Monitoring**: Track power production, consumption, and battery levels
- **Device Configuration**: WiFi setup, power limits, access point configuration
- **Cross-Platform**: Built with Flutter for mobile (Android) and desktop support
- **System View**: Combine multiple devices into unified solar systems with aggregated metrics
- **Shelly Script Automation**: Deploy JavaScript automation templates for zero-export control and monitoring

## Currently Supported

### Platforms
- **Android** ✅ (Primary platform)
- **Linux** ✅ (No Bluetooth)
- **Windows** ✅ (No Bluetoot)

### Supported Devices

#### Shelly (Bluetooth & WiFi/Network)
- **Supported Modules**: EM (3-phase meter), Switch (smart plug), EM1 (single-phase meter), EM1Data (energy totals), EMData (3-phase energy totals), Temperature (sensor), PM1 (Gen3 power meter)
- **Connection Types**: Bluetooth Low Energy, WiFi/Network (HTTP JSON-RPC 2.0)
- **Authentication**: RFC7616 Digest Authentication with SHA-256
- **Monitoring** (per module type):
  - **EM**: 3-phase voltage, current, active power per phase; total active power
  - **Switch**: Voltage, current, active power, temperature, total energy
  - **EM1**: Single-phase voltage, current, active/apparent power, power factor, frequency
  - **EM1Data/EMData**: Total energy import/export (per instance/phase)
  - **Temperature**: Temperature sensor readings
  - **PM1 (Gen3)**: Single-phase monitoring with bidirectional energy tracking
- **Configuration**:
  - WiFi/AP setup
  - RPC port configuration
  - Authentication settings
  - On/off switching (Switch module)
  - Device restart

#### DeyeSun (WiFi/Network)
- **Micro Inverters**: Solar inverters with dual protocol support
- **Connection Types**: WiFi/Network (HTTP/1.0 HTTPD with Basic Auth, Modbus TCP on configurable port)
- **Monitoring**: Real-time solar production with up to 4 PV string inputs (per-string voltage, current, power, daily/total yield), AC grid monitoring (voltage, current, frequency, power), radiator temperature, device uptime, operating time tracking
- **Configuration**:
  - Power limit (percentage-based)
  - Inverter on/off toggle
  - Online monitoring (Server A/B configuration)
  - WiFi setup (STA mode)
  - Access point configuration with security options
  - Device restart

#### Zendure (Bluetooth & WiFi)
- **Power Stations**: Portable power stations and energy storage systems
- **Connection Types**: Bluetooth Low Energy, WiFi/Network (REST API)
- **Monitoring**: Battery level (SOC with charge/discharge state), solar input power, grid input power, home output power, pack power (input/output), output limit, pack state, battery pack data (voltage, current per pack), WiFi/cloud connection state, firmware version
- **Configuration**:
  - Power limits (input/output with mode selection)
  - Battery SOC limits (min 5-40%, max 80-100%)
  - Advanced power settings (max inverter power, grid reverse, grid standard)
  - Emergency power supply (3 modes: normal/energy-saving/off)
  - Lamp/light toggle
  - WiFi/MQTT configuration (Bluetooth only)
  - MQTT configuration (WiFi only)

#### OpenDTU (WiFi/Network)
- **Solar Gateway**: Open-source DTU for Hoymiles micro inverters with multi-inverter management
- **Connection Types**: WiFi/Network (WebSocket `ws://{ip}:{port}/livedata` for real-time data, HTTP REST API for configuration)
- **Authentication**: Basic Auth (admin)
- **Monitoring**: Real-time multi-inverter aggregated data (total power, daily/total yield), per-inverter AC power (voltage, frequency, power), per-inverter DC string data (voltage, current, power), inverter temperature, system information (uptime, CPU temperature, memory usage: heap/sketch/littlefs), persistent inverter map with incremental updates
- **Configuration**:
  - Power limit per inverter (percentage-based)
  - Authentication settings
  - WiFi setup
  - Online monitoring cloud relay configuration ([solar-monitoring](https://github.com/tost11/solar-monitoring))
  - Device restart
  - Inverter on/off toggle (per device)
  - Inverter restart (per device)

#### Hoymiles (WiFi/Network)
- **Device Types**:
  - **DTU Gateways** (DTU-WLite, DTU-Pro, DTU-Lite-S): Manage multiple inverters with aggregated monitoring and expandable inverter list UI
  - **HMS Inverters** (HMS-800W-2T, HMS-1600W-4T etc.): Standalone micro inverters with built-in WiFi
- **Connection Types**: WiFi/Network (Binary TCP protocol with Protobuf serialization + CRC16 validation on port 10081)
- **Monitoring**: Real-time power production, up to 4 PV strings per inverter (per-string voltage, current, power, daily/total yields), AC monitoring (single-phase or three-phase voltage, frequency, active power) and temperature tracking
- **Configuration**:
  - Power limit (percentage-based per inverter)
  - WiFi setup
  - Access point configuration
  - Device and network settings
- **Note**: DTU-Sticks not implemented/working due to encryption of device

#### Kostal (WiFi/Network)
- **Plenticore Inverters**: Solar inverters with comprehensive 3-phase monitoring and battery management
- **Connection Types**: WiFi/Network (Modbus TCP on configurable port, default 1502; HTTP for device detection)
- **Device Roles**: Fixed roles (inverter, battery, smartMeter) for system integration
- **Monitoring**:
  - **DC**: 3 string inputs (voltage, current, power per string)
  - **AC**: 3-phase monitoring (voltage, current, active power per phase; reactive/apparent power in expert mode)
  - **Battery**: SOC, voltage, current, charge/discharge power, temperature, cycles, gross/net capacity
  - **Smart Meter**: External power meter with per-phase voltage, current, power, frequency, power factor
  - **Home Consumption**: Total consumption with breakdown (from PV, grid, battery)
  - **Yields**: Daily, monthly, yearly, and total energy production
  - **System Info**: Model/article number, max power, generation power, uptime, isolation resistance
- **Optimization**: Batch register reads for fast data fetching

### Connection Types

- **Bluetooth Low Energy (BLE)**: Direct device connection with custom GATT protocols
- **WiFi/Network**: HTTP-based communication (REST API, JSON-RPC, legacy HTTPD)
- **WebSocket**: Real-time bidirectional communication (OpenDTU)
- **Modbus TCP**: Advanced protocol support for DeyeSun and Kostal devices
- **Protobuf over TCP**: Binary protocol for Hoymiles devices (port 10081)

## System View

Combine multiple devices into logical solar systems for unified monitoring. Assign roles to devices (inverter, battery, smart meter, load) and view aggregated metrics:
- Total solar production from all inverters
- Battery charge/discharge power and average SOC
- Grid import/export from smart meters
- Total consumption from load devices

Access via the Systems menu. Each system automatically connects all assigned devices (WiFi + Bluetooth).

## Shelly Script Automation

Deploy JavaScript automation templates directly to Shelly devices for advanced control without cloud dependency. Scripts run autonomously on the device.

**Available Templates:**
- **Zendure Power Control**: Zero-export automation that automatically balances Zendure power stations based on Shelly EM3 grid measurements (bidirectional: discharge to home, charge from excess)

**Usage:** Open Shelly device → Menu → "Scripts" → "From Template"

For detailed documentation on creating and configuring scripts, see [SHELLY_SCRIPT_AUTOMATION.md](doc/SHELLY_SCRIPT_AUTOMATION.md).

## Roadmap

### Completed ✅

- **System View**: Combine multiple devices with role-based aggregation
- **Shelly Script Automation**: Template-based JavaScript automation
- **Zero-Export Control**: Automatic power balancing with Zendure + Shelly EM3

### Coming Soon 🚀

- **Additional Script Templates**: More automation scenarios
- **Local Backup & Restore**: Save/restore system configurations locally
- **Additional Device Brands**: Expand support for more manufacturers

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
   
4**Prepare build platforms**
   ```bash
   flutter create --platforms=android .
   #flutter create --platforms=linux .
   #flutter create --platforms=windows .
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

### Building with Git Version Information

The app displays version information including the git commit hash in the settings drawer. To embed the git version at build time, use the `--dart-define` flags:

#### Development Builds

```bash
# Android
flutter run --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Linux
flutter run -d linux --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Windows
flutter run -d windows --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)
```

#### Production Builds

```bash
# Android Release APK
flutter build apk --release --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Linux Release
flutter build linux --release --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)

# Windows Release
flutter build windows --release --dart-define=GIT_HASH=$(git rev-parse HEAD) --dart-define=GIT_HASH_SHORT=$(git rev-parse --short HEAD)
```

**Note**: Without these flags, the app will display "dev" or "unknown" as the git version. The version information is shown in:
- Settings drawer: "Version: v1.0.0 (git-hash)"
- App info screen: Full commit hash with copy-to-clipboard functionality

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

### System Management

- **Create System**: Tap "Systems" → "Add" to create a new system
- **Add Devices to System**: Select devices and assign roles (inverter, battery, meter, load)
- **View System Metrics**: System detail screen shows aggregated data from all devices

### Shelly Script Automation

- **Browse Templates**: Open Shelly device → Menu → "Scripts" → "From Template"
- **Configure & Deploy**: Fill in parameters (auto-populated when possible), preview or install directly
- **Manage Scripts**: Update parameters, upgrade to newer versions, enable/disable, or delete

### Network Discovery

The app automatically scans for devices using:
- **Bluetooth**: Scans for device-specific service UUIDs
- **LAN Scanning**: Checks local subnet IP ranges for compatible devices

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
