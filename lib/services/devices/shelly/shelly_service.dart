/// Abstract interface for Shelly device services (Bluetooth and WiFi)
///
/// Defines the common sendCommand interface that must be implemented
/// by concrete Bluetooth and WiFi services.
///
/// Note: Authentication logic is provided via ShellyAuthMixin, not through
/// this interface.
abstract class ShellyService {
  /// Send a command to the Shelly device
  ///
  /// Concrete implementations (ShellyBluetoothService, ShellyWifiService)
  /// must provide transport-specific logic for sending commands.
  ///
  /// @param method - The RPC method name (e.g., "EM.GetStatus", "Switch.Set")
  /// @param params - Parameters for the RPC method
  /// @return Response data as a Map, or null if no response
  Future<Map<String, dynamic>?> sendCommand(
    String method,
    Map<String, dynamic> params,
  );
}
