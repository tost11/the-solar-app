import 'package:flutter/material.dart';
import '../utils/map_utils.dart';
import '../constants/translation_keys.dart';
import '../models/to.dart';

/// Custom widget for displaying Zendure battery pack list
/// Supports expandable cards for each battery pack with detailed information
class ZendureBatteryPackListWidget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> data;
  final bool? expertMode;

  const ZendureBatteryPackListWidget({
    super.key,
    required this.data,
    this.expertMode,
  });

  @override
  State<ZendureBatteryPackListWidget> createState() =>
      _ZendureBatteryPackListWidgetState();
}

class _ZendureBatteryPackListWidgetState
    extends State<ZendureBatteryPackListWidget> {
  // Track which battery packs are expanded
  final Set<int> _expandedPacks = {};

  @override
  Widget build(BuildContext context) {
    // Extract battery packs from data
    final packs = _extractBatteryPacks(widget.data);

    if (packs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              TO(key: FieldTranslationKeys.batteryPackEmpty).getText(context),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: packs.asMap().entries.map((entry) {
        final index = entry.key;
        final pack = entry.value;
        final isExpanded = _expandedPacks.contains(index);

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.battery_charging_full,
                  color: _getStateColor(pack),
                  size: 32,
                ),
                title: Text(
                  TO(key: FieldTranslationKeys.batteryPackNumber, params: {'num': '${index + 1}'}).getText(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${pack['socLevel'] ?? '--'}% • ${_getStateText(pack)} • ${_formatPower(pack['power'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedPacks.remove(index);
                      } else {
                        _expandedPacks.add(index);
                      }
                    });
                  },
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPackDetails(pack),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Extract battery packs from data map
  /// Filters out incomplete packs (only containing 'sn' field)
  List<Map<String, dynamic>> _extractBatteryPacks(
      Map<String, Map<String, dynamic>> data) {

    var packDataRaw = MapUtils.OM(data, ['data','packData']) as List<dynamic>?;

    if (packDataRaw == null || packDataRaw.isEmpty) {
      return [];
    }

    return packDataRaw
        .whereType<Map<String, dynamic>>()
        .where((pack) {
          // Skip packs with only 'sn' field
          if (pack.keys.length == 1 && pack.containsKey('sn')) {
            return false;
          }
          return pack.containsKey('sn'); // Must have at least sn + other fields
        })
        .map((pack) => Map<String, dynamic>.from(pack))
        .toList();
  }

  /// Get status color based on battery pack state
  Color _getStateColor(Map<String, dynamic> pack) {
    final state = pack['state'] as int?;
    switch (state) {
      case 1:
        return Colors.blue; // Charging
      case 2:
        return Colors.green; // Discharging
      case 0:
        return Colors.grey; // Idle
      default:
        return Colors.red; // Unknown
    }
  }

  /// Get status text using translations
  String _getStateText(Map<String, dynamic> pack) {
    final state = pack['state'] as int?;
    final stateKey = switch (state) {
      0 => FieldTranslationKeys.batteryStateIdle,
      1 => FieldTranslationKeys.batteryStateCharging,
      2 => FieldTranslationKeys.batteryStateDischarging,
      _ => FieldTranslationKeys.batteryStateUnknown,
    };
    return TO(key: stateKey).getText(context);
  }

  /// Format power value
  String _formatPower(dynamic power) {
    if (power == null) return '-- W';
    if (power is num) {
      return '${power.toStringAsFixed(1)} W';
    }
    return '$power W';
  }

  /// Format temperature value (convert centi-degrees to °C)
  String _formatTemperature(dynamic temp) {
    if (temp == null) return '-- °C';
    if (temp is num) {
      // Convert centi-degrees to °C
      return '${(temp / 100).toStringAsFixed(1)} °C';
    }
    return '$temp °C';
  }

  /// Format voltage value (convert centi-volts to V)
  String _formatVoltage(dynamic voltage) {
    if (voltage == null) return '-- V';
    if (voltage is num) {
      // Convert centi-volts to V
      return '${(voltage / 100).toStringAsFixed(2)} V';
    }
    return '$voltage V';
  }

  /// Format current value (divide by 10 per protocol spec)
  String _formatCurrent(dynamic current) {
    if (current == null) return '-- A';
    if (current is num) {
      // Divide by 10 to get amperes (per protocol specification)
      // Raw value is signed 16-bit two's complement
      return '${(current / 10).toStringAsFixed(2)} A';
    }
    return '$current A';
  }

  /// Build detailed battery pack information
  Widget _buildPackDetails(Map<String, dynamic> pack) {
    // Access expert mode from widget parameter
    final expertMode = widget.expertMode ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always visible fields
        if (pack['sn'] != null)
          _buildDetailRow(
              context,
              Icons.qr_code,
              TO(key: FieldTranslationKeys.serialNumber).getText(context),
              pack['sn'].toString()),

        if (pack['power'] != null)
          _buildDetailRow(
              context,
              Icons.bolt,
              TO(key: FieldTranslationKeys.power).getText(context),
              _formatPower(pack['power'])),

        if (pack['maxTemp'] != null)
          _buildDetailRow(
              context,
              Icons.thermostat,
              TO(key: FieldTranslationKeys.maxTemperature).getText(context),
              _formatTemperature(pack['maxTemp'])),

        if (pack['totalVol'] != null)
          _buildDetailRow(
              context,
              Icons.electrical_services,
              TO(key: FieldTranslationKeys.totalVoltage).getText(context),
              _formatVoltage(pack['totalVol'])),

        if (pack['batcur'] != null)
          _buildDetailRow(
              context,
              Icons.electric_bolt,
              TO(key: FieldTranslationKeys.current).getText(context),
              _formatCurrent(pack['batcur'])),

        // Expert mode only fields
        if (expertMode) ...[
          if (pack['packType'] != null)
            _buildDetailRow(
                context,
                Icons.battery_std,
                TO(key: FieldTranslationKeys.batteryType).getText(context),
                pack['packType'].toString()),

          if (pack['maxVol'] != null)
            _buildDetailRow(
                context,
                Icons.arrow_upward,
                TO(key: FieldTranslationKeys.cellVoltageMax).getText(context),
                _formatVoltage(pack['maxVol'])),

          if (pack['minVol'] != null)
            _buildDetailRow(
                context,
                Icons.arrow_downward,
                TO(key: FieldTranslationKeys.cellVoltageMin).getText(context),
                _formatVoltage(pack['minVol'])),

          if (pack['softVersion'] != null)
            _buildDetailRow(
                context,
                Icons.code,
                TO(key: FieldTranslationKeys.firmwareVersion).getText(context),
                pack['softVersion'].toString()),
        ],
      ],
    );
  }

  /// Build a detail row with icon, label, and value
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
