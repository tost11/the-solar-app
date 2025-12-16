/// Capability mixin for devices that act as solar inverters
///
/// Devices with this capability can provide solar/DC input power data.
/// Examples: Zendure, Kostal, OpenDTU
mixin InverterCapability {
  /// Returns current solar/DC input power in watts
  ///
  /// Returns null if the data is not available or the device is not connected.
  ///
  /// Example implementations:
  /// - Zendure: ['data']['properties']['solarInputPower']
  /// - Kostal: ['data']['dc_power_total']
  /// - OpenDTU: Sum of all inverters' DC power
  double? getSolarPVPower(Map<String, dynamic> data);

  double? getSolarGridPower(Map<String, dynamic> data);
}
