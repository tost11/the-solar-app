/// Enum for device roles in the solar system
enum DeviceRole {
  /// Solar inverter producing power from PV panels
  inverter,

  /// Battery storage for energy
  battery,

  /// Smart meter measuring grid import/export
  smartMeter,

  /// Individual load/consumer
  load;

  /// Returns German display name for the role
  String get displayName {
    switch (this) {
      case DeviceRole.inverter:
        return 'Wechselrichter';
      case DeviceRole.battery:
        return 'Batterie';
      case DeviceRole.smartMeter:
        return 'Smart Meter';
      case DeviceRole.load:
        return 'Last';
    }
  }
}

/// Mixin for device role configuration
///
/// This mixin allows devices to declare their supported roles.
/// Some devices have fixed roles (e.g., Zendure is always inverter + battery),
/// while others have configurable roles (e.g., Shelly Plug can be smart meter OR load).
///
/// Usage:
/// ```dart
/// class ZendureDevice extends GenericWiFiDevice
///     with InverterCapability, BatteryCapability, DeviceRoleConfig {
///
///   @override
///   List<DeviceRole> getFixedRoles() => [
///     DeviceRole.inverter,
///     DeviceRole.battery,
///   ];
///
///   // ... implement capability methods
/// }
/// ```
mixin DeviceRoleConfig {
  /// Static roles defined by the device type (not user-configurable)
  ///
  /// These roles are always active for this device type.
  /// Examples:
  /// - Zendure: [inverter, battery]
  /// - Shelly EM3: [smartMeter]
  /// - Kostal: [inverter, battery, smartMeter]
  ///
  /// Default: empty list (no fixed roles)
  List<DeviceRole> getFixedRoles() => [];

  /// Configurable roles that the user can choose from
  ///
  /// The user can select ONE of these roles for this device instance.
  /// Examples:
  /// - Shelly Plug: [smartMeter, load] (user chooses one)
  ///
  /// Default: empty list (no configurable roles)
  List<DeviceRole> getConfigurableRoles() => [];

  /// Currently active user-configured role (if device has configurable roles)
  ///
  /// This is set by the user through the UI and persisted to storage.
  /// Only one configurable role can be active at a time.
  DeviceRole? userConfiguredRole;

  /// All currently active roles for this device
  ///
  /// Combines fixed roles and the user-configured role (if set).
  List<DeviceRole> get activeRoles => [
        ...getFixedRoles(),
        if (userConfiguredRole != null) userConfiguredRole!,
      ];

  /// Whether this device has any configurable roles
  bool get hasConfigurableRoles => getConfigurableRoles().isNotEmpty;

  /// Serialize role configuration to JSON
  ///
  /// Call this from your device's toJson() method:
  /// ```dart
  /// @override
  /// Map<String, dynamic> toJson() {
  ///   final json = super.toJson();
  ///   json.addAll(roleConfigToJson());
  ///   return json;
  /// }
  /// ```
  Map<String, dynamic> roleConfigToJson() => {
        if (userConfiguredRole != null)
          'userConfiguredRole': userConfiguredRole!.name,
      };

  /// Deserialize role configuration from JSON
  ///
  /// Call this from your device's fromJson() factory:
  /// ```dart
  /// factory ZendureDevice.fromJson(Map<String, dynamic> json) {
  ///   final device = ZendureDevice(...);
  ///   device.roleConfigFromJson(json);
  ///   return device;
  /// }
  /// ```
  void roleConfigFromJson(Map<String, dynamic> json) {
    final roleStr = json['userConfiguredRole'] as String?;
    if (roleStr != null) {
      try {
        userConfiguredRole = DeviceRole.values.firstWhere(
          (r) => r.name == roleStr,
        );
      } catch (e) {
        // Invalid role name in JSON, ignore
        userConfiguredRole = null;
      }
    }
  }
}
