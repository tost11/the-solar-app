import 'package:http/http.dart' as http;
import 'additional_connection_info.dart';
import 'network_device.dart';

/// Encapsulates all manufacturer-specific configuration for device detection
///
/// This model defines:
/// - Default network configuration (ports, authentication requirements)
/// - Detector function for identifying devices of this manufacturer
/// - UI configuration (labels for additional ports)
///
/// Used by NetworkScanService's Map-based detector registry for O(1) manufacturer lookup
class ManufacturerDetectorInfo {
  /// Display name of the manufacturer (e.g., "Zendure", "DeyeSun")
  final String manufacturerName;

  /// Default HTTP/TCP port for initial connection
  final int defaultPort;

  /// Optional additional port for secondary services (Modbus, WebSocket, etc.)
  final int? additionalPort;

  /// UI label for additional port field (e.g., "Modbus", "WebSocket")
  final String? additionalPortLabel;

  /// Whether username is configurable (if false, uses 'admin' as default)
  final bool requiresUsername;

  /// Whether password is required for this manufacturer
  final bool requiresPassword;

  /// Default username for authentication (if required)
  final String? defaultUsername;

  /// Default password for authentication (if required)
  final String? defaultPassword;

  final bool httpStartPage;

  /// Detector function that probes an IP address and returns NetworkDevice if manufacturer matches
  ///
  /// Parameters:
  /// - ipAddress: Target IP address to probe
  /// - initialResponse: Optional HTTP response from generic probe (may be null for TCP-based devices)
  /// - connectionInfo: Connection parameters (timeout, auth credentials, additional port)
  ///
  /// Returns NetworkDevice if device is identified as this manufacturer, null otherwise
  final Future<NetworkDevice?> Function(
    String ipAddress,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) detector;

  ManufacturerDetectorInfo({
    required this.manufacturerName,
    required this.defaultPort,
    this.additionalPort,
    this.additionalPortLabel,
    this.requiresUsername = false,
    this.requiresPassword = false,
    this.defaultUsername,
    this.defaultPassword,
    required this.detector,
    required this.httpStartPage
  });
}
