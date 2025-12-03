import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class DeviceStorageService {
  static const String _devicesKey = 'known_devices';

  Future<List<DeviceBase>> getKnownDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString(_devicesKey);

    debugPrint(devicesJson,wrapWidth: 1024);

    if (devicesJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(devicesJson);
      final List<DeviceBase> devices = [];

      for (final json in decoded) {
        try {
          final deviceJson = json as Map<String, dynamic>;

          var dev = DeviceFactory.fromJson(deviceJson);
          if(dev != null){
            devices.add(dev);
          }
        } catch (e) {
          print('Error loading device: $e');
          // Continue with next device
        }
      }

      return devices;
    } catch (e) {
      print('Error loading devices: $e');
      return [];
    }
  }

  Future<void> saveDevice(DeviceBase device) async {
    final devices = await getKnownDevices();

    // Check if device already exists
    final existingIndex = devices.indexWhere((d) => d.id == device.id);

    if (existingIndex != -1) {
      debugPrint("replace device");
      // Update existing device
      devices[existingIndex] = device;
    } else {
      // Add new device
      debugPrint("new device");
      devices.add(device);
    }

    await _saveDevices(devices);
  }

  Future<void> removeDevice(String deviceId) async {
    final devices = await getKnownDevices();
    devices.removeWhere((d) => d.id == deviceId);
    await _saveDevices(devices);
  }

  Future<void> _saveDevices(List<DeviceBase> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = jsonEncode(devices.map((d) => d.toJson()).toList());
    await prefs.setString(_devicesKey, devicesJson);

    debugPrint("Saved device");
  }
}
