import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
import '../../../constants/bluetooth_constants.dart';
import '../../../constants/shelly_constants.dart';
import '../../../models/devices/device_base.dart';
import '../../../models/devices/manufacturers/shelly/shelly_bluetooth_device.dart';
import '../../../utils/map_utils.dart';
import '../../../utils/debug_log.dart';
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
    DebugLog.device('Enabling BLE notifications...', level: LogLevel.debug);
    try {
      await readNotifyCharacteristic!.setNotifyValue(true);
      DebugLog.device('Notifications enabled', level: LogLevel.debug);
    } catch (e) {
      DebugLog.device('Failed to enable notifications: $e', level: LogLevel.error);
    }
  }

  @override
  Future<bool> internalInitializeDevice() async {
    await sendCommand(ShellyCommands.getDeviceInfo, {});
    return true;
  }

  /// Perform device-specific connection optimization
  Future<void> _onDeviceConnected() async {
    // Android-only optimizations
    if (Platform.isAndroid) {
      // Clear Android GATT cache for reliability
      try {
        await bluetoothDevice.clearGattCache();
      } catch (e) {
        DebugLog.device('GATT cache clear failed: $e', level: LogLevel.warning);
      }

      // Request high priority connection (Android optimization)
      try {
        await bluetoothDevice.requestConnectionPriority(
            connectionPriorityRequest: ConnectionPriority.high);
      } catch (e) {
        DebugLog.device('Connection priority request failed: $e', level: LogLevel.warning);
      }
    }

    // Request larger MTU for better performance (supported on Android and some other platforms)
    try {
      await bluetoothDevice.requestMtu(185);
    } catch (e) {
      DebugLog.device('MTU negotiation failed: $e', level: LogLevel.warning);
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
          DebugLog.device('Adding cached auth to request', level: LogLevel.verbose);
        }

        String jsonRequest = jsonEncode(request);
        List<int> requestBytes = utf8.encode(jsonRequest);

        DebugLog.device("Sending $jsonRequest", level: LogLevel.verbose);
        DebugLog.device('>>> $method (${requestBytes.length} bytes)', level: LogLevel.verbose);

        // Write request length (4 bytes, big-endian per Shelly spec)
        Uint8List lengthBytes = Uint8List(4);
        ByteData.view(lengthBytes.buffer).setUint32(0, requestBytes.length, Endian.big);
        await _writeWithChunking(writeCharacteristic!, lengthBytes);

        DebugLog.device("Length check OK", level: LogLevel.verbose);

        // Wait per Shelly spec
        await Future.delayed(const Duration(milliseconds: 300));

        // Write request data (chunked if necessary due to MTU)
        DebugLog.device("Writing request data...", level: LogLevel.verbose);
        await _writeWithChunking(rwCharacteristic!, requestBytes, addPreWriteDelay: false);

        // Read response length (4 bytes, big-endian)
        List<int> responseLengthBytes = await readNotifyCharacteristic!.read(timeout: 1500);
        if (responseLengthBytes.length < 4) {
          throw Exception('Invalid response length bytes: got ${responseLengthBytes.length} bytes');
        }
        int responseLength = ByteData.view(Uint8List.fromList(responseLengthBytes).buffer)
            .getUint32(0, Endian.big);
        DebugLog.device('Response length: $responseLength bytes', level: LogLevel.verbose);

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
        DebugLog.device('<<< $method response received', level: LogLevel.verbose);

        Map<String, dynamic> response = jsonDecode(jsonResponse);

        // Check for 401 authentication error
        if (response.containsKey('error')) {
          final error = response['error'];
          final errorCode = error is Map ? error['code'] : null;

          if (errorCode == 401) {
            DebugLog.device('Received 401 authentication challenge', level: LogLevel.debug);

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
        DebugLog.device('Error sending command $method: $e', level: LogLevel.error);
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
    DebugLog.device('Processing response for method: $method', level: LogLevel.verbose);
    DebugLog.device('Response: ${response.toString()}', level: LogLevel.verbose);

    var src = response["src"] as String?;
    if(src != null){
      //TODO make this better
      DebugLog.device("Set realm to: $src", level: LogLevel.verbose);
      (device as dynamic).deviceScr = src;
    }

    if (response.containsKey('error')) {
      DebugLog.device('Error in response: ${response['error']}', level: LogLevel.error);
      throw Exception("Error from shelly received: ${response['error']}");
    }

    var result = response['result'];
    if (result == null) {
      DebugLog.device('No result in response', level: LogLevel.warning);
      return;
    }

    if (method == ShellyCommands.getDeviceInfo) {
      _handleDeviceInfo(result);
    } else if (method == ShellyCommands.getStatus) {
      _handleData(result);
    } else {
      DebugLog.device('Unhandled method response: $method', level: LogLevel.warning);
    }
  }

  /// Handle device info response
  void _handleDeviceInfo(Map<String, dynamic> info) {
    DebugLog.device('Device info received', level: LogLevel.debug);
    DebugLog.device('Device info: ${jsonEncode(info)}', level: LogLevel.verbose);

    var deviceId = info['id'] as String?;
    var deviceModel = info['model'] as String?;
    var deviceFirmware = info['fw_id'] as String?;

    DebugLog.device('Device ID: $deviceId', level: LogLevel.debug);
    DebugLog.device('Model: $deviceModel', level: LogLevel.debug);
    DebugLog.device('Firmware: $deviceFirmware', level: LogLevel.debug);

    device.data["config"] = info;
    device.emitDeviceInfo(info);

    // Update device name and model if we got real model info
    if (deviceModel != null && deviceModel.isNotEmpty) {
      String newName = "Shelly $deviceModel";

      // Only save if name or model actually changed (avoid unnecessary writes)
      if (device.name != newName || device.deviceModel != deviceModel) {
        device.deviceModel = deviceModel;
        device.name = newName;
        DebugLog.device('Updated device name from "${device.name}" to "$newName"', level: LogLevel.debug);

        // Save updated device to storage
        DeviceStorageService().saveDevice(device);
      } else {
        DebugLog.device('Device name already correct: ${device.name}', level: LogLevel.debug);
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
      DebugLog.device('Detected Shelly modules: $detectedModules', level: LogLevel.debug);

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
        DebugLog.device('No error message in 401 response', level: LogLevel.warning);
        return null;
      }

      // Use base class method to parse challenge and build auth object
      final authObject = parseAndBuildAuth(errorMessage);
      if (authObject == null) {
        DebugLog.device('Failed to build authentication object', level: LogLevel.error);
        return null;
      }

      DebugLog.device('Built authentication object, retrying request...', level: LogLevel.debug);

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

      DebugLog.device("Retrying with auth: $jsonRequest", level: LogLevel.verbose);
      DebugLog.device('>>> $method (${requestBytes.length} bytes) [with auth]', level: LogLevel.verbose);

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
      DebugLog.device('<<< $method retry response received', level: LogLevel.verbose);

      Map<String, dynamic> retryResponse = jsonDecode(jsonResponse);

      // Check if retry also failed with 401
      if (retryResponse.containsKey('error')) {
        final retryError = retryResponse['error'];
        final retryErrorCode = retryError is Map ? retryError['code'] : null;

        if (retryErrorCode == 401) {
          DebugLog.device('Authentication retry failed with 401', level: LogLevel.error);
          // Clear cached auth since it didn't work
          resetAuthCache();
          throw Exception('Authentifizierung fehlgeschlagen. Bitte überprüfen Sie Benutzername und Passwort.');
        }
      }

      // Process successful response
      _processResponse(method, retryResponse);

      return MapUtils.OM(retryResponse, ["result"]) as Map<String, dynamic>?;
    } catch (e) {
      DebugLog.device('Error handling authentication challenge: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Helper method to write data with delay for BLE stability
  /// Uses explicit 5s timeout to avoid holding _commandMutex for the full
  /// FBP default (15s) if the device drops during write.
  Future<void> _write(
    BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    await characteristic.write(data, withoutResponse: false, timeout: 5);
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
