import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_category_config.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_control_item.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_data_field.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_menu_item.dart';
import 'package:the_solar_app/models/devices/generic_rendering/general_setting_item.dart';
import 'package:the_solar_app/models/devices/time_series_field_config.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/mixins/device_authentication_mixin.dart';
import 'package:the_solar_app/screens/configuration/authentication_screen.dart';
import 'package:the_solar_app/screens/configuration/general_settings_screen.dart';
import 'package:the_solar_app/screens/configuration/relay_settings_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_ap_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_service.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_wifi_v1_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';

/// Device implementation for Shelly v1 (Gen1) devices
///
/// All UI elements are generated dynamically from the /status payload:
/// - one control per entry in the `relays` array
/// - power/energy fields when a `meters` array is present (1 PM, 2 PM, 4Pro)
/// - temperature field when `tmp` is present
class ShellyV1DeviceImplementation extends DeviceImplementation {
  // Reference to the device (set after construction)
  DeviceBase? _device;

  /// Set the device reference (called by device constructor)
  void setDevice(DeviceBase device) {
    _device = device;
  }

  /// Latest raw /status payload
  Map<String, dynamic>? _getLiveData() {
    final data = _device?.data['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  /// Public access to the latest raw /status payload (used by subclasses)
  Map<String, dynamic>? get liveData => _getLiveData();

  List<dynamic> _getRelays() {
    final relays = _getLiveData()?['relays'];
    return relays is List ? relays : [];
  }

  List<dynamic> _getMeters() {
    final meters = _getLiveData()?['meters'];
    return meters is List ? meters : [];
  }

  List<dynamic> _getEmeters() {
    final emeters = _getLiveData()?['emeters'];
    return emeters is List ? emeters : [];
  }

  /// Whether the payload reports a `total_power` sum (3-phase devices)
  bool get _hasTotalPower => _getLiveData()?['total_power'] is num;

  bool? _relayState(Map<String, dynamic> data, int index) {
    return MapUtils.OM(data, ['data', 'relays', '$index', 'ison']) as bool?;
  }

  /// Meter power in watts (signed), null when device has no power metering
  double? _meterPower(Map<String, dynamic> data) {
    final power = MapUtils.OM(data, ['data', 'meters', '0', 'power']);
    return power is num ? power.toDouble() : null;
  }

  /// A single emeter reading (power/voltage/current/pf/total/total_returned)
  double? _emeterNum(Map<String, dynamic> data, int index, String key) {
    final value = MapUtils.OM(data, ['data', 'emeters', '$index', key]);
    return value is num ? value.toDouble() : null;
  }

  /// Total power in watts (sum of the phases), null when unavailable
  double? _totalPower(Map<String, dynamic> data) {
    final power = MapUtils.OM(data, ['data', 'total_power']);
    return power is num ? power.toDouble() : null;
  }

  /// Sum of a per-phase energy counter across all emeters (e.g. 'total',
  /// 'total_returned'), null when no phase reports a value
  double? _sumEmeterEnergy(Map<String, dynamic> data, String key) {
    final emeters = MapUtils.OM(data, ['data', 'emeters']);
    if (emeters is! List) return null;
    double sum = 0;
    var found = false;
    for (final e in emeters) {
      if (e is Map) {
        final v = e[key];
        if (v is num) {
          sum += v.toDouble();
          found = true;
        }
      }
    }
    return found ? sum : null;
  }

  /// Signed device power in watts: total_power (3-phase) when present, else the
  /// sum of per-phase emeter power, else the single-phase meter power
  double? _devicePower(Map<String, dynamic> data) {
    final total = _totalPower(data);
    if (total != null) return total;
    final emeters = MapUtils.OM(data, ['data', 'emeters']);
    if (emeters is List && emeters.isNotEmpty) {
      double sum = 0;
      var found = false;
      for (final e in emeters) {
        if (e is Map) {
          final p = e['power'];
          if (p is num) {
            sum += p.toDouble();
            found = true;
          }
        }
      }
      if (found) return sum;
    }
    return _meterPower(data);
  }

  static const List<String> _powerPhaseKeys = [
    FieldTranslationKeys.powerPhase1,
    FieldTranslationKeys.powerPhase2,
    FieldTranslationKeys.powerPhase3,
  ];

  static const List<String> _voltagePhaseKeys = [
    FieldTranslationKeys.voltagePhase1,
    FieldTranslationKeys.voltagePhase2,
    FieldTranslationKeys.voltagePhase3,
  ];

  static const List<String> _currentPhaseKeys = [
    FieldTranslationKeys.currentPhase1,
    FieldTranslationKeys.currentPhase2,
    FieldTranslationKeys.currentPhase3,
  ];

  static const List<String> _phaseCategoryKeys = [
    CategoryTranslationKeys.phase1,
    CategoryTranslationKeys.phase2,
    CategoryTranslationKeys.phase3,
  ];

  /// Per-phase field name: fixed Phase1/2/3 key when available, else the
  /// parameterized Instance key (robust for more than three phases)
  TO _phaseName(List<String> phaseKeys, String instanceKey, int index) {
    if (index < phaseKeys.length) {
      return TO(key: phaseKeys[index]);
    }
    return TO(key: instanceKey, params: {'instanceNum': '${index + 1}'});
  }

  /// Category display-name key for a phase index (null beyond the fixed keys)
  String? _phaseCategoryKey(int index) =>
      index < _phaseCategoryKeys.length ? _phaseCategoryKeys[index] : null;

  @override
  List<DeviceMenuItem> getMenuItems() {
    return [
      DeviceMenuItem(
        name: const TO(key: MenuTranslationKeys.generalSettings),
        subtitle: const TO(key: MenuSubtitleKeys.generalSettingsSubtitle),
        icon: Icons.settings,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingDeviceData,
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            showErrorDialog: false,
          );

          if (resp == null || !context.mounted) return;

          await NavigationUtils.pushConfigurationScreen(
            context,
            GeneralSettingsScreen(
              device: device,
              settings: getGeneralSettings(resp),
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: const TO(key: MenuTranslationKeys.relaySettings),
        subtitle: const TO(key: MenuSubtitleKeys.relaySettingsSubtitle),
        icon: Icons.settings_input_component,
        iconColor: Colors.teal,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingDeviceData,
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            showErrorDialog: false,
          );

          if (resp == null || !context.mounted) return;

          await NavigationUtils.pushConfigurationScreen(
            context,
            RelaySettingsScreen(
              device: device,
              groups: getRelaySettings(resp),
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: const TO(key: MenuTranslationKeys.authentication),
        subtitle: const TO(key: MenuSubtitleKeys.authenticationSubtitle),
        icon: Icons.lock,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingCurrentConfig,
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            showErrorDialog: false,
          );

          if (resp == null || !context.mounted) return;

          final authDev = device as DeviceAuthenticationMixin;
          final login = resp['login'];
          final currentEnabled = login is Map ? (login['enabled'] as bool? ?? false) : false;

          await NavigationUtils.pushConfigurationScreen(
            context,
            AuthenticationScreen(
              device: device,
              currentUsername: authDev.authUsername ?? 'admin',
              currentPassword: null,
              currentEnabled: currentEnabled,
              usernameEditable: !authDev.fixedUserName,
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: const TO(key: MenuTranslationKeys.wifiConfiguration),
        subtitle: const TO(key: MenuSubtitleKeys.wifiConfigurationSubtitle),
        icon: Icons.wifi,
        iconColor: Colors.green,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingCurrentConfig,
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, context.l10n.errorWhileLoadingConfig(e.toString())),
          );

          if (resp == null || !context.mounted) return;

          final currentSsid = MapUtils.OMas<String?>(resp, ['wifi_sta', 'ssid'], null);
          final currentActivated = MapUtils.OMas<bool?>(resp, ['wifi_sta', 'enabled'], true) ?? true;

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiConfigurationScreen(
              device: device,
              currentSsid: currentSsid,
              showActivateToggle: true,
              initialActivated: currentActivated,
            ),
          );

          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.messageWifiConfigComplete),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
      DeviceMenuItem(
        name: const TO(key: MenuTranslationKeys.accessPointConfiguration),
        subtitle: const TO(key: MenuSubtitleKeys.accessPointSubtitle),
        icon: Icons.router,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingCurrentConfig,
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, context.l10n.errorWhileLoadingConfig(e.toString())),
          );

          if (resp == null || !context.mounted) return;

          final apKey = MapUtils.OMas<String?>(resp, ['wifi_ap', 'key'], '') ?? '';

          await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiApConfigurationScreen(
              device: device,
              showSsidOption: false,
              showEnabledOption: true,
              enabledOptionRequiresExpert: false,
              showOpenOption: true,
              showRangeExtenderOption: false,
              currentEnabled: MapUtils.OMas<bool?>(resp, ['wifi_ap', 'enabled'], false) ?? false,
              currentPassword: apKey,
              currentIsOpen: apKey.isEmpty,
              fixedSsid: MapUtils.OMas<String?>(resp, ['wifi_ap', 'ssid'], null),
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: const TO(key: MenuTranslationKeys.restartDevice),
        subtitle: const TO(key: MenuSubtitleKeys.restartDeviceSubtitle),
        icon: Icons.restart_alt,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: Text(context.l10n.menuRestartDevice),
              content: Text(context.l10n.restartDeviceConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.l10n.menuRestartDevice),
                ),
              ],
            ),
          );

          if (confirmed != true) return;

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.messageDeviceRestarting,
            operation: () async {
              await device.sendCommand(COMMAND_RESTART, {});
              await Future.delayed(const Duration(seconds: 1));
              return true;
            },
            onSuccess: (_) => MessageUtils.showSuccess(context, context.l10n.messageDeviceRestarting),
            onError: (e) => MessageUtils.showError(context, context.l10n.errorWhileRestarting(e.toString())),
          );
        },
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() {
    final relays = _getRelays();
    if (relays.isEmpty) return [];

    final controls = <DeviceControlItem>[];

    for (int id = 0; id < relays.length; id++) {
      controls.add(DeviceControlItem(
        name: TO(key: FieldTranslationKeys.switchInstance, params: {'instanceNum': id + 1}),
        type: ControlType.switchToggle,
        icon: Icons.power,
        valueExtractor: (data) => _relayState(data, id),
        onChanged: (context, device, newValue) async {
          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: (newValue == true)
                ? context.l10n.switchToggleOnLoading(id + 1)
                : context.l10n.switchToggleOffLoading(id + 1),
            operation: () async {
              await device.sendCommand(COMMAND_SET_MAIN_POWER, {
                'id': id,
                'on': newValue,
              });

              // Update local state
              final live = device.data['data'];
              if (live is Map<String, dynamic>) {
                final relays = live['relays'];
                if (relays is List && id < relays.length && relays[id] is Map) {
                  (relays[id] as Map)['ison'] = newValue;
                  device.emitData(live);
                }
              }
            },
            showErrorDialog: true,
          );
        },
      ));
    }

    return controls;
  }

  @override
  List<DeviceDataField> getDataFields() {
    final fields = <DeviceDataField>[];
    final emeters = _getEmeters();

    if (emeters.isNotEmpty) {
      // Per-phase energy meter readings (EM / 3EM report an `emeters` array)
      for (int i = 0; i < emeters.length; i++) {
        final category = 'phase${i + 1}';
        fields.add(DeviceDataField(
          name: _phaseName(_powerPhaseKeys, FieldTranslationKeys.powerInstance, i),
          type: DataFieldType.watt,
          valueExtractor: (data) => _emeterNum(data, i, 'power'),
          icon: Icons.power,
          category: category,
        ));
        fields.add(DeviceDataField(
          name: _phaseName(_voltagePhaseKeys, FieldTranslationKeys.voltageInstance, i),
          type: DataFieldType.voltage,
          valueExtractor: (data) => _emeterNum(data, i, 'voltage'),
          icon: Icons.electric_bolt,
          expertMode: true,
          category: category,
        ));
        fields.add(DeviceDataField(
          name: _phaseName(_currentPhaseKeys, FieldTranslationKeys.currentInstance, i),
          type: DataFieldType.current,
          valueExtractor: (data) => _emeterNum(data, i, 'current'),
          icon: Icons.flash_on,
          expertMode: true,
          category: category,
        ));
        fields.add(DeviceDataField(
          name: TO(key: FieldTranslationKeys.powerFactorInstance, params: {'instanceNum': '${i + 1}'}),
          type: DataFieldType.powerFactor,
          valueExtractor: (data) => _emeterNum(data, i, 'pf'),
          icon: Icons.analytics,
          expertMode: true,
          category: category,
        ));
        fields.add(DeviceDataField(
          name: const TO(key: FieldTranslationKeys.totalEnergyImport),
          type: DataFieldType.energy,
          valueExtractor: (data) => _emeterNum(data, i, 'total'),
          icon: Icons.arrow_downward,
          category: category,
        ));
        fields.add(DeviceDataField(
          name: const TO(key: FieldTranslationKeys.totalEnergyExport),
          type: DataFieldType.energy,
          valueExtractor: (data) => _emeterNum(data, i, 'total_returned'),
          icon: Icons.arrow_upward,
          expertMode: true,
          category: category,
        ));
      }

      // Totals (only when the device reports a total_power sum, e.g. 3EM)
      if (_hasTotalPower) {
        fields.add(DeviceDataField(
          name: const TO(key: FieldTranslationKeys.totalPower),
          type: DataFieldType.watt,
          valueExtractor: (data) => _totalPower(data),
          icon: Icons.power_settings_new,
          category: 'totals',
        ));
        fields.add(DeviceDataField(
          name: const TO(key: FieldTranslationKeys.totalEnergyImport),
          type: DataFieldType.energy,
          valueExtractor: (data) => _sumEmeterEnergy(data, 'total'),
          icon: Icons.arrow_downward,
          category: 'totals',
        ));
        fields.add(DeviceDataField(
          name: const TO(key: FieldTranslationKeys.totalEnergyExport),
          type: DataFieldType.energy,
          valueExtractor: (data) => _sumEmeterEnergy(data, 'total_returned'),
          icon: Icons.arrow_upward,
          expertMode: true,
          category: 'totals',
        ));
      }
    } else if (_getMeters().isNotEmpty) {
      // Single-phase power metering (1 PM, 2 PM, 4Pro report a `meters` array)
      fields.add(DeviceDataField(
        name: const TO(key: FieldTranslationKeys.power),
        type: DataFieldType.watt,
        valueExtractor: (data) => _meterPower(data),
        icon: Icons.power,
      ));
      fields.add(DeviceDataField(
        name: const TO(key: FieldTranslationKeys.totalEnergy),
        type: DataFieldType.energy,
        valueExtractor: (data) {
          final total = MapUtils.OM(data, ['data', 'meters', '0', 'total']);
          return total is num ? total.toDouble() : null;
        },
        icon: Icons.bar_chart,
        expertMode: true,
      ));
    }

    // Temperature (only when tmp sensor data is present)
    final tmp = _getLiveData()?['tmp'];
    if (tmp is Map) {
      fields.add(DeviceDataField(
        name: const TO(key: FieldTranslationKeys.temperature),
        type: DataFieldType.temperature,
        valueExtractor: (data) {
          final tC = MapUtils.OM(data, ['data', 'tmp', 'tC']);
          return tC is num ? tC.toDouble() : null;
        },
        icon: Icons.thermostat,
      ));
    }

    return fields;
  }

  @override
  IconData? getDeviceIcon() {
    if (_getEmeters().isNotEmpty || _getMeters().isNotEmpty) return Icons.electric_meter;
    return Icons.power;
  }

  @override
  List<TimeSeriesFieldConfig> getTimeSeriesFields() {
    final fields = <TimeSeriesFieldConfig>[];
    final emeters = _getEmeters();

    if (emeters.isNotEmpty) {
      for (int i = 0; i < emeters.length; i++) {
        fields.add(TimeSeriesFieldConfig(
          name: _phaseName(_powerPhaseKeys, FieldTranslationKeys.powerInstance, i),
          type: DataFieldType.watt,
          mapping: ['emeters', '$i', 'power'],
          expertMode: false,
        ));
        fields.add(TimeSeriesFieldConfig(
          name: _phaseName(_voltagePhaseKeys, FieldTranslationKeys.voltageInstance, i),
          type: DataFieldType.voltage,
          mapping: ['emeters', '$i', 'voltage'],
          expertMode: true,
        ));
        fields.add(TimeSeriesFieldConfig(
          name: _phaseName(_currentPhaseKeys, FieldTranslationKeys.currentInstance, i),
          type: DataFieldType.current,
          mapping: ['emeters', '$i', 'current'],
          expertMode: true,
        ));
      }
      if (_hasTotalPower) {
        fields.add(TimeSeriesFieldConfig(
          name: const TO(key: FieldTranslationKeys.totalPower),
          type: DataFieldType.watt,
          mapping: ['total_power'],
          expertMode: false,
        ));
      }
    } else if (_getMeters().isNotEmpty) {
      fields.add(TimeSeriesFieldConfig(
        name: const TO(key: FieldTranslationKeys.power),
        type: DataFieldType.watt,
        mapping: ['meters', '0', 'power'],
        expertMode: false,
        hideIfEmpty: true,
      ));
    }

    return fields;
  }

  @override
  List<DeviceCategoryConfig> getCategoryConfigs() {
    final emeters = _getEmeters();
    if (emeters.isEmpty) return [];

    final configs = <DeviceCategoryConfig>[];
    for (int i = 0; i < emeters.length; i++) {
      configs.add(DeviceCategoryConfig(
        category: 'phase${i + 1}',
        displayName: 'Phase ${i + 1}',
        displayNameKey: _phaseCategoryKey(i),
        order: 10 * (i + 1),
        layout: CategoryLayout.standard,
      ));
    }
    if (_hasTotalPower) {
      configs.add(DeviceCategoryConfig(
        category: 'totals',
        displayName: 'Totals',
        displayNameKey: CategoryTranslationKeys.totals,
        order: 10 * (emeters.length + 1),
        layout: CategoryLayout.standard,
      ));
    }
    return configs;
  }

  /// Returns configurable roles for Shelly v1 devices
  List<DeviceRole> getConfigurableRoles() {
    return [
      DeviceRole.inverter,
      DeviceRole.smartMeter,
      DeviceRole.load,
    ];
  }

  /// InverterCapability - extract solar production (negative device power)
  double? getSolarPVPower(Map<String, dynamic> data) {
    final power = _devicePower(data);
    if (power == null) return null;
    return math.max(0.0, -power);
  }

  double? getSolarGridPower(Map<String, dynamic> data) {
    return getSolarPVPower(data);
  }

  /// SmartMeterCapability - bidirectional measurement
  double? getGridPower(Map<String, dynamic> data) {
    return _devicePower(data);
  }

  /// LoadCapability - extract consumption (positive device power)
  double? getLoadPower(Map<String, dynamic> data) {
    final power = _devicePower(data);
    if (power == null) return null;
    return math.max(0.0, power);
  }

  /// Returns the list of general settings available for this Shelly v1 device
  ///
  /// [config] is the raw /settings payload
  List<GeneralSettingItem> getGeneralSettings(Map<String, dynamic> config) {
    final cloud = config['cloud'];
    final settings = <GeneralSettingItem>[
      GeneralSettingItem(
        name: const TO(key: FieldTranslationKeys.settingLed),
        commandName: GENERAL_SETTINGS_LED_STATUS,
        currentStatus: !(config['led_status_disable'] as bool? ?? false),
        description: const TO(key: FieldTranslationKeys.settingLedDesc),
        icon: Icons.lightbulb,
        popUpOnChange: false,
      ),
      GeneralSettingItem(
        name: const TO(key: FieldTranslationKeys.settingDiscoverable),
        commandName: GENERAL_SETTINGS_DISCOVERABLE,
        currentStatus: config['discoverable'] as bool? ?? true,
        description: const TO(key: FieldTranslationKeys.settingDiscoverableDescV1),
        icon: Icons.visibility,
        popUpOnChange: false,
      ),
      GeneralSettingItem(
        name: const TO(key: FieldTranslationKeys.settingEcoMode),
        commandName: GENERAL_SETTGINS_ECO_MODE,
        currentStatus: config['eco_mode_enabled'] as bool? ?? false,
        description: const TO(key: FieldTranslationKeys.settingEcoModeDesc),
        icon: Icons.eco,
      ),
      GeneralSettingItem(
        name: const TO(key: FieldTranslationKeys.settingDebugMode),
        commandName: GENERAL_SETTINGS_DEBUG_ENABLE,
        currentStatus: config['debug_enable'] as bool? ?? false,
        description: const TO(key: FieldTranslationKeys.settingDebugModeDesc),
        icon: Icons.bug_report,
      ),
      GeneralSettingItem(
        name: const TO(key: FieldTranslationKeys.settingCloud),
        commandName: GENERAL_SETTINGS_CLOUD,
        currentStatus: cloud is Map ? (cloud['enabled'] as bool? ?? false) : false,
        description: const TO(key: FieldTranslationKeys.settingCloudDesc),
        icon: Icons.cloud,
        popUpOnChange: false,
      ),
      GeneralSettingItem(
        name: const TO(key: FieldTranslationKeys.settingPonWifiReset),
        commandName: GENERAL_SETTINGS_PON_WIFI_RESET,
        currentStatus: config['pon_wifi_reset'] as bool? ?? false,
        description: const TO(key: FieldTranslationKeys.settingPonWifiResetDesc),
        icon: Icons.power_settings_new,
      ),
    ];

    return settings;
  }

  /// Builds the per-relay settings groups from the /settings payload, one group
  /// per relay (titled with the relay's own name). Shelly Gen1 relays expose
  /// string-enum settings on /settings/relay/{id}.
  List<SettingsGroup> getRelaySettings(Map<String, dynamic> config) {
    final relays = config['relays'];
    if (relays is! List || relays.isEmpty) return [];

    final groups = <SettingsGroup>[];

    for (int i = 0; i < relays.length; i++) {
      final relay = relays[i];
      if (relay is! Map) continue;

      final btnType = relay['btn_type'] as String? ?? 'toggle';
      final defaultState = relay['default_state'] as String? ?? 'last';

      final name = relay['name'];
      final title = (name is String && name.isNotEmpty) ? name : 'Relay ${i + 1}';

      groups.add(SettingsGroup(
        title: title,
        items: [
          GeneralSettingItem(
            name: const TO(key: FieldTranslationKeys.settingBtnType),
            commandName: '${GENERAL_SETTINGS_RELAY_BTN_TYPE}_$i',
            type: SettingType.dropdown,
            currentValue: btnType,
            options: _btnTypeOptions(btnType),
            popUpOnChange: false,
            description: const TO(key: FieldTranslationKeys.settingBtnTypeDesc),
            icon: Icons.touch_app,
          ),
          GeneralSettingItem(
            name: const TO(key: FieldTranslationKeys.settingDefaultState),
            commandName: '${GENERAL_SETTINGS_RELAY_DEFAULT_STATE}_$i',
            type: SettingType.dropdown,
            currentValue: defaultState,
            options: _defaultStateOptions(defaultState),
            popUpOnChange: false,
            description: const TO(key: FieldTranslationKeys.settingDefaultStateDesc),
            icon: Icons.power_settings_new,
          ),
        ],
      ));
    }

    return groups;
  }

  /// Button action options. The device's current value is always included so the
  /// dropdown can display it even if it is not one of the documented values.
  List<SettingOption> _btnTypeOptions(String current) {
    const pairs = <(String, String)>[
      ('toggle', 'Umschalten'),
      ('momentary', 'Momentan'),
      ('edge', 'Flanke'),
      ('detached', 'Getrennt'),
      ('action', 'Aktion'),
      ('momentary_on_release', 'Bei Loslassen'),
    ];
    return _toSettingOptions(pairs, current);
  }

  /// Power-on state options.
  List<SettingOption> _defaultStateOptions(String current) {
    const pairs = <(String, String)>[
      ('off', 'Aus'),
      ('on', 'Ein'),
      ('last', 'Letzter Zustand'),
      ('switch', 'Wie Taste'),
    ];
    return _toSettingOptions(pairs, current);
  }

  List<SettingOption> _toSettingOptions(List<(String, String)> pairs, String current) {
    final options = pairs.map((p) => SettingOption(label: p.$2, value: p.$1)).toList();
    if (!pairs.any((p) => p.$1 == current)) {
      options.add(SettingOption(label: current, value: current));
    }
    return options;
  }

  bool? _readBoolAt(Map<String, dynamic> map, String path) {
    dynamic node = map;
    for (final part in path.split('.')) {
      if (node is! Map) return null;
      final next = node[part];
      if (next is Map || next is bool || next is num) {
        node = next;
      } else {
        return null;
      }
    }
    if (node is bool) return node;
    if (node is int) return node != 0;
    return null;
  }

  bool? _firstAvailableBool(Map<String, dynamic> resp, List<String> paths) {
    for (final path in paths) {
      final value = _readBoolAt(resp, path);
      if (value != null) return value;
    }
    return null;
  }

  /// Set a per-relay string-enum setting and verify the echoed value.
  ///
  /// [fullName] is the command name with the relay index appended
  /// (e.g. "relay_btn_type_0"); [prefix] is the constant without the index.
  Future<Map<String, dynamic>?> _setRelayParam(
    ShellyService service,
    String fullName,
    String prefix,
    String param,
    dynamic value,
  ) async {
    final id = int.tryParse(fullName.substring(prefix.length + 1)) ?? 0;
    final resp = await service.sendCommand(ShellyWifiV1Service.CMD_SET_RELAY_PARAM, {
      'id': id,
      'param': param,
      'value': value as String,
    });

    // /settings/relay/{id} returns the relay object; on v1.14 the catch-all may
    // return the full settings. Verify the echoed value in both shapes.
    final echoed = _firstAvailableString(resp, [param, 'relays.$id.$param']);
    if (resp != null && resp['status'] != 'ok' && echoed != null && echoed != value) {
      throw Exception('Setting was not applied (device value: $echoed)');
    }

    return {'success': true, 'setting': fullName, 'value': value};
  }

  String? _readStringAt(Map<String, dynamic> map, String path) {
    dynamic node = map;
    for (final part in path.split('.')) {
      if (node is Map) {
        node = node[part];
      } else if (node is List) {
        final idx = int.tryParse(part);
        node = (idx != null && idx < node.length) ? node[idx] : null;
      } else {
        return null;
      }
    }
    return node is String ? node : null;
  }

  String? _firstAvailableString(Map<String, dynamic>? resp, List<String> paths) {
    if (resp == null) return null;
    for (final path in paths) {
      final value = _readStringAt(resp, path);
      if (value != null) return value;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    final service = connectionService as ShellyService;

    if (command == COMMAND_FETCH_DATA) {
      return await service.sendCommand(ShellyWifiV1Service.CMD_GET_STATUS, {});
    } else if (command == COMMAND_FETCH_DEVICE_INFO) {
      return await service.sendCommand(ShellyWifiV1Service.CMD_GET_DEVICE_INFO, {});
    } else if (command == COMMAND_FETCH_WIFI_CONFIG) {
      return await service.sendCommand(ShellyWifiV1Service.CMD_GET_SETTINGS, {});
    } else if (command == COMMAND_FETCH_SYS_CONFIG) {
      return await service.sendCommand(ShellyWifiV1Service.CMD_GET_SETTINGS, {});
    } else if (command == COMMAND_SET_GENERAL_SETTING) {
      final name = params["name"] as String?;
      final value = params["value"];
      if (name == null || value == null) {
        throw Exception("could not set general setting: name or value is missing");
      }

      // Per-relay string-enum settings (button action, power-on state)
      if (name.startsWith('${GENERAL_SETTINGS_RELAY_BTN_TYPE}_')) {
        return await _setRelayParam(service, name, GENERAL_SETTINGS_RELAY_BTN_TYPE, 'btn_type', value);
      }
      if (name.startsWith('${GENERAL_SETTINGS_RELAY_DEFAULT_STATE}_')) {
        return await _setRelayParam(service, name, GENERAL_SETTINGS_RELAY_DEFAULT_STATE, 'default_state', value);
      }

      // v1.14 set-syntax: GET /settings?<field>=true|false (nested: /settings/cloud?enabled=...)
      String path;
      String param;
      List<String> verifyPaths;
      bool inverted = false;
      if (name == GENERAL_SETTINGS_LED_STATUS) {
        path = '/settings';
        param = 'led_status_disable';
        verifyPaths = ['led_status_disable'];
        inverted = true;
      } else if (name == GENERAL_SETTINGS_DEBUG_ENABLE) {
        path = '/settings';
        param = 'debug_enable';
        verifyPaths = ['debug_enable'];
      } else if (name == GENERAL_SETTGINS_ECO_MODE) {
        path = '/settings';
        param = 'eco_mode_enabled';
        verifyPaths = ['eco_mode_enabled'];
      } else if (name == GENERAL_SETTINGS_DISCOVERABLE) {
        path = '/settings';
        param = 'discoverable';
        verifyPaths = ['discoverable'];
      } else if (name == GENERAL_SETTINGS_CLOUD) {
        path = '/settings/cloud';
        param = 'enabled';
        verifyPaths = ['cloud.enabled', 'enabled'];
      } else if (name == GENERAL_SETTINGS_PON_WIFI_RESET) {
        path = '/settings';
        param = 'pon_wifi_reset';
        verifyPaths = ['pon_wifi_reset'];
      } else {
        throw UnimplementedError('General setting not implemented: $name');
      }

      final expected = inverted ? !value : value;
      final resp = await service.sendCommand(ShellyWifiV1Service.CMD_SET_BOOL_SETTING, {
        'path': path,
        'param': param,
        'value': expected,
      });

      // /settings/* is a catch-all on v1.14 (200 even for unknown paths) - verify the echoed value
      if (resp != null && resp['status'] != 'ok') {
        final echoed = _firstAvailableBool(resp, verifyPaths);
        if (echoed != null && echoed != expected) {
          throw Exception('Setting was not applied (device value: $echoed)');
        }
      }

      return {'success': true, 'setting': name, 'value': value};
    } else if (command == COMMAND_SET_WIFI) {
      String? ssid = params["ssid"];
      String? password = params["password"];
      final enabled = params["enabled"] as bool? ?? true;
      if (ssid == null || password == null) {
        throw Exception("could not config wlan ssid or password empty");
      }
      return await service.sendCommand(ShellyWifiV1Service.CMD_SET_WIFI, {"ssid": ssid, "password": password, "enabled": enabled});
    } else if (command == COMMAND_SET_AP_CONFIG) {
      final isOpen = params["isOpen"] as bool? ?? false;
      final password = params["password"] as String?;
      final enabled = params["enable"] as bool?;
      return await service.sendCommand(ShellyWifiV1Service.CMD_SET_AP, {
        "key": isOpen ? '' : (password ?? ''),
        if (enabled != null) "enabled": enabled,
      });
    } else if (command == COMMAND_RESTART) {
      return await service.sendCommand(ShellyWifiV1Service.CMD_RESTART, {});
    } else if (command == COMMAND_SET_MAIN_POWER) {
      int? id = params["id"] ?? 0;
      bool? on = params["on"];
      if (on == null) throw Exception("'on' parameter missing for relay control");
      return await service.sendCommand(ShellyWifiV1Service.CMD_SET_RELAY, {"id": id, "on": on});
    } else {
      throw UnimplementedError('Command not implemented: $command');
    }
  }
}
