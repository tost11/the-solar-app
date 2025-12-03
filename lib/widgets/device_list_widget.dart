import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceListWidget extends StatelessWidget {
  final List<ScanResult> scanResults;
  final bool isScanning;
  final Function(BluetoothDevice) onDeviceTap;

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
        final result = scanResults[index];
        final device = result.device;
        final rssi = result.rssi;

        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(
            device.name.isNotEmpty ? device.name : 'Unbekanntes Gerät',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${device.id}\nSignalstärke: $rssi dBm'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _logDeviceInfo(result);
            onDeviceTap(device);
          },
        );
      },
    );
  }

  void _logDeviceInfo(ScanResult result) {
    final device = result.device;
    final rssi = result.rssi;
    final advData = result.advertisementData;

    print('═══════════════════════════════════════════════════════════════');
    print('DEVICE CLICKED - Full Information:');
    print('═══════════════════════════════════════════════════════════════');
    print('Device Name: ${device.name.isNotEmpty ? device.name : 'Unbekanntes Gerät'}');
    print('Device ID: ${device.id}');
    print('RSSI (Signal Strength): $rssi dBm');
    print('Remote ID: ${device.remoteId}');

    print('\nAdvertisement Data:');
    print('  Local Name: ${advData.localName}');
    print('  TX Power Level: ${advData.txPowerLevel}');
    print('  Connectable: ${advData.connectable}');
    print('  Manufacturer Data: ${advData.manufacturerData}');
    print('  Service Data: ${advData.serviceData}');
    print('  Service UUIDs: ${advData.serviceUuids}');

    print('\nTimestamp: ${result.timeStamp}');
    print('═══════════════════════════════════════════════════════════════\n');
  }
}
