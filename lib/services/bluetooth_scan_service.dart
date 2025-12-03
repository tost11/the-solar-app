import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/bluetooth_constants.dart';

/// Service for handling Bluetooth Low Energy device scanning
///
/// This service manages BLE scanning operations, including:
/// - Permission checking for Bluetooth access
/// - Bluetooth adapter availability verification
/// - Device scanning with MAC address filtering
/// - Scan result management and updates
class BluetoothScanService {
  // Scan state
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // Callback for scan result updates
  Function(List<ScanResult>)? _onScanResultsUpdated;

  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;

  /// Sets a callback to be notified when scan results are updated
  void setOnScanResultsUpdated(Function(List<ScanResult>) callback) {
    _onScanResultsUpdated = callback;
  }

  /// Checks if all required Bluetooth permissions are granted
  ///
  /// Returns a map with permission status and error message if applicable
  Future<Map<String, dynamic>> checkBluetoothPermissions() async {
    // Desktop platforms don't require runtime permissions
    if (!Platform.isAndroid && !Platform.isIOS) {
      return {'granted': true, 'message': null};
    }

    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;
    final location = await Permission.location.status;

    if (!bluetoothScan.isGranted || !bluetoothConnect.isGranted || !location.isGranted) {
      return {
        'granted': false,
        'message': 'Bluetooth-Berechtigungen benötigt. Bitte erlaube sie.'
      };
    }

    return {'granted': true, 'message': null};
  }

  /// Checks if Bluetooth is supported and enabled on the device
  ///
  /// Returns a map with availability status and error message if applicable
  Future<Map<String, dynamic>> checkBluetoothAvailability() async {
    // Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      return {
        'available': false,
        'message': 'Bluetooth nicht unterstützt'
      };
    }

    // Check if Bluetooth adapter is turned on
    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      return {
        'available': false,
        'message': 'Bitte aktiviere Bluetooth!'
      };
    }

    return {'available': true, 'message': null};
  }

  /// Starts a Bluetooth Low Energy scan for supported devices
  ///
  /// Scans for devices with MAC addresses matching supported manufacturers:
  /// - Zendure devices (MAC prefix from BLUETOOTH_MAC_PREFIX_ZENDURE)
  /// - Shelly devices (MAC prefix from BLUETOOTH_MAC_PREFIX_SHELLY)
  ///
  /// [timeout] - Duration of the scan (default: 10 seconds)
  ///
  /// Returns a map with success status and error message if applicable
  Future<Map<String, dynamic>> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isScanning) {
      return {
        'success': false,
        'message': 'Scan läuft bereits'
      };
    }

    // Check permissions
    final permissionCheck = await checkBluetoothPermissions();
    if (permissionCheck['granted'] != true) {
      return {
        'success': false,
        'message': permissionCheck['message']
      };
    }

    // Check Bluetooth availability
    final availabilityCheck = await checkBluetoothAvailability();
    if (availabilityCheck['available'] != true) {
      return {
        'success': false,
        'message': availabilityCheck['message']
      };
    }

    // Clear previous results and start scanning
    _scanResults.clear();
    _isScanning = true;
    _notifyResultsUpdated();

    try {
      await FlutterBluePlus.startScan(timeout: timeout);

      // Subscribe to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        // Filter results for supported manufacturers
        List<ScanResult> filtered = [];
        for (ScanResult res in results) {
          String macAddress = res.device.remoteId.toString();
          String name = res.device.advName.toString();
          // Filter for both Zendure and Shelly devices
          if (macAddress.startsWith(BLUETOOTH_MAC_PREFIX_ZENDURE) ||
              name.startsWith(BLUETOOTH_NAME_PREFIX_SHELLY)) {
            filtered.add(res);
          }
        }
        _scanResults = filtered;
        _notifyResultsUpdated();
      });

      // Auto-stop scan after timeout
      Future.delayed(timeout, () async {
        if (_isScanning) {
          await stopScan();
        }
      });

      return {'success': true, 'message': null};
    } catch (e) {
      _isScanning = false;
      _notifyResultsUpdated();
      return {
        'success': false,
        'message': 'Fehler beim Scannen: $e'
      };
    }
  }

  /// Stops the current Bluetooth scan
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    _notifyResultsUpdated();
  }

  /// Notifies registered callback about scan results update
  void _notifyResultsUpdated() {
    if (_onScanResultsUpdated != null) {
      _onScanResultsUpdated!(_scanResults);
    }
  }

  /// Clears the list of scan results
  void clearResults() {
    _scanResults.clear();
    _notifyResultsUpdated();
  }

  /// Disposes of resources and cancels subscriptions
  void dispose() {
    _scanSubscription?.cancel();
    _scanResults.clear();
    _onScanResultsUpdated = null;
  }
}
