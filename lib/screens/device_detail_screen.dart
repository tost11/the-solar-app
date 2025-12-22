import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/device.dart';
import '../models/devices/generic_rendering/device_category_config.dart';
import '../models/devices/generic_rendering/device_control_item.dart';
import '../models/devices/generic_rendering/device_custom_section.dart';
import '../models/devices/generic_rendering/device_data_field.dart';
import '../models/devices/generic_rendering/device_menu_item_context.dart';
import '../services/device_storage_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/cards/device_data_card.dart';
import '../widgets/cards/device_info_card.dart';
import '../widgets/charts/time_series_chart_card.dart';
import '../widgets/controls/device_control_widget.dart';
import '../widgets/device_menu_bottom_sheet.dart';
import '../widgets/headers/connection_status_header.dart';
import '../widgets/layouts/responsive_data_grid.dart';
import '../utils/globals.dart';
import '../utils/message_utils.dart';
import '../utils/responsive_breakpoints.dart';
import 'device_settings_screen.dart';
import 'device_graph_screen.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;
  final bool skipAutoConnect;
  final String? systemId;
  final bool showAppBar;

  const DeviceDetailScreen({
    super.key,
    required this.device,
    this.skipAutoConnect = false,
    this.systemId,
    this.showAppBar = true,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final DeviceStorageService _storageService = DeviceStorageService();

  String _connectionStatus = 'Nicht verbunden';
  Map<String,Map<String,dynamic>> _receivedData =  {};
  bool _isConnecting = false;

  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<Map<String,dynamic>>? _dataSubscription;
  StreamSubscription<String>? _errorSubscription;


  @override
  void initState() {
    super.initState();
    _setupServiceListeners();

    // Only auto-connect if not skipped (e.g., when coming from system view with existing connection)
    if (!widget.skipAutoConnect) {
      _tryAutoConnect();
    }

    // Add listener for expert mode changes
    Globals.expertModeNotifier.addListener(_onExpertModeChanged);
  }

  // Callback when expert mode changes
  void _onExpertModeChanged() {
    if (mounted) {
      setState(() {
        // Rebuild entire screen to update expert mode dependent widgets
      });
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Remove listener to prevent memory leaks
    Globals.expertModeNotifier.removeListener(_onExpertModeChanged);

    _statusSubscription?.cancel();
    _dataSubscription?.cancel();
    _errorSubscription?.cancel();

    // Only disconnect if we initiated the connection
    // If skipAutoConnect was true, the parent screen owns the connection
    if (!widget.skipAutoConnect) {
      widget.device.getServiceConnection()?.dispose();
    }

    super.dispose();
  }

  void _setupServiceListeners() {
    _statusSubscription = widget.device.connectionStatus.listen((status) {
      setState(() => _connectionStatus = status);
    });

    _dataSubscription = widget.device.dataStream.listen((t) {
      setState(() => _receivedData = widget.device.data);//maby some replacemtn for stat update not shure
    });

    _errorSubscription = widget.device.errors.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });
  }

  Future<void> _tryAutoConnect() async {
    if (widget.device.connectionType == ConnectionType.wifi) {
      widget.device.setUpServiceConnection(null);
    }else{
      await _connectBluetoothDevice();
    }
  }

  Future<void> _connectBluetoothDevice() async {
    debugPrint("Connect to specifi bluetooth devic");
    setState(() => _isConnecting = true);

    try {

      //final blueDevice = (widget.device as BluetoothZendureDevice || widget.device as BluetoothShellyDevice );
      // Try to find the device by scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      BluetoothDevice ? foundDevice;

      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          //debugPrint("compare: ${widget.device.deviceSn} found: ${result.device.remoteId.toString()}");
          if (result.device.remoteId.toString() == widget.device.deviceSn) {
            foundDevice = result.device;
            break;
          }
        }
      });

      await Future.delayed(const Duration(seconds: 5));
      await subscription.cancel();
      await FlutterBluePlus.stopScan();

      if (foundDevice != null) {
        setState(() => _isConnecting = true);
        widget.device.setUpServiceConnection(foundDevice);

        // Update last seen
        //TODO fix that
        //await _storageService.updateDeviceLastSeen(widget.device.id);
        // Error handled by service
        setState(() => _isConnecting = false);
      } else {
        setState(() {
          _connectionStatus = 'Gerät nicht gefunden';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Scan-Fehler: $e';
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnectDevice() async {
    widget.device.getServiceConnection()?.disconnect();

    setState(() {
      _connectionStatus = 'Nicht verbunden';
    });
  }

  void _showMoreFunctions(BuildContext screenContext) {
    DeviceMenuBottomSheet.show(
      context: context,
      device: widget.device,
      extraParameters: {'systemId': widget.systemId},
    );
  }

  // Removed: _formatLastSeen - now using TimeFormatUtils.formatLastSeen()
  // Removed: _buildInfoCard - now using DeviceInfoCard widget
  // Removed: _buildDataCard - now using DeviceDataCard widget

  // Removed: _buildControlWidget - now using DeviceControlWidget widget

  /// Shows a dialog with the full field name and value
  void _showFieldDetailDialog(String fieldName, String value, String unit) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(fieldName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wert:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              unit.isNotEmpty ? '$value $unit' : value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  /// Renders custom sections for a specific position
  List<Widget> _buildCustomSections(CustomSectionPosition position, bool isConnected) {
    final sections = widget.device.customSections
        .where((section) => section.position == position)
        .where((section) => !section.requiresConnection || isConnected)
        .toList();

    if (sections.isEmpty) return [];

    return sections.map((section) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          if (section.title != null) ...[
            Text(
              section.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          section.builder(context, widget.device, _receivedData),
        ],
      );
    }).toList();
  }

  /// Build category header with divider
  Widget _buildCategoryHeader(String categoryName) {
    return Row(
      children: [
        Text(
          categoryName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Build grid for a category with specified layout
  Widget _buildCategoryGrid(
    List<DeviceDataField> fields,
    String? category,
    CategoryLayout layout,
  ) {
    switch (layout) {
      case CategoryLayout.standard:
        return _buildStandardGrid(fields);
      case CategoryLayout.oneLine:
        return _buildOneLineLayout(fields);
      case CategoryLayout.singleColumn:
        return _buildSingleColumnGrid(fields);
    }
  }

  /// Responsive grid with adaptive columns (mobile: 2, tablet: 3, desktop: 4)
  Widget _buildStandardGrid(List<DeviceDataField> fields) {
    return ResponsiveDataGrid(
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        final value = field.valueExtractor(_receivedData);
        return DeviceDataCard(
          title: field.name,
          value: field.formatValue(value),
          unit: field.unit,
          icon: field.icon,
          showDetailButton: field.showDetailButton,
          onDetailTap: field.showDetailButton
              ? () => _showFieldDetailDialog(field.name, field.formatValue(value), field.unit)
              : null,
        );
      },
    );
  }

  /// One-line list layout - compact horizontal cards
  Widget _buildOneLineLayout(List<DeviceDataField> fields) {
    return Column(
      children: fields.map((field) {
        final value = field.valueExtractor(_receivedData);
        final formattedValue = field.formatValue(value);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  // Icon
                  if (field.icon != null) ...[
                    Icon(
                      field.icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Field name
                  Expanded(
                    flex: 2,
                    child: Text(
                      field.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Value
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            formattedValue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        if (field.unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            field.unit,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        // Eye icon button
                        if (field.showDetailButton) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showFieldDetailDialog(
                              field.name,
                              formattedValue,
                              field.unit,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.visibility,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Single column layout (PHASE 2)
  Widget _buildSingleColumnGrid(List<DeviceDataField> fields) {
    // TODO: Implement single column layout
    return _buildStandardGrid(fields); // Fallback to standard for now
  }

  /// Check if any field in the list has a non-null, non-empty value
  bool _hasNonEmptyFields(List<DeviceDataField> fields) {
    for (final field in fields) {
      final value = field.valueExtractor(_receivedData);
      if (value != null && value.toString().isNotEmpty && value.toString() != '-') {
        return true;
      }
    }
    return false;
  }

  /// Get sorted list of categories based on configuration
  List<String?> _getSortedCategories(
    Iterable<String?> categories,
    List<DeviceCategoryConfig> configs,
  ) {
    final categoryList = categories.toList();

    // Sort: null (uncategorized) first, then by config order, then alphabetically
    categoryList.sort((a, b) {
      if (a == null) return -1; // Uncategorized always first
      if (b == null) return 1;

      final configA = configs.firstWhere(
        (c) => c.category == a,
        orElse: () => DeviceCategoryConfig(category: a, displayName: a, order: 999),
      );
      final configB = configs.firstWhere(
        (c) => c.category == b,
        orElse: () => DeviceCategoryConfig(category: b, displayName: b, order: 999),
      );

      final orderCompare = configA.order.compareTo(configB.order);
      return orderCompare != 0 ? orderCompare : a.compareTo(b);
    });

    return categoryList;
  }

  /// Get category configuration for a category name
  DeviceCategoryConfig? _getCategoryConfig(
    String category,
    List<DeviceCategoryConfig> configs,
  ) {
    try {
      return configs.firstWhere((c) => c.category == category);
    } catch (_) {
      return null;
    }
  }

  /// Build controls section only
  Widget _buildControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Steuerung',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Build control items
        ...widget.device.controlItems.map((controlItem) {
          final currentValue = controlItem.valueExtractor(_receivedData);
          // Disable if valueExtractor returns null
          final isEnabled = currentValue != null;

          return Card(
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Icon (if provided)
                    if (controlItem.icon != null) ...[
                      Icon(
                        controlItem.icon,
                        size: 24,
                        color: isEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Control name (left side)
                    Expanded(
                      child: Text(
                        controlItem.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isEnabled ? null : Colors.grey,
                        ),
                      ),
                    ),

                    // Control widget (right side)
                    DeviceControlWidget(
                      controlItem: controlItem,
                      device: widget.device,
                      currentValue: currentValue,
                      isEnabled: isEnabled,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Build data fields section only
  Widget _buildDataFieldsSection() {
    // Filter data fields based on expert mode
    final visibleFields = widget.device.dataFields
        .where((field) => !field.expertMode || Globals.expertMode)
        .toList();

    // Group fields by category
    final Map<String?, List<DeviceDataField>> groupedFields = {};
    for (final field in visibleFields) {
      groupedFields.putIfAbsent(field.category, () => []).add(field);
    }

    // Get sorted list of categories
    final sortedCategories = _getSortedCategories(
      groupedFields.keys,
      widget.device.categoryConfigs,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Uncategorized fields first (no heading)
        if (groupedFields.containsKey(null) &&
            _hasNonEmptyFields(groupedFields[null]!))
          _buildCategoryGrid(
            groupedFields[null]!,
            null,
            CategoryLayout.standard,
          ),

        // Categorized fields
        ...sortedCategories.where((cat) => cat != null).map((category) {
          final fields = groupedFields[category]!;

          // Skip category if all fields are empty
          if (!_hasNonEmptyFields(fields)) {
            return const SizedBox.shrink();
          }

          final config = _getCategoryConfig(
            category!,
            widget.device.categoryConfigs,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildCategoryHeader(
                config?.displayName ?? category,
              ),
              const SizedBox(height: 12),
              _buildCategoryGrid(
                fields,
                category,
                config?.layout ?? CategoryLayout.standard,
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build controls and data on left, graphs on right (tablet/desktop WITH graphs)
  Widget _buildControlsDataAndGraphsLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN: Controls + Data (60% width)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Controls section (if any exist)
              if (widget.device.controlItems.isNotEmpty) ...[
                _buildControlsSection(),
                const SizedBox(height: 24),
              ],

              // Data fields below controls
              _buildDataFieldsSection(),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // RIGHT COLUMN: Graphs (40% width)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section header
              Text(
                'Live-Diagramme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Letzte 5 Min | alle 5 Sek',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Graphs vertically stacked
              ...widget.device.timeSeriesFields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TimeSeriesChartCard(field: field),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Build data on left, controls on right (tablet/desktop WITHOUT graphs)
  Widget _buildDataAndControlsLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN: Data fields (70% width)
        Expanded(
          flex: 7,
          child: _buildDataFieldsSection(),
        ),

        const SizedBox(width: 16),

        // RIGHT COLUMN: Controls (30% width)
        Expanded(
          flex: 3,
          child: widget.device.controlItems.isNotEmpty
              ? _buildControlsSection()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Build graphs section (mobile fallback - not currently used)
  Widget _buildGraphsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Text(
          'Live-Diagramme',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Datenbereich: Letzte 5 Minuten | Aktualisierung: alle 5 Sekunden',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Responsive graph grid (tablet: 2 cols, desktop: 3 cols)
        ResponsiveGraphGrid(
          itemCount: widget.device.timeSeriesFields.length,
          itemBuilder: (context, index) {
            return TimeSeriesChartCard(
              field: widget.device.timeSeriesFields[index],
            );
          },
        ),
      ],
    );
  }

  /// Build AppBar actions for device detail screen
  List<Widget> _buildAppBarActions(BuildContext context, bool isConnected) {
    return [
      // Graph icon button (visible when connected and has time series fields)
      if (widget.device.timeSeriesFields.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.show_chart),
          onPressed: isConnected
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceGraphScreen(
                        device: widget.device,
                      ),
                    ),
                  );
                }
              : null,
          tooltip: 'Live-Diagramme',
        ),
      // Functions menu icon (always visible, disabled when not connected)
      IconButton(
        icon: const Icon(Icons.app_registration),
        onPressed: isConnected ? () => _showMoreFunctions(context) : null,
        tooltip: 'Weitere Funktionen',
      ),
      // Settings icon for device configuration
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceSettingsScreen(
                device: widget.device,
              ),
            ),
          );

          // Refresh if settings were changed
          if (result == true) {
            setState(() {
              // Trigger rebuild with updated device name
            });
          }
        },
        tooltip: 'Geräteeinstellungen',
      ),
    ];
  }

  /// Build body content for device detail screen
  Widget _buildBody(BuildContext context, bool isConnected) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom sections before device info
            ..._buildCustomSections(CustomSectionPosition.beforeDeviceInfo, isConnected),

            // Compressed Device Header
            ConnectionStatusHeader(
              deviceName: widget.device.name,
              connectionStatus: _connectionStatus,
              connectionType: widget.device.connectionType,
              isConnected: isConnected,
            ),

            // Custom sections after device info
            ..._buildCustomSections(CustomSectionPosition.afterDeviceInfo, isConnected),

            // Connection Controls
            if (!isConnected && !_isConnecting)
              ElevatedButton.icon(
                onPressed: _tryAutoConnect,
                icon: Icon(widget.device.connectionType == ConnectionType.wifi ? Icons.wifi : Icons.bluetooth_searching),
                label: Text(widget.device.connectionType == ConnectionType.wifi ? 'WiFi verbinden' : 'Bluetooth verbinden'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

            if (_isConnecting)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(widget.device.connectionType == ConnectionType.wifi ? 'Verbinde mit WiFi...' : 'Suche Bluetooth-Gerät...'),
                    ],
                  ),
                ),
              ),

            if (isConnected) ...[
              // Custom sections after connection controls
              ..._buildCustomSections(CustomSectionPosition.afterConnectionControls, isConnected),

              // Custom sections after controls (moved before Live Data section)
              ..._buildCustomSections(CustomSectionPosition.afterControls, isConnected),

              // Live Data Section Header
              Text(
                'Live-Daten',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              if (_receivedData.isNotEmpty) ...[
                // Responsive layout logic
                if (ResponsiveBreakpoints.isMobile(context)) ...[
                  // MOBILE: Vertical stacking (controls -> data)
                  if (widget.device.controlItems.isNotEmpty) ...[
                    _buildControlsSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildDataFieldsSection(),
                ] else if (widget.device.timeSeriesFields.isNotEmpty) ...[
                  // TABLET/DESKTOP WITH GRAPHS: (controls+data) | graphs
                  _buildControlsDataAndGraphsLayout(),
                ] else ...[
                  // TABLET/DESKTOP WITHOUT GRAPHS: data | controls
                  _buildDataAndControlsLayout(),
                ],
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('Warte auf Daten...'),
                  ),
                ),

              // Custom sections after live data
              ..._buildCustomSections(CustomSectionPosition.afterLiveData, isConnected),
            ],
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.device.getServiceConnection()?.isConnected() == true;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop && isConnected) {
          // Disconnect when leaving the screen
          await _disconnectDevice();
        }
      },
      child: widget.showAppBar
          ? AppScaffold(
              appBar: AppBarWidget(
                title: "Geräteansicht",
                actions: _buildAppBarActions(context, isConnected),
              ),
              body: _buildBody(context, isConnected),
            )
          : _buildBody(context, isConnected),
    );
  }
}
