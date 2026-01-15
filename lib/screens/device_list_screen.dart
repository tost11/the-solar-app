import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/device.dart';
import '../models/system.dart';
import '../services/device_storage_service.dart';
import '../services/system_storage_service.dart';
import '../utils/device_connection_utils.dart';
import '../utils/responsive_breakpoints.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/device_menu_bottom_sheet.dart';
import '../widgets/empty_states/empty_state_widget.dart';
import '../widgets/list_items/device_list_item.dart';
import '../widgets/layouts/collapsible_sidebar.dart';
import '../widgets/layouts/responsive_master_detail.dart';
import 'scan_for_device_screen.dart';
import 'device_detail_screen.dart';
import 'device_graph_screen.dart';
import 'device_settings_screen.dart';
import 'system_edit_screen.dart';
import 'system_list_screen.dart';

class DeviceListScreen extends StatefulWidget {
  final Device? initialSelectedDevice;

  const DeviceListScreen({
    super.key,
    this.initialSelectedDevice,
  });

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DeviceStorageService _storageService = DeviceStorageService();
  List<Device> _devices = [];
  bool _isLoading = true;
  Device? _selectedDevice; // For master-detail layout
  Device? _selectedDeviceForActions; // For showing actions in AppBar
  int _currentMasterDetailTab = 0; // Track master-detail tab selection
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  // Connection state tracking
  final Map<String, bool> _deviceConnectionStates = {};
  final Map<String, bool> _deviceAutoReconnectStates = {};
  final Map<String, StreamSubscription<String>> _connectionSubscriptions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDevice = widget.initialSelectedDevice;
    _loadDevices();

    // On mobile: Auto-navigate to detail view if initial device provided
    if (widget.initialSelectedDevice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ResponsiveBreakpoints.isMobile(context)) {
          _navigateToDevice(widget.initialSelectedDevice);
        }
      });
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    // Cancel all connection status subscriptions
    for (final subscription in _connectionSubscriptions.values) {
      subscription.cancel();
    }
    _connectionSubscriptions.clear();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final devices = await _storageService.getKnownDevices();
    setState(() {
      _devices = devices;

      // Update selected device reference to newly loaded instance
      if (_selectedDevice != null) {
        try {
          _selectedDevice = devices.firstWhere(
            (d) => d.id == _selectedDevice!.id,
          );
          // Also update _selectedDeviceForActions if it matches
          if (_selectedDeviceForActions?.id == _selectedDevice?.id) {
            _selectedDeviceForActions = _selectedDevice;
          }
        } catch (e) {
          // Device not found in reload - clear selection
          _selectedDevice = null;
          _selectedDeviceForActions = null;
        }
      }

      _isLoading = false;
    });

    // Setup connection listeners for newly loaded devices
    _setupConnectionListeners();
  }

  void _setupConnectionListeners() {
    for (final device in _devices) {
      _listenToDeviceConnection(device);
    }
  }

  void _listenToDeviceConnection(Device device) {
    // Cancel existing subscription if any
    _connectionSubscriptions[device.id]?.cancel();

    // Listen to connection status changes
    _connectionSubscriptions[device.id] = device.connectionStatus.listen((status) {
      if (mounted) {
        setState(() {
          _deviceConnectionStates[device.id] = device.getServiceConnection()?.isConnected() ?? false;
          _deviceAutoReconnectStates[device.id] = device.getServiceConnection()?.autoReconnect ?? false;
        });
      }
    });

    // Set initial connection and auto-reconnect state
    _deviceConnectionStates[device.id] = device.getServiceConnection()?.isConnected() ?? false;
    _deviceAutoReconnectStates[device.id] = device.getServiceConnection()?.autoReconnect ?? false;
  }

  void _setupDeviceDataListener() {
    // Cancel existing subscription
    _dataSubscription?.cancel();

    // Setup new subscription if device is selected
    if (_selectedDeviceForActions != null) {
      _dataSubscription = _selectedDeviceForActions!.dataStream.listen((data) {
        setState(() {
          // Force rebuild to update graph icon visibility
        });
      });
    }
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

      // Clear selected device if it was deleted
      if (_selectedDevice?.id == device.id) {
        setState(() {
          _selectedDevice = null;
          _selectedDeviceForActions = null;
        });
      }

      await _loadDevices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${device.name} wurde entfernt')),
        );
      }
    }
  }

  Future<void> _connectDevice(Device device) async {
    await DeviceConnectionUtils.connectDevice(context, device);
  }

  Future<void> _disconnectDevice(Device device) async {
    await DeviceConnectionUtils.disconnectDevice(context, device);
  }

  void _showDeviceMoreFunctions(BuildContext context, Device device) {
    // Show device functions menu using reusable widget
    DeviceMenuBottomSheet.show(
      context: context,
      device: device,
      // No systemId in device_list_screen context
    );
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

    // Handle returned device from scan screen
    if (result is Device) {
      // New device was added - reload and select it
      await _loadDevices();
      if (mounted) {
        setState(() {
          _selectedDevice = _devices.firstWhere(
            (d) => d.id == result.id,
            orElse: () => result,
          );
        });

        // On mobile: navigate to the device detail screen
        if (ResponsiveBreakpoints.isMobile(context)) {
          _navigateToDevice(_selectedDevice);
        }
      }
    } else if (result == true) {
      // Generic reload signal
      await _loadDevices();
    }
  }

  // Removed: _formatLastSeen - now using TimeFormatUtils.formatLastSeen()

  void _navigateToSystem() async {
    final name = await _showSystemNameDialog();
    if (name == null || name.isEmpty) return;

    final newSystem = System(
      id: const Uuid().v4(),
      name: name,
      deviceReferences: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final storageService = SystemStorageService();
    await storageService.saveSystem(newSystem);

    // Navigate to edit screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SystemEditScreen(system: newSystem),
        ),
      );
      // Trigger refresh if needed
      setState(() {});
    }
  }

  Future<String?> _showSystemNameDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues System erstellen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'System-Name',
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Mobile: Use traditional tab bar layout
    if (ResponsiveBreakpoints.isMobile(context)) {
      return _buildMobileLayout();
    }

    // Tablet/Desktop: Use master-detail split-screen layout
    return _buildMasterDetailLayout();
  }

  /// Build traditional mobile layout with TabBar
  Widget _buildMobileLayout() {
    return AppScaffold(
      appBar: AppBarWidget(
        title: _tabController.index == 0 ? 'Meine Geräte' : 'Systeme',
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(icon: Icon(Icons.devices), text: 'Geräte'),
            Tab(icon: Icon(Icons.dashboard), text: 'Systeme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeviceListView(true), // Mobile: navigates on tap
          const SystemListScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Build master-detail layout for tablet/desktop
  Widget _buildMasterDetailLayout() {
    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Meine Geräte',
        actions: [
          // Device-specific actions (when device is selected)
          if (_selectedDeviceForActions != null) ...[
            // Graph icon
            if (_selectedDeviceForActions!.timeSeriesFields.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.show_chart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceGraphScreen(
                        device: _selectedDeviceForActions!,
                      ),
                    ),
                  );
                },
                tooltip: 'Live-Diagramme',
              ),
            // Functions menu icon
            IconButton(
              icon: const Icon(Icons.app_registration),
              onPressed: () => _showDeviceMoreFunctions(context, _selectedDeviceForActions!),
              tooltip: 'Weitere Funktionen',
            ),
            // Settings icon
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSettingsScreen(
                      device: _selectedDeviceForActions!,
                    ),
                  ),
                );
                if (result == true) {
                  setState(() {});
                  _loadDevices();
                }
              },
              tooltip: 'Geräteeinstellungen',
            ),
            // Divider between device actions and general actions
            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: ResponsiveMasterDetail<Device>(
        initialSelectedItem: _selectedDevice,
        tabs: const [
          SidebarTab(label: 'Geräte', icon: Icons.devices),
          SidebarTab(label: 'Systeme', icon: Icons.dashboard),
        ],
        masterBuilder: (context, tabIndex, isExpanded, onItemSelected) {
          // Track tab changes
          if (_currentMasterDetailTab != tabIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentMasterDetailTab = tabIndex;
                });
              }
            });
          }

          Widget listContent;
          if (tabIndex == 0) {
            // Devices tab
            listContent = _buildDeviceListView(false, onItemSelected: onItemSelected, isExpanded: isExpanded);
          } else {
            // Systems tab
            listContent = SystemListScreen(isExpanded: isExpanded);
          }

          // Wrap content with bottom bar for master-detail layout
          return Column(
            children: [
              Expanded(child: listContent),
              _buildSidebarBottomBar(isExpanded),
            ],
          );
        },
        detailBuilder: (context, selectedDevice) {
          // Update selected device for actions
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedDeviceForActions != selectedDevice) {
              setState(() {
                _selectedDeviceForActions = selectedDevice;
              });
              _setupDeviceDataListener();
            }
          });

          if (selectedDevice != null) {
            return DeviceDetailScreen(
              device: selectedDevice,
              skipAutoConnect: false,
              showAppBar: false, // Hide AppBar in master-detail layout
            );
          }
          return _buildEmptyDetailView();
        },
        emptyDetailWidget: _buildEmptyDetailView(),
      ),
    );
  }

  /// Build device list view (used in both mobile and master-detail)
  Widget _buildDeviceListView(
    bool isMobile, {
    void Function(Device)? onItemSelected,
    bool isExpanded = true,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_devices.isEmpty) {
      // Show empty state only when expanded
      if (isExpanded) {
        return EmptyStateWidget(
          icon: Icons.solar_power_outlined,
          title: 'Keine Geräte',
          message: 'Fügen Sie Ihr erstes Gerät hinzu',
          actionLabel: 'Gerät hinzufügen',
          onActionPressed: () => _navigateToDevice(null),
        );
      } else {
        // When collapsed and empty, show nothing
        return const SizedBox.shrink();
      }
    }

    // Icon-only view when collapsed
    if (!isExpanded) {
      return ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          final isSelected = _selectedDevice?.id == device.id;

          return Tooltip(
            message: device.name.isEmpty ? 'Gerät' : device.name,
            child: Container(
              height: 48, // Fixed height for icon button
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    device.deviceIcon,
                    size: 24,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  onPressed: () {
                    // Update local state for highlighting, then notify parent
                    setState(() {
                      _selectedDevice = device;
                    });
                    onItemSelected?.call(device);
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    // Full list view when expanded
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        final isSelected = !isMobile && _selectedDevice?.id == device.id;

        return Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: DeviceListItem(
            device: device,
            isConnected: _deviceConnectionStates[device.id] ?? false,
            isAutoReconnecting: _deviceAutoReconnectStates[device.id] ?? false,
            onTap: () {
              if (isMobile) {
                _navigateToDevice(device);
              } else {
                // Update local state for highlighting, then notify parent
                setState(() {
                  _selectedDevice = device;
                });
                onItemSelected?.call(device);
              }
            },
            onDelete: () => _deleteDevice(device),
            onConnect: () => _connectDevice(device),
            onDisconnect: () => _disconnectDevice(device),
          ),
        );
      },
    );
  }

  /// Build empty detail view for master-detail layout
  Widget _buildEmptyDetailView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Kein Gerät ausgewählt',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wählen Sie ein Gerät aus der Liste',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom bar with context-aware add button (mobile layout)
  Widget _buildBottomBar() {
    final currentTab = _tabController.index;
    final isDevicesTab = currentTab == 0;
    final buttonText = isDevicesTab ? 'Gerät hinzufügen' : 'System hinzufügen';
    final buttonAction = isDevicesTab
        ? () => _navigateToDevice(null)
        : () => _navigateToSystem();

    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: buttonAction,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build bottom bar for sidebar (master-detail layout)
  Widget _buildSidebarBottomBar(bool isExpanded) {
    final isDevicesTab = _currentMasterDetailTab == 0;
    final buttonText = isDevicesTab ? 'Gerät hinzufügen' : 'System hinzufügen';
    final tooltipText = isDevicesTab ? 'Gerät hinzufügen' : 'System hinzufügen';
    final buttonAction = isDevicesTab
        ? () => _navigateToDevice(null)
        : () => _navigateToSystem();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: isExpanded
          ? ElevatedButton.icon(
              onPressed: buttonAction,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: const Size(double.infinity, 44),
              ),
            )
          : Center(
              child: Tooltip(
                message: tooltipText,
                child: IconButton(
                  onPressed: buttonAction,
                  icon: const Icon(Icons.add),
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
    );
  }
}
