

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/device.dart';
import 'package:the_solar_app/models/network_device.dart';
import 'package:the_solar_app/models/additional_connection_info.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'package:http/http.dart' as http;

import '../../../utils/map_utils.dart';

class ZendureWifiService extends BaseDeviceService {

  /// Static method to detect if HTTP response is from a Zendure device
  ///
  /// Returns a NetworkDevice if the response is from a Zendure device, null otherwise
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    int ? port,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    port ??= 80;
    try {
      // Check if initial response indicates we should probe further
      // (e.g., 404 means root endpoint doesn't exist, which is expected for Zendure devices)
      if (initialResponse == null || initialResponse.statusCode == 404) {
        // Make request to Zendure-specific endpoint
        final response = await http.get(
          Uri.parse('http://$ipAddress:$port/properties/report'),
          headers: {'Accept': 'application/json'},
        ).timeout(connectionInfo.timeout);

        if (response.statusCode == 200) {
          // Parse JSON response
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;

          // Check for Zendure-specific keys
          if (responseData.containsKey('sn') &&
              responseData.containsKey('product') &&
              responseData.containsKey('properties')) {

            final serialNumber = responseData['sn'] as String?;
            final deviceModel = responseData['product'] as String?;

            if (serialNumber != null) {
              return NetworkDevice(
                ipAddress: ipAddress,
                hostname: null,
                manufacturer: DEVICE_MANUFACTURER_ZENDURE,
                deviceModel: deviceModel ?? 'Unknown',
                serialNumber: serialNumber,
                port: port
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error detecting Zendure device: $e');
    }

    return null;
  }

  // Connection timeout - if no data received within this time, consider disconnected
  static const int CONNECTION_TIMEOUT_MS = 15000;  // 15 seconds

  late WiFiZendureDevice wifiDevice;

  ZendureWifiService(DeviceBase device):
    super((device as WiFiZendureDevice).fetchDataInterval, device) {
    wifiDevice = device as WiFiZendureDevice;
  }

  // No need to override internalDisconnect() - default implementation is sufficient
  // (wrapper handles lastSeen, autoReconnect, data clearing, status messages)

  String getBaseUri(){
    return 'http://${wifiDevice.getCurrentBaseUrl()}';
  }

  @override
  Future<bool> internalConnect() async {
    await wifiDevice.connectIpOrHostname((ip,port) async {
      // Connection verified
      await internalFetchData();//getBaseUri() uses paramters set here so call wihtout functions is fine
    });

    isInitialized = true;
    return false;//do not fetch data directly init data is fine
  }

  @override
  Future<void> internalFetchData() async{

    //debugPrint("request new data!");

    final response = await http
        .get(
      Uri.parse('${getBaseUri()}/properties/report'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      debugPrint("received data: $data",wrapWidth: 1024);
      if(data["sn"] != null && data["sn"] is String){
        debugPrint("sn is: ${device.deviceSn}");
      }

      if(device.data["data"] == null){
        device.data["data"] = Map<String,dynamic>();
      }

      if ((data.containsKey('properties') && data['properties'] is Map)) {
        (device.data["data"] as Map<String,dynamic>)["properties"] = data['properties'];
      }
      if ((data.containsKey('packData') && data['packData'] is List)) {
        (device.data["data"] as Map<String,dynamic>)["packData"] = data['packData'];
      }

      device.emitData(data);

      lastSeen = DateTime.now().millisecondsSinceEpoch;
    } else {
      throw Exception('Failed to fetch properties: HTTP ${response.statusCode}');
    }
  }

  @override
  bool isConnected() {
    return (DateTime.now().millisecondsSinceEpoch - lastSeen) < CONNECTION_TIMEOUT_MS;
  }

  Future<Map<String,dynamic>?> sendCommand(dynamic data) async {
    debugPrint("Sending write wifi zendure command: ${jsonEncode(data)}");

    var sendData = {
      "sn": device.deviceSn, // Required
      "properties": data
    };

    var response = await http.post(
        Uri.parse('${getBaseUri()}/properties/write'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(sendData)
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Command failed: HTTP ${response.statusCode}');
    }

    try {
      var obj = jsonDecode(response.body);
      var res = MapUtils.OM(obj,["properties"]);
      if(res == null){
        return {};
      }
      return res as Map<String,dynamic>;
    }catch(e){
      print(e.toString());
      throw Exception("could not parse");
    }
  }

  Future<Map<String,dynamic>?> setRPCGetCommand(dynamic command) async {
    var response = await http.get(
        Uri.parse('${getBaseUri()}/rpc?method='+command),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
    ).timeout(const Duration(seconds: 5));

    Map<String,dynamic> obj;
    try {
      obj = jsonDecode(response.body);
    }catch(e){
      print(e.toString());
      throw Exception("could not parse response");
    }
    debugPrint("Zendure getcommand received ${obj.toString()}");
    if(obj.containsKey("error")){
      throw Exception("Error on response ${obj['error'].toString()}");
    }
    if(!obj.containsKey("data")){
      throw Exception("error on get command zendure: $command: ${obj.toString()}");
    }
    return obj["data"] as Map<String,dynamic>;

  }

  Future<Map<String,dynamic>?> sendRPCCommand(String command ,dynamic data) async {

    var sendData = {
      "sn": device.deviceSn, // Required
      "method": command,
      "params": { "config": data }
    };

    debugPrint("Sending rpc command: ${jsonEncode(sendData)}");

    var response = await http.post(
        Uri.parse('${getBaseUri()}/rpc'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(sendData)
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Command failed: HTTP ${response.statusCode}');
    }

    try {
      var obj = jsonDecode(response.body);
      return obj as Map<String,dynamic>;
    }catch(e){
      print(e.toString());
      throw Exception("could not parse response");
    }
  }
}