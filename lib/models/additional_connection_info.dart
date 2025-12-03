/// Connection parameters for device detection and probing
///
/// Replaces the simple Duration parameter with comprehensive connection configuration
/// that supports manufacturer-specific requirements (authentication, multiple ports).
///
/// Used by:
/// - NetworkScanService detector functions
/// - Manual device addition flow
/// - Automatic network scanning with per-device configuration
class AdditionalConnectionInfo {
  /// Connection timeout for probe operations
  final Duration timeout;

  /// Optional username for devices requiring authentication (e.g., DeyeSun, OpenDTU)
  final String? username;

  /// Optional password for devices requiring authentication
  final String? password;

  /// Optional additional port for secondary services
  ///
  /// Examples:
  /// - DeyeSun: Modbus TCP port (502)
  /// - OpenDTU: WebSocket port (same as HTTP, but specified separately)
  final int? additionalPort;

  AdditionalConnectionInfo({
    required this.timeout,
    this.username,
    this.password,
    this.additionalPort,
  });
}
