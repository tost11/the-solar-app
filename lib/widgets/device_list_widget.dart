import 'package:flutter/material.dart';
import '../utils/debug_log.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
import '../services/bluetooth_scan_service.dart';

class DeviceListWidget extends StatelessWidget {
  final List<BluetoothScanResult> scanResults;
  final bool isScanning;
  final Function(BluetoothDevice, String?) onDeviceTap;

  const DeviceListWidget({
    super.key,
    required this.scanResults,
    required this.isScanning,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (scanResults.isEmpty) {
      return Center(
        child: Text(
          isScanning
              ? 'Suche nach Geräten...'
              : 'Keine Geräte gefunden.\nDrücke "Scan starten"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        final enrichedResult = scanResults[index];
        final device = enrichedResult.device;
        final rssi = enrichedResult.scanResult?.rssi;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: enrichedResult.isKnownManufacturer
                ? Colors.green.shade100
                : Colors.orange.shade100,
            child: Icon(
              Icons.bluetooth,
              color: enrichedResult.isKnownManufacturer
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  device.name.isNotEmpty ? device.name : 'Unbekanntes Gerät',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (!enrichedResult.isKnownManufacturer)
                _buildUnknownDeviceBadge(),
            ],
          ),
          subtitle: Text('${device.id}\nSignalstärke: ${rssi != null ? '$rssi dBm' : 'unbekannt'}'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (enrichedResult.scanResult != null) {
              _logDeviceInfo(enrichedResult.scanResult!);
            }
            onDeviceTap(device, enrichedResult.detectedManufacturer);
          },
        );
      },
    );
  }

  Widget _buildUnknownDeviceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 12, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            'Unbekannt',
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _logDeviceInfo(ScanResult result) {
    final device = result.device;
    final rssi = result.rssi;
    final advData = result.advertisementData;
    DebugLog.ui('═══════════════════════════════════════════════════════════════', level: LogLevel.debug);
    DebugLog.ui('DEVICE CLICKED - Full Information:', level: LogLevel.debug);
    DebugLog.ui('═══════════════════════════════════════════════════════════════', level: LogLevel.debug);
    DebugLog.ui('Device Name: ${device.name.isNotEmpty ? device.name : "Unbekanntes Gerät"}', level: LogLevel.debug);
    DebugLog.ui('Device ID: ${device.id}', level: LogLevel.debug);
    DebugLog.ui('RSSI (Signal Strength): $rssi dBm', level: LogLevel.debug);
    DebugLog.ui('Remote ID: ${device.remoteId}', level: LogLevel.debug);
    DebugLog.ui('Remote ID: ${device.remoteId}', level: LogLevel.debug);
    DebugLog.ui('\nAdvertisement Data:', level: LogLevel.debug);
    DebugLog.ui('  Local Name: ${advData.localName}', level: LogLevel.debug);
    DebugLog.ui('  TX Power Level: ${advData.txPowerLevel}', level: LogLevel.debug);
    DebugLog.ui('  Connectable: ${advData.connectable}', level: LogLevel.debug);
    DebugLog.ui('  Manufacturer Data: ${advData.manufacturerData}', level: LogLevel.verbose);
    DebugLog.ui('  Service Data: ${advData.serviceData}', level: LogLevel.verbose);
    DebugLog.ui('  Service UUIDs: ${advData.serviceUuids}', level: LogLevel.verbose);
    DebugLog.ui('  Service UUIDs: ${advData.serviceUuids}', level: LogLevel.verbose);
    DebugLog.ui('\nTimestamp: ${result.timeStamp}', level: LogLevel.debug);
    DebugLog.ui('═══════════════════════════════════════════════════════════════\n', level: LogLevel.debug);
    DebugLog.ui('═══════════════════════════════════════════════════════════════\n', level: LogLevel.debug);
  }
}
