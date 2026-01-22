import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/device.dart';
import '../models/devices/device_base.dart';  // For DeviceError class
import '../models/devices/generic_rendering/device_category_config.dart';
import '../models/devices/generic_rendering/device_control_item.dart';
import '../models/devices/generic_rendering/device_custom_section.dart';
import '../models/devices/generic_rendering/device_data_field.dart';
import '../models/devices/generic_rendering/device_menu_item_context.dart';
import '../models/devices/time_series_field_config.dart';
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
import '../utils/device_connection_utils.dart';
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

  String _connectionStatus = '';  // Will be set in initState()
  Map<String,Map<String,dynamic>> _receivedData =  {};
  bool _isConnecting = false;
  bool _isAutoReconnecting = false;  // Track auto-reconnect state
  int _visibleTimeSeriesCount = 0;  // Cached count of visible time series fields

  // Error footer state
  String? _lastErrorMessage;  // Current error message (null if no error)
  DateTime? _lastErrorTimestamp;  // When the error occurred
  Timer? _errorDismissTimer;  // Timer to auto-dismiss error after 10 seconds

  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<Map<String,dynamic>>? _dataSubscription;
  StreamSubscription<DeviceError>? _errorSubscription;


  @override
  void initState() {
    super.initState();

    // Check connection and initialization state
    final service = widget.device.getServiceConnection();
    final isConnected = service?.isConnected() ?? false;
    final isInitialized = service?.isInitialized ?? false;

    // Determine initial status
    if (!isConnected) {
      _connectionStatus = 'Nicht verbunden';
      _isAutoReconnecting = service?.autoReconnect ?? false;
    } else if (!isInitialized) {
      _connectionStatus = 'Lade Gerätedaten...';
    } else {
      _connectionStatus = 'Verbunden';
    }

    // Load cached data if device is already initialized
    if (isConnected && isInitialized) {
      final cachedData = widget.device.data;
      if (cachedData.isNotEmpty) {
        _receivedData = cachedData;
      }
    }

    // Setup stream subscriptions
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
        // Update cached count when expert mode changes
        _visibleTimeSeriesCount = _getVisibleTimeSeriesFields().length;
      });
    }
  }

  @override
  void didUpdateWidget(DeviceDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Device changed - need to reset everything
    if (oldWidget.device.id != widget.device.id) {
      debugPrint('[DeviceDetailScreen] Device changed from ${oldWidget.device.name} to ${widget.device.name}');

      // 1. Cancel old device's stream subscriptions
      _statusSubscription?.cancel();
      _dataSubscription?.cancel();
      _errorSubscription?.cancel();

      // 2. Check connection and initialization state FIRST
      final service = widget.device.getServiceConnection();
      final isConnected = service?.isConnected() ?? false;
      final isInitialized = service?.isInitialized ?? false;

      // 3. Determine initial status based on connection and initialization state
      String initialStatus;
      if (!isConnected) {
        initialStatus = 'Nicht verbunden';
      } else if (!isInitialized) {
        initialStatus = 'Lade Gerätedaten...';
      } else {
        initialStatus = 'Verbunden';
      }

      // 4. Reset local state (load cached data if device is initialized)
      setState(() {
        // Initialize status based on actual connection state
        _connectionStatus = initialStatus;

        // If device is initialized, load existing data. Otherwise reset to empty.
        if (isConnected && isInitialized) {
          final cachedData = widget.device.data['data'];
          if (cachedData is Map<String, Map<String, dynamic>>) {
            _receivedData = cachedData;
          } else {
            _receivedData = {};
          }
        } else {
          _receivedData = {};
        }

        _isConnecting = false;
        _isAutoReconnecting = !isConnected && (service?.autoReconnect ?? false);
        _visibleTimeSeriesCount = 0;

        // Reset error state
        _lastErrorMessage = null;
        _lastErrorTimestamp = null;
      });

      // Cancel error timer
      _errorDismissTimer?.cancel();

      // 5. DO NOT disconnect old device - let user manage connections explicitly
      // Users can now connect/disconnect devices from the list view
      // This allows multiple devices to stay connected while switching views

      // 6. Setup new device's stream subscriptions
      _setupServiceListeners();

      // 7. Auto-connect to new device if enabled
      if (!widget.skipAutoConnect) {
        _tryAutoConnect();
      }
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Remove listener to prevent memory leaks
    Globals.expertModeNotifier.removeListener(_onExpertModeChanged);

    _statusSubscription?.cancel();
    _dataSubscription?.cancel();
    _errorSubscription?.cancel();

    // Cancel error dismiss timer
    _errorDismissTimer?.cancel();

    // Don't dispose service connection when screen closes
    // Connections persist across navigation and are managed explicitly by user
    // via disconnect button or device list controls

    super.dispose();
  }

  void _setupServiceListeners() {
    // Cancel any existing subscriptions first (defensive)
    _statusSubscription?.cancel();
    _dataSubscription?.cancel();
    _errorSubscription?.cancel();

    // Setup new subscriptions
    _statusSubscription = widget.device.connectionStatus.listen((status) {
      if (mounted) {
        setState(() {
          _connectionStatus = status;
          // Update auto-reconnect state
          final service = widget.device.getServiceConnection();
          final isConnected = service?.isConnected() ?? false;
          _isAutoReconnecting = !isConnected && (service?.autoReconnect ?? false);
        });
      }
    });

    _dataSubscription = widget.device.dataStream.listen((t) {
      if (mounted) {
        setState(() {
          _receivedData = widget.device.data;
          // Update cached visible time series count
          _visibleTimeSeriesCount = _getVisibleTimeSeriesFields().length;
        });
      }
    });

    _errorSubscription = widget.device.errors.listen((error) {
      if (mounted) {
        _handleDeviceError(error);
      }
    });
  }

  /// Handle device errors - route based on isBackgroundError flag
  void _handleDeviceError(DeviceError error) {
    // ROUTING LOGIC:
    // - isBackgroundError == true → Show in detail screen footer (connection errors)
    // - isBackgroundError == false → Show in global overlay (command errors)

    if (error.isBackgroundError) {
      // Background/connection errors → Footer (10-second persistence)
      setState(() {
        _lastErrorMessage = error.message;
        _lastErrorTimestamp = error.timestamp;
      });

      // Cancel existing timer
      _errorDismissTimer?.cancel();

      // Auto-dismiss after 10 seconds
      _errorDismissTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _lastErrorMessage = null;
            _lastErrorTimestamp = null;
          });
        }
      });
    } else {
      // Foreground/command errors → Global overlay (immediate feedback)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Check if error should be displayed (occurred within last 10 seconds)
  bool _shouldShowError() {
    if (_lastErrorMessage == null || _lastErrorTimestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final diff = now.difference(_lastErrorTimestamp!);
    return diff.inSeconds < 10;
  }

  Future<void> _tryAutoConnect() async {
    await DeviceConnectionUtils.connectDevice(context, widget.device, showMessages: false);
  }

  Future<void> _disconnectDevice() async {
    await DeviceConnectionUtils.disconnectDevice(context, widget.device, showMessages: false);

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
    // Filter out fields with hideIfEmpty=true and null values
    final visibleFields = fields.where((field) {
      if (!field.hideIfEmpty) return true;
      final value = field.valueExtractor(_receivedData);
      return value != null;
    }).toList();

    return ResponsiveDataGrid(
      itemCount: visibleFields.length,
      itemBuilder: (context, index) {
        final field = visibleFields[index];
        final value = field.valueExtractor(_receivedData);
        return DeviceDataCard(
          title: field.name,
          value: field.formatValue(value),
          unit: field.getUnit(value),
          icon: field.icon,
          showDetailButton: field.showDetailButton,
          onDetailTap: field.showDetailButton
              ? () => _showFieldDetailDialog(field.name, field.formatValue(value), field.getUnit(value))
              : null,
        );
      },
    );
  }

  /// One-line list layout - compact horizontal cards
  Widget _buildOneLineLayout(List<DeviceDataField> fields) {
    // Filter out fields with hideIfEmpty=true and null values
    final visibleFields = fields.where((field) {
      if (!field.hideIfEmpty) return true;
      final value = field.valueExtractor(_receivedData);
      return value != null;
    }).toList();

    return Column(
      children: visibleFields.map((field) {
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
                        if (field.getUnit(value).isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            field.getUnit(value),
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
                              field.getUnit(value),
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

  /// Check if category should be visible based on field values and category config
  bool _shouldShowCategory(List<DeviceDataField> fields, DeviceCategoryConfig? config) {
    // Extract configuration (use defaults if not specified)
    final hideWhenAllNull = config?.hideWhenAllNull ?? false;
    final hideWhenAllZero = config?.hideWhenAllZero ?? false;

    bool hasNonNullValue = false;
    bool hasNonZeroValue = false;

    for (final field in fields) {
      final value = field.valueExtractor(_receivedData);

      // Check for non-null values
      if (value != null && value.toString().isNotEmpty && value.toString() != '-') {
        hasNonNullValue = true;

        // Check for non-zero values
        if (value is num) {
          if (value.abs() > 0.0) {
            hasNonZeroValue = true;
            break; // Found a non-zero value, can stop checking
          }
        } else {
          // Non-numeric values are considered "non-zero"
          final numValue = num.tryParse(value.toString());
          if (numValue == null || numValue.abs() > 0.0) {
            hasNonZeroValue = true;
            break;
          }
        }
      }
    }

    // Apply filtering logic based on configuration
    if (hideWhenAllNull && !hasNonNullValue) {
      return false; // Hide: all values are null/empty
    }

    if (hideWhenAllZero && !hasNonZeroValue) {
      return false; // Hide: all values are zero
    }

    return true; // Show the category
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

  /// Get time series fields visible based on expert mode
  List<TimeSeriesFieldConfig> _getVisibleTimeSeriesFields() {
    return widget.device.timeSeriesFields
        .where((field) => !field.expertMode || Globals.expertMode)
        .where((field) {
          if (!field.hideIfEmpty) return true;
          return field.values.isNotEmpty;
        })
        .toList();
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
        if (groupedFields.containsKey(null)) ...[
          if (_shouldShowCategory(groupedFields[null]!, null))
            _buildCategoryGrid(
              groupedFields[null]!,
              null,
              CategoryLayout.standard,
            ),
        ],

        // Categorized fields
        ...sortedCategories.where((cat) => cat != null).map((category) {
          final fields = groupedFields[category]!;

          final config = _getCategoryConfig(
            category!,
            widget.device.categoryConfigs,
          );

          // Check if category should be shown based on config
          if (!_shouldShowCategory(fields, config)) {
            return const SizedBox.shrink();
          }

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

              // Graphs vertically stacked (filtered by expert mode)
              ..._getVisibleTimeSeriesFields().map((field) {
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

        // Responsive graph grid (tablet: 2 cols, desktop: 3 cols) - filtered by expert mode
        Builder(
          builder: (context) {
            final visibleGraphs = _getVisibleTimeSeriesFields();
            return ResponsiveGraphGrid(
              itemCount: visibleGraphs.length,
              itemBuilder: (context, index) {
                return TimeSeriesChartCard(
                  field: visibleGraphs[index],
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Build static error footer if error should be displayed
  Widget? _buildErrorFooter() {
    // Only show if error is recent (within 10 seconds)
    if (!_shouldShowError()) {
      return null;
    }

    return Container(
      width: double.infinity,  // Full width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.shade100,  // More prominent background
        border: Border(
          top: BorderSide(color: Colors.red.shade400, width: 2),  // Top border for separation
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),  // Shadow above footer
          ),
        ],
      ),
      child: SafeArea(
        top: false,  // Don't apply safe area to top
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error icon
            Icon(
              Icons.error_outline,
              color: Colors.red.shade800,
              size: 22,
            ),
            const SizedBox(width: 12),

            // Error message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Fehler',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastErrorMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),

            // Dismiss button
            InkWell(
              onTap: () {
                setState(() {
                  _lastErrorMessage = null;
                  _lastErrorTimestamp = null;
                });
                _errorDismissTimer?.cancel();
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  color: Colors.red.shade800,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build AppBar actions for device detail screen
  List<Widget> _buildAppBarActions(BuildContext context, bool isConnected) {
    return [
      // Graph icon button (visible when connected and has visible time series fields)
      // Use cached count to ensure proper rebuild when fields are populated
      if (_visibleTimeSeriesCount > 0)
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
    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
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
              isAutoReconnecting: _isAutoReconnecting,
            ),

            // Custom sections after device info
            ..._buildCustomSections(CustomSectionPosition.afterDeviceInfo, isConnected),

            // Connection Controls
            if (!_isConnecting) ...[
              // Show AutoReconnect status when disconnected
              if (!isConnected && widget.device.getServiceConnection()?.autoReconnect == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Auto-Verbindung aktiviert - Versucht automatisch zu verbinden',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stop auto-reconnect button
                        ElevatedButton.icon(
                          onPressed: _disconnectDevice,
                          icon: const Icon(Icons.stop, size: 16),
                          label: const Text('Stoppen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade100,
                            foregroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Disconnect button (when connected)
              if (isConnected)
                ElevatedButton.icon(
                  onPressed: _disconnectDevice,
                  icon: Icon(
                    widget.device.connectionType == ConnectionType.wifi
                      ? Icons.wifi_off
                      : Icons.bluetooth_disabled,
                  ),
                  label: Text(
                    widget.device.connectionType == ConnectionType.wifi
                      ? 'WiFi trennen'
                      : 'Bluetooth trennen',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                )
              // Connect button (when not connected)
              else
                ElevatedButton.icon(
                  onPressed: _tryAutoConnect,
                  icon: Icon(
                    widget.device.connectionType == ConnectionType.wifi
                      ? Icons.wifi
                      : Icons.bluetooth_searching,
                  ),
                  label: Text(
                    widget.device.connectionType == ConnectionType.wifi
                      ? 'WiFi verbinden'
                      : 'Bluetooth verbinden',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
            ],

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
                ] else if (_visibleTimeSeriesCount > 0) ...[
                  // TABLET/DESKTOP WITH GRAPHS: (controls+data) | graphs
                  _buildControlsDataAndGraphsLayout(),
                ] else if (widget.device.controlItems.isNotEmpty) ...[
                  // TABLET/DESKTOP WITHOUT GRAPHS BUT WITH CONTROLS: data | controls
                  _buildDataAndControlsLayout(),
                ] else ...[
                  // TABLET/DESKTOP WITHOUT GRAPHS AND WITHOUT CONTROLS: full-width data
                  _buildDataFieldsSection(),
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
          ),
        ),

        // Static error footer at bottom (outside scroll area)
        if (_buildErrorFooter() != null) _buildErrorFooter()!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.device.getServiceConnection()?.isConnected() == true;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        // Don't auto-disconnect when leaving screen
        // Users can manage connections explicitly via disconnect button or device list
        // This allows seamless switching between device detail views without reconnecting
      },
      child: widget.showAppBar
          ? AppScaffold(
              appBar: AppBarWidget(
                key: ValueKey('appbar_$_visibleTimeSeriesCount'),  // Force rebuild when count changes
                title: "Geräteansicht",
                actions: _buildAppBarActions(context, isConnected),
              ),
              body: _buildBody(context, isConnected),
            )
          : _buildBody(context, isConnected),
    );
  }
}
