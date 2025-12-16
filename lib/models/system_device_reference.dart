import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';

/// Reference to a device in a system
///
/// Links a device (by serial number) to a system and specifies
/// which roles the device plays in this specific system.
class SystemDeviceReference {
  /// Serial number of the device (references DeviceBase.deviceSn)
  final String deviceSn;

  /// Roles this device plays in THIS system
  /// For devices with multiple capabilities, this determines which ones to use
  final List<DeviceRole> rolesInSystem;

  const SystemDeviceReference({
    required this.deviceSn,
    required this.rolesInSystem,
  });

  /// Factory constructor from JSON
  factory SystemDeviceReference.fromJson(Map<String, dynamic> json) {
    // BACKWARDS COMPATIBILITY: Support old format (roleInSystem) and new (rolesInSystem)
    if (json.containsKey('rolesInSystem')) {
      // New format
      return SystemDeviceReference(
        deviceSn: json['deviceSn'] as String,
        rolesInSystem: (json['rolesInSystem'] as List<dynamic>)
            .map((r) => DeviceRole.values.firstWhere(
                  (role) => role.name == r,
                  orElse: () => DeviceRole.inverter,
                ))
            .toList(),
      );
    } else {
      // Old format - migrate
      return SystemDeviceReference(
        deviceSn: json['deviceSn'] as String,
        rolesInSystem: [
          DeviceRole.values.firstWhere(
            (r) => r.name == json['roleInSystem'],
            orElse: () => DeviceRole.inverter,
          ),
        ],
      );
    }
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceSn': deviceSn,
      'rolesInSystem': rolesInSystem.map((r) => r.name).toList(),
    };
  }
}
