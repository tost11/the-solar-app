import 'package:flutter/cupertino.dart';

/// Mixin for adding WiFi connection capabilities to device models.
///
/// Provides IP address and port fields,
/// along with helper methods for JSON serialization.
///
/// This mixin can be used by any device type that connects via WiFi
/// (e.g., Zendure, DeyeSun, OpenDTU, or other brands in the future).
mixin DeviceWifiMixin {
  /// IP address for WiFi device connection
  String ? netIpAddress;
  String ? netHostname;

  /// Port number for WiFi device connection (typically 80)
  int? netPort;

  bool currentConnectionHostname = false;

  /// Serializes WiFi connection fields to JSON
  ///
  /// Returns a map containing ipAddress and port fields.
  /// Null values are excluded from the map.
  Map<String, dynamic> wifiToJson() {
    return {
      if (netIpAddress != null) 'ipAddress': netIpAddress,
      if (netHostname != null) 'hostname': netHostname,
      if (netPort != null) 'port': netPort
    };
  }

  /// Deserializes WiFi connection fields from JSON
  ///
  /// Restores ipAddress and port from the provided map.
  /// If port is not present in JSON, defaults to 80.
  void wifiFromJson(Map<String, dynamic> json) {
    netIpAddress = json['ipAddress'] as String?;
    netHostname = json['hostname'] as String?;
    netPort = (json['port'] as int?) ?? 80;
  }

  String getHostnameBaseUrl(){
    if(netHostname == null){
      throw new Exception("could nto get base url hostname is null");
    }
    return "$netHostname:$netPort";
  }

  Future<T> connectIpOrHostname<T>(Future<T> Function(String ip, int port) func) async {
    if(netIpAddress == null && netHostname == null){
      throw Exception("Could not connect! hostname and ip both null");
    }
    Object prevEx = Exception("Could not connect (and this here should never be fired...)");
    try {
      if (netHostname != null) {
        currentConnectionHostname = true;
        return await func(netHostname!,netPort!);
      }
    }catch (e){
      debugPrint("Could not connect to: $netHostname $netPort");
      prevEx = e;
    }

    try {
      if (netIpAddress != null) {
        currentConnectionHostname = false;
        return await func(netIpAddress!, netPort!);
      } else {
        throw prevEx;
      }
    }catch (e){
      debugPrint("Could not connect to: $netIpAddress $netPort");
      rethrow;
    }
  }

  String getCurrentConnectionOrHost(){
    String? used = currentConnectionHostname ? netHostname : netIpAddress;
    if(used == null){
      throw new Exception("current connectin ip or host not set");
    }
    return used;
  }

  String getCurrentBaseUrl(){
    return "${getCurrentConnectionOrHost()}:$netPort";
  }

  String getCurrenHostOrIp(){
    return "${getCurrentConnectionOrHost()}";
  }
}
