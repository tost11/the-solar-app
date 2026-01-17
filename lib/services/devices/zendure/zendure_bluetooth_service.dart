import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../constants/bluetooth_constants.dart';
import '../../../models/devices/device_base.dart';
import '../../../utils/map_utils.dart';
import '../bluetooth_device_service.dart';
import '../../device_storage_service.dart';

/// Service for communicating with Zendure devices via Bluetooth Low Energy
///
/// Implements Zendure-specific BLE protocol including:
/// - BLESPP handshake
/// - WiFi configuration with firmware version detection
/// - Power limit control
/// - Real-time data monitoring
class ZendureBluetoothService extends BluetoothDeviceService {
  StreamSubscription<List<int>>? _notifySubscription;

  String? _deviceSn;
  //final InverterData _inverterData = InverterData(rawData: {});

  // Additional streams for Zendure-specific data
  //Stream<InverterData> get inverterData => dataStream;
  //InverterData get currentData => _inverterData;
  String? get deviceSn => _deviceSn;

  /// Constructor - passes Zendure UUIDs to base class
  ZendureBluetoothService({required DeviceBase device,required BluetoothDevice bluetoothDvice})
      : super(
          bluetoothDevice: bluetoothDvice,
          updateTime: null,//no update perfomed device dose it itself
          baseDevice: device,
          serviceUuid: ZENDURE_SERVICE_UUID,
          serviceUuidShort: ZENDURE_SERVICE_SHORT,
          notifyCharacteristicUuid: ZENDURE_NOTIFY_UUID,
          notifyCharacteristicUuidShort: ZENDURE_NOTIFY_SHORT,
          writeCharacteristicUuid: ZENDURE_WRITE_UUID,
          writeCharacteristicUuidShort: ZENDURE_WRITE_SHORT,
        ){
  }

  Future<bool> internalConnect()async {

    await super.internalConnect();

    //not realy correct but ok for now
    isInitialized = true;
    return false;//data will come by notification
  }

  @override
  bool validateCharacteristics() {
    // Zendure requires notify and write characteristics
    return notifyCharacteristic != null && writeCharacteristic != null;
  }

  @override
  Future<void> internalFetchData() async {
    //nothing to do here data come from device automaticly
  }

  @override
  Future<void> internalDisconnect() async {
    // Cancel subscription FIRST (before BLE disconnect)
    if (_notifySubscription != null) {
      try {
        await _notifySubscription?.cancel();
      } catch (e) {
        print('Error cancelling BLE subscription: $e');
      } finally {
        _notifySubscription = null;
      }
    }

    // Clear device serial number
    _deviceSn = null;

    // Call parent's Bluetooth disconnect logic (characteristics, lifecycle hooks)
    await super.internalDisconnect();

    // Disconnect from BLE device
    try {
      await bluetoothDevice.disconnect();
    } catch (e) {
      print('Error disconnecting from BLE device: $e');
    }
  }

  @override
  Future<void> setupCharacteristics() async {
    // Enable notifications
    print('\nEnabling notifications...');
    await notifyCharacteristic!.setNotifyValue(true);

    // Listen to notifications
    _notifySubscription = notifyCharacteristic!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        _handleNotification(value);
      }
    });

    print('Notifications enabled');
  }

  Future<void> sendPlainCommand(Map<String,dynamic> properites) async {
    _sendCommand(properites);
  }


  /// Set power limits on the device
  Future<void> sendCommand(Map<String,dynamic> properites) async {
    if (writeCharacteristic == null) {
      throw Exception('Not connected to device');
    }

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String messageId = _generateMessageId();

    Map<String, dynamic> command = {
      'method': 'write',
      'timestamp': timestamp,
      'messageId': messageId,
      'deviceId': device.deviceSn,
      'properties': properites
    };

    print("Zendure bluetooth geneic send command with props: $properites");

    await _sendCommand(command);
  }

  // Private methods

  void _handleNotification(List<int> value) {
    String jsonStr = utf8.decode(value);
    print('\n<<< RECEIVED:');
    print(jsonStr);

    try {
      Map<String, dynamic> data = jsonDecode(jsonStr);
      _processMessage(data);
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  Future<void> _processMessage(Map<String, dynamic> data) async {
    String? method = data['method'];
    print('Method: $method');

    switch (method) {
      case 'BLESPP':
        await _handleBlesppHandshake(data);
        break;
      case 'getInfo-rsp':
        await _handleDeviceInfo(data);
        break;
      case 'read_reply':
        device.emitStatus('Lese Daten...');
        break;
      case 'report':
        _handleReport(data);
        break;
      case 'write_reply':
        _handleWriteReply(data);
        break;
    }
  }

  Future<void> _handleBlesppHandshake(Map<String, dynamic> data) async {
    //TODO assert if different
    //deviceId = data['deviceId'];
    //print('Device ID: $deviceId');

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> response = {
      'messageId': timestamp.toString(),
      'method': 'BLESPP_OK'
    };

    await _sendCommand(response);
    device.emitStatus('Handshake OK');

    await Future.delayed(const Duration(milliseconds: 500));
    await _requestDeviceInfo();
  }

  Future<void> _handleDeviceInfo(Map<String, dynamic> data) async {
    print('\nDEVICE INFO:');
    debugPrint(data.toString());

    // Store device serial number
    _deviceSn = data['sn'] as String?;
    print('Device SN: $_deviceSn');


    var firmwares = Map<String,dynamic>();
    final List<dynamic> modules = data['modules'] ?? [];
    if (data['modules'] != null) {
      firmwares = {
        for (final m in modules) m['module'] as String: m['version'] as int,
      };
    }

    print('Firmwares: $firmwares');

    device.data["firmwares"] = firmwares;

    // Note: Zendure doesn't provide model field in API response
    // deviceSn is also final and cannot be updated
    // Name was already set from advName during initial scan
    // No further updates needed for Zendure devices

    // Emit device info through stream
    device.emitDeviceInfo({
      'deviceSn': _deviceSn,
      'firmwares': firmwares,
    });

    device.emitStatus('Info erhalten');

    await Future.delayed(const Duration(milliseconds: 500));
    await _requestAllData();
  }

  void _handleReport(Map<String, dynamic> data) {
    var newProps = data["properties"] as Map<String,dynamic>?;
    var newPackData = data["packData"] as List<dynamic>?;
    if(device.data["data"] == null){
      device.data["data"] = Map<String,dynamic>();
    }
    var oldProps = (device.data["data"] as Map<String,dynamic>)["properties"] as Map<String,dynamic>?;
    if(oldProps == null){
      oldProps = Map<String,dynamic>();
    }
    var oldPackData = (device.data["data"] as Map<String,dynamic>)["packData"] as List<dynamic>?;
    if(oldPackData == null){
      oldPackData = [];
    }

    if (newProps != null) {
      var newData = MapUtils.mergeMaps(oldProps,newProps);
      if(newData != null){
        debugPrint("new properties are: ${newData.toString()}");
        (device.data["data"] as Map<String,dynamic>)['properties'] = newData;
      }
    }
    if (newPackData != null) {
      newPackData.removeWhere((item) => item is Map && item.length <= 1);//remove all pack data only containing id
      var lastPackData = (device.data["data"] as Map<String,dynamic>)['packData'] ?? [];

      for(var oldItem in lastPackData){
        bool found = false;
        for (var newItem in newPackData){
          if ((newItem as Map)["sn"] == (oldItem as Map)["sn"]) {
            found = true;
            break;
          }
        }
        if(found == false){
          newPackData.add(oldItem);
        }
      }

      (device.data["data"] as Map<String,dynamic>)['packData'] = newPackData;
    }

    if (data['properties'] != null) {
      debugPrint(data['properties'].toString());
    }

    print('\nREPORT DATA:');
    print(jsonEncode(data));

    device.emitStatus('Daten empfangen');
    device.emitData(data);
  }

  void _handleWriteReply(Map<String, dynamic> data) {
    int? success = data['success'] as int?;

    print('\nWRITE REPLY:');
    print('Success: $success');

    if (data['properties'] != null) {
      _handleReport(data);
    }

    if (success == 1) {
      device.emitStatus('Einstellung erfolgreich');
      print('Write command successful!');
    } else {
      device.emitStatus('Fehler beim Schreiben');
      device.emitError('Write command failed');
      print('Write command failed!');
    }

    print('═══════════════════════════════════════════════════════════════\n');
  }

  Future<void> _requestDeviceInfo() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Map<String, dynamic> request = {
      'messageId': timestamp.toString(),
      'method': 'getInfo',
      'timestamp': timestamp
    };

    await _sendCommand(request);
  }

  Future<void> _requestAllData() async {

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Map<String, dynamic> request = {
      'messageId': '11',
      'deviceId': device.deviceSn,
      'timestamp': timestamp,
      'properties': ['getAll'],
      'method': 'read'
    };

    await _sendCommand(request);
  }
  
  
  Future<void> _sendCommand(Map<String, dynamic> command) async {
    if (writeCharacteristic == null) return;

    String jsonStr = jsonEncode(command);
    print('\n>>> SENDING:');
    print(jsonStr);

    List<int> bytes = utf8.encode(jsonStr);
    await writeCharacteristic!.write(bytes, withoutResponse: false);
  }

  String _generateMessageId() {
    // Generate a UUID-like message ID (32 hex characters)
    const chars = '0123456789abcdef';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
            32, (index) => chars[(timestamp + index * 7) % chars.length])
        .join();
  }

  @override
  void dispose() {
    _notifySubscription?.cancel();
    super.dispose();
  }
}
