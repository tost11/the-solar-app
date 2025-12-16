/// Capability mixin for devices that have battery storage
///
/// Devices with this capability can provide battery power and state of charge.
/// Examples: Zendure, Kostal
mixin BatteryCapability {
  /// Returns battery charge/discharge power in watts
  ///
  /// Convention:
  /// - Positive value = battery is charging (power flowing into battery)
  /// - Negative value = battery is discharging (power flowing out of battery)
  /// - Zero = battery is idle
  ///
  /// Returns null if the data is not available or the device is not connected.
  ///
  /// Example implementations:
  /// - Zendure: packInputPower - outputPackPower
  /// - Kostal: ['data']['battery_charge_discharge_power']
  double? getBatteryPower(Map<String, dynamic> data);

  /// Returns battery state of charge in percent (0-100)
  ///
  /// Returns null if the data is not available or the device is not connected.
  ///
  /// Example implementations:
  /// - Zendure: ['data']['properties']['electricLevel']
  /// - Kostal: ['data']['battery_soc'] or ['data']['battery_soc_actual']
  double? getBatterySOC(Map<String, dynamic> data);
}
