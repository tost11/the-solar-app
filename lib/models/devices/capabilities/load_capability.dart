/// Capability mixin for devices that measure load/consumption power
///
/// Devices with this capability can provide power consumption data
/// for individual loads or appliances.
/// Examples: Shelly Plug (when configured as load), Kostal (total consumption)
mixin LoadCapability {
  /// Returns load/consumption power in watts
  ///
  /// Always positive (power consumed by the load).
  ///
  /// Returns null if the data is not available or the device is not connected.
  ///
  /// Example implementations:
  /// - Shelly Plug: ['data']['apower'] (when configured as load)
  /// - Kostal: ['data']['consumption_total']
  double? getLoadPower(Map<String, dynamic> data);
}
