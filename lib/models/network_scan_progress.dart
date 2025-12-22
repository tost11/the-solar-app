import 'network_device.dart';

/// Progress information for network scanning
///
/// Tracks the state of both ping sweep and device probing phases
class NetworkScanProgress {
  /// Total IPs being scanned
  final int totalIPs;

  /// Number of IPs that have been pinged (regardless of response)
  final int checkedIPs;

  /// IPs that responded to ping (reachable)
  final int foundHosts;

  /// Reachable hosts with known/supported device types
  final int knownDevices;

  /// Reachable hosts that were probed but not supported
  final int testedDevices;

  /// IPs remaining to be fully processed
  ///
  /// Counts down from totalIPs as:
  /// - Unreachable IPs are discovered (pinged but no response)
  /// - Reachable IPs are probed (known or tested)
  int get remainingDevices =>
      totalIPs - checkedIPs + foundHosts - knownDevices - testedDevices;

  /// Progress of ping sweep (0.0 to 1.0)
  double get pingProgress => totalIPs > 0 ? foundHosts / totalIPs : 0.0;

  /// Progress of device probing (0.0 to 1.0)
  double get probeProgress => foundHosts > 0
      ? (knownDevices + testedDevices) / foundHosts
      : 0.0;

  /// Overall combined progress (0.0 to 1.0)
  ///
  /// Counts each IP as "processed" when:
  /// - Failed ping (unreachable): checkedIPs - foundHosts
  /// - Known device (found and supported): knownDevices
  /// - Unknown device (found but not supported): testedDevices
  double get overallProgress => totalIPs > 0
      ? (checkedIPs - foundHosts + knownDevices + testedDevices) / totalIPs
      : 0.0;

  /// Discovered device (if any)
  final NetworkDevice? device;

  NetworkScanProgress({
    required this.totalIPs,
    required this.checkedIPs,
    required this.foundHosts,
    required this.knownDevices,
    required this.testedDevices,
    this.device,
  });

  NetworkScanProgress copyWith({
    int? totalIPs,
    int? checkedIPs,
    int? foundHosts,
    int? knownDevices,
    int? testedDevices,
    NetworkDevice? device,
  }) {
    return NetworkScanProgress(
      totalIPs: totalIPs ?? this.totalIPs,
      checkedIPs: checkedIPs ?? this.checkedIPs,
      foundHosts: foundHosts ?? this.foundHosts,
      knownDevices: knownDevices ?? this.knownDevices,
      testedDevices: testedDevices ?? this.testedDevices,
      device: device ?? this.device,
    );
  }
}
