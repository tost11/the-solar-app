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
import '../models/device_factory.dart';
import '../models/network_device.dart';
import '../models/network_scan_progress.dart';
import '../models/devices/mixins/device_wifi_mixin.dart';
import '../utils/map_utils.dart';
import '../utils/net_utils.dart';
import '../widgets/device_list_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/scan_advanced_options_widget.dart';
import '../utils/permission_utils.dart';
import '../utils/localization_extension.dart';
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

  // Advanced scanning options widget key
  final GlobalKey<ScanAdvancedOptionsWidgetState> _advancedOptionsKey = GlobalKey();

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
                    label: context.l10n.labelPermissions,
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
      return await _connectToBluetoothDevice(device, DEVICE_MANUFACTURER_SHELLY);
    } else if (macAddress.startsWith(BLUETOOTH_MAC_PREFIX_ZENDURE)) {
      return await _connectToBluetoothDevice(device, DEVICE_MANUFACTURER_ZENDURE);
    } else {
      throw Exception('Unknown device brand');
    }
  }

  Future<DeviceBase> _connectToBluetoothDevice(BluetoothDevice device, String type) async {
    String id = device.remoteId.toString() + "_ble";

    try {
      // Check if device already exists in storage
      final existingDevices = await _storageService.getKnownDevices();
      DeviceBase? existingDevice;
      try {
        existingDevice = existingDevices.firstWhere((d) => d.id == id);
      } catch (e) {
        existingDevice = null;
      }

      // If device already exists, return it (keep existing name, don't overwrite)
      if (existingDevice != null) {
        debugPrint("Device already known, using existing: ${existingDevice.name}");
        return existingDevice;
      }

      // New device: use advertised name as temporary name
      String advertisedName = device.advName;
      String deviceName = advertisedName.isNotEmpty ? "Zendure $advertisedName" : "Zendure Device";

      // Create device with temporary name
      // Model will be updated later when device info is fetched
      final knownDevice = DeviceFactory.createBluetoothDevice(
        id: id,
        name: deviceName,
        deviceSn: device.remoteId.toString(),
        deviceModel: null,  // Will be updated after connection
        manufacturer: type,
        bluetoothDevice: device
      );

      await _storageService.saveDevice(knownDevice);
      debugPrint("New device created: $deviceName");
      return knownDevice;
    } catch (e) {
      debugPrint("error while creating bluetooth device with type $type: $e");
      rethrow;
    }
  }

  Future<void> _startNetworkScan() async {
    if (_isScanningNetwork) return;

    // Get scanning configuration from advanced options widget
    final config = _advancedOptionsKey.currentState?.getCurrentConfiguration();
    if (config == null) {
      debugPrint('Advanced options widget not initialized yet');
      return;
    }

    // Get local network IPs based on configuration
    List<String> localIPs;
    if (config.isAutoMode) {
      // Auto mode: scan all available networks
      localIPs = await NetUtils.getLocalNetworkIPs();
    } else {
      // Specific interface selected
      if (config.ipAddress != null) {
        localIPs = [config.ipAddress!];
      } else {
        // Fallback to auto if selected interface no longer available
        localIPs = await NetUtils.getLocalNetworkIPs();
      }
    }

    if (localIPs.isEmpty) {
      if (mounted) {
        MessageUtils.showError(
          context,
          context.l10n.errorNoWifiLanConnection,
          title: context.l10n.errorNoWifiLanConnectionTitle,
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
          context.l10n.errorNoPrivateNetwork(localIPs.join(", ")),
          title: context.l10n.errorNoPrivateNetworkTitle,
        );
      }
      return;
    }

    debugPrint('Scanning ${subnets.length} subnet(s): ${subnets.join(", ")}');

    setState(() {
      _networkDevices.clear();
      _scanProgress = null;
      _isScanningNetwork = true;
    });

    try {
      // Determine timeouts based on configuration
      final icmpTimeout = config.useFastScanning
          ? Duration(seconds: config.icmpTimeoutSeconds)
          : Duration(seconds: config.deviceTimeoutSeconds);

      final probeTimeout = Duration(seconds: config.deviceTimeoutSeconds);

      // Perform ICMP ping sweep to discover all devices on the network
      await _networkScanService.scanNetwork(
        subnets: subnets, // Pass list of subnets to scan
        timeout: icmpTimeout, // ICMP timeout from configuration
        maxConcurrentPings: 20, // 20 parallel ping workers
        probeTimeout: probeTimeout, // Device probe timeout from configuration
        skipIcmpScan: !config.useFastScanning, // Skip ICMP when fast scanning disabled
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _scanProgress = progress;
            });
            // Enrich device with known status before adding to list
            if (progress.device != null) {
              _enrichNetworkDeviceWithKnownStatus(progress.device!)
                .then((enrichedDevice) {
                  if (mounted) {
                    setState(() {
                      _networkDevices.add(enrichedDevice);
                    });
                  }
                });
            }
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.messageDevicesFoundInNetwork(_networkDevices.length)),
            backgroundColor: _networkDevices.isNotEmpty ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = context.l10n.errorNetworkScanError;

        if (e.toString().contains('WiFi')) {
          errorMessage = context.l10n.errorNotConnectedToWifi;
        } else {
          errorMessage = context.l10n.errorNetworkScanFailed(e.toString());
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
    return await MessageUtils.showConfirmationDialog(
      context,
      title: context.l10n.warningPublicNetworkTitle,
      message: context.l10n.warningPublicNetwork(currentIP),
      okButtonText: context.l10n.actionContinueAnyway,
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
    final existingDevices = await _storageService.getKnownDevices();
    final expectedId = networkDevice.serialNumber + "_wifi";

    // Check if device already exists using where().firstOrNull pattern
    final existingDevice = existingDevices.where((d) => d.id == expectedId).firstOrNull;

    if (existingDevice != null) {
      // Device already known - update IP and port if changed
      if (existingDevice is DeviceWifiMixin) {
        final storedIp = (existingDevice as dynamic).netIpAddress;
        final storedPort = (existingDevice as dynamic).netPort;
        final ipChanged = storedIp != networkDevice.ipAddress;
        final portChanged = storedPort != networkDevice.port;

        if (ipChanged || portChanged) {
          (existingDevice as dynamic).netIpAddress = networkDevice.ipAddress;
          (existingDevice as dynamic).netPort = networkDevice.port;
          await _storageService.saveDevice(existingDevice);

          if (mounted) {
            if (ipChanged && portChanged) {
              MessageUtils.showInfo(
                context,
                context.l10n.messageIpUpdated(storedIp!, storedPort.toString(), networkDevice.ipAddress, networkDevice.port.toString())
              );
            } else if (ipChanged) {
              MessageUtils.showInfo(
                context,
                context.l10n.messageIpOnlyUpdated(storedIp!, networkDevice.ipAddress)
              );
            } else {
              MessageUtils.showInfo(
                context,
                context.l10n.messagePortUpdated(storedPort.toString(), networkDevice.port.toString())
              );
            }
          }
        }
      }

      return existingDevice;
    }

    // Device not found - create new
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

  Future<void> _saveDeviceWithoutConnecting(NetworkDevice device, int index) async {
    final savedDevice = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.messageSavingDevice,
      operation: () async {
        return await _connectToNetworkDevice(device);
      },
      showErrorDialog: true, // Shows error dialog on failure
    );

    if (mounted && savedDevice != null) {
      // Update device status in list
      setState(() {
        _networkDevices[index] = NetworkDevice(
          ipAddress: device.ipAddress,
          hostname: device.hostname,
          manufacturer: device.manufacturer,
          deviceModel: device.deviceModel,
          serialNumber: device.serialNumber,
          port: device.port,
          additionalPort: device.additionalPort,
          username: device.username,
          password: device.password,
          knownStatus: DeviceKnownStatus.knownSameIp,
          previousIpAddress: null,
        );
      });
      MessageUtils.showSuccess(context, context.l10n.messageDeviceSaved);
    }
  }

  Future<void> _connectAndOpenDevice(NetworkDevice device) async {
    var knownDevice = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.messageConnectingToDevice,
      operation: () async {
        return await _connectToNetworkDevice(device);
      },
      showErrorDialog: true,
    );

    if (mounted && knownDevice != null) {
      Navigator.pop(context, knownDevice);
    }
  }

  Future<NetworkDevice> _enrichNetworkDeviceWithKnownStatus(
    NetworkDevice scannedDevice
  ) async {
    final knownDevices = await _storageService.getKnownDevices();

    // Generate expected WiFi device ID
    final expectedId = scannedDevice.serialNumber + "_wifi";

    // Find matching device by ID using where().firstOrNull pattern
    final existingDevice = knownDevices.where((d) => d.id == expectedId).firstOrNull;

    if (existingDevice == null) {
      return scannedDevice; // Unknown device
    }

    // Device is known - check if IP or port changed
    String? storedIp;
    int? storedPort;
    if (existingDevice is DeviceWifiMixin) {
      storedIp = (existingDevice as dynamic).netIpAddress;
      storedPort = (existingDevice as dynamic).netPort;
    }

    final ipChanged = storedIp != scannedDevice.ipAddress;
    final portChanged = storedPort != scannedDevice.port;

    if (!ipChanged && !portChanged) {
      // Same IP and port
      return NetworkDevice(
        ipAddress: scannedDevice.ipAddress,
        hostname: scannedDevice.hostname,
        manufacturer: scannedDevice.manufacturer,
        deviceModel: scannedDevice.deviceModel,
        serialNumber: scannedDevice.serialNumber,
        port: scannedDevice.port,
        additionalPort: scannedDevice.additionalPort,
        username: scannedDevice.username,
        password: scannedDevice.password,
        knownStatus: DeviceKnownStatus.knownSameIp,
      );
    } else {
      // IP or port changed
      final previousAddress = storedPort != null ? '$storedIp:$storedPort' : storedIp;
      return NetworkDevice(
        ipAddress: scannedDevice.ipAddress,
        hostname: scannedDevice.hostname,
        manufacturer: scannedDevice.manufacturer,
        deviceModel: scannedDevice.deviceModel,
        serialNumber: scannedDevice.serialNumber,
        port: scannedDevice.port,
        additionalPort: scannedDevice.additionalPort,
        username: scannedDevice.username,
        password: scannedDevice.password,
        knownStatus: DeviceKnownStatus.knownNewIp,
        previousIpAddress: previousAddress,
      );
    }
  }

  Widget _buildKnownDeviceBadge(NetworkDevice device) {
    String label;
    Color backgroundColor;
    IconData icon;

    switch (device.knownStatus) {
      case DeviceKnownStatus.knownSameIp:
        label = context.l10n.labelKnownDevice;
        backgroundColor = Colors.orange.shade100;
        icon = Icons.warning_amber_rounded;
        break;
      case DeviceKnownStatus.knownNewIp:
        label = context.l10n.labelKnownNewAddress;
        backgroundColor = Colors.blue.shade100;
        icon = Icons.info_outline;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: backgroundColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[800]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (device.knownStatus == DeviceKnownStatus.knownNewIp &&
              device.previousIpAddress != null) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '(${device.previousIpAddress})',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDeviceCardColor(NetworkDevice device) {
    if (device.knownStatus == DeviceKnownStatus.knownSameIp) {
      return Colors.orange.shade100;
    } else if (device.knownStatus == DeviceKnownStatus.knownNewIp) {
      return Colors.blue.shade100;
    }
    return Colors.green.shade100;
  }

  IconData _getDeviceCardIcon(NetworkDevice device) {
    // Use centralized icon mapping from DeviceFactory
    return DeviceFactory.getDefaultIconByManufacturer(device.manufacturer);
  }

  Color _getDeviceCardIconColor(NetworkDevice device) {
    if (device.knownStatus == DeviceKnownStatus.knownSameIp) {
      return Colors.orange.shade700;
    } else if (device.knownStatus == DeviceKnownStatus.knownNewIp) {
      return Colors.blue.shade700;
    }
    return Colors.green.shade700;
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
                context.l10n.labelFound,
                '${_scanProgress!.foundHosts}',
                Icons.router,
                Colors.blue,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard(
                context.l10n.labelKnownDevices,
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
                context.l10n.labelTested,
                '${_scanProgress!.testedDevices}',
                Icons.done,
                Colors.orange,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard(
                context.l10n.labelRemaining,
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
              _buildStatusText(context.l10n.labelFound, _scanProgress!.foundHosts, Icons.router),
              _buildStatusText(context.l10n.labelKnown, _scanProgress!.knownDevices, Icons.check_circle),
              _buildStatusText(context.l10n.labelTested, _scanProgress!.testedDevices, Icons.done),
              _buildStatusText(context.l10n.labelRemaining, _scanProgress!.remainingDevices, Icons.pending),
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

  Widget _buildDeviceActionButtons(NetworkDevice device, int index) {
    // Save button: enabled for unknown devices or known devices with new IP
    final saveEnabled = device.knownStatus == DeviceKnownStatus.unknown ||
                        device.knownStatus == DeviceKnownStatus.knownNewIp;

    // Button labels adapt to device status
    final saveLabel = device.knownStatus == DeviceKnownStatus.knownNewIp
        ? context.l10n.actionUpdateIp
        : context.l10n.save;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: Text(saveLabel),
              onPressed: saveEnabled
                ? () => _saveDeviceWithoutConnecting(device, index)
                : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.open_in_browser, size: 18),
              label: Text(context.l10n.connect),
              onPressed: () => _connectAndOpenDevice(device),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(NetworkDevice device, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        String layoutMode;

        // Determine layout mode based on width
        if (width > 900) {
          layoutMode = 'SUPER_WIDE';
        } else if (width > 600) {
          layoutMode = 'WIDE';
        } else {
          layoutMode = 'STANDARD';
        }

        // Return appropriate layout
        if (width > 900) {
          return _buildSuperWideDeviceCard(device, index);
        } else if (width > 600) {
          return _buildWideDeviceCard(device, index);
        } else {
          return _buildStandardDeviceCard(device, index);
        }
      },
    );
  }

  Widget _buildStandardDeviceCard(NetworkDevice device, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDeviceCardColor(device),
          child: Icon(_getDeviceCardIcon(device), color: _getDeviceCardIconColor(device)),
        ),
        title: Text(
          device.manufacturer != null
              ? (device.deviceModel != null
                  ? '${device.manufacturer} ${device.deviceModel}'
                  : '${device.manufacturer} ${context.l10n.device}')
              : device.ipAddress,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // IP/SN and Badge row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN: IP + SN (no Expanded - shrink to fit)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IP Address Row
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
                    const SizedBox(height: 2),
                    // Serial Number
                    Text(
                      'SN: ${device.serialNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                // Warning Badge (float left next to IP/SN)
                if (device.knownStatus != DeviceKnownStatus.unknown)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildKnownDeviceBadge(device),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Action Buttons
            _buildDeviceActionButtons(device, index),
          ],
        ),
        trailing: null,
        onTap: null,
      ),
    );
  }

  Widget _buildWideDeviceCard(NetworkDevice device, int index) {
    final saveEnabled = device.knownStatus == DeviceKnownStatus.unknown ||
                        device.knownStatus == DeviceKnownStatus.knownNewIp;
    final saveLabel = device.knownStatus == DeviceKnownStatus.knownNewIp
        ? context.l10n.actionUpdate
        : context.l10n.save;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT: Avatar/Icon
            CircleAvatar(
              backgroundColor: _getDeviceCardColor(device),
              child: Icon(_getDeviceCardIcon(device), color: _getDeviceCardIconColor(device)),
            ),
            const SizedBox(width: 12),
            // MIDDLE: Device info (name + IP/badge + SN)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Device Name
                  Text(
                    device.manufacturer != null
                        ? (device.deviceModel != null
                            ? '${device.manufacturer} ${device.deviceModel}'
                            : '${device.manufacturer} ${context.l10n.device}')
                        : device.ipAddress,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // IP Address + Badge Row
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
                      // Badge floats left next to IP
                      if (device.knownStatus != DeviceKnownStatus.unknown)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildKnownDeviceBadge(device),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Serial Number
                  Text(
                    'SN: ${device.serialNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // RIGHT: Buttons (vertically stacked)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save/Update Button
                SizedBox(
                  width: 120,
                  child: OutlinedButton.icon(
                    onPressed: saveEnabled
                        ? () => _saveDeviceWithoutConnecting(device, index)
                        : null,
                    icon: Icon(
                      device.knownStatus == DeviceKnownStatus.knownNewIp
                          ? Icons.update
                          : Icons.bookmark_add_outlined,
                      size: 16,
                    ),
                    label: Text(
                      saveLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Connect Button
                SizedBox(
                  width: 120,
                  child: OutlinedButton.icon(
                    onPressed: () => _connectAndOpenDevice(device),
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: Text(context.l10n.connect, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperWideDeviceCard(NetworkDevice device, int index) {
    final saveEnabled = device.knownStatus == DeviceKnownStatus.unknown ||
                        device.knownStatus == DeviceKnownStatus.knownNewIp;
    final saveLabel = device.knownStatus == DeviceKnownStatus.knownNewIp
        ? context.l10n.actionUpdate
        : context.l10n.save;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT: Avatar/Icon
            CircleAvatar(
              backgroundColor: _getDeviceCardColor(device),
              child: Icon(_getDeviceCardIcon(device), color: _getDeviceCardIconColor(device)),
            ),
            const SizedBox(width: 12),
            // MIDDLE: Device info (name + IP/badge + SN)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Device Name
                  Text(
                    device.manufacturer != null
                        ? (device.deviceModel != null
                            ? '${device.manufacturer} ${device.deviceModel}'
                            : '${device.manufacturer} ${context.l10n.device}')
                        : device.ipAddress,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // IP Address + Badge Row
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
                      // Badge floats left next to IP
                      if (device.knownStatus != DeviceKnownStatus.unknown)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildKnownDeviceBadge(device),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Serial Number
                  Text(
                    'SN: ${device.serialNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // RIGHT: Buttons (horizontally side-by-side)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save/Update Button
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: OutlinedButton.icon(
                    onPressed: saveEnabled
                        ? () => _saveDeviceWithoutConnecting(device, index)
                        : null,
                    icon: Icon(
                      device.knownStatus == DeviceKnownStatus.knownNewIp
                          ? Icons.update
                          : Icons.bookmark_add_outlined,
                      size: 16,
                    ),
                    label: Text(
                      saveLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Connect Button
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: OutlinedButton.icon(
                    onPressed: () => _connectAndOpenDevice(device),
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: Text(context.l10n.connect, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              Text(
                context.l10n.noDevicesFound,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.startScanToFindDevices,
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.messageSearchingForKnownDevices,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Show device list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _networkDevices.length,
      itemBuilder: (context, index) {
        final device = _networkDevices[index];
        return _buildDeviceCard(device, index); // Pass index
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.actionAddDevice,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.bluetooth), text: context.l10n.bluetooth),
            Tab(icon: const Icon(Icons.wifi), text: context.l10n.network),
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
                    Text(
                      context.l10n.labelBluetoothDevices,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.helpScanForNearbyDevices,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.bluetooth_searching),
                      label: Text(_isScanning ? context.l10n.messageScanning : context.l10n.actionBluetoothScan),
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
                        loadingMessage: context.l10n.messageConnectingToDevice,
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

          // Network Tab - Fully scrollable
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.labelNetworkDevices,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.helpScanLocalNetwork,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Scanning status or button section
                      if (_isScanningNetwork)
                        SizedBox(
                          height: 104,
                          child: _buildCompactScanStatus(),
                        )
                      else
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: _startNetworkScan,
                                    icon: const Icon(Icons.router),
                                    label: Text(context.l10n.actionNetworkScan),
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
                                    label: Text(context.l10n.actionManual),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade100,
                                      minimumSize: const Size(0, 48),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Advanced scanning options
                            ScanAdvancedOptionsWidget(key: _advancedOptionsKey),
                          ],
                        ),
                    ],
                  ),
                ),
                const Divider(),
                _buildNetworkDevicesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
