import 'dart:async';
import 'dart:io' show Platform;
import 'package:bluez/bluez.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
import 'package:permission_handler/permission_handler.dart';
import '../constants/bluetooth_constants.dart';
import '../utils/debug_log.dart';

/// Enriched scan result with manufacturer detection
class BluetoothScanResult {
  final ScanResult? scanResult;        // null for system-device-seeded entries
  final BluetoothDevice? _device;      // used when scanResult is null
  final String? detectedManufacturer;  // null = unknown manufacturer

  BluetoothScanResult(ScanResult sr, this.detectedManufacturer)
      : scanResult = sr,
        _device = null;

  /// Constructor for devices seeded from BlueZ directly (no ScanResult available)
  BluetoothScanResult.fromDevice(BluetoothDevice device, this.detectedManufacturer)
      : scanResult = null,
        _device = device;

  bool get isKnownManufacturer => detectedManufacturer != null;
  BluetoothDevice get device => scanResult?.device ?? _device!;
}

/// Service for handling Bluetooth Low Energy device scanning
///
/// This service manages BLE scanning operations, including:
/// - Permission checking for Bluetooth access
/// - Bluetooth adapter availability verification
/// - Device scanning with MAC address filtering
/// - Scan result management and updates
class BluetoothScanService {
  // Scan state
  List<BluetoothScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // Linux BlueZ RSSI watch state
  BlueZClient? _bluezClient;
  StreamSubscription? _bluezDevicesChangedSub;
  final Map<String, StreamSubscription> _bluezRssiSubs = {};

  // Callback for scan result updates
  Function(List<BluetoothScanResult>)? _onScanResultsUpdated;

  List<BluetoothScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;

  /// Sets a callback to be notified when scan results are updated
  void setOnScanResultsUpdated(Function(List<BluetoothScanResult>) callback) {
    _onScanResultsUpdated = callback;
  }

  /// Detects manufacturer from scan result based on MAC address or device name
  ///
  /// Returns manufacturer constant or null if unknown
  String? detectManufacturer(ScanResult result) {
    return _detectManufacturerFromDevice(result.device);
  }

  /// Detect manufacturer from a BluetoothDevice directly
  String? _detectManufacturerFromDevice(BluetoothDevice device) {
    String macAddress = device.remoteId.toString();
    String advName = device.advName.toString();
    String platformName = device.platformName.toString();
    // Use advName if available, fall back to platformName (Linux uses platformName)
    String name = advName.isNotEmpty ? advName : platformName;

    if (macAddress.startsWith(BLUETOOTH_MAC_PREFIX_ZENDURE1) || macAddress.startsWith(BLUETOOTH_MAC_PREFIX_ZENDURE2) || name.startsWith(BLUETOOTH_NAME_PREFIX_ZENDURE)) {//TODO do name better with regex
      return DEVICE_MANUFACTURER_ZENDURE;
    }
    if (name.startsWith(BLUETOOTH_NAME_PREFIX_SHELLY)) {
      return DEVICE_MANUFACTURER_SHELLY;
    }
    if (name.startsWith(HOYMILES_BLE_NAME_PREFIX)) {
      return DEVICE_MANUFACTURER_HOYMILES;
    }

    return null; // Unknown manufacturer
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
    final isSupported = await FlutterBluePlus.isSupported;
    DebugLog.bluetooth('isSupported: $isSupported', level: LogLevel.debug);
    if (isSupported == false) {
      return {
        'available': false,
        'message': 'Bluetooth nicht unterstützt'
      };
    }

    // Check if Bluetooth adapter is turned on
    DebugLog.bluetooth('Checking adapter state...', level: LogLevel.debug);
    var adapterState = await FlutterBluePlus.adapterState.first;
    DebugLog.bluetooth('Adapter state: $adapterState', level: LogLevel.debug);
    if (adapterState != BluetoothAdapterState.on) {
      return {
        'available': false,
        'message': 'Bitte aktiviere Bluetooth!'
      };
    }

    return {'available': true, 'message': null};
  }

  /// Starts a Bluetooth Low Energy scan for devices
  ///
  /// [timeout] - Duration of the scan (default: 10 seconds)
  /// [showAllDevices] - If false (default), filters for known manufacturers only (Zendure, Shelly).
  ///                   If true, shows all BLE devices with manufacturer detection.
  ///
  /// Returns a map with success status and error message if applicable
  Future<Map<String, dynamic>> startScan({
    Duration timeout = const Duration(seconds: 10),
    bool showAllDevices = false,
  }) async {
    DebugLog.bluetooth('startScan() called (timeout: ${timeout.inSeconds}s, showAll: $showAllDevices, platform: ${Platform.operatingSystem})', level: LogLevel.info);

    if (_isScanning) {
      DebugLog.bluetooth('Already scanning, aborting', level: LogLevel.warning);
      return {
        'success': false,
        'message': 'Scan läuft bereits'
      };
    }

    // Check permissions
    final permissionCheck = await checkBluetoothPermissions();
    DebugLog.bluetooth('Permissions granted: ${permissionCheck['granted']}', level: LogLevel.debug);
    if (permissionCheck['granted'] != true) {
      return {
        'success': false,
        'message': permissionCheck['message']
      };
    }

    // Check Bluetooth availability
    final availabilityCheck = await checkBluetoothAvailability();
    DebugLog.bluetooth('Bluetooth available: ${availabilityCheck['available']}', level: LogLevel.debug);
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
      DebugLog.bluetooth('Calling FlutterBluePlus.startScan(timeout: $timeout)...', level: LogLevel.debug);
      await FlutterBluePlus.startScan(timeout: timeout);
      DebugLog.bluetooth('FlutterBluePlus.startScan() returned successfully', level: LogLevel.debug);

      // On Linux, BlueZ only emits newly discovered devices via deviceAdded.
      // Devices already cached in the adapter never appear in FBP's scanResults
      // even if they are actively advertising. We use the bluez package directly
      // to watch for RSSI property changes — which fires when a known device
      // re-advertises during discovery — to supplement FBP's scan results.
      if (Platform.isLinux) {
        _startLinuxRssiWatch(showAllDevices);
      }

      // Subscribe to scan results
      DebugLog.bluetooth('Subscribing to FlutterBluePlus.scanResults stream...', level: LogLevel.debug);
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        DebugLog.bluetooth('scanResults event: ${results.length} raw results', level: LogLevel.verbose);
        for (ScanResult res in results) {
          DebugLog.bluetooth('Raw: name="${res.device.platformName}" advName="${res.advertisementData.advName}" id=${res.device.remoteId}', level: LogLevel.verbose);
        }

        // Detect manufacturer and conditionally filter
        List<BluetoothScanResult> enriched = [];
        for (ScanResult res in results) {
          String? manufacturer = detectManufacturer(res);

          // Apply filter only if showAllDevices is false
          if (!showAllDevices && manufacturer == null) {
            continue; // Skip unknown devices (current behavior)
          }

          enriched.add(BluetoothScanResult(res, manufacturer));
        }
        DebugLog.bluetooth('After filtering: ${enriched.length} devices', level: LogLevel.debug);

        // On Linux, merge with BlueZ-seeded results (devices found via RSSI watch)
        if (Platform.isLinux) {
          final enrichedIds = enriched.map((r) => r.device.remoteId.str).toSet();
          final linuxSeeded = _scanResults.where(
            (r) => r.scanResult == null && !enrichedIds.contains(r.device.remoteId.str),
          ).toList();
          _scanResults = [...enriched, ...linuxSeeded];
        } else {
          _scanResults = enriched;
        }
        _notifyResultsUpdated();
      });

      // Auto-stop scan after timeout
      Future.delayed(timeout, () async {
        DebugLog.bluetooth('Timeout reached (${timeout.inSeconds}s)', level: LogLevel.debug);
        if (_isScanning) {
          await stopScan();
        }
      });

      return {'success': true, 'message': null};
    } catch (e) {
      DebugLog.error('Exception during scan: $e', category: 'bluetooth');
      _isScanning = false;
      _stopLinuxRssiWatch();
      _notifyResultsUpdated();
      return {
        'success': false,
        'message': 'Fehler beim Scannen: $e'
      };
    }
  }

  // ==========================================================================
  // Linux BlueZ RSSI watch — supplements FBP's scan with known-device detection
  // ==========================================================================

  /// Starts watching BlueZ device RSSI changes during an active scan.
  ///
  /// On Linux, FBP's onScanResponse only fires for deviceAdded (new D-Bus objects).
  /// When a known device re-advertises during discovery, BlueZ updates its RSSI
  /// property via propertiesChanged — which FBP ignores entirely. This method
  /// uses the bluez package directly to watch those RSSI changes and add
  /// in-range known devices to the scan results.
  Future<void> _startLinuxRssiWatch(bool showAllDevices) async {
    try {
      _bluezClient = BlueZClient();
      await _bluezClient!.connect();

      // Pre-populate FBP's platformName cache for all known BlueZ devices.
      // Without this, BluetoothDevice.fromId().platformName returns "" because
      // FBP only populates names via scan results or explicit systemDevices() calls.
      await FlutterBluePlus.systemDevices([]);

      final devices = _bluezClient!.devices;
      DebugLog.bluetooth('Linux RSSI watch: ${devices.length} BlueZ devices', level: LogLevel.debug);

      // Seed devices that already have a non-zero RSSI (actively advertising)
      for (final device in devices) {
        _checkAndAddBluezDevice(device, showAllDevices);
      }

      // Subscribe to RSSI property changes on all existing devices
      for (final device in devices) {
        _watchDeviceRssi(device, showAllDevices);
      }

      // Watch for new devices added during the scan
      _bluezDevicesChangedSub = _bluezClient!.deviceAdded.listen((device) {
        DebugLog.bluetooth('Linux RSSI watch: new device added ${device.address}', level: LogLevel.debug);
        _checkAndAddBluezDevice(device, showAllDevices);
        _watchDeviceRssi(device, showAllDevices);
      });
    } catch (e) {
      DebugLog.bluetooth('Linux RSSI watch: failed to start: $e', level: LogLevel.warning);
    }
  }

  /// Subscribe to propertiesChanged for a single BlueZ device, watching for RSSI updates.
  void _watchDeviceRssi(BlueZDevice device, bool showAllDevices) {
    final address = device.address;
    // Don't double-subscribe
    if (_bluezRssiSubs.containsKey(address)) return;

    try {
      _bluezRssiSubs[address] = device.propertiesChanged.listen((properties) {
        if (properties.contains('RSSI')) {
          _checkAndAddBluezDevice(device, showAllDevices);
        }
      });
    } catch (e) {
      // Device may not have the org.bluez.Device1 interface (e.g. adapters)
      DebugLog.bluetooth('Linux RSSI watch: cannot watch $address: $e', level: LogLevel.verbose);
    }
  }

  /// Check if a BlueZ device is in range (RSSI != 0) and add to scan results if not already present.
  void _checkAndAddBluezDevice(BlueZDevice device, bool showAllDevices) {
    final rssi = device.rssi;
    if (rssi == 0) return; // Not currently advertising / stale

    final address = device.address;

    // Check if already in results (by MAC address)
    final alreadyPresent = _scanResults.any((r) => r.device.remoteId.str == address);
    if (alreadyPresent) return;

    // Use FBP device reference — platformName is populated via systemDevices() call
    final fbpDevice = BluetoothDevice.fromId(address);
    final manufacturer = _detectManufacturerFromDevice(fbpDevice);

    // Apply manufacturer filter
    if (!showAllDevices && manufacturer == null) return;

    DebugLog.bluetooth(
      'Linux RSSI watch: adding ${fbpDevice.platformName} ($address) rssi=$rssi manufacturer=$manufacturer',
      level: LogLevel.debug,
    );

    _scanResults = [..._scanResults, BluetoothScanResult.fromDevice(fbpDevice, manufacturer)];
    _notifyResultsUpdated();
  }

  /// Stops the Linux BlueZ RSSI watch and cleans up resources.
  void _stopLinuxRssiWatch() {
    _bluezDevicesChangedSub?.cancel();
    _bluezDevicesChangedSub = null;

    for (final sub in _bluezRssiSubs.values) {
      sub.cancel();
    }
    _bluezRssiSubs.clear();

    try {
      _bluezClient?.close();
    } catch (_) {}
    _bluezClient = null;
  }

  // ==========================================================================

  /// Stops the current Bluetooth scan
  Future<void> stopScan() async {
    DebugLog.bluetooth('stopScan() called (was scanning: $_isScanning)', level: LogLevel.info);
    await FlutterBluePlus.stopScan();
    _stopLinuxRssiWatch();
    _isScanning = false;
    _notifyResultsUpdated();
    DebugLog.bluetooth('Scan stopped', level: LogLevel.info);
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
    _stopLinuxRssiWatch();
    _scanResults.clear();
    _onScanResultsUpdated = null;
  }
}
