import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/services/devices/kostal/kostal_modbus_connection.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_wifi_service.dart';
import '../models/network_device.dart';
import '../models/manufacturer_detector_info.dart';
import '../models/additional_connection_info.dart';
import 'devices/zendure/zendure_wifi_service.dart';
import 'devices/deyesun/deyesun_wifi_service.dart';
import 'devices/deyesun/deyesun_modbus_connection.dart';
import 'devices/opendtu/opendtu_wifi_service.dart';
import 'devices/hoymiles/hoymiles_wifi_service.dart';
import 'devices/hoymiles/hoymiles_protocol.dart';
import 'devices/kostal/kostal_wifi_service.dart';

class NetworkScanService {
  final _networkInfo = NetworkInfo();
  List<NetworkDevice> _discoveredDevices = [];
  final _scanner = LanScanner(debugLogging: true);
  final Mutex _progressMutex = Mutex();
  int _checkedCount = 0;

  // Map-based detector registry - O(1) lookup by manufacturer key
  static final Map<String, ManufacturerDetectorInfo> _detectorRegistry = {};
  static bool _detectorsInitialized = false;

  List<NetworkDevice> get discoveredDevices => _discoveredDevices;
  bool get hasDevices => _discoveredDevices.isNotEmpty;

  /// Registers a detector for a specific manufacturer
  ///
  /// Uses manufacturer constant (e.g., DEVICE_MANUFACTURER_ZENDURE) as key
  /// for O(1) lookup without cascading if statements
  static void registerDetector(String manufacturerKey, ManufacturerDetectorInfo detectorInfo) {
    _detectorRegistry[manufacturerKey] = detectorInfo;
  }

  /// Gets detector information for a specific manufacturer
  ///
  /// Returns null if manufacturer is not registered
  static ManufacturerDetectorInfo? getDetectorInfo(String manufacturerKey) {
    return _detectorRegistry[manufacturerKey];
  }

  /// Gets list of all supported manufacturer keys
  ///
  /// Used by manual device addition screen to populate manufacturer dropdown
  static List<String> getSupportedManufacturers() {
    return _detectorRegistry.keys.toList();
  }


  /// Initializes detectors by registering all supported manufacturers
  static void initializeDetectors() {
    if (_detectorsInitialized) return;

    // Register Zendure - No authentication
    registerDetector(DEVICE_MANUFACTURER_ZENDURE, ManufacturerDetectorInfo(
      manufacturerName: 'Zendure',
      defaultPort: 80,
      requiresUsername: false,
      requiresPassword: false,
      detector: ZendureWifiService.isResponseFromManufacturer,
      httpStartPage: false
    ));

    // Register DeyeSun - Both username and password configurable
    registerDetector(DEVICE_MANUFACTURER_DEYE_SUN, ManufacturerDetectorInfo(
      manufacturerName: 'DeyeSun',
      defaultPort: 80,
      additionalPort: DeyeSunModbusConnection.DEFAULT_PORT, // 8899
      additionalPortLabel: 'Modbus',
      requiresUsername: true,
      requiresPassword: true,
      defaultUsername: 'admin',
      defaultPassword: 'admin',
      detector: DeyeSunWifiService.isResponseFromManufacturer,
      httpStartPage: true
    ));

    // Register Shelly - Fixed username 'admin', password configurable
    registerDetector(DEVICE_MANUFACTURER_SHELLY, ManufacturerDetectorInfo(
      manufacturerName: 'Shelly',
      defaultPort: 80,
      requiresUsername: false,
      requiresPassword: true,
      defaultUsername: 'admin',
      defaultPassword: '', // No default password
      detector: ShellyWifiService.isResponseFromManufacturer,
      httpStartPage: true
    ));

    // Register OpenDTU - Fixed username 'admin', password configurable
    registerDetector(DEVICE_MANUFACTURER_OPENDTU, ManufacturerDetectorInfo(
      manufacturerName: 'OpenDTU',
      defaultPort: 80,
      requiresUsername: false,
      requiresPassword: true,
      defaultUsername: 'admin',
      defaultPassword: '', // No default password
      detector: OpenDTUWifiService.isResponseFromManufacturer,
      httpStartPage: true
    ));

    // Register Hoymiles (TCP-based) - No authentication
    registerDetector(DEVICE_MANUFACTURER_HOYMILES, ManufacturerDetectorInfo(
      manufacturerName: 'Hoymiles',
      defaultPort: HoymilesProtocol.DTU_PORT, // 10081
      requiresUsername: false,
      requiresPassword: false,
      detector: HoymilesWifiService.isResponseFromManufacturer,
      httpStartPage: false
    ));

    // Register Kostal (HTTP + Modbus TCP detection) - No authentication
    registerDetector(DEVICE_MANUFACTURER_KOSTAL, ManufacturerDetectorInfo(
      manufacturerName: 'Kostal',
      defaultPort: 80,
      requiresUsername: false,
      requiresPassword: false,
      detector: KostalWifiService.isResponseFromManufacturer,
      httpStartPage: true, // Enable HTTP probing for faster detection
      additionalPort: KostalModbusConnection.DEFAULT_PORT,
      additionalPortLabel: "Modbus"
    ));

    _detectorsInitialized = true;
    print('Device detectors initialized: ${_detectorRegistry.length} manufacturers registered');
  }

  NetworkScanService() {
    // Ensure detectors are initialized
    initializeDetectors();
  }

  /// Scans the local network for devices using ICMP ping sweep
  ///
  /// [timeout] - Timeout for each ping (default: 10 second)
  /// [firstIP] - First IP address in range to scan (default: 1)
  /// [lastIP] - Last IP address in range to scan (default: 255)
  /// [onProgress] - Callback for progress updates with (totalHosts, checkedCount, foundDevice)
  /// [maxConcurrentProbes] - Maximum number of concurrent device probes (default: 10)
  /// [probeTimeout] - Timeout for HTTP probing each device (default: 2 seconds for fast scanning)
  Future<List<NetworkDevice>> scanNetwork({
    Duration timeout = const Duration(seconds: 10),
    int firstIP = 1,
    int lastIP = 255,
    List<String>? subnets, // NEW: Accept list of subnets instead of getting WiFi IP
    void Function(int totalHosts, int checkedCount, NetworkDevice? foundDevice)? onProgress,
    int maxConcurrentProbes = 10,
    Duration probeTimeout = const Duration(seconds: 2),
  }) async {
    print('\n═══════════════════════════════════════════════════════════════');
    print('SCANNING LOCAL NETWORK VIA ICMP PING SWEEP');
    print('═══════════════════════════════════════════════════════════════');

    _discoveredDevices.clear();

    try {
      // Validate subnets parameter
      if (subnets == null || subnets.isEmpty) {
        throw Exception('Keine Netzwerke zum Scannen angegeben');
      }

      print('Subnets to scan: ${subnets.join(", ")}');
      print('Timeout per host: ${timeout.inMilliseconds}ms');

      // Scan all subnets in parallel
      final List<Future<List<Host>>> scanFutures = [];

      for (final subnet in subnets) {
        print('Queuing scan for subnet: $subnet.1 - $subnet.$lastIP');
        final scanFuture = _scanner.quickIcmpScanAsync(
          subnet,
          firstIP: firstIP,
          lastIP: lastIP,
          timeout: timeout,
        );
        scanFutures.add(scanFuture);
      }

      // Wait for all subnet scans to complete
      final allSubnetResults = await Future.wait(scanFutures);

      // Combine all hosts from all subnets
      final List<Host> hosts = [];
      for (int i = 0; i < allSubnetResults.length; i++) {
        final subnetHosts = allSubnetResults[i];
        hosts.addAll(subnetHosts);
        print('Subnet ${subnets[i]}: Found ${subnetHosts.length} reachable hosts');
      }

      print('Ping sweep completed. Found ${hosts.length} total reachable hosts across ${subnets.length} subnet(s)');
      print('\nProbing devices for manufacturer identification...');
      print('Using continuous parallel probing with max $maxConcurrentProbes concurrent probes');

      // Notify about total hosts found
      final totalHosts = hosts.length;
      _checkedCount = 0;
      onProgress?.call(totalHosts, 0, null);

      // Worker pool pattern: continuous parallelism
      final hostList = hosts.toList();
      int nextIndex = 0;

      Future<void> probeNext() async {
        while (true) {
          // Get next host index atomically
          int? index;
          await _progressMutex.protect(() async {
            if (nextIndex < hostList.length) {
              index = nextIndex;
              nextIndex++;
            }
          });

          if (index == null) break; // No more hosts

          final host = hostList[index!];
          final ipAddress = host.internetAddress.address;
          final device = await _probeDevice(ipAddress, probeTimeout);

          // Mutex-protected callback and counter update
          await _progressMutex.protect(() async {
            _checkedCount++;
            if (device != null) {
              _discoveredDevices.add(device);
              print('  ✓ ${device.manufacturer} device found: ${device.serialNumber}');
            }
            onProgress?.call(totalHosts, _checkedCount, device);
          });
        }
      }

      // Start worker pool
      final workers = List.generate(
        maxConcurrentProbes.clamp(1, totalHosts),
        (_) => probeNext(),
      );

      await Future.wait(workers);

      print('\n═══════════════════════════════════════════════════════════════');
      print('Network scan completed.');
      print('Total hosts found: ${hosts.length}');
      print('Supported devices found: ${_discoveredDevices.length}');
      print('═══════════════════════════════════════════════════════════════\n');

      return _discoveredDevices;
    } catch (e) {
      print('Error scanning network: $e');
      print('═══════════════════════════════════════════════════════════════\n');
      rethrow;
    }
  }

  /// Probes a device via HTTP to check if it's a supported manufacturer device
  ///
  /// Returns a NetworkDevice if matched by any manufacturer, null otherwise
  Future<NetworkDevice?> _probeDevice(String ipAddress, Duration probeTimeout) async {
    try {
      print('  Probing $ipAddress...');

      // Make generic HTTP request
      http.Response? response;
      try {
        response = await http.get(
          Uri.parse('http://$ipAddress/'),
          headers: {'Accept': '*/*'},
        ).timeout(probeTimeout);
      } catch (e) {
        // HTTP probe failed, response stays null
      }

      // Try all registered detectors
      for (final entry in _detectorRegistry.entries) {
        final detectorInfo = entry.value;
        final connectionInfo = AdditionalConnectionInfo(
          timeout: probeTimeout,
        );

        try {
          final device = await detectorInfo.detector(ipAddress, response, connectionInfo);
          if (device != null) {
            return device;
          }
        } catch (e) {
          print('    ✗ ${detectorInfo.manufacturerName} detector error: $e');
        }
      }

      print('    ✗ Unknown device (no detector matched) on $ipAddress');
    } catch (e) {
      print('    ✗ Error on $ipAddress: $e');
    }

    return null;
  }

  /// Manually probe a specific manufacturer's device at given IP
  ///
  /// Used by manual device addition screen to probe a specific device configuration
  ///
  /// Returns NetworkDevice if device matches manufacturer, null otherwise
  /// Throws Exception if manufacturer is unknown or probe fails
  static Future<NetworkDevice?> probeManufacturer({
    required String manufacturerKey,
    required String ipAddress,
    required int port,
    String? username,
    String? password,
    int? additionalPort,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final detectorInfo = _detectorRegistry[manufacturerKey];
    if (detectorInfo == null) {
      throw Exception('Unknown manufacturer: $manufacturerKey');
    }

    final connectionInfo = AdditionalConnectionInfo(
      timeout: timeout,
      username: username,
      password: password,
      additionalPort: additionalPort,
    );

    try {
      // Make HTTP request if detector expects response
      http.Response? response;

      if(detectorInfo.httpStartPage == true) {
        response = await http.get(
          Uri.parse('http://$ipAddress:$port/'),
          headers: {'Accept': '*/*'},
        ).timeout(timeout);
      }

      return await detectorInfo.detector(ipAddress, response, connectionInfo);
    } catch (e) {
      debugPrint('Manual probe error for $manufacturerKey at $ipAddress: $e');
      rethrow;
    }
  }

  /// Clears the list of discovered devices
  void clearDevices() {
    _discoveredDevices.clear();
  }

  /// Disposes of resources
  void dispose() {
    clearDevices();
  }
}
