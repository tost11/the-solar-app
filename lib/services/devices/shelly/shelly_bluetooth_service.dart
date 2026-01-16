import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../constants/bluetooth_constants.dart';
import '../../../constants/shelly_constants.dart';
import '../../../models/devices/device_base.dart';
import '../../../models/devices/manufacturers/shelly/shelly_bluetooth_device.dart';
import '../../../utils/map_utils.dart';
import '../bluetooth_device_service.dart';
import '../../device_storage_service.dart';
import 'shelly_auth_mixin.dart';
import 'shelly_service.dart';
import 'package:mutex/mutex.dart';

/// Service for communicating with Shelly devices via Bluetooth Low Energy
///
/// Implements the Shelly BLE RPC protocol:
/// 1. Write request length (4 bytes) to write characteristic
/// 2. Write JSON-RPC request to RW characteristic
/// 3. Read response length (4 bytes) from read/notify characteristic
/// 4. Read response data in chunks from RW characteristic
class ShellyBluetoothService extends BluetoothDeviceService with ShellyAuthMixin implements ShellyService {

  final Mutex _commandMutex = Mutex();

  /// Constructor - initializes BLE connection with Shelly-specific UUIDs
  ShellyBluetoothService(DeviceBase device, BluetoothDevice bluetoothDevice)
      : super(
          updateTime: (device as ShellyBluetoothDeviceTemplate).fetchDataInterval,
          bluetoothDevice: bluetoothDevice,
          baseDevice: device,
          serviceUuid: SHELLY_GATT_SERVICE_UUID,
          rwCharacteristicUuid: SHELLY_RW_UUID,
          readNotifyCharacteristicUuid: SHELLY_READ_NOTIFY_UUID,
          writeCharacteristicUuid: SHELLY_WRITE_UUID,
        );

  /// Connect to the Bluetooth device
  /// Reuses parent's connection logic and adds Shelly-specific initialization
  @override
  Future<bool> internalConnect() async {
    // Use parent's Bluetooth connection logic
    await super.internalConnect();

    // Shelly immediately fetches data after connection
    return true;
  }

  /// Perform Shelly-specific connection optimizations
  /// Called by parent after connection but before service discovery
  @override
  Future<void> onDeviceConnected() async {
    await _onDeviceConnected();
  }

  /// Device-specific Shelly Bluetooth disconnection logic
  @override
  Future<void> internalDisconnect() async {
    // Call parent's Bluetooth disconnect logic (characteristics, lifecycle hooks)
    await super.internalDisconnect();

    // Clear Shelly-specific auth cache
    resetAuthCache();
  }

  /// Validate that all required Shelly characteristics were found by parent
  @override
  bool validateCharacteristics() {
    return rwCharacteristic != null &&
        readNotifyCharacteristic != null &&
        writeCharacteristic != null;
  }

  /// Setup Shelly characteristics (enable notifications)
  @override
  Future<void> setupCharacteristics() async {
    debugPrint('\nEnabling notifications...');
    try {
      await readNotifyCharacteristic!.setNotifyValue(true);
      debugPrint('Notifications enabled');
    } catch (e) {
      debugPrint('Failed to enable notifications: $e');
    }
  }

  @override
  Future<bool> internalInitializeDevice() async {
    await sendCommand(ShellyCommands.getDeviceInfo, {});
    return true;
  }

  /// Perform device-specific connection optimization
  Future<void> _onDeviceConnected() async {
    // Clear Android GATT cache for reliability
    try {
      await bluetoothDevice.clearGattCache();
    } catch (e) {
      debugPrint('GATT cache clear not supported: $e');
    }

    // Request larger MTU for better performance
    try {
      await bluetoothDevice.requestMtu(185);
    } catch (e) {
      debugPrint('MTU negotiation failed: $e');
    }

    // Request high priority connection (Android optimization)
    try {
      await bluetoothDevice.requestConnectionPriority(
          connectionPriorityRequest: ConnectionPriority.high);
    } catch (e) {
      debugPrint('Connection priority request failed: $e');
    }
  }

  /// Send a JSON-RPC command to the device via BLE
  @override
  Future<Map<String, dynamic>?> sendCommand(String method, Map<String, dynamic> params) async {
    if (rwCharacteristic == null ||
        writeCharacteristic == null ||
        readNotifyCharacteristic == null) {
      throw Exception('Not connected to device');
    }

    Map<String, dynamic>? returnResponse;

    await _commandMutex.protect(() async {
      try {
        // Build JSON-RPC request (per official Shelly BLE specification)
        int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        Map<String, dynamic> request = {
          'id': id,
          'src': 'flutter_app', // Required by Shelly spec
          'method': method,
        };
        if (params.isNotEmpty) {
          request['params'] = params;
        }

        // Add authentication if enabled and cached
        if (cachedAuthObject != null) {
          request['auth'] = cachedAuthObject;
          debugPrint('Adding cached auth to request');
        }

        String jsonRequest = jsonEncode(request);
        List<int> requestBytes = utf8.encode(jsonRequest);

        debugPrint("Sending $jsonRequest");
        debugPrint('>>> $method (${requestBytes.length} bytes)');

        // Write request length (4 bytes, big-endian per Shelly spec)
        Uint8List lengthBytes = Uint8List(4);
        ByteData.view(lengthBytes.buffer).setUint32(0, requestBytes.length, Endian.big);
        await _writeWithChunking(writeCharacteristic!, lengthBytes);

        debugPrint("length ok");

        // Wait per Shelly spec
        await Future.delayed(const Duration(milliseconds: 300));

        // Write request data (chunked if necessary due to MTU)
        debugPrint("Writing request data...");
        await _writeWithChunking(rwCharacteristic!, requestBytes, addPreWriteDelay: false);

        // Read response length (4 bytes, big-endian)
        List<int> responseLengthBytes = await readNotifyCharacteristic!.read(timeout: 1500);
        if (responseLengthBytes.length < 4) {
          throw Exception('Invalid response length bytes: got ${responseLengthBytes.length} bytes');
        }
        int responseLength = ByteData.view(Uint8List.fromList(responseLengthBytes).buffer)
            .getUint32(0, Endian.big);
        debugPrint('Response length: $responseLength bytes');

        // Read response data in chunks
        List<int> responseBytes = [];
        int attempts = 0;
        const maxAttempts = 50;

        while (responseBytes.length < responseLength && attempts < maxAttempts) {
          try {
            List<int> chunk = await rwCharacteristic!.read(timeout: 1500);
            if (chunk.isEmpty) {
              await Future.delayed(const Duration(milliseconds: 300));
              attempts++;
              continue;
            }

            responseBytes.addAll(chunk);
            attempts++;
          } catch (e) {
            attempts++;
            if (attempts >= maxAttempts) {
              throw Exception('Failed to read response after $attempts attempts');
            }
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }

        if (responseBytes.length < responseLength) {
          throw Exception('Incomplete response: got ${responseBytes.length}/$responseLength bytes');
        }

        // Parse JSON response
        String jsonResponse = utf8.decode(responseBytes);
        debugPrint('<<< $method response received');

        Map<String, dynamic> response = jsonDecode(jsonResponse);

        // Check for 401 authentication error
        if (response.containsKey('error')) {
          final error = response['error'];
          final errorCode = error is Map ? error['code'] : null;

          if (errorCode == 401) {
            debugPrint('Received 401 authentication challenge');

            // Try to handle authentication and retry
            final retryResponse = await _handleAuthenticationChallenge(
              error,
              method,
              params,
              id,
            );

            if (retryResponse != null) {
              returnResponse = retryResponse;
              return; // Exit the mutex protect block
            } else {
              // Authentication failed, propagate error
              throw Exception('Authentication failed: ${error['message']}');
            }
          }
        }

        _processResponse(method, response);

        returnResponse = MapUtils.OM(response, ["result"]) as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('Error sending command $method: $e');
        if(method != ShellyCommands.getStatus && method != ShellyCommands.getDeviceInfo) {
          //ony when command from user show inf forderground
          device.emitError('Befehl fehlgeschlagen: $e');
        }
        rethrow;
      }
    });

    return returnResponse;
  }

  /// Fetch data from the device (called periodically)
  @override
  Future<void> internalFetchData() async {
    await sendCommand(ShellyCommands.getStatus, {});
  }

  /// Process response from device
  void _processResponse(String method, Map<String, dynamic> response) {
    debugPrint('\nProcessing response for method: $method');
    debugPrint(response.toString());

    var src = response["src"] as String?;
    if(src != null){
      //TODO make this better
      debugPrint("set realm to: $src");
      (device as dynamic).deviceScr = src;
    }

    if (response.containsKey('error')) {
      debugPrint('Error in response: ${response['error']}');
      throw Exception("Error from shelly received: ${response['error']}");
    }

    var result = response['result'];
    if (result == null) {
      debugPrint('No result in response');
      return;
    }

    if (method == ShellyCommands.getDeviceInfo) {
      _handleDeviceInfo(result);
    } else if (method == ShellyCommands.getStatus) {
      _handleData(result);
    } else {
      debugPrint('Unhandled method response: $method');
    }
  }

  /// Handle device info response
  void _handleDeviceInfo(Map<String, dynamic> info) {
    debugPrint('\nDEVICE INFO:');
    debugPrint(jsonEncode(info));

    var deviceId = info['id'] as String?;
    var deviceModel = info['model'] as String?;
    var deviceFirmware = info['fw_id'] as String?;

    debugPrint('Device ID: $deviceId');
    debugPrint('Model: $deviceModel');
    debugPrint('Firmware: $deviceFirmware');

    device.data["config"] = info;
    device.emitDeviceInfo(info);

    // Update device name and model if we got real model info
    if (deviceModel != null && deviceModel.isNotEmpty) {
      String newName = "Shelly $deviceModel";

      // Only save if name or model actually changed (avoid unnecessary writes)
      if (device.name != newName || device.deviceModel != deviceModel) {
        device.deviceModel = deviceModel;
        device.name = newName;
        debugPrint('Updated device name from "${device.name}" to "$newName"');

        // Save updated device to storage
        DeviceStorageService().saveDevice(device);
      } else {
        debugPrint('Device name already correct: ${device.name}');
      }
    }

    device.emitStatus('Geräteinfo erhalten');
  }

  /// Handle energy monitoring data response
  void _handleData(Map<String, dynamic> data) {
    // Detect modules in response
    final detectedModules = _detectModules(data);

    // Update cached modules and regenerate fields if modules changed
    final currentModules = device.data['_detectedModules'];
    if (currentModules == null || !_mapsEqual(currentModules as Map?, detectedModules)) {
      device.data['_detectedModules'] = detectedModules;
      debugPrint('Detected Shelly modules: $detectedModules');

      // Regenerate dynamic fields, controls, and time series based on new modules
      _updateDeviceElements();
    }

    device.data["data"] = data;
    device.emitData(data);
    device.emitStatus('Daten empfangen');
  }

  /// Update device UI elements after module detection
  void _updateDeviceElements() {
    final impl = (device as dynamic).deviceImpl;
    // dataFields is now a computed getter - no need to update
    device.controlItems = impl.getControlItems();
    device.timeSeriesFields = impl.getTimeSeriesFields();
  }

  /// Detect Shelly modules in the response data
  Map<String, List<int>> _detectModules(Map<String, dynamic> data) {
    final modules = <String, List<int>>{};
    final regex = RegExp(r'^(em|em1|em1data|emdata|pm1|switch|cover|input|light|temperature):(\d+)$');

    for (final key in data.keys) {
      final match = regex.firstMatch(key);
      if (match != null) {
        final moduleType = match.group(1)!;
        final instanceId = int.parse(match.group(2)!);
        modules.putIfAbsent(moduleType, () => []).add(instanceId);
      }
    }

    // Sort instance IDs
    modules.forEach((key, value) => value.sort());

    return modules;
  }

  /// Compare two maps for equality (deep comparison of structure)
  bool _mapsEqual(Map<dynamic, dynamic>? map1, Map<dynamic, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final val1 = map1[key];
      final val2 = map2[key];

      if (val1 is List && val2 is List) {
        if (val1.length != val2.length) return false;
        for (int i = 0; i < val1.length; i++) {
          if (val1[i] != val2[i]) return false;
        }
      } else if (val1 != val2) {
        return false;
      }
    }

    return true;
  }

  /// Handle authentication challenge (401 error) and retry request
  ///
  /// Returns the result of the retry, or null if authentication failed
  Future<Map<String, dynamic>?> _handleAuthenticationChallenge(
    dynamic error,
    String method,
    Map<String, dynamic> params,
    int requestId,
  ) async {
    try {
      // Extract error message
      final errorMessage = error is Map ? error['message'] as String? : null;
      if (errorMessage == null) {
        debugPrint('No error message in 401 response');
        return null;
      }

      // Use base class method to parse challenge and build auth object
      final authObject = parseAndBuildAuth(errorMessage);
      if (authObject == null) {
        debugPrint('Failed to build authentication object');
        return null;
      }

      debugPrint('Built authentication object, retrying request...');

      // Retry the request with authentication
      // Build request with auth
      Map<String, dynamic> retryRequest = {
        'id': requestId,
        'src': 'flutter_app',
        'method': method,
        'auth': authObject,
      };
      if (params.isNotEmpty) {
        retryRequest['params'] = params;
      }

      String jsonRequest = jsonEncode(retryRequest);
      List<int> requestBytes = utf8.encode(jsonRequest);

      debugPrint("Retrying with auth: $jsonRequest");
      debugPrint('>>> $method (${requestBytes.length} bytes) [with auth]');

      // Write request length
      Uint8List lengthBytes = Uint8List(4);
      ByteData.view(lengthBytes.buffer).setUint32(0, requestBytes.length, Endian.big);
      await _writeWithChunking(writeCharacteristic!, lengthBytes);

      await Future.delayed(const Duration(milliseconds: 300));

      // Write request data
      await _writeWithChunking(rwCharacteristic!, requestBytes, addPreWriteDelay: false);

      // Read response length
      List<int> responseLengthBytes = await readNotifyCharacteristic!.read(timeout: 1500);
      if (responseLengthBytes.length < 4) {
        throw Exception('Invalid response length bytes: got ${responseLengthBytes.length} bytes');
      }
      int responseLength = ByteData.view(Uint8List.fromList(responseLengthBytes).buffer)
          .getUint32(0, Endian.big);

      // Read response data
      List<int> responseBytes = [];
      int attempts = 0;
      const maxAttempts = 50;

      while (responseBytes.length < responseLength && attempts < maxAttempts) {
        try {
          List<int> chunk = await rwCharacteristic!.read(timeout: 1500);
          if (chunk.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 300));
            attempts++;
            continue;
          }

          responseBytes.addAll(chunk);
          attempts++;
        } catch (e) {
          attempts++;
          if (attempts >= maxAttempts) {
            throw Exception('Failed to read response after $attempts attempts');
          }
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (responseBytes.length < responseLength) {
        throw Exception('Incomplete response: got ${responseBytes.length}/$responseLength bytes');
      }

      // Parse retry response
      String jsonResponse = utf8.decode(responseBytes);
      debugPrint('<<< $method retry response received');

      Map<String, dynamic> retryResponse = jsonDecode(jsonResponse);

      // Check if retry also failed with 401
      if (retryResponse.containsKey('error')) {
        final retryError = retryResponse['error'];
        final retryErrorCode = retryError is Map ? retryError['code'] : null;

        if (retryErrorCode == 401) {
          debugPrint('Authentication retry failed with 401');
          // Clear cached auth since it didn't work
          resetAuthCache();
          throw Exception('Authentifizierung fehlgeschlagen. Bitte überprüfen Sie Benutzername und Passwort.');
        }
      }

      // Process successful response
      _processResponse(method, retryResponse);

      return MapUtils.OM(retryResponse, ["result"]) as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error handling authentication challenge: $e');
      return null;
    }
  }

  /// Helper method to write data with delay for BLE stability
  Future<void> _write(
    BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    await characteristic.write(data, withoutResponse: false);
  }

  /// Unified helper to write data with chunking and proper delays
  ///
  /// Handles BLE resource management by:
  /// - Adding pre-write delay to ensure previous operations completed
  /// - Chunking data based on MTU
  /// - Adding delays between chunks
  Future<void> _writeWithChunking(
    BluetoothCharacteristic characteristic,
    List<int> data, {
    bool addPreWriteDelay = true,
  }) async {
    // Add pre-write delay to avoid resource exhaustion
    if (addPreWriteDelay) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Get MTU and calculate max chunk size
    int mtu = await connectedDevice!.mtu.first;
    int maxChunkSize = mtu - 3; // BLE overhead

    // Write data (chunked if necessary)
    if (data.length <= maxChunkSize) {
      await _write(characteristic, data);
    } else {
      // Split into chunks
      for (int i = 0; i < data.length; i += maxChunkSize) {
        int end = (i + maxChunkSize < data.length)
            ? i + maxChunkSize
            : data.length;
        List<int> chunk = data.sublist(i, end);
        await _write(characteristic, chunk);

        // Add delay between chunks (except after last chunk)
        if (end < data.length) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
