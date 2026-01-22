enum DeviceKnownStatus {
  unknown,        // Device not in known devices list
  knownSameIp,   // Device known with same IP address
  knownNewIp,    // Device known but IP address changed
}

class NetworkDevice {
  final String ipAddress;
  final String? hostname;
  final String manufacturer;
  final String? deviceModel;
  final String serialNumber;
  final int port;
  final int? additionalPort;
  final String ? username;
  final String ? password;
  final DeviceKnownStatus knownStatus;
  final String? previousIpAddress; // Only set when status is knownNewIp

  NetworkDevice({
    required this.ipAddress,
    this.hostname,
    required this.manufacturer,
    this.deviceModel,
    required this.serialNumber,
    required this.port,
    this.additionalPort,
    this.username,
    this.password,
    this.knownStatus = DeviceKnownStatus.unknown,
    this.previousIpAddress,
  });

  @override
  String toString() {
    return 'NetworkDevice(ip: $ipAddress, hostname: $hostname, manufacturer: $manufacturer, model: $deviceModel, sn: $serialNumber, port: $port, additionalPort: $additionalPort, username: $username, password: $password, knownStatus: $knownStatus, previousIpAddress: $previousIpAddress)';
  }
}
