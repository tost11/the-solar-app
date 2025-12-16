import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/models/system.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import 'package:the_solar_app/services/system_aggregator_service.dart';
import 'package:the_solar_app/screens/device_detail_screen.dart';
import 'package:the_solar_app/screens/system_edit_screen.dart';
import 'package:the_solar_app/utils/bluetooth_connection_utils.dart';
import 'package:the_solar_app/widgets/system_metric_card.dart';

/// System detail screen showing aggregated metrics for ONE system
///
/// Receives a System parameter and shows only devices in that system.
class SystemDetailScreen extends StatefulWidget {
  final System system;

  const SystemDetailScreen({
    super.key,
    required this.system,
  });

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  final SystemAggregatorService _aggregator = SystemAggregatorService();
  final DeviceStorageService _deviceStorage = DeviceStorageService();
  List<DeviceBase> _allDevices = [];
  final List<StreamSubscription> _subscriptions = [];
  bool _isLoading = true;
  Timer? _connectionRetryTimer;
  static const _retryInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _stopConnectionRetryTimer();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _disconnectDevices();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    try {
      final devices = await _deviceStorage.getKnownDevices();
      setState(() {
        _allDevices = devices;
        _isLoading = false;
      });

      _subscribeToDeviceUpdates();
      await _connectDevices();
      _startConnectionRetryTimer();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToDeviceUpdates() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Only subscribe to devices in THIS system
    final deviceSnsInSystem = widget.system.deviceSerialNumbers.toSet();
    final devicesInSystem = _allDevices.where(
      (d) => deviceSnsInSystem.contains(d.deviceSn),
    );

    for (final device in devicesInSystem) {
      final subscription = device.dataStream.listen((_) {
        if (mounted) setState(() {});
      });
      _subscriptions.add(subscription);
    }
  }

  Future<void> _connectDevices() async {
    // Get devices in this system
    final deviceSnsInSystem = widget.system.deviceSerialNumbers.toSet();
    final devicesInSystem = _allDevices.where(
      (d) => deviceSnsInSystem.contains(d.deviceSn),
    ).toList();

    // Separate WiFi and Bluetooth devices
    final wifiDevices = devicesInSystem.where(
      (d) => d.connectionType == ConnectionType.wifi,
    );
    final bluetoothDevices = devicesInSystem.where(
      (d) => d.connectionType == ConnectionType.bluetooth,
    ).toList();

    // Connect WiFi devices immediately
    for (final device in wifiDevices) {
      try {
        device.setUpServiceConnection(null);
      } catch (e) {
        debugPrint('Failed to connect to WiFi device ${device.name}: $e');
      }
    }

    // Scan and connect Bluetooth devices in batch (more efficient)
    if (bluetoothDevices.isNotEmpty) {
      await _connectBluetoothDevices(bluetoothDevices);
    }
  }

  Future<void> _connectBluetoothDevices(List<DeviceBase> bluetoothDevices) async {
    // Filter to only devices that are not currently connected
    final disconnectedDevices = bluetoothDevices.where((device) {
      final service = device.getServiceConnection();
      return service == null || !service.isConnected();
    }).toList();

    if (disconnectedDevices.isEmpty) return;

    debugPrint('Trying to connect ${disconnectedDevices.length} Bluetooth devices...');
    await BluetoothConnectionUtils.scanAndConnectMultiple(disconnectedDevices);
  }

  void _startConnectionRetryTimer() {
    _connectionRetryTimer?.cancel();
    _connectionRetryTimer = Timer.periodic(_retryInterval, (_) async {
      if (!mounted) return;

      // Get Bluetooth devices in this system
      final deviceSnsInSystem = widget.system.deviceSerialNumbers.toSet();
      final bluetoothDevices = _allDevices.where((d) {
        return deviceSnsInSystem.contains(d.deviceSn) &&
               d.connectionType == ConnectionType.bluetooth;
      }).toList();

      if (bluetoothDevices.isNotEmpty) {
        await _connectBluetoothDevices(bluetoothDevices);
      }
    });
  }

  void _stopConnectionRetryTimer() {
    _connectionRetryTimer?.cancel();
    _connectionRetryTimer = null;
  }

  void _disconnectDevices() {
    final deviceSnsInSystem = widget.system.deviceSerialNumbers.toSet();
    final devicesInSystem = _allDevices.where(
      (d) => deviceSnsInSystem.contains(d.deviceSn),
    );

    for (final device in devicesInSystem) {
      try {
        device.getServiceConnection()?.dispose();
      } catch (e) {
        debugPrint('Error disconnecting device ${device.name}: $e');
      }
    }
  }

  Future<void> _editSystem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SystemEditScreen(system: widget.system),
      ),
    );

    if (result == true) {
      await _loadDevices();
    }
  }

  Future<void> _refreshDevices() async {
    await _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.system.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Aggregate ONLY devices in this system
    final metrics = _aggregator.aggregateSystem(widget.system, _allDevices);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.system.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editSystem,
            tooltip: 'System bearbeiten',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDevices,
        child: widget.system.deviceReferences.isEmpty
            ? _buildEmptyState(theme)
            : _buildSystemView(metrics, theme),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.devices_other,
          size: 80,
          color: theme.colorScheme.secondary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Keine Geräte im System',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Fügen Sie Geräte hinzu, um Metriken zu sehen.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: _editSystem,
            icon: const Icon(Icons.add),
            label: const Text('Geräte hinzufügen'),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemView(SystemMetrics metrics, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        // System status indicator
        if (metrics.activeDeviceCount == 0)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keine aktiven Geräte mit Daten',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Metric cards
        SystemMetricCard(
          title: 'Solar-Produktion',
          value: metrics.totalSolarPower,
          unit: 'W',
          icon: Icons.wb_sunny,
          color: Colors.orange,
        ),
        SystemMetricCard(
          title: 'Solar ins Netz',
          value: metrics.totalSolarGridPower,
          unit: 'W',
          icon: Icons.grid_4x4,
          color: Colors.amber,
        ),
        SystemMetricCard(
          title: 'Batterie',
          value: metrics.totalBatteryPower,
          secondaryValue: metrics.averageBatterySOC,
          unit: 'W',
          secondaryUnit: '%',
          icon: Icons.battery_charging_full,
          color: Colors.green,
        ),
        SystemMetricCard(
          title: 'Netz',
          value: metrics.totalGridPower,
          unit: 'W',
          icon: Icons.electric_bolt,
          color: (metrics.totalGridPower != null && metrics.totalGridPower! < 0)
              ? Colors.green
              : Colors.red,
        ),
        SystemMetricCard(
          title: 'Verbraucher',
          value: metrics.totalLoadPower,
          unit: 'W',
          icon: Icons.power,
          color: Colors.purple,
        ),
        SystemMetricCard(
          title: 'Zusätzliche Last',
          value: metrics.totalAdditionalLoadPower,
          unit: 'W',
          icon: Icons.power_settings_new,
          color: Colors.deepPurple,
        ),

        const SizedBox(height: 8),

        // Device list for this system
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            leading: Icon(
              Icons.devices,
              color: theme.colorScheme.primary,
            ),
            title: Text('Geräte (${metrics.deviceCount})'),
            subtitle: Text(
              '${metrics.activeDeviceCount} aktiv',
              style: theme.textTheme.bodySmall,
            ),
            initiallyExpanded: true,
            children: widget.system.deviceReferences.map((ref) {
              DeviceBase? device;
              try {
                device = _allDevices.firstWhere(
                  (d) => d.deviceSn == ref.deviceSn,
                );
              } catch (e) {
                // Device not found
              }
              if (device == null) {
                return ListTile(
                  title: Text('Gerät ${ref.deviceSn} nicht gefunden'),
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                );
              }
              return ListTile(
                leading: Icon(device.deviceIcon),
                title: Text(device.name),
                subtitle: Text('Rollen: ${ref.rolesInSystem.map((r) => r.displayName).join(', ')}'),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Gerät inspizieren',
                  onPressed: () => _navigateToDeviceDetail(device!),
                ),
              );
            }).toList(),
          ),
        ),

        // Last updated timestamp
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Aktualisiert: ${_formatTimestamp(metrics.timestamp)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 5) {
      return 'Gerade eben';
    } else if (diff.inSeconds < 60) {
      return 'vor ${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return 'vor ${diff.inMinutes}m';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} Uhr';
    }
  }

  /// Navigate to device detail screen with existing connection
  Future<void> _navigateToDeviceDetail(DeviceBase device) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailScreen(
          device: device,
          skipAutoConnect: true,  // Reuse existing connection from system
          systemId: widget.system.id,  // Pass system ID for automation filtering
        ),
      ),
    );

    // Refresh UI when returning (device data may have changed)
    if (mounted) {
      setState(() {});
    }
  }
}
