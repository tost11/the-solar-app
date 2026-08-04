import 'dart:async';
import '../utils/debug_log.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WiFiService {
  List<String> _availableNetworks = [];

  List<String> get availableNetworks => _availableNetworks;
  bool get hasNetworks => _availableNetworks.isNotEmpty;

  Future<List<String>> scanNetworks() async {
    DebugLog.network('═══════════════════════════════════════════════════════════════', level: LogLevel.debug);
    DebugLog.network('SCANNING FOR WIFI NETWORKS', level: LogLevel.debug);
    DebugLog.network('═══════════════════════════════════════════════════════════════', level: LogLevel.debug);

    try {
      // Check if WiFi scan is supported
      final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
      if (canGetScannedResults != CanGetScannedResults.yes) {
        throw Exception('WiFi scan not supported or permission denied');
      }

      // Start WiFi scan
      final canStartScan = await WiFiScan.instance.canStartScan();
      if (canStartScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        DebugLog.network('WiFi scan started...', level: LogLevel.debug);

        // Wait for scan to complete
        await Future.delayed(const Duration(seconds: 3));
      }

      // Get scan results
      final results = await WiFiScan.instance.getScannedResults();
      DebugLog.network('Found ${results.length} WiFi networks', level: LogLevel.debug);

      // Extract unique SSIDs (filter out empty SSIDs)
      Set<String> ssids = {};
      for (var result in results) {
        if (result.ssid.isNotEmpty) {
          ssids.add(result.ssid);
          DebugLog.network('  - ${result.ssid} (${result.level} dBm)', level: LogLevel.debug);
        }
      }

      _availableNetworks = ssids.toList()..sort();
      DebugLog.network('Unique SSIDs: ${_availableNetworks.length}', level: LogLevel.debug);
      DebugLog.network('═══════════════════════════════════════════════════════════════\n', level: LogLevel.debug);

      return _availableNetworks;
    } catch (e) {
      DebugLog.network('Error scanning WiFi: $e', level: LogLevel.error);
      rethrow;
    }
  }

  void clearNetworks() {
    _availableNetworks.clear();
  }
}
