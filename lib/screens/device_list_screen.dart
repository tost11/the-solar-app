import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/device_storage_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';
import 'scan_for_device_screen.dart';
import 'device_detail_screen.dart';
import 'system_list_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DeviceStorageService _storageService = DeviceStorageService();
  List<Device> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final devices = await _storageService.getKnownDevices();
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  Future<void> _deleteDevice(Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät entfernen'),
        content: Text('Möchten Sie "${device.name}" wirklich entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.removeDevice(device.id);
      await _loadDevices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${device.name} wurde entfernt')),
        );
      }
    }
  }

  void _navigateToDevice(Device? device) async {
    Widget destinationScreen;

    if (device != null) {
      // Navigate to device detail screen for existing device
      destinationScreen = DeviceDetailScreen(device: device);
    } else {
      // Navigate to scan screen to add new device
      destinationScreen = ScanForDeviceScreen(preselectedDevice: null);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
    );

    // Reload devices when returning
    if (result == true || result == null) {
      _loadDevices();
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inHours < 1) {
      return 'Vor ${difference.inMinutes} Minuten';
    } else if (difference.inDays < 1) {
      return 'Vor ${difference.inHours} Stunden';
    } else if (difference.inDays < 7) {
      return 'Vor ${difference.inDays} Tagen';
    } else {
      return '${lastSeen.day}.${lastSeen.month}.${lastSeen.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("size of list is: ${_devices}");

    return AppScaffold(
      appBar: AppBarWidget(
        title: _tabController.index == 0 ? 'Meine Geräte' : 'Systeme',
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToDevice(null),
              tooltip: 'Gerät hinzufügen',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}), // Rebuild to update title and actions
          tabs: const [
            Tab(icon: Icon(Icons.devices), text: 'Geräte'),
            Tab(icon: Icon(Icons.dashboard), text: 'Systeme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Devices tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _devices.isEmpty
                  ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.solar_power_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Keine Geräte',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fügen Sie Ihr erstes Gerät hinzu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToDevice(null),
                        icon: const Icon(Icons.add),
                        label: const Text('Gerät hinzufügen'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            device.deviceIcon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          device.name.isEmpty ? 'Zendure Gerät' : device.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (device.deviceSn != null)
                              Text('SN: ${device.deviceSn}'),
                            Row(
                              children: [
                                Icon(
                                  device.connectionType == ConnectionType.bluetooth
                                      ? Icons.bluetooth
                                      : Icons.wifi,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  device.connectionType.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${_formatLastSeen(device.lastSeen)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteDevice(device),
                        ),
                        onTap: () => _navigateToDevice(device),
                      ),
                    );
                  },
                ),

          // System tab
          const SystemListScreen(),
        ],
      ),
    );
  }
}
