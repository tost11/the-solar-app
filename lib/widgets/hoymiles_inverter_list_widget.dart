import 'package:flutter/material.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/map_utils.dart';

/// Widget to display list of inverters connected to Hoymiles DTU
///
/// Similar to OpenDTUInverterListWidget - shows expandable per-inverter details
class HoymilesInverterListWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const HoymilesInverterListWidget({
    super.key,
    required this.data,
  });

  @override
  State<HoymilesInverterListWidget> createState() =>
      _HoymilesInverterListWidgetState();
}

class _HoymilesInverterListWidgetState
    extends State<HoymilesInverterListWidget> {
  final Set<String> _expandedInverters = {};

  @override
  Widget build(BuildContext context) {
    final inverters =
        MapUtils.OM(widget.data, ['realtime', 'inverters']) as Map<String, dynamic>?;

    if (inverters == null || inverters.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Keine Wechselrichter verbunden',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: inverters.entries.map((entry) {
        final serial = entry.key;
        final inverterData = entry.value as Map<String, dynamic>;
        final isExpanded = _expandedInverters.contains(serial);

        return _buildInverterCard(serial, inverterData, isExpanded);
      }).toList(),
    );
  }

  Widget _buildInverterCard(
    String serial,
    Map<String, dynamic> data,
    bool isExpanded,
  ) {
    final type = data['type'] as String?;
    final linkStatus = data['link_status'] as int? ?? 0;
    final temperature = data['temperature'] as int?;
    final power = data['active_power'] as int?;

    // Determine status color
    Color statusColor = Colors.grey;
    String statusText = 'Offline';
    if (linkStatus == 1) {
      statusColor = Colors.green;
      statusText = 'Online';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.solar_power,
              color: statusColor,
              size: 32,
            ),
            title: Text(
              'Seriennummer: $serial',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$statusText • ${type ?? "Unknown"} • ${power ?? 0} W',
              style: TextStyle(color: statusColor),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  if (isExpanded) {
                    _expandedInverters.remove(serial);
                  } else {
                    _expandedInverters.add(serial);
                  }
                });
              },
            ),
          ),
          if (isExpanded) _buildExpandedDetails(type, data),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(String? type, Map<String, dynamic> data) {
    if (type == 'single-phase') {
      return _buildSinglePhaseDetails(data);
    } else if (type == 'three-phase') {
      return _buildThreePhaseDetails(data);
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(context.l10n.noDetailsAvailable),
    );
  }

  Widget _buildSinglePhaseDetails(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Einphasen-Wechselrichter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          _buildDetailRow('Leistung', '${data['active_power'] ?? 0} W'),
          _buildDetailRow('Spannung',
              '${(data['voltage'] ?? 0) / 10.0} V'),
          _buildDetailRow('Frequenz',
              '${(data['frequency'] ?? 0) / 100.0} Hz'),
          _buildDetailRow('Strom',
              '${(data['current'] ?? 0) / 100.0} A'),
          _buildDetailRow('Temperatur',
              '${(data['temperature'] ?? 0) / 10.0} °C'),
          _buildDetailRow('Leistungsfaktor',
              '${(data['power_factor'] ?? 0) / 1000.0}'),
          if (data['power_limit'] != null)
            _buildDetailRow(
                'Leistungsgrenze', '${data['power_limit']} %'),
          if (data['firmware_version'] != null)
            _buildDetailRow(
                'Firmware', data['firmware_version'].toString()),
        ],
      ),
    );
  }

  Widget _buildThreePhaseDetails(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dreiphasen-Wechselrichter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          _buildDetailRow('Leistung', '${data['active_power'] ?? 0} W'),
          const SizedBox(height: 8),
          const Text(
            'Phase A',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDetailRow('Spannung',
              '${(data['voltage_phase_a'] ?? 0) / 10.0} V'),
          _buildDetailRow('Strom',
              '${(data['current_phase_a'] ?? 0) / 100.0} A'),
          const SizedBox(height: 8),
          const Text(
            'Phase B',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDetailRow('Spannung',
              '${(data['voltage_phase_b'] ?? 0) / 10.0} V'),
          _buildDetailRow('Strom',
              '${(data['current_phase_b'] ?? 0) / 100.0} A'),
          const SizedBox(height: 8),
          const Text(
            'Phase C',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildDetailRow('Spannung',
              '${(data['voltage_phase_c'] ?? 0) / 10.0} V'),
          _buildDetailRow('Strom',
              '${(data['current_phase_c'] ?? 0) / 100.0} A'),
          const SizedBox(height: 8),
          _buildDetailRow('Frequenz',
              '${(data['frequency'] ?? 0) / 100.0} Hz'),
          _buildDetailRow('Temperatur',
              '${(data['temperature'] ?? 0) / 10.0} °C'),
          _buildDetailRow('Leistungsfaktor',
              '${(data['power_factor'] ?? 0) / 1000.0}'),
          if (data['firmware_version'] != null)
            _buildDetailRow(
                'Firmware', data['firmware_version'].toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
