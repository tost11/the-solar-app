
import '../utils/debug_log.dart';
import 'package:the_solar_app/models/devices/capabilities/battery_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/load_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/smart_meter_capability.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/models/system.dart';

/// System-level metrics aggregated from all devices
///
/// Combines data from multiple devices based on their roles
/// (inverter, battery, smart meter, load) to provide a holistic
/// view of the entire solar system.
class SystemMetrics {
  /// Total solar production power from all inverters (Watts)
  final double? totalSolarPower;

  /// Total battery charge/discharge power from all batteries (Watts)
  /// Positive = charging, negative = discharging
  final double? totalBatteryPower;

  /// Average battery state of charge across all batteries (0-100%)
  final double? averageBatterySOC;

  /// Total grid import/export power from all smart meters (Watts)
  /// Positive = importing, negative = exporting
  final double? totalGridPower;

  /// Total consumption power from all load devices (Watts)
  final double? totalLoadPower;

  /// Number of devices contributing to the metrics
  final int deviceCount;

  /// Number of active devices (with valid data)
  final int activeDeviceCount;

  /// Timestamp when the metrics were calculated
  final DateTime timestamp;

  final double? totalAdditionalLoadPower;

  final double? totalSolarGridPower;

  const SystemMetrics({
    required this.totalSolarPower,
    required this.totalSolarGridPower,
    required this.totalBatteryPower,
    required this.averageBatterySOC,
    required this.totalGridPower,
    required this.totalLoadPower,
    required this.totalAdditionalLoadPower,
    required this.deviceCount,
    required this.activeDeviceCount,
    required this.timestamp,
  });

  /// Returns true if any metrics have valid data
  bool get hasData =>
      totalSolarPower != null ||
      totalBatteryPower != null ||
      totalGridPower != null ||
      totalLoadPower != null;

  /// Returns true if battery metrics are available
  bool get hasBatteryMetrics =>
      totalBatteryPower != null || averageBatterySOC != null;
}

/// Service for aggregating device data into system-level metrics
///
/// Collects data from all devices based on their capabilities and roles,
/// then combines them into a single SystemMetrics object showing the
/// overall state of the solar system.
///
/// Usage:
/// ```dart
/// final aggregator = SystemAggregatorService();
/// final metrics = aggregator.aggregateDevices(deviceList);
/// print('Total solar: ${metrics.totalSolarPower}W');
/// ```
class SystemAggregatorService {
  /// Aggregates devices in a specific system
  ///
  /// Resolves device references by serial number from allDevices,
  /// then uses the role specified in the system (not device's global role).
  ///
  /// [system] The system containing device references with roles
  /// [allDevices] Complete list of all available devices
  ///
  /// Returns [SystemMetrics] with aggregated values for this system only
  SystemMetrics aggregateSystem(
    System system,
    List<DeviceBase> allDevices,
  ) {
    DebugLog.system('=== SystemAggregator: Aggregating system "${system.name}" ===', level: LogLevel.debug);

    double totalSolar = 0;
    double totalGridSolar = 0;
    double totalBattery = 0;
    double totalGrid = 0;
    double totalLoad = 0;
    double totalAdditionalLoad = 0;
    List<double> batterySocs = [];
    int activeDevices = 0;
    bool hasSolarData = false;
    bool hasSolarGridData = false;
    bool hasBatteryPowerData = false;
    bool hasGridData = false;
    bool hasLoadData = false;
    bool hasAdditionalLoad = false;

    // Resolve devices by serial number
    for (final deviceRef in system.deviceReferences) {
      // Find device by serial number
      DeviceBase? device;
      try {
        device = allDevices.firstWhere(
          (d) => d.deviceSn == deviceRef.deviceSn,
        );
      } catch (e) {
        // Device not found, skip
        DebugLog.system('  Device ${deviceRef.deviceSn} not found in allDevices', level: LogLevel.warning);
        continue;
      }

      final data = device.data;
      if (data.isEmpty) {
        DebugLog.system('  Device "${device.name}" (${device.deviceSn}): No data available', level: LogLevel.warning);
        continue;
      }

      DebugLog.system('  Processing device "${device.name}" (${device.deviceSn}) with roles: ${deviceRef.rolesInSystem.map((r) => r.name).join(", ")}', level: LogLevel.debug);

      bool deviceHasData = false;

      // Iterate over ALL roles this device has in this system
      for (final roleInSystem in deviceRef.rolesInSystem) {
        // Check capability based on role in THIS system
        switch (roleInSystem) {
          case DeviceRole.inverter:
            if (device is InverterCapability) {
              final inverterDevice = device as InverterCapability;
              final power = inverterDevice.getSolarPVPower(data);
              if (power != null) {
                DebugLog.system('    [inverter] Contributing ${power}W to solar production (total: ${totalSolar + power}W)', level: LogLevel.debug);
                totalSolar += power;
                deviceHasData = true;
                hasSolarData = true;
              } else {
                DebugLog.system('    [inverter] No power data available', level: LogLevel.warning);
              }
              final powerGrid = inverterDevice.getSolarGridPower(data);
              if (powerGrid != null) {
                DebugLog.system('    [inverter] Contributing ${powerGrid}W to solar grid production (total: ${totalSolar + powerGrid}W)', level: LogLevel.debug);
                totalGridSolar += powerGrid;
                totalLoad += powerGrid;
                deviceHasData = true;
                hasSolarGridData = true;
              } else {
                DebugLog.system('    [inverter] No power grid data available', level: LogLevel.warning);
              }
            } else {
              DebugLog.system('    [inverter] Device does not implement InverterCapability', level: LogLevel.warning);
            }
            break;

          case DeviceRole.battery:
            if (device is BatteryCapability) {
              final batteryDevice = device as BatteryCapability;
              final power = batteryDevice.getBatteryPower(data);
              final soc = batteryDevice.getBatterySOC(data);

              if (power != null) {
                DebugLog.system('    [battery] Contributing ${power}W to battery power (total: ${totalBattery + power}W)', level: LogLevel.debug);
                totalBattery += power;
                deviceHasData = true;
                hasBatteryPowerData = true;
              }

              if (soc != null) {
                DebugLog.system('    [battery] Battery SOC: ${soc}%', level: LogLevel.debug);
                batterySocs.add(soc);
                deviceHasData = true;
              }

              if (power == null && soc == null) {
                DebugLog.system('    [battery] No power or SOC data available', level: LogLevel.warning);
              }
            } else {
              DebugLog.system('    [battery] Device does not implement BatteryCapability', level: LogLevel.warning);
            }
            break;

          case DeviceRole.smartMeter:
            if (device is SmartMeterCapability) {
              final smartMeterDevice = device as SmartMeterCapability;
              final power = smartMeterDevice.getGridPower(data);
              if (power != null) {
                final direction = power < 0 ? 'exporting' : 'importing';
                DebugLog.system('    [smartMeter] Contributing ${power}W to grid power ($direction) (total: ${totalGrid + power}W)', level: LogLevel.debug);
                totalGrid += power;
                hasLoadData = true;
                deviceHasData = true;
                hasGridData = true;
              } else {
                DebugLog.system('    [smartMeter] No grid power data available', level: LogLevel.warning);
              }
            } else {
              DebugLog.system('    [smartMeter] Device does not implement SmartMeterCapability', level: LogLevel.warning);
            }
            break;

          case DeviceRole.load:
            if (device is LoadCapability) {
              final loadDevice = device as LoadCapability;
              final power = loadDevice.getLoadPower(data);
              if (power != null) {
                DebugLog.system('    [load] Contributing ${power}W to load power (total: ${totalLoad + power}W)', level: LogLevel.debug);
                totalAdditionalLoad += power;
                deviceHasData = true;
                hasAdditionalLoad = true;
              } else {
                DebugLog.system('    [load] No load power data available', level: LogLevel.warning);
              }
            } else {
              DebugLog.system('    [load] Device does not implement LoadCapability', level: LogLevel.warning);
            }
            break;
        }
      }

      if (deviceHasData) activeDevices++;
    }

    // Calculate average battery SOC
    final avgSoc = batterySocs.isNotEmpty
        ? batterySocs.reduce((a, b) => a + b) / batterySocs.length
        : null;

    DebugLog.system('=== Summary ===', level: LogLevel.debug);
    DebugLog.system("  Solar: ${hasSolarData ? "${totalSolar}W" : "no data"}", level: LogLevel.debug);
    DebugLog.system("  SolarGrid: ${hasSolarGridData ? "${totalGridSolar}W" : "no data"}", level: LogLevel.debug);
    DebugLog.system("  Battery: ${hasBatteryPowerData ? "${totalBattery}W" : "no data"}${avgSoc != null ? " (avg SOC: ${avgSoc.toStringAsFixed(1)}%)" : ""}", level: LogLevel.debug);
    DebugLog.system("  Grid: ${hasGridData ? "${totalGrid}W" : "no data"}", level: LogLevel.debug);
    DebugLog.system("  Load: ${hasLoadData ? "${totalLoad}W" : "no data"}", level: LogLevel.debug);
    DebugLog.system("  Additional Load: ${hasAdditionalLoad ? "${totalAdditionalLoad}W" : "no data"}", level: LogLevel.debug);
    DebugLog.system("  Active devices: $activeDevices / ${system.deviceReferences.length}", level: LogLevel.debug);
    DebugLog.system('===============', level: LogLevel.debug);

    return SystemMetrics(
      totalSolarPower: hasSolarData ? totalSolar : null,
      totalBatteryPower: hasBatteryPowerData ? totalBattery : null,
      averageBatterySOC: avgSoc,
      totalGridPower: hasGridData ? totalGrid : null,
      totalLoadPower: hasLoadData ? totalLoad : null,
      totalAdditionalLoadPower: hasAdditionalLoad ? totalAdditionalLoad : null,
      totalSolarGridPower: hasSolarGridData ? totalGridSolar : null,
      deviceCount: system.deviceReferences.length,
      activeDeviceCount: activeDevices,
      timestamp: DateTime.now(),
    );
  }
}
