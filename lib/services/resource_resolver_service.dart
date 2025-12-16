import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../models/devices/mixins/device_wifi_mixin.dart';
import '../models/resolved_resource.dart';
import 'device_storage_service.dart';
import 'system_storage_service.dart';

/// Service for resolving script parameter values from devices
///
/// Provides functionality to automatically extract property values
/// (like IP addresses, serial numbers, hostnames) from saved devices
/// or from devices within a specific system.
class ResourceResolverService {
  final DeviceStorageService _deviceStorage = DeviceStorageService();
  final SystemStorageService _systemStorage = SystemStorageService();

  /// Resolve from all known devices
  ///
  /// Searches through all saved devices and extracts the specified property.
  /// Returns a list of resolved resources that can be used to populate
  /// script parameters.
  Future<List<ResolvedResource>> resolveFromAllDevices(
    String source,
    String sourceProperty,
    String? filterInfo,
  ) async {
    final devices = await _deviceStorage.getKnownDevices();
    return _resolveFromDevices(devices, sourceProperty, filterInfo);
  }

  /// Resolve from devices in a specific system
  ///
  /// Only searches devices that are configured in the specified system.
  /// Falls back to all devices if the system is not found.
  Future<List<ResolvedResource>> resolveFromSystem(
    String systemId,
    String source,
    String sourceProperty,
    String? filterInfo,
  ) async {
    final system = await _systemStorage.getSystemById(systemId);
    if (system == null) {
      debugPrint('System not found: $systemId, falling back to all devices');
      return resolveFromAllDevices(source, sourceProperty, filterInfo);
    }

    // Get all devices and filter to system devices
    final allDevices = await _deviceStorage.getKnownDevices();
    final systemDeviceSns = system.deviceSerialNumbers.toSet();
    final systemDevices = allDevices.where(
      (d) => systemDeviceSns.contains(d.deviceSn),
    ).toList();

    return _resolveFromDevices(systemDevices, sourceProperty, filterInfo);
  }

  /// Core resolution logic
  ///
  /// Filters devices by manufacturer (if specified) and extracts the
  /// specified property from each device.
  Future<List<ResolvedResource>> _resolveFromDevices(
    List<DeviceBase> devices,
    String sourceProperty,
    String? filterInfo,
  ) async {
    // Apply manufacturer filters if specified
    final filteredDevices = _applyFilters(devices, filterInfo);

    // Extract property from each device
    final results = <ResolvedResource>[];
    for (final device in filteredDevices) {
      final value = _extractPropertyFromDevice(device, sourceProperty);
      if (value != null && value.isNotEmpty) {
        results.add(ResolvedResource.create(device, value));
      }
    }

    return results;
  }

  /// Extract property value from device (case-insensitive property names)
  ///
  /// Supports common device properties:
  /// - serialNumber, deviceSn: Device serial number
  /// - deviceName, name: Device name
  /// - ipAddress, netIpAddress: IP address (WiFi devices only)
  /// - hostname, netHostname: Hostname (WiFi devices only)
  /// - port, netPort: Port number (WiFi devices only)
  /// - manufacturer: Device manufacturer (extracted from JSON)
  /// - model, deviceModel: Device model
  String? _extractPropertyFromDevice(DeviceBase device, String propertyName) {
    try {
      switch (propertyName.toLowerCase()) {
        case 'serialnumber':
        case 'devicesn':
          return device.deviceSn;
        case 'devicename':
        case 'name':
          return device.name;
        case 'ipaddress':
        case 'netipaddress':
          return (device is DeviceWifiMixin) ? (device as DeviceWifiMixin).netIpAddress : null;
        case 'hostname':
        case 'nethostname':
          return (device is DeviceWifiMixin) ? (device as DeviceWifiMixin).netHostname : null;
        case 'port':
        case 'netport':
          return (device is DeviceWifiMixin) ? (device as DeviceWifiMixin).netPort?.toString() : null;
        case 'manufacturer':
        case 'devicetype':
          // deviceType is stored in JSON during serialization
          // We can extract it by serializing the device
          final json = device.toJson();
          return json['deviceType'] as String?;
        case 'model':
        case 'devicemodel':
          return device.deviceModel;
        default:
          debugPrint('Unknown property: $propertyName');
          return null;
      }
    } catch (e) {
      debugPrint('Error extracting $propertyName from ${device.name}: $e');
      return null;
    }
  }

  /// Apply manufacturer filters (comma-separated)
  ///
  /// Filters the device list to only include devices from the specified
  /// manufacturers. Filter format: "zendure,shelly,opendtu" (case-insensitive)
  List<DeviceBase> _applyFilters(List<DeviceBase> devices, String? filterInfo) {
    if (filterInfo == null || filterInfo.isEmpty) {
      return devices;
    }

    // Parse comma-separated manufacturers
    final filters = filterInfo
        .split(',')
        .map((f) => f.trim().toLowerCase())
        .where((f) => f.isNotEmpty)
        .toSet();

    if (filters.isEmpty) {
      return devices;
    }

    // Filter by manufacturer
    return devices.where((device) {
      try {
        final json = device.toJson();
        final deviceType = (json['deviceType'] as String?)?.toLowerCase();
        return deviceType != null && filters.contains(deviceType);
      } catch (e) {
        debugPrint('Error filtering device ${device.name}: $e');
        return false;
      }
    }).toList();
  }
}
