import 'package:flutter/material.dart';

/// Generic screen to display device information in a structured way
class DeviceInfoScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DeviceInfoScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geräteinformationen'),
      ),
      body: data.isEmpty
          ? const Center(
              child: Text('Keine Informationen verfügbar'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final entry = data.entries.elementAt(index);
                return _buildSection(context, entry.key, entry.value);
              },
            ),
    );
  }

  /// Build a section card
  Widget _buildSection(BuildContext context, String title, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            // Section content
            if (value is Map<String, dynamic>)
              ..._buildMapContent(value)
            else
              _buildValueWidget(value),
          ],
        ),
      ),
    );
  }

  /// Build content for a map (nested key-value pairs)
  List<Widget> _buildMapContent(Map<String, dynamic> map) {
    final widgets = <Widget>[];
    for (final entry in map.entries) {
      widgets.add(_buildKeyValuePair(entry.key, entry.value));
    }
    return widgets;
  }

  /// Build a single key-value pair
  Widget _buildKeyValuePair(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key
          Expanded(
            flex: 2,
            child: Text(
              '$key:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Value
          Expanded(
            flex: 3,
            child: _buildValueWidget(value),
          ),
        ],
      ),
    );
  }

  /// Build widget for a value based on its type
  Widget _buildValueWidget(dynamic value) {
    if (value == null) {
      return const SelectableText(
        '-',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    String displayText;
    if (value is String) {
      displayText = value.isEmpty ? '-' : value;
    } else if (value is int || value is double) {
      displayText = value.toString();
    } else if (value is bool) {
      displayText = value ? 'Ja' : 'Nein';
    } else if (value is List) {
      displayText = value.join(', ');
    } else if (value is Map) {
      // Nested map - format as bullet points
      final entries = (value as Map<String, dynamic>)
          .entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
      displayText = entries;
    } else {
      displayText = value.toString();
    }

    return SelectableText(
      displayText,
      style: const TextStyle(
        color: Colors.black87,
      ),
    );
  }
}
