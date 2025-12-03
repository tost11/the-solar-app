import 'package:flutter/material.dart';
import '../utils/map_utils.dart';

/// Custom widget for displaying OpenDTU inverter list
/// Supports both single inverter and multiple inverter configurations
class OpenDTUInverterListWidget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> data;

  const OpenDTUInverterListWidget({
    super.key,
    required this.data,
  });

  @override
  State<OpenDTUInverterListWidget> createState() => _OpenDTUInverterListWidgetState();
}

class _OpenDTUInverterListWidgetState extends State<OpenDTUInverterListWidget> {
  // Track which inverters are expanded
  final Set<int> _expandedInverters = {};

  @override
  Widget build(BuildContext context) {
    // Extract inverters from data
    // OpenDTU WebSocket sends inverter data in 'data' -> 'inverters' array
    final inverters = _extractInverters(widget.data);

    if (inverters.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Keine Wechselrichter-Daten verfügbar',
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
      children: inverters.asMap().entries.map((entry) {
        final index = entry.key;
        final inverter = entry.value;
        final isExpanded = _expandedInverters.contains(index);

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.solar_power,
                  color: _getStatusColor(inverter),
                  size: 32,
                ),
                title: Text(
                  inverter['name'] ?? 'Wechselrichter ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${_formatPower(inverter['power'])} • ${_getStatusText(inverter)}',
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
                        _expandedInverters.remove(index);
                      } else {
                        _expandedInverters.add(index);
                      }
                    });
                  },
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildInverterDetails(inverter),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Extract inverters from data map
  /// Now expects inverters as Map<String, dynamic> (serial -> data)
  List<Map<String, dynamic>> _extractInverters(Map<String, Map<String, dynamic>> data) {
    final List<Map<String, dynamic>> inverters = [];

    // Extract inverters map from WebSocket data
    final invertersMap = MapUtils.OM(data, ['data', 'inverters']);

    if (invertersMap != null && invertersMap is Map<String, dynamic>) {
      // Iterate through all inverters in the map
      for (var entry in invertersMap.entries) {
        final inverterData = entry.value;
        if (inverterData is Map<String, dynamic>) {
          // Map the parsed data to widget format
          inverters.add({
            'serial': inverterData['serial'],
            'name': inverterData['name'],
            'power': inverterData['ac_power'],
            'yield_day': inverterData['yield_day'],
            'yield_total': inverterData['yield_total'],
            'reachable': inverterData['reachable'],
            'producing': inverterData['producing'],
            'limit_relative': inverterData['limit_relative'],
            'limit_absolute': inverterData['limit_absolute'],
            'temperature': inverterData['temperature'],
            'dc_power': inverterData['dc_power'],
            'ac_voltage': inverterData['ac_voltage'],
            'ac_current': inverterData['ac_current'],
            'ac_frequency': inverterData['ac_frequency'],
            'dc_strings': inverterData['dc_strings'],
          });
        }
      }
    }

    return inverters;
  }

  /// Get status color based on inverter state
  Color _getStatusColor(Map<String, dynamic> inverter) {
    final reachable = inverter['reachable'] as bool?;
    final producing = inverter['producing'] as bool?;

    if (reachable == true && producing == true) {
      return Colors.green;
    } else if (reachable == true) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get status text
  String _getStatusText(Map<String, dynamic> inverter) {
    final reachable = inverter['reachable'] as bool?;
    final producing = inverter['producing'] as bool?;

    if (reachable == true && producing == true) {
      return 'Produziert';
    } else if (reachable == true) {
      return 'Erreichbar';
    } else {
      return 'Nicht erreichbar';
    }
  }

  /// Format power value
  String _formatPower(dynamic power) {
    if (power == null) return '-- W';
    if (power is num) {
      return '${power.toStringAsFixed(1)} W';
    }
    return '$power W';
  }

  /// Build detailed inverter information
  Widget _buildInverterDetails(Map<String, dynamic> inverter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Serial Number
        if (inverter['serial'] != null)
          _buildDetailRow(
            Icons.qr_code,
            'Seriennummer',
            inverter['serial'].toString(),
          ),

        // Power
        if (inverter['power'] != null)
          _buildDetailRow(
            Icons.bolt,
            'Aktuelle Leistung',
            _formatPower(inverter['power']),
          ),

        // DC Power
        if (inverter['dc_power'] != null)
          _buildDetailRow(
            Icons.solar_power,
            'DC Leistung',
            _formatPower(inverter['dc_power']),
          ),

        // Yield Day
        if (inverter['yield_day'] != null)
          _buildDetailRow(
            Icons.wb_sunny,
            'Tagesertrag',
            '${inverter['yield_day']} Wh',
          ),

        // Yield Total
        if (inverter['yield_total'] != null)
          _buildDetailRow(
            Icons.solar_power,
            'Gesamtertrag',
            '${inverter['yield_total']} kWh',
          ),

        // Power Limit
        if (inverter['limit_relative'] != null && inverter['limit_absolute'] != null)
          _buildDetailRow(
            Icons.speed,
            'Leistungsgrenze',
            '${inverter['limit_relative']}% (${inverter['limit_absolute']} W)',
          ),

        // Temperature
        if (inverter['temperature'] != null)
          _buildDetailRow(
            Icons.thermostat,
            'Temperatur',
            '${inverter['temperature']} °C',
          ),

        // AC Voltage
        if (inverter['ac_voltage'] != null)
          _buildDetailRow(
            Icons.electrical_services,
            'AC Spannung',
            '${inverter['ac_voltage']} V',
          ),

        // AC Current
        if (inverter['ac_current'] != null)
          _buildDetailRow(
            Icons.electric_bolt,
            'AC Strom',
            '${inverter['ac_current']} A',
          ),

        // AC Frequency
        if (inverter['ac_frequency'] != null)
          _buildDetailRow(
            Icons.graphic_eq,
            'AC Frequenz',
            '${inverter['ac_frequency']} Hz',
          ),
      ],
    );
  }

  /// Build a detail row with icon, label, and value
  Widget _buildDetailRow(IconData icon, String label, String value) {
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
