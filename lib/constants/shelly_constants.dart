/// Shelly RPC Command Constants
///
/// JSON-RPC method names for communication with Shelly Gen2+ devices.
/// These constants provide a centralized definition of all Shelly RPC commands
/// used throughout the application.
class ShellyCommands {
  // Private constructor to prevent instantiation
  ShellyCommands._();

  // Device Information
  static const String getDeviceInfo = 'Shelly.GetDeviceInfo';
  static const String getStatus = 'Shelly.GetStatus';
  static const String reboot = 'Shelly.Reboot';
  static const String setAuth = 'Shelly.SetAuth';

  // WiFi Commands
  static const String wifiGetConfig = 'WiFi.GetConfig';
  static const String wifiSetConfig = 'WiFi.SetConfig';

  // System Commands
  static const String sysGetConfig = 'Sys.GetConfig';
  static const String sysSetConfig = 'Sys.SetConfig';

  // Script Management
  static const String scriptList = 'Script.List';
  static const String scriptCreate = 'Script.Create';
  static const String scriptDelete = 'Script.Delete';
  static const String scriptGetCode = 'Script.GetCode';
  static const String scriptPutCode = 'Script.PutCode';
  static const String scriptSetConfig = 'Script.SetConfig';
  static const String scriptGetConfig = 'Script.GetConfig';
  static const String scriptGetStatus = 'Script.GetStatus';
  static const String scriptEval = 'Script.Eval';
  static const String scriptStart = 'Script.Start';
  static const String scriptStop = 'Script.Stop';

  // Energy Monitoring (Legacy)
  static const String emGetStatus = 'EM.GetStatus';

  // Switch Control
  static const String switchSet = 'Switch.Set';
}
