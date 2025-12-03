class NetworkDevice {
  final String ipAddress;
  final String? hostname;
  final String manufacturer;
  final String? deviceModel;
  final String serialNumber;
  final int port;
  final int? additionalPort;

  NetworkDevice({
    required this.ipAddress,
    this.hostname,
    required this.manufacturer,
    this.deviceModel,
    required this.serialNumber,
    required this.port,
    this.additionalPort,
  });

  @override
  String toString() {
    return 'NetworkDevice(ip: $ipAddress, hostname: $hostname, manufacturer: $manufacturer, model: $deviceModel, sn: $serialNumber, port: $port, additionalPort: $additionalPort)';
  }
}
