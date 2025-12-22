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
- **HMS Inverters**: Standalone micro inverters with built-in WiFi (HMS-400W, HMS-800W-2T, etc.)
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
- **mDNS/Bonjour**: Discovers devices advertising `_http._tcp` service
- **LAN Scanning**: Checks local subnet IP ranges for compatible devices

## Architecture & Development

For detailed information about the project architecture, design patterns, and development guidelines, see [ARCHITECTURE.md](doc/ARCHITECTURE.md).

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
