/// Capability mixin for devices that measure grid power (smart meters)
///
/// Devices with this capability can provide grid import/export power data.
/// Examples: Shelly EM3, Kostal (with powermeter), Shelly Plug (when configured)
mixin SmartMeterCapability {
  /// Returns grid power in watts
  ///
  /// Convention:
  /// - Positive value = importing from grid (consuming from utility)
  /// - Negative value = exporting to grid (feeding into utility)
  /// - Zero = no grid exchange (self-sufficient)
  ///
  /// Returns null if the data is not available or the device is not connected.
  ///
  /// Example implementations:
  /// - Shelly EM3: ['data']['total_act_power']
  /// - Kostal: ['data']['consumption_grid']
  /// - Shelly Plug: ['data']['apower'] (when configured as smart meter)
  double? getGridPower(Map<String, dynamic> data);
}
