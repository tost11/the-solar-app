import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/services/devices/kostal/kostal_modbus_connection.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_wifi_service.dart';
import '../models/network_device.dart';
import '../models/manufacturer_detector_info.dart';
import '../models/additional_connection_info.dart';
import '../models/network_scan_progress.dart';
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
  /// [onProgress] - Callback for progress updates with NetworkScanProgress model
  /// [maxConcurrentProbes] - Maximum number of concurrent device probes (default: 10)
  /// [maxConcurrentPings] - Maximum number of concurrent ping operations (default: 20)
  /// [probeTimeout] - Timeout for HTTP probing each device (default: 2 seconds for fast scanning)
  Future<List<NetworkDevice>> scanNetwork({
    Duration timeout = const Duration(seconds: 10),
    int firstIP = 1,
    int lastIP = 255,
    List<String>? subnets, // NEW: Accept list of subnets instead of getting WiFi IP
    void Function(NetworkScanProgress progress)? onProgress,
    int maxConcurrentProbes = 10,
    int maxConcurrentPings = 40,
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
      print('Timeout per ping: ${timeout.inMilliseconds}ms');

      // Generate list of all IPs to scan
      final List<String> ipList = [];
      for (final subnet in subnets) {
        for (int i = firstIP; i <= lastIP; i++) {
          ipList.add('$subnet.$i');
        }
      }

      print('Generated ${ipList.length} IP addresses to scan across ${subnets.length} subnet(s)');
      print('Using $maxConcurrentPings parallel ping workers');

      // Ping all IPs using worker pool pattern
      final List<String> reachableIPs = [];
      int nextPingIndex = 0;
      int checkedPingCount = 0;
      final totalIPs = ipList.length;

      // Progress tracking
      int foundHostsCount = 0;
      int knownDevicesCount = 0;
      int testedDevicesCount = 0;

      // Notify about total IPs to scan
      onProgress?.call(NetworkScanProgress(
        totalIPs: totalIPs,
        checkedIPs: 0,
        foundHosts: 0,
        knownDevices: 0,
        testedDevices: 0,
      ));

      Future<void> pingNext() async {
        while (true) {
          String? ip;
          await _progressMutex.protect(() async {
            if (nextPingIndex < ipList.length) {
              ip = ipList[nextPingIndex];
              nextPingIndex++;
            }
          });

          if (ip == null) break;

          final isReachable = await _pingHost(ip!, timeout);

          await _progressMutex.protect(() async {
            checkedPingCount++;
            if (isReachable) {
              reachableIPs.add(ip!);
              foundHostsCount++;
            }
            // Progress update DURING ping sweep
            onProgress?.call(NetworkScanProgress(
              totalIPs: totalIPs,
              checkedIPs: checkedPingCount,
              foundHosts: foundHostsCount,
              knownDevices: knownDevicesCount,
              testedDevices: testedDevicesCount,
            ));
          });
        }
      }

      // Start ping workers
      final pingWorkers = List.generate(
        maxConcurrentPings.clamp(1, totalIPs),
        (_) => pingNext(),
      );
      await Future.wait(pingWorkers);

      print('Ping sweep completed. Found ${reachableIPs.length} reachable hosts out of ${totalIPs} IPs');
      print('\nProbing ${reachableIPs.length} devices for manufacturer identification...');
      print('Using continuous parallel probing with max $maxConcurrentProbes concurrent probes');

      // Notify about transition to probing phase
      _checkedCount = 0;

      // Worker pool pattern: continuous parallelism
      int nextIndex = 0;

      Future<void> probeNext() async {
        while (true) {
          // Get next IP index atomically
          int? index;
          await _progressMutex.protect(() async {
            if (nextIndex < reachableIPs.length) {
              index = nextIndex;
              nextIndex++;
            }
          });

          if (index == null) break; // No more IPs

          final ipAddress = reachableIPs[index!];
          final device = await _probeDevice(ipAddress, probeTimeout);

          // Mutex-protected callback and counter update
          await _progressMutex.protect(() async {
            _checkedCount++;
            if (device != null) {
              _discoveredDevices.add(device);
              knownDevicesCount++;
              print('  ✓ ${device.manufacturer} device found: ${device.serialNumber}');
            } else {
              testedDevicesCount++;
            }

            onProgress?.call(NetworkScanProgress(
              totalIPs: totalIPs,
              checkedIPs: checkedPingCount,
              foundHosts: foundHostsCount,
              knownDevices: knownDevicesCount,
              testedDevices: testedDevicesCount,
              device: device,
            ));
          });
        }
      }

      // Start worker pool
      final workers = List.generate(
        maxConcurrentProbes.clamp(1, reachableIPs.length),
        (_) => probeNext(),
      );

      await Future.wait(workers);

      print('\n═══════════════════════════════════════════════════════════════');
      print('Network scan completed.');
      print('Total reachable hosts: ${reachableIPs.length}');
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
          final device = await detectorInfo.detector(ipAddress, null, response, connectionInfo);
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

  /// Pings a single IP address with timeout protection
  ///
  /// Returns true if host responds to ICMP ping within timeout
  Future<bool> _pingHost(String ipAddress, Duration timeout) async {
    try {

      // Language-agnostic ping parser that works across English, German, Portuguese, etc.
      // Matches numeric patterns (time in ms with float support, TTL) instead of language-specific keywords
      // Uses lookahead assertions to match time and TTL in any order
      final parser = PingParser(
        // Match: IP address + time (integer or float with . or ,) + TTL (in any order)
        // Time supports: "34ms", "34.5ms", "34,5ms" (European format)
        // Works with: "time=34ms", "time= 34ms", "time = 43.5 ms"
        // Order-independent: "time=45ms TTL=64" or "TTL=64 time=45ms" both work
        // Example EN: "Reply from 192.168.1.1: bytes=32 time=45ms TTL=64"
        // Example DE: "Antwort von 192.168.1.1: Bytes=32 Zeit=45.5ms TTL=64"
        // Example PT: "Resposta de 192.168.1.1: bytes=32 tempo=45,5ms TTL=64"
        responseRgx: RegExp(
          r'(?<ip>\d+\.\d+\.\d+\.\d+)(?=.*?[=:]?\s*(?<time>\d+[.,]?\d*)\s*ms)(?=.*?TTL[=:]?\s*(?<ttl>\d+)).*',
          caseSensitive: false,
        ),
        // Summary pattern - simplified numeric extraction (optional, not critical)
        summaryRgx: RegExp(r'(?<tx>\d+).*?(?<rx>\d+)'),
        // Error detection: check if "host" appears in output (unreachable/unknown)
        timeoutRgx: RegExp(r'host', caseSensitive: false),
        timeToLiveRgx: RegExp(r'(?!)'),//this never matches no good solution for different languages
        unknownHostStr: RegExp(r' host ', caseSensitive: false),
      );

      final ping = Ping(ipAddress, count: 1, parser: parser, encoding: Utf8Codec(allowMalformed: true));
      //final ping = Ping(ipAddress, count: 1, parser: parser, encoding: systemEncoding);
      //final ping = Ping(ipAddress, count: 1);

      // Wait for first response with timeout
      await for (final response in ping.stream.timeout(timeout)) {
        if (response.error == null && response.response?.time != null) {
          // Successful ping response
          return true;
        }
      }

      // No successful response received
      return false;
    } catch (e) {
      // Timeout or error occurred
      return false;
    }
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

      debugPrint("Give http repose: ${response?.statusCode.toString()} and url: $ipAddress:$port to detector");

      return await detectorInfo.detector(ipAddress, port, response, connectionInfo);
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
