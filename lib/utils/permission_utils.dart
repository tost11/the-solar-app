import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionUtils {
  /// Checks and requests all necessary permissions for Bluetooth and WiFi scanning
  /// Returns true if all permissions are granted, false otherwise
  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    // Check Bluetooth support
    if (await FlutterBluePlus.isSupported == false) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth wird auf diesem Gerät nicht unterstützt'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      return false;
    }

    // Only request runtime permissions on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true; // Desktop platforms don't need runtime permissions
    }

    bool allGranted = true;

    // Request Bluetooth permissions
    final bluetoothPermissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    for (final permission in bluetoothPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        final result = await permission.request();
        if (!result.isGranted) {
          allGranted = false;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_getPermissionName(permission)}-Berechtigung erforderlich'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Einstellungen',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
        }
      }
    }

    // Request WiFi permissions (Android 13+ requires nearbyWifiDevices)
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Request nearbyWifiDevices permission on Android 13+
        if (sdkInt >= 33) {
          final nearbyWifiDevices = await Permission.nearbyWifiDevices.status;
          if (!nearbyWifiDevices.isGranted) {
            final result = await Permission.nearbyWifiDevices.request();
            if (!result.isGranted) {
              allGranted = false;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('WiFi-Geräte-Berechtigung erforderlich für Netzwerk-Scan'),
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Einstellungen',
                      onPressed: () => openAppSettings(),
                    ),
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error checking Android version for WiFi permissions: $e');
      }
    }

    // Request location when in use (needed for WiFi scanning on all Android versions)
    if (Platform.isAndroid || Platform.isIOS) {
      final locationWhenInUse = await Permission.locationWhenInUse.status;
      if (!locationWhenInUse.isGranted) {
        final result = await Permission.locationWhenInUse.request();
        if (!result.isGranted) {
          allGranted = false;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Standort-Berechtigung erforderlich für WiFi-Scan'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Einstellungen',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
        }
      }
    }

    if (allGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle Berechtigungen erteilt'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }

    return allGranted;
  }

  /// Helper method to get user-friendly permission names
  static String _getPermissionName(Permission permission) {
    if (permission == Permission.bluetoothScan) return 'Bluetooth-Scan';
    if (permission == Permission.bluetoothConnect) return 'Bluetooth-Verbindung';
    if (permission == Permission.location) return 'Standort';
    if (permission == Permission.nearbyWifiDevices) return 'WiFi-Geräte';
    if (permission == Permission.locationWhenInUse) return 'Standort (im Gebrauch)';
    return 'Unbekannt';
  }
}
