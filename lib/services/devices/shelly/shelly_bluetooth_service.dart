import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../constants/bluetooth_constants.dart';
import '../../../models/devices/device_base.dart';
import '../../../models/devices/manufacturers/shelly/shelly_bluetooth_device.dart';
import '../../../utils/map_utils.dart';
import 'shelly_service.dart';
import 'package:mutex/mutex.dart';

/// Service for communicating with Shelly devices via Bluetooth Low Energy
///
/// Implements the Shelly BLE RPC protocol:
/// 1. Write request length (4 bytes) to write characteristic
/// 2. Write JSON-RPC request to RW characteristic
/// 3. Read response length (4 bytes) from read/notify characteristic
/// 4. Read response data in chunks from RW characteristic
class ShellyBluetoothService extends ShellyService {

  // Bluetooth connection
  final BluetoothDevice bluetoothDevice;

  // Characteristics
  BluetoothCharacteristic? _notifyCharacteristic;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _rwCharacteristic;
  BluetoothCharacteristic? _readNotifyCharacteristic;

  // Protected getters
  BluetoothCharacteristic? get notifyCharacteristic => _notifyCharacteristic;
  BluetoothCharacteristic? get writeCharacteristic => _writeCharacteristic;
  BluetoothCharacteristic? get rwCharacteristic => _rwCharacteristic;
  BluetoothCharacteristic? get readNotifyCharacteristic => _readNotifyCharacteristic;
  BluetoothDevice? get connectedDevice => bluetoothDevice;

  final Mutex _commandMutex = Mutex();
  bool _initialized = false;
  final String _readDataCommand;

  /// Constructor - initializes BLE connection
  ShellyBluetoothService(DeviceBase device, BluetoothDevice bluetoothDevice, String readDataCommand)
      : bluetoothDevice = bluetoothDevice,
        _readDataCommand = readDataCommand,
        super((device as ShellyBluetoothDeviceTemplate).fetchDataInterval, device) {
    connect();
  }

  @override
  bool isConnected() {
    return bluetoothDevice.isConnected;
  }

  @override
  bool isInitialized() {
    return _initialized;
  }

  /// Connect to the Bluetooth device
  @override
  Future<void> connect() async {
    try {
      device.emitStatus('Verbinde...');
      debugPrint('\n═══════════════════════════════════════════════════════════════');
      debugPrint('CONNECTING TO SHELLY DEVICE');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('Device: ${bluetoothDevice.platformName}');
      debugPrint('ID: ${bluetoothDevice.remoteId}');

      // Connect to device
      await bluetoothDevice.connect(timeout: const Duration(seconds: 15));
      debugPrint('Connected successfully!');

      device.emitStatus('Verbunden');

      // Perform device-specific connection optimization
      await _onDeviceConnected();

      // Discover services
      debugPrint('\nDiscovering services...');
      List<BluetoothService> services = await bluetoothDevice.discoverServices();
      debugPrint('Found ${services.length} services');

      // Find characteristics
      await _findCharacteristics(services);

      // Validate characteristics
      if (!_validateCharacteristics()) {
        throw Exception('Required characteristics not found');
      }

      // Setup characteristics (enable notifications, etc.)
      await _setupCharacteristics();

      // Initialize device
      await _initializeDevice();

    } catch (e) {
      debugPrint('Connection error: $e');
      device.emitError('Verbindungsfehler: $e');
      device.emitStatus('Verbindung fehlgeschlagen');
      rethrow;
    }
  }

  /// Disconnect from the Bluetooth device
  @override
  Future<void> disconnect() async {
    try {
      await bluetoothDevice.disconnect();
      await _onAfterDisconnect();
      resetAuthCache();
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }

  /// Find Shelly-specific characteristics across all services
  Future<void> _findCharacteristics(List<BluetoothService> services) async {
    debugPrint('\nSearching for Shelly characteristics...');

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        String uuid = characteristic.uuid.toString().toUpperCase();

        if (uuid.contains(SHELLY_RW_UUID.toUpperCase())) {
          _rwCharacteristic = characteristic;
          debugPrint('Found RW characteristic: $uuid');
        }
        if (uuid.contains(SHELLY_READ_NOTIFY_UUID.toUpperCase())) {
          _readNotifyCharacteristic = characteristic;
          debugPrint('Found Read/Notify characteristic: $uuid');
        }
        if (uuid.contains(SHELLY_WRITE_UUID.toUpperCase())) {
          _writeCharacteristic = characteristic;
          debugPrint('Found Write characteristic: $uuid');
        }
      }
    }
  }

  /// Validate that all required characteristics were found
  bool _validateCharacteristics() {
    return rwCharacteristic != null &&
        readNotifyCharacteristic != null &&
        writeCharacteristic != null;
  }

  /// Setup characteristics (enable notifications)
  Future<void> _setupCharacteristics() async {
    debugPrint('\nEnabling notifications...');
    try {
      await readNotifyCharacteristic!.setNotifyValue(true);
      debugPrint('Notifications enabled');
    } catch (e) {
      debugPrint('Failed to enable notifications: $e');
    }
  }

  /// Initialize the device (request device info, etc.)
  Future<void> _initializeDevice() async {
    device.emitStatus('Bereit');
    debugPrint('Ready to send commands\n');

    // Request device info
    await _requestDeviceInfo();

    _initialized = true;
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

  /// Clean up after disconnect
  Future<void> _onAfterDisconnect() async {
    device.data = {};
    device.emitData(device.data);
    _initialized = false;
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
        await _write(writeCharacteristic!, lengthBytes);

        // Wait per Shelly spec
        await Future.delayed(const Duration(milliseconds: 300));

        // Write request data (chunked if necessary due to MTU)
        int mtu = await connectedDevice!.mtu.first;
        int maxChunkSize = mtu - 3; // BLE overhead

        if (requestBytes.length <= maxChunkSize) {
          await _write(rwCharacteristic!, requestBytes);
        } else {
          // Split into chunks
          for (int i = 0; i < requestBytes.length; i += maxChunkSize) {
            int end = (i + maxChunkSize < requestBytes.length)
                ? i + maxChunkSize
                : requestBytes.length;
            List<int> chunk = requestBytes.sublist(i, end);
            await _write(rwCharacteristic!, chunk);
            if (end < requestBytes.length) {
              await Future.delayed(const Duration(milliseconds: 300));
            }
          }
        }

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
        device.emitError('Befehl fehlgeschlagen: $e');
        rethrow;
      }
    });

    return returnResponse;
  }

  /// Fetch data from the device (called periodically)
  @override
  void fetchData() {
    sendCommand(
      _readDataCommand,
      _readDataCommand == "Shelly.GetStatus" ? {} : {"id": 0},
    );
  }

  // Private methods

  /// Request device information
  Future<void> _requestDeviceInfo() async {
    debugPrint('\nRequesting device info...');
    device.emitStatus('Lese Geräteinfo...');
    await sendCommand('Shelly.GetDeviceInfo', {});
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
      device.emitError('Fehler: ${response['error']}');
      return;
    }

    var result = response['result'];
    if (result == null) {
      debugPrint('No result in response');
      return;
    }

    if (method == 'Shelly.GetDeviceInfo') {
      _handleDeviceInfo(result);
    } else if (method == _readDataCommand) {
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

    device.emitStatus('Geräteinfo erhalten');
  }

  /// Handle energy monitoring data response
  void _handleData(Map<String, dynamic> data) {
    device.data["data"] = data;
    device.emitData(data);
    device.emitStatus('Daten empfangen');
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
      await _write(writeCharacteristic!, lengthBytes);

      await Future.delayed(const Duration(milliseconds: 300));

      // Write request data
      int mtu = await connectedDevice!.mtu.first;
      int maxChunkSize = mtu - 3;

      if (requestBytes.length <= maxChunkSize) {
        await _write(rwCharacteristic!, requestBytes);
      } else {
        for (int i = 0; i < requestBytes.length; i += maxChunkSize) {
          int end = (i + maxChunkSize < requestBytes.length)
              ? i + maxChunkSize
              : requestBytes.length;
          List<int> chunk = requestBytes.sublist(i, end);
          await _write(rwCharacteristic!, chunk);
          if (end < requestBytes.length) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
      }

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

  @override
  void dispose() {
    super.dispose();
  }
}
