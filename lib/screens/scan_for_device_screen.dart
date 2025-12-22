import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../constants/bluetooth_constants.dart';
import '../services/devices/zendure/zendure_bluetooth_service.dart';
import '../services/devices/shelly/shelly_bluetooth_service.dart';
import '../services/device_storage_service.dart';
import '../services/network_scan_service.dart';
import '../services/bluetooth_scan_service.dart';
import '../models/device.dart';
import '../models/network_device.dart';
import '../models/network_scan_progress.dart';
import '../utils/map_utils.dart';
import '../utils/net_utils.dart';
import '../widgets/device_list_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';
import '../utils/permission_utils.dart';
import 'manual_device_add_screen.dart';

class ScanForDeviceScreen extends StatefulWidget {
  final Device? preselectedDevice;

  const ScanForDeviceScreen({super.key, this.preselectedDevice});

  @override
  State<ScanForDeviceScreen> createState() => _ScanForDeviceScreenState();
}

class _ScanForDeviceScreenState extends State<ScanForDeviceScreen> with SingleTickerProviderStateMixin {
  // Services
  final DeviceStorageService _storageService = DeviceStorageService();
  final NetworkScanService _networkScanService = NetworkScanService();
  final BluetoothScanService _bluetoothScanService = BluetoothScanService();
  final NetworkInfo _networkInfo = NetworkInfo();

  // Bluetooth scanning
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  // Network scanning
  List<NetworkDevice> _networkDevices = [];
  bool _isScanningNetwork = false;

  // Network scanning progress - unified view
  NetworkScanProgress? _scanProgress;
  bool _fastScanning = true; // Fast scanning enabled by default

  // Tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissions();

    // Set up callback for Bluetooth scan results updates
    _bluetoothScanService.setOnScanResultsUpdated((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
          _isScanning = _bluetoothScanService.isScanning;
        });
      }
    });
  }

  @override
  void dispose() {
    _bluetoothScanService.dispose();
    _networkScanService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    await PermissionUtils.checkAndRequestPermissions(context);
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    // Start the scan using the service
    final result = await _bluetoothScanService.startScan(
      timeout: const Duration(seconds: 10),
    );

    // Handle errors
    if (!result['success'] && result['message'] != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            action: result['message'].contains('Berechtigungen')
                ? SnackBarAction(
                    label: 'Berechtigungen',
                    onPressed: () => _checkPermissions(),
                  )
                : null,
          ),
        );
      }
    }
  }

  Future<void> _stopScan() async {
    await _bluetoothScanService.stopScan();
  }

  Future<DeviceBase> _connectToDevice(BluetoothDevice device) async {
    String macAddress = device.remoteId.toString();
    String name = device.advName.toString();

    // Detect device brand based on MAC prefix or name
    if (name.startsWith(BLUETOOTH_NAME_PREFIX_SHELLY)) {
      return await _connectToBluetoothDevice(device,DEVICE_MANUFACTURER_SHELLY,["config","model"]);
    } else if (macAddress.startsWith(BLUETOOTH_MAC_PREFIX_ZENDURE)) {
      return await _connectToBluetoothDevice(device,DEVICE_MANUFACTURER_ZENDURE,["config","model"]);
    } else {
      throw Exception('Unknown device brand');
    }
  }

  Future<DeviceBase> _connectToBluetoothDevice(BluetoothDevice device, String type,List<String> param) async {

    String id = device.remoteId.toString() + "_ble";

    try {
      var tempDevice = DeviceFactory.createBluetoothDevice(
          bluetoothDevice: device,
          name: "Gerät "+type,
          manufacturer: type,
          deviceModel: null,//will be fetched in next step
          deviceSn: device.remoteId.toString(),
          id: id);

      tempDevice.setUpServiceConnection(device);

      //this will check if services for bluetooth exist
      await tempDevice.getServiceConnection()?.connect();

      // Get device model from config data
      String deviceModel = MapUtils.OM(tempDevice.data,param) as String? ?? "";

      tempDevice.removeServiceConnection();

      // Create the correct device instance based on the model
      final knownDevice = DeviceFactory.createBluetoothDevice(
        id: id,
        name: type + deviceModel,
        deviceSn: device.remoteId.toString(),
        deviceModel: deviceModel,
        manufacturer: type,
        bluetoothDevice: device
      );

      await _storageService.saveDevice(knownDevice);

      return knownDevice;
    } catch (e) {
      debugPrint("error while creating bluetooth device with type $type: $e");
      rethrow;
    }
  }

  Future<void> _startNetworkScan() async {
    if (_isScanningNetwork) return;

    // Get all local network IPs (WiFi + Ethernet) using NetUtils
    final localIPs = await NetUtils.getLocalNetworkIPs();

    if (localIPs.isEmpty) {
      if (mounted) {
        MessageUtils.showError(
          context,
          'Netzwerk-Scan ist nur über WiFi oder LAN möglich.\n\n'
          'Bitte verbinden Sie sich mit einem WiFi-Netzwerk oder LAN und versuchen Sie es erneut.',
          title: 'Keine WiFi/LAN-Verbindung',
        );
      }
      return;
    }

    // Extract unique subnets using NetUtils
    final subnets = NetUtils.extractUniqueSubnets(localIPs, ipToCSubnet);

    if (subnets.isEmpty) {
      if (mounted) {
        MessageUtils.showError(
          context,
          'Keine privaten Netzwerke gefunden.\n\n'
          'Gefundene IPs: ${localIPs.join(", ")}\n\n'
          'Stellen Sie sicher, dass Sie mit einem lokalen Netzwerk verbunden sind.',
          title: 'Kein privates Netzwerk',
        );
      }
      return;
    }

    debugPrint('Scanning ${subnets.length} subnet(s): ${subnets.join(", ")}');

    // Check WiFi permissions on Android 13+ (API 33+) only
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // NEARBY_WIFI_DEVICES permission only exists on Android 13+ (API 33+)
        if (sdkInt >= 33) {
          final nearbyWifiDevices = await Permission.nearbyWifiDevices.status;

          if (!nearbyWifiDevices.isGranted) {
            final result = await Permission.nearbyWifiDevices.request();
            if (!result.isGranted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('WiFi-Geräte-Berechtigung benötigt für Netzwerk-Scan'),
                    action: SnackBarAction(
                      label: 'Einstellungen',
                      onPressed: () => openAppSettings(),
                    ),
                  ),
                );
              }
              return;
            }
          }
        }
        // On Android < 13, no additional permissions needed for mDNS
      } catch (e) {
        print('Error checking Android version: $e');
        // Continue with scan if we can't determine version
      }
    }

    setState(() {
      _networkDevices.clear();
      _scanProgress = null;
      _isScanningNetwork = true;
    });

    try {
      // Perform ICMP ping sweep to discover all devices on the network
      await _networkScanService.scanNetwork(
        subnets: subnets, // Pass list of subnets to scan
        timeout: const Duration(seconds: 5), // Timeout per ping
        maxConcurrentPings: 20, // 20 parallel ping workers
        probeTimeout: _fastScanning
            ? const Duration(seconds: 2)
            : const Duration(seconds: 5),
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _scanProgress = progress;
              if (progress.device != null) {
                _networkDevices.add(progress.device!);
              }
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_networkDevices.length} Geräte im Netzwerk gefunden'),
            backgroundColor: _networkDevices.isNotEmpty ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Netzwerk-Scan Fehler';

        if (e.toString().contains('WiFi')) {
          errorMessage = 'Nicht mit WiFi verbunden. Bitte WiFi aktivieren.';
        } else {
          errorMessage = 'Netzwerk-Scan Fehler: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanningNetwork = false);
      }
    }
  }

  /// Show warning dialog when WiFi IP is not in a private network range
  ///
  /// Returns true if user clicks OK to proceed, false if cancelled
  Future<bool> _showNonPrivateIPWarning(String currentIP) async {
    final message = 'Ihre aktuelle IP-Adresse scheint nicht in einem privaten Netzwerk zu sein.\n\n'
        'Aktuelle IP: $currentIP\n\n'
        'Das Scannen von öffentlichen IP-Bereichen ist möglicherweise nicht sinnvoll. '
        'Stellen Sie sicher, dass Sie mit einem lokalen WiFi-Netzwerk verbunden sind.\n\n'
        'Möchten Sie trotzdem fortfahren?';

    return await MessageUtils.showConfirmationDialog(
      context,
      title: 'Warnung: Öffentliches Netzwerk',
      message: message,
      okButtonText: 'OK, Fortfahren',
      okButtonColor: Colors.orange,
    );
  }

  Future<void> _navigateToManualAdd() async {
    final device = await Navigator.push<DeviceBase>(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualDeviceAddScreen(),
      ),
    );

    if (device != null && mounted) {
      // Return device to parent DeviceListScreen
      Navigator.pop(context, device);
    }
  }

  Future<DeviceBase> _connectToNetworkDevice(NetworkDevice networkDevice) async {
    // Create a WiFi Device entry for the network device
    final deviceName = networkDevice.deviceModel != null
        ? '${networkDevice.manufacturer} ${networkDevice.deviceModel} (${networkDevice.ipAddress})'
        : '${networkDevice.manufacturer} (${networkDevice.ipAddress})';

    final knownDevice = DeviceFactory.createWiFiDevice(
      id: networkDevice.serialNumber + "_wifi",
      ipAddress: networkDevice.ipAddress,
      name: deviceName,
      deviceModel: networkDevice.deviceModel,
      deviceSn: networkDevice.serialNumber,
      manufacturer: networkDevice.manufacturer,
      hostname: networkDevice.hostname,
      port: networkDevice.port
    );

    _storageService.saveDevice(knownDevice);

    return knownDevice;
  }

  Widget _buildScanProgressInfo() {
    if (_scanProgress == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress bar (overall combined progress)
          LinearProgressIndicator(
            value: _scanProgress!.overallProgress,
          ),
          const SizedBox(height: 16),

          // Info cards in 2x2 grid
          Row(
            children: [
              Expanded(child: _buildInfoCard(
                'Gefunden',
                '${_scanProgress!.foundHosts}',
                Icons.router,
                Colors.blue,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard(
                'Bekannte Geräte',
                '${_scanProgress!.knownDevices}',
                Icons.check_circle,
                Colors.green,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInfoCard(
                'Geprüft',
                '${_scanProgress!.testedDevices}',
                Icons.done,
                Colors.orange,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard(
                'Verbleibend',
                '${_scanProgress!.remainingDevices}',
                Icons.pending,
                Colors.grey,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactScanStatus() {
    if (_scanProgress == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar (overall combined progress)
          LinearProgressIndicator(
            value: _scanProgress!.overallProgress,
            backgroundColor: Colors.green.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 12),
          // Unified status text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusText('Gefunden', _scanProgress!.foundHosts, Icons.router),
              _buildStatusText('Bekannt', _scanProgress!.knownDevices, Icons.check_circle),
              _buildStatusText('Geprüft', _scanProgress!.testedDevices, Icons.done),
              _buildStatusText('Übrig', _scanProgress!.remainingDevices, Icons.pending),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(String label, int value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(NetworkDevice device) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.wifi, color: Colors.green.shade700),
        ),
        title: Text(
          device.manufacturer != null
              ? (device.deviceModel != null
                  ? '${device.manufacturer} ${device.deviceModel}'
                  : '${device.manufacturer} Gerät')
              : device.ipAddress,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.router, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  device.ipAddress,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'SN: ${device.serialNumber}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          var knownDevice = await DialogUtils.executeWithLoading(
              context,
              loadingMessage: 'Verbinde zu Gerät...',
              operation: () async {
                return await _connectToNetworkDevice(device);
              },
              showErrorDialog: true
          );
          // Return device to parent DeviceListScreen
          if (mounted && knownDevice != null) {
            Navigator.pop(context, knownDevice);
          }
        }
      ),
    );
  }

  Widget _buildNetworkDevicesList() {
    // Show empty state when not scanning and no devices
    if (_networkDevices.isEmpty && !_isScanningNetwork) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_find,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Keine Geräte gefunden',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Starten Sie einen Scan um Geräte zu finden',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show waiting message when scanning and no devices yet
    if (_networkDevices.isEmpty && _isScanningNetwork) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Suche nach bekannten Geräten...',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Show device list
    return ListView.builder(
      itemCount: _networkDevices.length,
      itemBuilder: (context, index) {
        final device = _networkDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Gerät hinzufügen',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
            Tab(icon: Icon(Icons.wifi), text: 'Netzwerk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Bluetooth Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Bluetooth-Geräte',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scannen Sie nach Geräten in der Nähe (Zendure, Shelly)',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.bluetooth_searching),
                      label: Text(_isScanning ? 'Scannt...' : 'Bluetooth-Scan'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: DeviceListWidget(
                  scanResults: _scanResults,
                  isScanning: _isScanning,
                  onDeviceTap: (device) async {
                    var knownDevice = await DialogUtils.executeWithLoading(
                        context,
                        loadingMessage: 'Verbinde zu Gerät...',
                        operation: () async {
                          return await _connectToDevice(device);
                        },
                        showErrorDialog: true
                    );
                    // Return device to parent DeviceListScreen
                    if (mounted && knownDevice != null) {
                      Navigator.pop(context, knownDevice);
                    }
                  }
                ),
              ),
            ],
          ),

          // Network Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Netzwerk-Geräte',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scannen Sie Ihr lokales Netzwerk nach Geräten',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // IMPORTANT: Both the scan button section and scanning status must have
                    // the same fixed height (104px) to prevent the device list below from
                    // jumping when scanning starts/stops. When modifying this UI, maintain
                    // the SizedBox height wrapper on both branches of this conditional.
                    if (_isScanningNetwork)
                      SizedBox(
                        height: 104,
                        child: _buildCompactScanStatus(),
                      )
                    else
                      SizedBox(
                        height: 104,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: _startNetworkScan,
                                    icon: const Icon(Icons.router),
                                    label: const Text('Netzwerk-Scan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade100,
                                      minimumSize: const Size(0, 48),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToManualAdd,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Manuell'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade100,
                                      minimumSize: const Size(0, 48),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _fastScanning,
                                  onChanged: (value) {
                                    setState(() {
                                      _fastScanning = value ?? true;
                                    });
                                  },
                                ),
                                const Text('Fast Scanning (2s)'),
                                const SizedBox(width: 4),
                                Tooltip(
                                  message: 'Fast: 2s timeout\nSlow: 5s timeout',
                                  child: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(child: _buildNetworkDevicesList()),
            ],
          ),
        ],
      ),
    );
  }
}
