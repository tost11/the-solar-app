import 'dart:async';
import 'package:wifi_scan/wifi_scan.dart';

class WiFiService {
  List<String> _availableNetworks = [];

  List<String> get availableNetworks => _availableNetworks;
  bool get hasNetworks => _availableNetworks.isNotEmpty;

  Future<List<String>> scanNetworks() async {
    print('\n═══════════════════════════════════════════════════════════════');
    print('SCANNING FOR WIFI NETWORKS');
    print('═══════════════════════════════════════════════════════════════');

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
        print('WiFi scan started...');

        // Wait for scan to complete
        await Future.delayed(const Duration(seconds: 3));
      }

      // Get scan results
      final results = await WiFiScan.instance.getScannedResults();
      print('Found ${results.length} WiFi networks');

      // Extract unique SSIDs (filter out empty SSIDs)
      Set<String> ssids = {};
      for (var result in results) {
        if (result.ssid.isNotEmpty) {
          ssids.add(result.ssid);
          print('  - ${result.ssid} (${result.level} dBm)');
        }
      }

      _availableNetworks = ssids.toList()..sort();
      print('Unique SSIDs: ${_availableNetworks.length}');
      print('═══════════════════════════════════════════════════════════════\n');

      return _availableNetworks;
    } catch (e) {
      print('Error scanning WiFi: $e');
      rethrow;
    }
  }

  void clearNetworks() {
    _availableNetworks.clear();
  }
}
