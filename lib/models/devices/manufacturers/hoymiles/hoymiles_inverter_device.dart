import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import '../../capabilities/device_role_config.dart';
import '../../device_base.dart';
import '../../generic_rendering/device_category_config.dart';
import '../../generic_rendering/device_data_field.dart';
import 'hoymiles_device.dart';
import 'implementations/hoymiles_inverter_implementation.dart';

/// Hoymiles HMS-series standalone inverter with built-in WiFi
///
/// Examples: HMS-400W-1T, HMS-800W-2T, HMS-1000W-2T, HMS-2000DW-4T
class HoymilesInverterDevice extends HoymilesDevice with DeviceRoleConfig, InverterCapability {

  final HoymilesInverterImplementation _impl = HoymilesInverterImplementation();

  HoymilesInverterDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    String? ipAddress,
    String? hostname,
    int? port = 10081,
    super.deviceModel,
  }) : super(
    connectionType: ConnectionType.wifi,
    menuItems: HoymilesInverterImplementation().getMenuItems(),
    categoryConfigs: const [
      DeviceCategoryConfig(
        category: 'ac',
        displayName: 'AC (Netz)',
        displayNameKey: CategoryTranslationKeys.acGrid,
        layout: CategoryLayout.standard,
        order: 10,
      ),
      DeviceCategoryConfig(
        category: 'pv1',
        displayName: 'PV1',
        displayNameKey: CategoryTranslationKeys.pv1,
        layout: CategoryLayout.standard,
        order: 20,
      ),
      DeviceCategoryConfig(
        category: 'pv2',
        displayName: 'PV2',
        displayNameKey: CategoryTranslationKeys.pv2,
        layout: CategoryLayout.standard,
        order: 30,
      ),
      DeviceCategoryConfig(
        category: 'pv3',
        displayName: 'PV3',
        displayNameKey: CategoryTranslationKeys.pv3,
        layout: CategoryLayout.standard,
        order: 40,
      ),
      DeviceCategoryConfig(
        category: 'pv4',
        displayName: 'PV4',
        displayNameKey: CategoryTranslationKeys.pv4,
        layout: CategoryLayout.standard,
        order: 50,
      ),
    ],
    timeSeriesFields: HoymilesInverterImplementation().getTimeSeriesFields(),
  ){
    netHostname = hostname;
    netPort = port;
    netIpAddress = ipAddress;
  }

  @override
  List<DeviceDataField> get dataFields => _impl.getDataFields();

  @override
  List<DeviceCategoryConfig> get categoryConfigs => _impl.getCategoryConfigs();

  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();
    return await _impl.sendCommand(connectionService, command, params);
  }

  /// Factory constructor from JSON
  factory HoymilesInverterDevice.fromJson(Map<String, dynamic> json) {
    final device = HoymilesInverterDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      deviceSn: json['deviceSn'] as String,
      deviceModel: json['deviceModel'] as String?,
    );

    // Restore WiFi fields
    device.wifiFromJson(json);

    return device;
  }

  @override
  List<DeviceRole> getFixedRoles() => [
    DeviceRole.inverter
  ];

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'inverter', 'pv', 'power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'inverter', 'sgs', 'active_power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
