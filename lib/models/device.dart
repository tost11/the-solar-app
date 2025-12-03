// This file re-exports the new device classes for backward compatibility
// Import and re-export all device-related classes
import 'devices/device_base.dart';

// Export everything
export 'devices/device_base.dart';
export 'devices/manufacturers/zendure/bluetooth_zendure_device.dart';
export 'devices/manufacturers/zendure/wifi_zendure_device.dart';
export 'device_factory.dart';

// Type alias for backward compatibility
// Existing code using "Device" can continue to work
typedef Device = DeviceBase;
