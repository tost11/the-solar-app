import 'package:flutter/material.dart';
import '../utils/net_utils.dart';

/// Expandable widget for advanced network scanning options
class ScanAdvancedOptionsWidget extends StatefulWidget {
  const ScanAdvancedOptionsWidget({super.key});

  @override
  State<ScanAdvancedOptionsWidget> createState() => ScanAdvancedOptionsWidgetState();
}

class ScanAdvancedOptionsWidgetState extends State<ScanAdvancedOptionsWidget> {
  // Expansion state
  bool _isExpanded = false;

  // Network interface selection
  String? _selectedInterfaceName; // null = Auto mode
  String? _selectedIpAddress;
  List<NetworkInterfaceInfo> _availableInterfaces = [];
  bool _isLoadingInterfaces = false;

  // Fast scanning toggle
  bool _useFastScanning = true;

  // Timeout controllers
  final TextEditingController _icmpTimeoutController = TextEditingController(text: '2');
  final TextEditingController _deviceTimeoutController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    _loadNetworkInterfaces();
  }

  @override
  void dispose() {
    _icmpTimeoutController.dispose();
    _deviceTimeoutController.dispose();
    super.dispose();
  }

  /// Load available network interfaces
  Future<void> _loadNetworkInterfaces() async {
    if (mounted) {
      setState(() {
        _isLoadingInterfaces = true;
      });
    }

    try {
      final interfaces = await NetUtils.getNetworkInterfaceList();
      if (mounted) {
        setState(() {
          _availableInterfaces = interfaces;
          _isLoadingInterfaces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInterfaces = false;
        });
      }
    }
  }

  /// Public method for parent to read current configuration
  /// This is called by the scan screen when starting a scan
  ScanConfiguration getCurrentConfiguration() {
    return ScanConfiguration(
      interfaceName: _selectedInterfaceName,
      ipAddress: _selectedIpAddress,
      useFastScanning: _useFastScanning,
      icmpTimeoutSeconds: int.tryParse(_icmpTimeoutController.text) ?? 2,
      deviceTimeoutSeconds: int.tryParse(_deviceTimeoutController.text) ?? 5,
    );
  }

  /// Validate timeout input value
  String? _validateTimeoutInput(String value) {
    if (value.isEmpty) {
      return 'Erforderlich';
    }

    final timeout = int.tryParse(value);
    if (timeout == null) {
      return 'Ungültige Zahl';
    }

    if (timeout < 1 || timeout > 30) {
      return 'Muss zwischen 1 und 30 sein';
    }

    return null; // Valid
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expand/Collapse Button with fixed height
        SizedBox(
          height: 40,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            label: const Text('Erweiterte Optionen'),
            style: TextButton.styleFrom(
              alignment: Alignment.center,
            ),
          ),
        ),

        // Expandable Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? _buildAdvancedOptionsContent()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Build the expanded advanced options form
  Widget _buildAdvancedOptionsContent() {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Interface/IP Dropdown
            _buildInterfaceDropdown(),
            const SizedBox(height: 12),

            // 2. Fast Scanning Checkbox
            _buildFastScanningCheckbox(),
            const SizedBox(height: 12),

            // 3. ICMP Timeout Input
            _buildIcmpTimeoutInput(),
            const SizedBox(height: 12),

            // 4. Device Timeout Input
            _buildDeviceTimeoutInput(),
          ],
        ),
      ),
    );
  }

  /// Build network interface selection dropdown
  Widget _buildInterfaceDropdown() {
    // Build dropdown items: "Auto" + available interfaces
    final dropdownItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Auto (alle Netzwerke)'),
      ),
      ..._availableInterfaces.map((interface) {
        return DropdownMenuItem<String?>(
          value: interface.name,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  interface.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (interface.isPublic) ...[
                const SizedBox(width: 4),
                const Tooltip(
                  message: 'Warnung: Öffentliche IP-Adresse!\nKann außerhalb des lokalen Netzwerks scannen.',
                  child: Icon(
                    Icons.warning,
                    size: 18,
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Netzwerk-Interface',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: 'Wählen Sie ein spezifisches Netzwerk oder "Auto" für alle verfügbaren Netzwerke',
              child: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            ),
            const Spacer(),
            if (_isLoadingInterfaces)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _loadNetworkInterfaces,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Netzwerk-Interfaces neu laden',
              ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String?>(
          value: _selectedInterfaceName,
          items: dropdownItems,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              // Find the corresponding IP address
              String? ipAddress;
              if (value != null) {
                final interface = _availableInterfaces.firstWhere(
                  (i) => i.name == value,
                  orElse: () => _availableInterfaces.first,
                );
                ipAddress = interface.ipAddress;
              }

              _selectedInterfaceName = value;
              _selectedIpAddress = ipAddress;
            });
          },
        ),
        // Show warning if public IP is selected
        if (_selectedInterfaceName != null)
          () {
            final selectedInterface = _availableInterfaces.firstWhere(
              (i) => i.name == _selectedInterfaceName,
              orElse: () => _availableInterfaces.first,
            );
            if (selectedInterface.isPublic) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Öffentliche IP! Scan kann außerhalb des lokalen Netzwerks erfolgen.',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }(),
      ],
    );
  }

  /// Build fast scanning checkbox
  Widget _buildFastScanningCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _useFastScanning,
          onChanged: (value) {
            setState(() {
              _useFastScanning = value ?? true;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _useFastScanning = !_useFastScanning;
              });
            },
            child: const Text('Fast Scanning (ICMP Timeout verwenden)'),
          ),
        ),
        Tooltip(
          message: 'Aktiviert: Verwendet separaten ICMP Timeout\n'
              'Deaktiviert: Verwendet Device Timeout für beide',
          child: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Build ICMP timeout input field
  Widget _buildIcmpTimeoutInput() {
    final isEnabled = _useFastScanning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ICMP Timeout (Sekunden)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: 'Timeout für Ping-Sweep (nur wenn Fast Scanning aktiv)',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _icmpTimeoutController,
          enabled: isEnabled,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: '2',
            suffixText: 's',
            errorText: isEnabled ? _validateTimeoutInput(_icmpTimeoutController.text) : null,
          ),
          onChanged: (value) {
            setState(() {}); // Trigger validation
          },
        ),
      ],
    );
  }

  /// Build device timeout input field
  Widget _buildDeviceTimeoutInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Device Timeout (Sekunden)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: 'Timeout für HTTP-Prüfung jedes Geräts',
              child: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _deviceTimeoutController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: '5',
            suffixText: 's',
            errorText: _validateTimeoutInput(_deviceTimeoutController.text),
          ),
          onChanged: (value) {
            setState(() {}); // Trigger validation
          },
        ),
      ],
    );
  }
}

/// Simple data class to hold scanning configuration
class ScanConfiguration {
  final String? interfaceName; // null = Auto mode
  final String? ipAddress;
  final bool useFastScanning;
  final int icmpTimeoutSeconds; // 1-30 range
  final int deviceTimeoutSeconds; // 1-30 range

  ScanConfiguration({
    this.interfaceName,
    this.ipAddress,
    required this.useFastScanning,
    required this.icmpTimeoutSeconds,
    required this.deviceTimeoutSeconds,
  });

  /// Default configuration
  factory ScanConfiguration.defaults() {
    return ScanConfiguration(
      interfaceName: null, // Auto
      ipAddress: null,
      useFastScanning: true,
      icmpTimeoutSeconds: 2,
      deviceTimeoutSeconds: 5,
    );
  }

  bool get isAutoMode => interfaceName == null;
}
