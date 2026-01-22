import 'package:flutter/material.dart';
import '../utils/map_utils.dart';
import '../utils/globals.dart';
import '../models/to.dart';
import '../constants/translation_keys.dart';

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
  void initState() {
    super.initState();
    // Listen for expert mode changes
    Globals.expertModeNotifier.addListener(_onExpertModeChanged);
  }

  @override
  void dispose() {
    Globals.expertModeNotifier.removeListener(_onExpertModeChanged);
    super.dispose();
  }

  void _onExpertModeChanged() {
    if (mounted) {
      setState(() {
        // Rebuild widget when expert mode changes
      });
    }
  }

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
              TO(key: FieldTranslationKeys.noInverterData).getText(context),
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
                  inverter['name'] ?? TO(key: FieldTranslationKeys.inverterFallback, params: {'num': '${index + 1}'}).getText(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${_formatPower(inverter['power'])} • ${_getStatusText(inverter, context)}',
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
  String _getStatusText(Map<String, dynamic> inverter, BuildContext context) {
    final reachable = inverter['reachable'] as bool?;
    final producing = inverter['producing'] as bool?;

    if (reachable == true && producing == true) {
      return TO(key: FieldTranslationKeys.statusProducing).getText(context);
    } else if (reachable == true) {
      return TO(key: FieldTranslationKeys.statusReachable).getText(context);
    } else {
      return TO(key: FieldTranslationKeys.statusNotReachable).getText(context);
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
            TO(key: FieldTranslationKeys.serialNumber).getText(context),
            inverter['serial'].toString(),
          ),

        // Power
        if (inverter['power'] != null)
          _buildDetailRow(
            Icons.bolt,
            TO(key: FieldTranslationKeys.currentPower).getText(context),
            _formatPower(inverter['power']),
          ),

        // DC Power
        if (inverter['dc_power'] != null)
          _buildDetailRow(
            Icons.solar_power,
            TO(key: FieldTranslationKeys.dcPower).getText(context),
            _formatPower(inverter['dc_power']),
          ),

        // Yield Day
        if (inverter['yield_day'] != null)
          _buildDetailRow(
            Icons.wb_sunny,
            TO(key: FieldTranslationKeys.dailyYield).getText(context),
            '${inverter['yield_day']} Wh',
          ),

        // Yield Total
        if (inverter['yield_total'] != null)
          _buildDetailRow(
            Icons.solar_power,
            TO(key: FieldTranslationKeys.totalYield).getText(context),
            '${inverter['yield_total']} kWh',
          ),

        // Power Limit
        if (inverter['limit_relative'] != null && inverter['limit_absolute'] != null)
          _buildDetailRow(
            Icons.speed,
            TO(key: FieldTranslationKeys.powerLimit).getText(context),
            '${inverter['limit_relative']}% (${inverter['limit_absolute']} W)',
          ),

        // Temperature
        if (inverter['temperature'] != null)
          _buildDetailRow(
            Icons.thermostat,
            TO(key: FieldTranslationKeys.temperature).getText(context),
            '${inverter['temperature']} °C',
          ),

        // AC Voltage - EXPERT MODE ONLY
        if (Globals.expertMode && inverter['ac_voltage'] != null)
          _buildDetailRow(
            Icons.electrical_services,
            TO(key: FieldTranslationKeys.acVoltage).getText(context),
            _formatNumericValue(inverter['ac_voltage'], 'V'),
          ),

        // AC Current - EXPERT MODE ONLY
        if (Globals.expertMode && inverter['ac_current'] != null)
          _buildDetailRow(
            Icons.electric_bolt,
            TO(key: FieldTranslationKeys.acCurrent).getText(context),
            _formatNumericValue(inverter['ac_current'], 'A'),
          ),

        // AC Frequency - EXPERT MODE ONLY
        if (Globals.expertMode && inverter['ac_frequency'] != null)
          _buildDetailRow(
            Icons.graphic_eq,
            TO(key: FieldTranslationKeys.acFrequency).getText(context),
            _formatNumericValue(inverter['ac_frequency'], 'Hz'),
          ),

        // DC Strings Section
        if (inverter['dc_strings'] != null && inverter['dc_strings'] is List)
          ..._buildDCStringsSection(inverter['dc_strings'] as List, context),
      ],
    );
  }

  /// Build DC strings section with dividers and expert mode support
  List<Widget> _buildDCStringsSection(List<dynamic> dcStrings, BuildContext context) {
    if (dcStrings.isEmpty) return [];

    final widgets = <Widget>[];

    // Section divider
    widgets.add(
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Divider(thickness: 2),
      ),
    );

    // Loop through each DC string
    for (int i = 0; i < dcStrings.length; i++) {
      final string = dcStrings[i];
      if (string is! Map<String, dynamic>) continue;

      // String divider (before each string except first)
      if (i > 0) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 1, indent: 20, endIndent: 20),
          ),
        );
      }

      // String name header
      String stringName = MapUtils.OMas(string,["name","u"],"");
      if(stringName == ""){
        stringName = TO(key: FieldTranslationKeys.stringFallback, params: {'num': '${i+1}'}).getText(context);
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            stringName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );


      // Power - ALWAYS VISIBLE
      if (string['power'] != null) {
        widgets.add(_buildDetailRow(
          Icons.bolt,
          TO(key: FieldTranslationKeys.power).getText(context),
          _formatPower(string['power']),
        ));
      }

      // Voltage - EXPERT MODE ONLY
      if (Globals.expertMode && string['voltage'] != null) {
        widgets.add(_buildDetailRow(
          Icons.electrical_services,
          TO(key: FieldTranslationKeys.voltage).getText(context),
          _formatNumericValue(string['voltage'], 'V'),
        ));
      }

      // Current - EXPERT MODE ONLY
      if (Globals.expertMode && string['current'] != null) {
        widgets.add(_buildDetailRow(
          Icons.electric_bolt,
          TO(key: FieldTranslationKeys.current).getText(context),
          _formatNumericValue(string['current'], 'A'),
        ));
      }

      // Yield Day - ALWAYS VISIBLE
      if (string['yield_day'] != null) {
        widgets.add(_buildDetailRow(
          Icons.wb_sunny,
          TO(key: FieldTranslationKeys.dailyYield).getText(context),
          '${string['yield_day']} Wh',
        ));
      }

      // Yield Total - ALWAYS VISIBLE
      if (string['yield_total'] != null) {
        widgets.add(_buildDetailRow(
          Icons.solar_power,
          TO(key: FieldTranslationKeys.totalYield).getText(context),
          '${string['yield_total']} kWh',
        ));
      }

      // Note: Irradiation field is available in data but NOT displayed per user request
    }

    return widgets;
  }

  /// Format numeric value with unit
  /// Handles OpenDTU data format which can be: number or {v: value, u: unit, d: decimals}
  String _formatNumericValue(dynamic value, String defaultUnit) {
    if (value == null) return '-- $defaultUnit';

    // If value is a Map (OpenDTU format: {v: value, u: unit, d: decimals})
    if (value is Map<String, dynamic>) {
      final numValue = value['v'];
      if (numValue == null) return '-- $defaultUnit';

      if (numValue is num) {
        return '${numValue.toStringAsFixed(1)} $defaultUnit';
      }
      return '$numValue $defaultUnit';
    }

    // If value is already a number
    if (value is num) {
      return '${value.toStringAsFixed(1)} $defaultUnit';
    }

    // Fallback: convert to string
    return '$value $defaultUnit';
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
