// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Solar App';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get select => 'Select';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get update => 'Update';

  @override
  String get install => 'Install';

  @override
  String get preview => 'Preview';

  @override
  String get connected => 'Connected';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get connecting => 'Connecting...';

  @override
  String get loadingDeviceData => 'Loading Device Data...';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get disconnecting => 'Disconnecting...';

  @override
  String get error => 'Error';

  @override
  String get deviceNotConnected => 'Device Not Connected';

  @override
  String get noResponseFromDevice => 'No Response from Device';

  @override
  String get couldNotRetrieveData => 'Could Not Retrieve Data';

  @override
  String get operationFailed => 'Operation Failed';

  @override
  String get settings => 'Settings';

  @override
  String get expertMode => 'Expert Mode';

  @override
  String get expertModeDescription => 'Show Advanced Options';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionsDescription => 'Check App Permissions';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'User Interface Language';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get exitApp => 'Exit App';

  @override
  String get version => 'Version';

  @override
  String get tapForDetails => 'Tap for Details';

  @override
  String get devices => 'Devices';

  @override
  String get knownDevices => 'Known Devices';

  @override
  String get addDevice => 'Add Device';

  @override
  String get scanForDevices => 'Scan for Devices';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceType => 'Device Type';

  @override
  String get deviceInfo => 'Device Information';

  @override
  String get deviceSettings => 'Device Settings';

  @override
  String get deleteDevice => 'Delete Device';

  @override
  String get deviceRole => 'Device Role';

  @override
  String get selectDeviceRole => 'Select Device Role';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get areYouSure => 'Are You Sure?';

  @override
  String get deleteDeviceConfirm => 'Do you really want to delete this device?';

  @override
  String get cannotBeUndone => 'This action cannot be undone.';

  @override
  String get deviceList => 'Device List';

  @override
  String get deviceDetail => 'Device Details';

  @override
  String get scanScreen => 'Scan for Devices';

  @override
  String get manualAdd => 'Manual Add';

  @override
  String get scanning => 'Scanning...';

  @override
  String get bluetoothDevices => 'Bluetooth Devices';

  @override
  String get networkDevices => 'Network Devices';

  @override
  String get noDevicesFound => 'No Devices Found';

  @override
  String devicesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Devices Found',
      one: '1 Device Found',
      zero: 'No Devices Found',
    );
    return '$_temp0';
  }

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get autoReconnect => 'Auto Reconnect';

  @override
  String get power => 'Power';

  @override
  String get voltage => 'Voltage';

  @override
  String get current => 'Current';

  @override
  String get battery => 'Battery';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get outputLimit => 'Output Limit';

  @override
  String get status => 'Status';

  @override
  String get temperature => 'Temperature';

  @override
  String get energy => 'Energy';

  @override
  String get parameters => 'Parameters';

  @override
  String get configureParameters => 'Configure Parameters';

  @override
  String get newParametersAvailable => 'New Parameters Available';

  @override
  String get updateToNewVersion => 'Update to New Version?';

  @override
  String get updateParameters => 'Update Parameters';

  @override
  String get directInstall => 'Direct Install';

  @override
  String get installOnDevice => 'Install on Device';

  @override
  String get createFromTemplate => 'Create from Template';

  @override
  String get scripts => 'Scripts';

  @override
  String get deleteScript => 'Delete Script?';

  @override
  String get installScript => 'Install Script?';

  @override
  String get autostartEnabled => 'Autostart Enabled';

  @override
  String get showAllScripts => 'Show All Scripts';

  @override
  String get compatibilityInfo => 'Compatibility Information';

  @override
  String get loading => 'Loading...';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get name => 'Name';

  @override
  String get value => 'Value';

  @override
  String get description => 'Description';

  @override
  String get savedSuccessfully => 'Saved Successfully';

  @override
  String get deletedSuccessfully => 'Deleted Successfully';

  @override
  String get updatedSuccessfully => 'Updated Successfully';

  @override
  String get installedSuccessfully => 'Installed Successfully';

  @override
  String get connectedSuccessfully => 'Connected Successfully';

  @override
  String get disconnectedSuccessfully => 'Disconnected Successfully';

  @override
  String get noItemSelected => 'No Item Selected';

  @override
  String get selectItemFromList => 'Select an Item from the List';

  @override
  String errorWhileSaving(String error) {
    return 'Error while saving: $error';
  }

  @override
  String errorWhileLoading(String error) {
    return 'Error while loading: $error';
  }

  @override
  String errorWhileToggling(String error) {
    return 'Error while toggling: $error';
  }

  @override
  String errorWhileExecuting(String error) {
    return 'Error while executing: $error';
  }

  @override
  String errorWhileAdjusting(String error) {
    return 'Error while adjusting: $error';
  }

  @override
  String errorWhileRestarting(String error) {
    return 'Error while restarting device: $error';
  }

  @override
  String errorWhileDisconnecting(String error) {
    return 'Error while disconnecting: $error';
  }

  @override
  String get errorWhileUploading => 'Error while uploading code';

  @override
  String errorWhileLoadingConfig(String error) {
    return 'Error while loading configuration: $error';
  }

  @override
  String errorCouldNotRetrieveScripts(String error) {
    return 'Could not retrieve scripts: $error';
  }

  @override
  String get errorCouldNotRetrieveScriptCode =>
      'Could not retrieve script code';

  @override
  String get errorCouldNotLoadLatestVersion => 'Could not load latest version';

  @override
  String get validationFieldCannotBeEmpty => 'Field cannot be empty';

  @override
  String get validationDeviceNameCannotBeEmpty => 'Device name cannot be empty';

  @override
  String get validationUsernameCannotBeEmpty => 'Username cannot be empty';

  @override
  String get validationMqttServerCannotBeEmpty => 'MQTT server cannot be empty';

  @override
  String get validationEnterIpOrHostname =>
      'Please enter IP address or hostname';

  @override
  String get validationEnterSecurePassword => 'Enter a secure password';

  @override
  String get formUsername => 'Username';

  @override
  String get formPassword => 'Password';

  @override
  String get formSsid => 'SSID';

  @override
  String get formPort => 'Port';

  @override
  String get formHostname => 'Hostname';

  @override
  String get formIpAddress => 'IP Address';

  @override
  String get formManufacturer => 'Manufacturer';

  @override
  String get formEnterUsername => 'Enter username';

  @override
  String get formEnterPassword => 'Enter password';

  @override
  String get formEnterPort => 'Enter port number';

  @override
  String get formEnterSsid => 'Enter SSID';

  @override
  String get formEnterWifiPassword => 'WiFi Password';

  @override
  String get formSelectOrEnterWifiNetwork =>
      'Enter or select WiFi network name';

  @override
  String get formProtocolPort => 'Protocol Port (e.g. Modbus)';

  @override
  String get formAdditionalPortHelper =>
      'Additional port for protocol communication';

  @override
  String get messageDeviceNameSaved => 'Device name saved';

  @override
  String get messageDeviceSaved => 'Device saved';

  @override
  String get messageDeviceRestarting => 'Device is restarting';

  @override
  String get messagePowerLimitSet => 'Power limit set successfully';

  @override
  String get messageMqttEnabled => 'MQTT connection enabled';

  @override
  String get messageMqttDisabled => 'MQTT connection disabled';

  @override
  String get messageAuthSaved => 'Authentication saved';

  @override
  String get messageNetworkSaved => 'Network saved';

  @override
  String get messageIntervalSaved => 'Interval saved';

  @override
  String get messageSaving => 'Saving...';

  @override
  String get statusDeviceNotFound => 'Device not found';

  @override
  String get statusConnectionError => 'Connection error';

  @override
  String get statusNoInvertersFound => 'No inverters found';

  @override
  String get statusNoScriptsFound => 'No scripts found';

  @override
  String get statusDeviceAlreadyInSystem => 'Device already in system';

  @override
  String get statusDeviceRemoved => 'Device removed';

  @override
  String get statusDeviceHasNoRoleConfig => 'Device has no role configuration';

  @override
  String get statusDeviceHasNoConfigurableRoles =>
      'Device has no configurable roles';

  @override
  String get screenDeviceSettings => 'Device Settings';

  @override
  String get screenAuthentication => 'Authentication';

  @override
  String get screenMqttConfig => 'MQTT Configuration';

  @override
  String get screenWifiConfig => 'Configure WiFi';

  @override
  String get screenGeneralSettings => 'General Settings';

  @override
  String get screenManualDeviceAdd => 'Add Device Manually';

  @override
  String get screenNetworkConfig => 'Network Connection';

  @override
  String get screenAccessPointConfig => 'Access Point Configuration';

  @override
  String get screenUpdateParameters => 'Update Parameters';

  @override
  String get screenAutomation => 'Automation';

  @override
  String get actionSaveNetwork => 'Save Network';

  @override
  String get actionSaveAuth => 'Save Authentication';

  @override
  String get actionSaveInterval => 'Save Interval';

  @override
  String get actionSetupNetwork => 'Setup network connection';

  @override
  String get actionSetupAccessPoint => 'Setup WiFi access point';

  @override
  String get actionSetupAuth => 'Setup username and password';

  @override
  String get actionLimitOutput => 'Limit output power';

  @override
  String get actionToggleInverters => 'Toggle inverters on/off';

  @override
  String get actionTogglesAllInverters => 'Toggles all inverters';

  @override
  String get actionRestart => 'Restart';

  @override
  String get helpDeviceSettingsDescription =>
      'Configure the name and authentication for this device.';

  @override
  String get helpMqttDescription =>
      'Connect your device to an MQTT broker for Home Automation integration.';

  @override
  String get helpEnableOrDisableMqtt =>
      'Enables or disables the MQTT connection';

  @override
  String get helpEnableOrDisableAp => 'Enables or disables the access point';

  @override
  String get helpApWarning =>
      'Warning: When disabled, interaction with the device may no longer be possible. Use with caution!';

  @override
  String get helpOpenNetwork => 'Network without password (not recommended)';

  @override
  String get helpUpdateIntervalDescription =>
      'Time interval between data fetches from the device';

  @override
  String get helpIntervalDefault => 'Default: 30 seconds (Range: 1-300)';

  @override
  String get helpAuthDescription =>
      'Username and password for device authentication';

  @override
  String get wifiEnableAccessPoint => 'Enable Access Point';

  @override
  String get wifiOpenNetwork => 'Open Network';

  @override
  String get wifiConfigureWifi => 'Configure WiFi';

  @override
  String get wifiSsidLabel => 'SSID';

  @override
  String get wifiPasswordLabel => 'Password';

  @override
  String get wifiSelectNetwork => 'Select Network';

  @override
  String get wifiEnterNetworkName => 'Enter Network Name';

  @override
  String get wifiApMode => 'Access Point Mode';

  @override
  String get wifiStationMode => 'Station Mode';

  @override
  String get wifiScanNetworks => 'Scan Networks';

  @override
  String get wifiNoNetworksFound => 'No Networks Found';

  @override
  String get wifiConnectionStrength => 'Connection Strength';

  @override
  String get mqttConfiguration => 'MQTT Configuration';

  @override
  String get mqttEnable => 'Enable MQTT';

  @override
  String get mqttServer => 'MQTT Server';

  @override
  String get mqttPort => 'MQTT Port';

  @override
  String get mqttTopic => 'MQTT Topic';

  @override
  String get mqttUsername => 'MQTT Username';

  @override
  String get mqttPassword => 'MQTT Password';

  @override
  String get mqttQos => 'QoS Level';

  @override
  String get authTitle => 'Authentication';

  @override
  String get authUsername => 'Username';

  @override
  String get authPassword => 'Password';

  @override
  String get authUsernameCannotBeChanged => 'Username cannot be changed';

  @override
  String get authRequired => 'Authentication required';

  @override
  String get networkIpAddress => 'IP Address';

  @override
  String get networkHostname => 'Hostname';

  @override
  String get networkPort => 'Port';

  @override
  String get networkSubnet => 'Subnet';

  @override
  String get networkGateway => 'Gateway';

  @override
  String get networkDns => 'DNS Server';

  @override
  String get menuSetupNetwork => 'Setup network connection';

  @override
  String get menuSetupAccessPoint => 'Set Up WiFi Access Point';

  @override
  String get menuSetupAuth => 'Setup username and password';

  @override
  String get menuLimitPower => 'Limit output power';

  @override
  String get menuLampAndEmergency => 'Lamp and emergency outlet';

  @override
  String get menuToggleInverters => 'Toggles all inverters';

  @override
  String get menuConfigureDevice => 'Configure device';

  @override
  String get intervalUpdateInterval => 'Update Interval';

  @override
  String get intervalSeconds => 'Seconds';

  @override
  String get intervalEnterInterval => 'Interval (seconds)';

  @override
  String intervalDefaultRange(int defaultValue, int min, int max) {
    return 'Default: $defaultValue seconds (Range: $min-$max)';
  }

  @override
  String get intervalDescription =>
      'Time interval between data fetches from the device';

  @override
  String get systemGrid => 'Grid';

  @override
  String get systemConsumer => 'Consumer';

  @override
  String get systemAdditionalLoad => 'Additional Load';

  @override
  String get systemInverter => 'Inverter';

  @override
  String get systemBattery => 'Battery';

  @override
  String get systemSolarPanels => 'Solar Panels';

  @override
  String get deviceOff => 'Off';

  @override
  String get deviceOn => 'On';

  @override
  String get deviceAuto => 'Automatic';

  @override
  String get deviceManual => 'Manual';

  @override
  String get deviceResetToDefaults => 'Reset to Defaults';

  @override
  String get deviceFactoryReset => 'Factory Reset';

  @override
  String powerRange(int min, int max) {
    return 'Range: $min - $max W';
  }

  @override
  String get powerLimit => 'Power Limit';

  @override
  String get powerOutput => 'Power Output';

  @override
  String get powerInput => 'Power Input';

  @override
  String get powerConsumption => 'Consumption';

  @override
  String get tabDevices => 'Devices';

  @override
  String get tabNetwork => 'Network';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabSystems => 'Systems';

  @override
  String get tabSettings => 'Settings';

  @override
  String get miscRange => 'Range';

  @override
  String get miscDefault => 'Default';

  @override
  String get miscOptional => 'Optional';

  @override
  String get miscRequired => 'Required';

  @override
  String get actionRemoveDevice => 'Remove Device';

  @override
  String confirmRemoveDevice(String deviceName) {
    return 'Do you really want to remove \"$deviceName\"?';
  }

  @override
  String get actionRemove => 'Remove';

  @override
  String errorWhileRemoving(String error) {
    return 'Error while removing: $error';
  }

  @override
  String get actionCreateNewSystem => 'Create New System';

  @override
  String get formSystemName => 'System Name';

  @override
  String get actionCreate => 'Create';

  @override
  String get screenMyDevices => 'My Devices';

  @override
  String get screenSystems => 'Systems';

  @override
  String get actionLiveCharts => 'Live Charts';

  @override
  String get actionMoreFunctions => 'More Functions';

  @override
  String get emptyStateNoDevices => 'No Devices';

  @override
  String get emptyStateAddFirstDevice => 'Add your first device';

  @override
  String get actionAddDevice => 'Add Device';

  @override
  String get labelDevice => 'Device';

  @override
  String get emptyStateNoDeviceSelected => 'No Device Selected';

  @override
  String get actionAddSystem => 'Add System';

  @override
  String get labelPermissions => 'Permissions';

  @override
  String get errorNoWifiLanConnection =>
      'Network scan is only possible via WiFi or LAN.\n\nPlease connect to a WiFi network or LAN and try again.';

  @override
  String get titleNoWifiLanConnection => 'No WiFi/LAN Connection';

  @override
  String errorNoPrivateNetwork(String ips) {
    return 'No private networks found.\n\nFound IPs: $ips\n\nMake sure you are connected to a local network.';
  }

  @override
  String get titleNoPrivateNetwork => 'No Private Network';

  @override
  String get errorNetworkScan => 'Network Scan Error';

  @override
  String get errorNotConnectedToWifi =>
      'Not connected to WiFi. Please enable WiFi.';

  @override
  String errorNetworkScanWithDetails(String error) {
    return 'Network scan error: $error';
  }

  @override
  String warningPublicNetwork(String currentIp) {
    return 'Your current IP address does not appear to be in a private network.\n\nCurrent IP: $currentIp\n\nScanning public IP ranges may not be useful. Make sure you are connected to a local WiFi network.\n\nDo you want to continue anyway?';
  }

  @override
  String get titleWarningPublicNetwork => 'Warning: Public Network';

  @override
  String get actionOkContinue => 'OK, Continue';

  @override
  String messageIpUpdated(
    String oldIp,
    String oldPort,
    String newIp,
    String newPort,
  ) {
    return 'IP address updated from $oldIp:$oldPort to $newIp:$newPort';
  }

  @override
  String messageIpAddressUpdated(String oldIp, String newIp) {
    return 'IP address updated from $oldIp to $newIp';
  }

  @override
  String messagePortUpdated(String oldPort, String newPort) {
    return 'Port updated from $oldPort to $newPort';
  }

  @override
  String get messageSavingDevice => 'Saving device...';

  @override
  String get messageConnectingToDevice => 'Connecting to device...';

  @override
  String get labelDeviceKnown => 'Device Known';

  @override
  String get labelKnownNewAddress => 'Known (new address)';

  @override
  String get labelFound => 'Found';

  @override
  String get labelKnownDevices => 'Known Devices';

  @override
  String get labelTested => 'Tested';

  @override
  String get labelRemaining => 'Remaining';

  @override
  String get labelKnown => 'Known';

  @override
  String get labelLeft => 'Left';

  @override
  String get actionUpdateIp => 'Update IP';

  @override
  String get actionAddDevices => 'Add Devices';

  @override
  String get actionInspectDevice => 'Inspect Device';

  @override
  String get actionChooseRole => 'Choose Role';

  @override
  String get actionCreateSystem => 'Create System';

  @override
  String get actionDeleteSystem => 'Delete System';

  @override
  String get messageDeviceHasNoRoleConfig => 'Device has no role configuration';

  @override
  String get messageDeviceHasNoConfigurableRoles =>
      'Device has no configurable roles';

  @override
  String get messageDeviceAlreadyInSystem => 'Device already in system';

  @override
  String messageDeviceAddedWithRoles(String name, String roles) {
    return 'Device \"$name\" added with role(s): $roles';
  }

  @override
  String get messageDeviceRemoved => 'Device removed';

  @override
  String get messageNoDevicesInSystem => 'No devices in system';

  @override
  String get messageAddDevicesToSeeMetrics => 'Add devices to see metrics.';

  @override
  String get messageNoActiveDevicesWithData => 'No active devices with data';

  @override
  String get messageNoSystems => 'No Systems';

  @override
  String get messageCreateYourFirstSystem => 'Create your first system';

  @override
  String confirmRemoveDeviceWithRoles(String name, int count, String roles) {
    return 'Do you want to remove \"$name\" with $count role(s) ($roles) from this system?';
  }

  @override
  String confirmRemoveUnknownDeviceWithRoles(int count, String roles) {
    return 'Do you want to remove this device with $count role(s) ($roles) from the system?';
  }

  @override
  String confirmDeleteSystem(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String screenEditSystem(String name) {
    return 'Edit $name';
  }

  @override
  String get screenCreateNewSystem => 'Create New System';

  @override
  String labelRoles(String roles) {
    return 'Roles: $roles';
  }

  @override
  String labelDevicesCount(int count) {
    return '$count Devices';
  }

  @override
  String labelDevicesWithCount(int count) {
    return 'Devices ($count)';
  }

  @override
  String statusDeviceNotFoundWithSn(String sn) {
    return 'Device $sn not found';
  }

  @override
  String get systemSolarProduction => 'Solar Production';

  @override
  String get systemSolarToGrid => 'Solar to Grid';

  @override
  String get active => 'active';

  @override
  String get errorNoWifiLanConnectionTitle => 'No WiFi/LAN Connection';

  @override
  String get errorNoPrivateNetworkTitle => 'No Private Network';

  @override
  String messageDevicesFoundInNetwork(int count) {
    return '$count devices found in network';
  }

  @override
  String get errorNetworkScanError => 'Network Scan Error';

  @override
  String errorNetworkScanFailed(String error) {
    return 'Network Scan Error: $error';
  }

  @override
  String get warningPublicNetworkTitle => 'Warning: Public Network';

  @override
  String get actionContinueAnyway => 'OK, Continue';

  @override
  String messageIpOnlyUpdated(String oldIp, String newIp) {
    return 'IP address updated from $oldIp to $newIp';
  }

  @override
  String get labelKnownDevice => 'Known Device';

  @override
  String get device => 'Device';

  @override
  String get actionUpdate => 'Update';

  @override
  String get startScanToFindDevices => 'Start a scan to find devices';

  @override
  String get messageSearchingForKnownDevices =>
      'Searching for known devices...';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get network => 'Network';

  @override
  String get labelBluetoothDevices => 'Bluetooth Devices';

  @override
  String get helpScanForNearbyDevices =>
      'Scan for nearby devices (Zendure, Shelly)';

  @override
  String get messageScanning => 'Scanning...';

  @override
  String get actionBluetoothScan => 'Bluetooth Scan';

  @override
  String get labelNetworkDevices => 'Network Devices';

  @override
  String get helpScanLocalNetwork => 'Scan your local network for devices';

  @override
  String get actionNetworkScan => 'Network Scan';

  @override
  String get actionManual => 'Manual';

  @override
  String get remove => 'Remove';

  @override
  String get create => 'Create';

  @override
  String get screenDeviceInfo => 'Device Information';

  @override
  String get messageNoInformationAvailable => 'No information available';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get screenLiveGraphs => 'Live Graphs';

  @override
  String get screenAppInfo => 'App Information';

  @override
  String get screenPowerLimit => 'Set Power Limit';

  @override
  String get screenAdvancedPowerSettings => 'Advanced Power Settings';

  @override
  String screenPortConfiguration(String portName) {
    return '$portName';
  }

  @override
  String get screenPercentagePowerLimit => 'Power Limit';

  @override
  String get screenOnlineMonitoring => 'Configure Online Monitoring';

  @override
  String get screenBatterySoc => 'Set Battery Limits';

  @override
  String get screenPower => 'Set Power';

  @override
  String get screenZendureWifiMqtt => 'MQTT Configuration';

  @override
  String get screenOpenDtuOnlineMonitoring => 'Online Monitoring';

  @override
  String get validationSsidRequired => 'SSID cannot be empty';

  @override
  String get validationPasswordRequired => 'Password cannot be empty';

  @override
  String get validationPortRequired => 'Port cannot be empty';

  @override
  String get validationPortRange => 'Port must be a number between 1 and 65535';

  @override
  String get validationUsernameRequired => 'Username cannot be empty';

  @override
  String get validationPasswordEmpty => 'Password cannot be empty';

  @override
  String get validationMinSocLessThanMax =>
      'Minimum SOC must be less than maximum SOC';

  @override
  String get validationPrimaryServerRequired =>
      'Primary server URL is required';

  @override
  String get validationPrimaryUrlInvalid =>
      'Invalid primary server URL (do not use http:// or https:// protocol)';

  @override
  String get validationSystemIdRequired => 'System ID is required';

  @override
  String get validationTokenRequired => 'Token/password is required';

  @override
  String get validationSecondaryUrlInvalid =>
      'Invalid secondary server URL (do not use http:// or https:// protocol)';

  @override
  String get validationPrimaryPortInvalid => 'Invalid primary port (1-65535)';

  @override
  String get validationSecondaryPortInvalid =>
      'Invalid secondary port (1-65535)';

  @override
  String get validationUploadIntervalRange =>
      'Upload interval must be between 1 and 3600 seconds';

  @override
  String get validationServerAIpRequired =>
      'Server A: IP address or domain must be specified';

  @override
  String get validationServerAIpInvalid => 'Server A: Invalid IP address';

  @override
  String get validationServerAPortRange =>
      'Server A: Port must be between 1 and 65534';

  @override
  String get validationServerBIpRequired =>
      'Server B: IP address or domain must be specified';

  @override
  String get validationServerBIpInvalid => 'Server B: Invalid IP address';

  @override
  String get validationServerBPortRange =>
      'Server B: Port must be between 1 and 65534';

  @override
  String get messageCopiedToClipboard => 'Copied to clipboard';

  @override
  String get messageWifiConfigSent => 'WiFi configuration sent successfully!';

  @override
  String messagePortConfigured(String portName) {
    return '$portName configured successfully';
  }

  @override
  String messagePowerLimitSetWithValue(String value) {
    return 'Power settings successfully set: $value W';
  }

  @override
  String messagePowerPercentageSet(String percentage) {
    return 'Power limit set to $percentage%';
  }

  @override
  String messageBatteryLimitsSet(String min, String max) {
    return 'Battery limits successfully set: Min $min%, Max $max%';
  }

  @override
  String get messageOnlineMonitoringConfigured =>
      'Online monitoring configured successfully';

  @override
  String messageSettingUpdated(String settingName) {
    return '$settingName was updated';
  }

  @override
  String get messageAuthEnabled => 'Authentication was enabled';

  @override
  String get messageAuthDisabled => 'Authentication was disabled';

  @override
  String errorWhileSending(String error) {
    return 'Error while sending: $error';
  }

  @override
  String errorConfiguringPort(String error) {
    return 'Error configuring port: $error';
  }

  @override
  String errorSettingPowerLimit(String error) {
    return 'Error setting power limit: $error';
  }

  @override
  String errorSettingPercentageLimit(String error) {
    return 'Error setting power limit: $error';
  }

  @override
  String errorSettingBatteryLimits(String error) {
    return 'Error setting battery limits: $error';
  }

  @override
  String errorConfiguringOnlineMonitoring(String error) {
    return 'Error configuring online monitoring: $error';
  }

  @override
  String errorChangingSetting(String error) {
    return 'Error changing setting: $error';
  }

  @override
  String errorSavingAuth(String error) {
    return 'Error saving authentication: $error';
  }

  @override
  String get sectionNetworkSetup => 'Network Setup';

  @override
  String get sectionMqttConfig => 'MQTT Configuration';

  @override
  String get sectionNote => 'Note';

  @override
  String get sectionLimitType => 'Limit Type';

  @override
  String get sectionCurrentValue => 'Current Value';

  @override
  String get sectionAdjustLimit => 'Adjust Limit';

  @override
  String get sectionCurrentSettings => 'Current Settings';

  @override
  String get sectionMaxInverterPower => 'Max Inverter Power';

  @override
  String get sectionPreciseInput => 'Precise Input';

  @override
  String get sectionGridFeedback => 'Grid Feed-in';

  @override
  String get sectionGridStandard => 'Grid Standard';

  @override
  String get sectionPortNumber => 'Port Number';

  @override
  String get sectionPercentageLimit => 'Power Limit in Percent';

  @override
  String get sectionWattLimit => 'Power Limit in Watts';

  @override
  String get sectionDeviceInfo => 'Device Information';

  @override
  String get sectionOnlineMonitoring => 'Online Monitoring';

  @override
  String get sectionPrimaryServer => 'Primary Server';

  @override
  String get sectionSecondaryServer => 'Secondary Server';

  @override
  String get sectionCredentials => 'Credentials';

  @override
  String get sectionServerA => 'Server A (Primary Server)';

  @override
  String get sectionServerB => 'Server B (Secondary Server)';

  @override
  String get sectionGeneralSettings => 'General Settings';

  @override
  String get sectionCurrentValues => 'Current Values';

  @override
  String get sectionMinSoc => 'Minimum SOC';

  @override
  String get sectionMaxSoc => 'Maximum SOC';

  @override
  String get sectionAuthConfig => 'Configure Authentication';

  @override
  String get sectionUsername => 'Username';

  @override
  String get sectionPassword => 'Password';

  @override
  String get buttonCopy => 'Copy';

  @override
  String get buttonConfigureWifi => 'Configure WiFi';

  @override
  String get buttonSavePowerLimit => 'Save Power Limit';

  @override
  String get buttonDeactivate => 'Deactivate';

  @override
  String get segmentDisabled => 'Disabled';

  @override
  String get segmentAllowed => 'Allowed';

  @override
  String get segmentForbidden => 'Forbidden';

  @override
  String get segmentGermany => 'Germany';

  @override
  String get segmentFrance => 'France';

  @override
  String get segmentAustria => 'Austria';

  @override
  String get labelMaxInverterPower => 'Max Inverter Power';

  @override
  String get labelGridFeedback => 'Feed-in';

  @override
  String get labelGridStandard => 'Grid Standard';

  @override
  String get labelPowerInWatts => 'Power in Watts';

  @override
  String get labelPercent => 'Percent';

  @override
  String get labelWatt => 'Watts';

  @override
  String get labelMinimum => 'Minimum';

  @override
  String get labelMaximum => 'Maximum';

  @override
  String get labelMinSoc => 'Min SOC';

  @override
  String get labelMaxSoc => 'Max SOC';

  @override
  String labelProtocol(String required) {
    return 'Protocol$required';
  }

  @override
  String labelServerUrl(String required) {
    return 'Server URL$required';
  }

  @override
  String get labelPortField => 'Port';

  @override
  String get labelSystemId => 'System ID *';

  @override
  String get labelToken => 'Token/Password *';

  @override
  String get labelUploadInterval => 'Upload Interval (seconds)';

  @override
  String get labelIpAddress => 'IP Address';

  @override
  String get labelDomain => 'Domain';

  @override
  String get labelUsername => 'Username';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelRequiredField => 'Required';

  @override
  String get labelOptionalField => 'Optional';

  @override
  String get labelInputLimit => 'Input (Grid → Device)';

  @override
  String get labelOutputLimit => 'Output (Device → Grid)';

  @override
  String get labelUnknown => 'Unknown';

  @override
  String get helpConnectDeviceToWifi =>
      'Connect your device to your WiFi network,';

  @override
  String get helpWifiSetupInstructions =>
      '• Make sure your device is turned on\n• The WiFi password is transmitted securely\n• After successful configuration, it may take a few seconds for the device to connect';

  @override
  String get helpMqttExplanation =>
      'This is for official app web communication, not for local MQTT. On old versions it was the only way to get data. Only change if you know what you\'re doing!';

  @override
  String get helpMqttServerExample => 'e.g. broker.example.com:1883';

  @override
  String get helpPleaseWait => 'Please wait a moment';

  @override
  String get helpInputNotAvailable => 'Input limit is not available';

  @override
  String helpPowerRange(String maxValue) {
    return 'Range: 0 - $maxValue W';
  }

  @override
  String get helpWattValue => 'Value between 1 and 100';

  @override
  String helpMaxWatt(String maxWatt) {
    return 'Max: $maxWatt W (equals 100%)';
  }

  @override
  String get helpWattRounding =>
      'Watt values are rounded to full percentage steps';

  @override
  String helpNominalPower(String maxWatt) {
    return 'Nominal power: $maxWatt W';
  }

  @override
  String helpCurrentLimit(String watt, String percentage) {
    return 'Current limit: $watt W ($percentage%)';
  }

  @override
  String get helpGridFeedbackDescription =>
      'Determines whether energy may be fed into the grid';

  @override
  String get helpGridStandardDescription =>
      'Grid connection standard for your country';

  @override
  String get helpPortRange => 'Port must be between 1 and 65535';

  @override
  String get helpPortWarning =>
      '• Make sure the port is not being used by other services\n• The device may restart after configuration\n• Default ports should only be changed if necessary';

  @override
  String helpCurrentPercentageLimit(String limit) {
    return 'Current limit: $limit%';
  }

  @override
  String get helpServerUrlFormat => 'Without http:// or https://';

  @override
  String helpDefaultPort(String port) {
    return 'Default: $port';
  }

  @override
  String get helpDefaultPortNote => 'Default ports are not shown in URL';

  @override
  String get helpConfigureOnlineMonitoring =>
      'Configure servers for online monitoring';

  @override
  String get helpOnlineMonitoringInstructions =>
      '• Enter the URL of the monitoring server\n• Enter your credentials\n• Optionally configure a second server\n• The upload interval determines how often data is sent\n• After configuration, data will be uploaded automatically';

  @override
  String get helpServerExampleIp => 'e.g. 192.168.1.100';

  @override
  String get helpServerExampleDomain => 'e.g. monitoring.example.com';

  @override
  String get helpPortExample => 'e.g. 10000';

  @override
  String get helpSystemIdExample => 'e.g. 1234';

  @override
  String get helpUploadIntervalExample => 'e.g. 30';

  @override
  String get helpProtocolExample => 'e.g. solar.pihost.org';

  @override
  String get helpOnlineMonitoringDescription =>
      '• Make sure the server URLs are correct\n• Optional: Secondary server as backup\n• Upload interval: 1-3600 seconds\n• Changes take effect immediately';

  @override
  String get helpManageDeviceSettings =>
      'Manage basic settings of your device.';

  @override
  String get helpNoSettingsAvailable => 'No settings available';

  @override
  String get helpSettingsApplyImmediately =>
      'Changes are applied to the device immediately. Settings requiring confirmation will show a dialog before the change.';

  @override
  String get helpConfirmationRequired => 'Confirmation required';

  @override
  String get helpProtectDevice =>
      'Protect your device with username and password.';

  @override
  String get helpAuthToggle =>
      'Enables or disables password protection for the device';

  @override
  String get helpUsernameCannotChange => 'Username cannot be changed';

  @override
  String get helpEnterSecurePassword => 'Enter a secure password';

  @override
  String get helpAuthWarning =>
      'Warning: When authentication is disabled, anyone on the network can access the device.';

  @override
  String get dialogWifiConfigSending => 'Sending WiFi configuration...';

  @override
  String get dialogSettingChanging => 'Changing setting...';

  @override
  String dialogPowerLimitSetting(String percentage) {
    return 'Setting power limit to $percentage%...';
  }

  @override
  String dialogConfirmToggleSetting(String settingName, String action) {
    return '$settingName $action?';
  }

  @override
  String dialogConfirmToggleMessage(String settingName, String action) {
    return 'Do you really want to $action $settingName?';
  }

  @override
  String get dialogActionEnable => 'enable';

  @override
  String get dialogActionDisable => 'disable';

  @override
  String get dialogDisableAuthTitle => 'Disable authentication?';

  @override
  String get dialogDisableAuthMessage =>
      'Do you really want to disable authentication? The device will be accessible without password protection afterwards.';

  @override
  String get infoNoGraphFields => 'This device has no visible graph fields.';

  @override
  String get infoDataRange =>
      'Data range: Last 5 minutes | Update: every 5 seconds';

  @override
  String get infoWattRoundingNote =>
      'Watt values are rounded to full percentage steps';

  @override
  String get shellyScriptsScreenTitle => 'Scripts & Automation';

  @override
  String get shellyScriptDetailTitle => 'Script Details';

  @override
  String get shellyScriptConfigTitle => 'Configure Parameters';

  @override
  String get shellyScriptLibraryTitle => 'Script Templates';

  @override
  String get shellyScriptPreviewTitle => 'Code Preview';

  @override
  String get shellyScriptUpdateTitle => 'Update Parameters';

  @override
  String get statusActivated => 'Activated';

  @override
  String get statusDeactivated => 'Deactivated';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get shellyScriptsConfigureParams => 'Configure Parameters';

  @override
  String get shellyScriptsDirectInstall => 'Install Directly';

  @override
  String get shellyScriptsRepairScript => 'Repair Script (failed update)';

  @override
  String get shellyScriptsUpgradeVersion => 'Upgrade to New Version';

  @override
  String get shellyScriptsLoadingCode => 'Loading script code...';

  @override
  String get shellyScriptsLoadingCurrent => 'Loading current script...';

  @override
  String get shellyScriptsStoppingScript => 'Stopping script...';

  @override
  String get shellyScriptsPreparingUpdate => 'Preparing update...';

  @override
  String get shellyScriptsUpdatingScript => 'Updating script...';

  @override
  String get shellyScriptsFinalizingUpdate => 'Finalizing update...';

  @override
  String get shellyScriptsDeletingScript => 'Deleting script...';

  @override
  String get shellyScriptsActivatingScript => 'Activating script...';

  @override
  String get shellyScriptsDeactivatingScript => 'Deactivating script...';

  @override
  String get shellyScriptsStartingScript => 'Starting script...';

  @override
  String get shellyScriptsStartScript => 'Start Script';

  @override
  String get shellyScriptsStopScript => 'Stop Script';

  @override
  String get shellyScriptsCreatingScript => 'Creating script on device...';

  @override
  String get shellyScriptsUploadingCode => 'Uploading script code...';

  @override
  String get shellyScriptsFinalizingInstall => 'Finalizing installation...';

  @override
  String get shellyScriptsSearchingDevices => 'Searching devices...';

  @override
  String shellyScriptsScriptUpdated(String version) {
    return 'Script successfully updated to version $version';
  }

  @override
  String get shellyScriptsScriptDeleted => 'Script deleted';

  @override
  String get shellyScriptsScriptActivated => 'Script activated';

  @override
  String get shellyScriptsScriptDeactivated => 'Script deactivated';

  @override
  String get shellyScriptsScriptStarted => 'Script started';

  @override
  String get shellyScriptsScriptStopped => 'Script stopped';

  @override
  String get shellyScriptsScriptInstalled =>
      'Script successfully installed and started';

  @override
  String get shellyScriptsParamsUpdated => 'Parameters successfully updated';

  @override
  String get shellyScriptsErrorLoadingCode => 'Could not retrieve script code';

  @override
  String get shellyScriptsErrorNoMetadata =>
      'Could not extract template metadata';

  @override
  String get shellyScriptsErrorNoTemplateId =>
      'Template ID missing in metadata';

  @override
  String shellyScriptsErrorTemplateNotFound(String templateId) {
    return 'Template not found: $templateId';
  }

  @override
  String shellyScriptsErrorUpdatingStaging(String error) {
    return 'Error updating: $error\nScript remains in staging status (0.0.0).';
  }

  @override
  String get shellyScriptsErrorNoScriptId =>
      'Error: Could not retrieve script ID';

  @override
  String shellyScriptsErrorUploadingCode(String error) {
    return 'Error uploading: $error\nScript remains in staging status (0.0.0).';
  }

  @override
  String get shellyScriptsErrorCodeUploadFailed => 'Error uploading code';

  @override
  String shellyScriptsErrorInstalling(String error) {
    return 'Error installing script: $error';
  }

  @override
  String shellyScriptsErrorLoadingTemplates(String error) {
    return 'Error loading templates: $error';
  }

  @override
  String get shellyScriptsErrorSectionTitle => 'Error';

  @override
  String get shellyScriptErrorCrashed => 'Crashed';

  @override
  String get shellyScriptErrorSyntax => 'Syntax Error';

  @override
  String get shellyScriptErrorReference => 'Reference Error';

  @override
  String get shellyScriptErrorType => 'Type Error';

  @override
  String get shellyScriptErrorMemory => 'Out of Memory';

  @override
  String get shellyScriptErrorCodespace => 'Out of Codespace';

  @override
  String get shellyScriptErrorInternal => 'Internal Error';

  @override
  String get shellyScriptErrorNotImplemented => 'Not Implemented';

  @override
  String get shellyScriptErrorFileRead => 'File Read Error';

  @override
  String get shellyScriptErrorBadArgs => 'Invalid Arguments';

  @override
  String shellyScriptsValidationRequired(String label) {
    return '$label is required';
  }

  @override
  String shellyScriptsValidationMustBeNumber(String label) {
    return '$label must be a number';
  }

  @override
  String shellyScriptsValidationMinValue(String label, String min) {
    return '$label must be at least $min';
  }

  @override
  String shellyScriptsValidationMaxValue(String label, String max) {
    return '$label must be at most $max';
  }

  @override
  String get shellyScriptsValidationPortRange =>
      'Port must be between 1 and 65535';

  @override
  String get shellyScriptsValidationFieldRequired => 'This field is required';

  @override
  String get shellyScriptsValidationInvalidValue => 'Invalid value';

  @override
  String get shellyScriptsDialogNewParamsTitle => 'New Parameters Available';

  @override
  String shellyScriptsDialogNewParamsMessage(
    String version,
    String params,
    String currentVersion,
    String newVersion,
  ) {
    return 'The new version $version contains new parameters that need to be configured:\n\n$params\n\nCurrent version: $currentVersion\nNew version: $newVersion';
  }

  @override
  String get shellyScriptsDialogUpgradeTitle => 'Upgrade to New Version?';

  @override
  String shellyScriptsDialogUpgradeMessage(String version) {
    return 'Do you want to upgrade the script to version $version?\n\nThis operation will briefly stop and restart the script.';
  }

  @override
  String get shellyScriptsDialogDeleteTitle => 'Delete Script?';

  @override
  String shellyScriptsDialogDeleteMessage(String name) {
    return 'Do you really want to delete the script \"$name\"? This action cannot be undone.';
  }

  @override
  String get shellyScriptsDialogInstallTitle => 'Install Script?';

  @override
  String shellyScriptsDialogInstallMessage(String name) {
    return 'Do you want to install the script \"$name\" without preview?';
  }

  @override
  String get shellyScriptsDialogInstallConfirmTitle =>
      'Install Script on Device?';

  @override
  String shellyScriptsDialogInstallConfirmMessage(String name) {
    return 'Do you really want to install the script \"$name\" on your Shelly device?';
  }

  @override
  String get shellyScriptsDialogUpdateParamsTitle => 'Update Parameters?';

  @override
  String get shellyScriptsDialogUpdateParamsMessage =>
      'Do you really want to update the parameters? The script will be regenerated with the new values.';

  @override
  String get shellyScriptsDialogCompatibilityTitle =>
      'Compatibility Information';

  @override
  String get shellyScriptsInfoAutomation => 'Automation';

  @override
  String get shellyScriptsInfoFailed => 'Failed';

  @override
  String shellyScriptsInfoVersion(String version, String id) {
    return 'Version: $version • ID: $id';
  }

  @override
  String shellyScriptsInfoScriptId(String id) {
    return 'Script ID: $id';
  }

  @override
  String shellyScriptsInfoVersionUpdating(String version) {
    return 'Version: $version (updating)';
  }

  @override
  String get shellyScriptsHelpEditTip => 'Tap Edit to open a script.';

  @override
  String get shellyScriptsEmptyStateTitle => 'No Scripts Available';

  @override
  String get shellyScriptsEmptyStateMessage =>
      'No scripts are currently configured on this device.';

  @override
  String get shellyScriptsInfoTitle => 'Information:';

  @override
  String get shellyScriptsInfoContent =>
      '• Activated: Script runs automatically on events\n• Running: Script is currently executing\n• Status updates every 10 seconds\n• Edit: Opens detail view with controls';

  @override
  String get shellyScriptsFabCreateFromTemplate => 'Create from Template';

  @override
  String get shellyScriptsStatusTitle => 'Status';

  @override
  String get shellyScriptsAutostartTitle => 'Autostart Enabled';

  @override
  String get shellyScriptsAutostartSubtitle =>
      'Script starts automatically on configured events';

  @override
  String get shellyScriptsControlTitle => 'Controls:';

  @override
  String get shellyScriptsControlInfo =>
      '• Autostart: Script runs automatically on events\n• Start/Stop: Manually start/stop the script\n• Status updates automatically';

  @override
  String get shellyScriptsConfigInfoText =>
      'Fill in all parameters and tap \"Preview\" to see the generated script code.';

  @override
  String get shellyScriptsPreviewSubtitle =>
      'Review the generated code before installation';

  @override
  String get shellyScriptsPreviewInfoText =>
      'The script will be installed on your Shelly device, activated, and started automatically.';

  @override
  String get shellyScriptsUpdateInfoText =>
      'Update the parameters. The script will be regenerated and uploaded with the new values.';

  @override
  String get shellyScriptsSearchPlaceholder => 'Search templates...';

  @override
  String get shellyScriptsShowAllToggle => 'Show All Scripts';

  @override
  String get shellyScriptsCurrentDevice => 'Current Device:';

  @override
  String get shellyScriptsCompatibleDevices => 'Compatible Devices:';

  @override
  String get shellyScriptsAllDevices => 'All Devices';

  @override
  String get shellyScriptsNotCompatibleWarning =>
      'Not intended for this device';

  @override
  String shellyScriptsVersionDisplay(String version) {
    return 'Version $version';
  }

  @override
  String shellyScriptsAuthorCredit(String author) {
    return 'by $author';
  }

  @override
  String shellyScriptsRequiresDevices(String devices) {
    return 'Requires: $devices';
  }

  @override
  String shellyScriptsParamCount(int count) {
    return '$count parameters';
  }

  @override
  String get shellyScriptsFilterAll => 'All';

  @override
  String get shellyScriptsEmptyLibrary => 'No Templates Found';

  @override
  String get shellyScriptsUnknownModel => 'Unknown';

  @override
  String get shellyScriptsNoDevicesFound => 'No matching devices found';

  @override
  String shellyScriptsAutoFilledFrom(String deviceName) {
    return 'Auto-filled from: $deviceName';
  }

  @override
  String shellyScriptsSelectDeviceCount(int count) {
    return 'Select Device ($count found)';
  }

  @override
  String shellyScriptsSourceProperty(String sourceProperty) {
    return 'Source: $sourceProperty';
  }

  @override
  String shellyScriptsFilterProperty(String filter) {
    return 'Filter: $filter';
  }

  @override
  String get shellyScriptsNoDevicesFoundHelper => '(no devices found)';

  @override
  String get shellyScriptsAutoFilledHelper => '(auto-filled)';

  @override
  String shellyScriptsDevicesFoundHelper(int count) {
    return '($count devices found)';
  }

  @override
  String shellyScriptsSelectDeviceModal(String label) {
    return 'Select device for \"$label\"';
  }

  @override
  String get shellyScriptsParamRequired => '(required)';

  @override
  String get unknownUpdating => 'Unknown (updating)';

  @override
  String get wifiConfigurationCompleted => 'WiFi Configuration Completed';

  @override
  String get accessPointConfigured => 'Access Point Successfully Configured';

  @override
  String get powerLimitSet => 'Power Limit Successfully Set';

  @override
  String get deviceRestarting => 'Device is Restarting';

  @override
  String errorLoadingConfiguration(String error) {
    return 'Error loading configuration: $error';
  }

  @override
  String errorRestartingDevice(String error) {
    return 'Error restarting device: $error';
  }

  @override
  String get errorUnknownFirmware =>
      'Not possible because current firmware is unknown, try again in a moment (waiting for data)';

  @override
  String get loadingDeviceInfo => 'Loading device information...';

  @override
  String get loadingConfiguration => 'Loading current configuration...';

  @override
  String get menuDeviceInfo => 'Device Information';

  @override
  String get menuConfigureWifi => 'Configure WiFi';

  @override
  String get menuSetupApWifi => 'Set Up AP WiFi';

  @override
  String get menuConfigurePassword => 'Configure Password';

  @override
  String get menuSetupWlan => 'Set Up WLAN Connection';

  @override
  String get menuOnlineMonitoring => 'Configure Online Monitoring';

  @override
  String get menuGeneralSettings => 'General Settings';

  @override
  String get menuInverterPowerLimit => 'Limit Inverter Power';

  @override
  String get menuOutputPowerLimit => 'Limit Output Power';

  @override
  String get menuRestartOpendtu => 'Restart OpenDTU';

  @override
  String get menuConfigureRpcPort => 'Configure RPC UDP Port';

  @override
  String get menuSubtitleSetupNetwork => 'Set up network connection';

  @override
  String get menuSubtitleSetupAccessPoint => 'Set up AP WiFi';

  @override
  String get menuSubtitleMqttSetup => 'Set up MQTT broker connection';

  @override
  String get menuSubtitleToggleAllInverters => 'Toggle all inverters';

  @override
  String get deviceFallbackName => 'Device';

  @override
  String get labelPort => 'Port';

  @override
  String get labelPowerInput => 'Input (Grid → Device)';

  @override
  String get labelPowerOutput => 'Output (Device → Grid)';

  @override
  String get hintHostnameOrIp => 'Hostname or IP Address';

  @override
  String get helpDevicePoweredOn => '• Make sure your device is turned on';

  @override
  String get helpStrongPassword => '• A strong password protects your network';

  @override
  String get helpMqttPorts =>
      '• Standard MQTT port is 1883 (unencrypted) or 8883 (TLS)';

  @override
  String get helpMqttAuthRecommended =>
      '• Authentication is optional but recommended';

  @override
  String get helpMqttAutoConnect =>
      '• After configuration, the device connects automatically';

  @override
  String get infoConfigureAccessPoint =>
      'Configure the WiFi Access Point of Your Device';

  @override
  String get infoMqttAuthToggle => 'Enables username and password for MQTT';

  @override
  String get infoMqttDisabled =>
      'MQTT is disabled. The device will not connect to an MQTT broker.';

  @override
  String get noRoleSupport => 'No Role Support';

  @override
  String get noDetailsAvailable => 'No Details Available';

  @override
  String get onlineMonitoringConfigured =>
      'Online Monitoring Successfully Configured';

  @override
  String get authenticationConfigured =>
      'Authentication Successfully Configured';

  @override
  String get mqttConfigurationUpdated =>
      'MQTT Configuration Successfully Updated';

  @override
  String get fieldDailyYield => 'Daily Yield';

  @override
  String get fieldTotalYield => 'Total Yield';

  @override
  String get fieldCurrentPower => 'Current Power';

  @override
  String get fieldAcPower => 'AC Power';

  @override
  String get fieldDcPower => 'DC Power';

  @override
  String get fieldActivePower => 'Active Power';

  @override
  String get fieldReactivePower => 'Reactive Power';

  @override
  String get fieldApparentPower => 'Apparent Power';

  @override
  String get fieldPowerFactor => 'Power Factor';

  @override
  String get fieldDcTotalPower => 'DC Total Power';

  @override
  String fieldPvVoltage(String num) {
    return 'PV$num Voltage';
  }

  @override
  String fieldPvCurrent(String num) {
    return 'PV$num Current';
  }

  @override
  String fieldPvPower(String num) {
    return 'PV$num Power';
  }

  @override
  String fieldPvTotalYield(String num) {
    return 'PV$num Total Yield';
  }

  @override
  String fieldPvDailyYield(String num) {
    return 'PV$num Daily Yield';
  }

  @override
  String get fieldTotalEnergyImport => 'Total Energy Import';

  @override
  String get fieldTotalEnergyExport => 'Total Energy Export';

  @override
  String get fieldTotalEnergy => 'Total Energy';

  @override
  String get fieldEnergyPerMinuteImport => 'Energy per Minute (Import)';

  @override
  String get fieldEnergyPerMinuteExport => 'Energy per Minute (Export)';

  @override
  String get fieldOutputLimit => 'Output Limit';

  @override
  String get fieldInputLimit => 'Input Limit';

  @override
  String get fieldGridVoltage => 'Grid Voltage';

  @override
  String get fieldGridCurrent => 'Grid Current';

  @override
  String get fieldGridFrequency => 'Grid Frequency';

  @override
  String get fieldVoltagePhase1 => 'Voltage Phase 1';

  @override
  String get fieldVoltagePhase2 => 'Voltage Phase 2';

  @override
  String get fieldVoltagePhase3 => 'Voltage Phase 3';

  @override
  String get fieldCurrentPhase1 => 'Current Phase 1';

  @override
  String get fieldCurrentPhase2 => 'Current Phase 2';

  @override
  String get fieldCurrentPhase3 => 'Current Phase 3';

  @override
  String fieldVoltageInstance(String instanceNum) {
    return 'Voltage $instanceNum';
  }

  @override
  String fieldCurrentInstance(String instanceNum) {
    return 'Current $instanceNum';
  }

  @override
  String get fieldDcVoltage => 'DC Voltage';

  @override
  String get fieldDcCurrent => 'DC Current';

  @override
  String get fieldAcVoltage => 'AC Voltage';

  @override
  String get fieldAcCurrent => 'AC Current';

  @override
  String get fieldBatteryLevel => 'Battery Level';

  @override
  String get fieldBatteryPower => 'Battery Power';

  @override
  String get fieldBatterySoc => 'Battery SOC';

  @override
  String get fieldBatteryState => 'Battery State';

  @override
  String get fieldChargeMaxLimit => 'Charge Max Limit';

  @override
  String get fieldDischargeMaxLimit => 'Discharge Max Limit';

  @override
  String get fieldPackState => 'Pack State';

  @override
  String get fieldCellVoltageMin => 'Cell Voltage Min';

  @override
  String get fieldCellVoltageMax => 'Cell Voltage Max';

  @override
  String get fieldCellTemperatureMax => 'Cell Temperature Max';

  @override
  String get fieldBatteryPackEmpty => 'No battery pack data available';

  @override
  String fieldBatteryPackNumber(String num) {
    return 'Battery #$num';
  }

  @override
  String get fieldBatteryStateIdle => 'Idle';

  @override
  String get fieldBatteryStateCharging => 'Charging';

  @override
  String get fieldBatteryStateDischarging => 'Discharging';

  @override
  String get fieldBatteryStateUnknown => 'Unknown';

  @override
  String get fieldBatteryType => 'Type';

  @override
  String get fieldTemperature => 'Temperature';

  @override
  String get fieldUptime => 'Uptime';

  @override
  String get fieldLimitStatus => 'Limit Status';

  @override
  String get fieldPowerLimit => 'Power Limit';

  @override
  String get fieldModel => 'Model';

  @override
  String get fieldRatedPower => 'Rated Power';

  @override
  String get fieldFirmwareVersion => 'Firmware Version';

  @override
  String get fieldSerialNumber => 'Serial Number';

  @override
  String get fieldArticleNumber => 'Article Number';

  @override
  String get fieldManufacturer => 'Manufacturer';

  @override
  String get fieldAverageTemperature => 'Average Temperature';

  @override
  String get fieldMaxTemperature => 'Max. Temperature';

  @override
  String get fieldMinTemperature => 'Min. Temperature';

  @override
  String get fieldWifiSignal => 'WiFi Signal';

  @override
  String get fieldWifiState => 'WiFi State';

  @override
  String fieldSwitchInstance(String instanceNum) {
    return 'Switch $instanceNum';
  }

  @override
  String fieldPowerInstance(String instanceNum) {
    return 'Power $instanceNum';
  }

  @override
  String fieldEnergyInstance(String instanceNum) {
    return 'Energy $instanceNum';
  }

  @override
  String fieldFrequencyInstance(String instanceNum) {
    return 'Frequency $instanceNum';
  }

  @override
  String fieldPowerFactorInstance(String instanceNum) {
    return 'Power Factor $instanceNum';
  }

  @override
  String fieldActivePowerInstance(String instanceNum) {
    return 'Active Power $instanceNum';
  }

  @override
  String fieldReactivePowerInstance(String instanceNum) {
    return 'Reactive Power $instanceNum';
  }

  @override
  String fieldApparentPowerInstance(String instanceNum) {
    return 'Apparent Power $instanceNum';
  }

  @override
  String fieldTemperatureInstance(String instanceNum) {
    return 'Temperature $instanceNum';
  }

  @override
  String fieldStatusInstance(String instanceNum) {
    return 'Status $instanceNum';
  }

  @override
  String fieldYieldInstance(String instanceNum) {
    return 'Yield $instanceNum';
  }

  @override
  String get fieldTotalPower => 'Total Power';

  @override
  String get fieldTotalCurrent => 'Total Current';

  @override
  String get fieldTotalVoltage => 'Total Voltage';

  @override
  String get fieldActivePowerTotal => 'Active Power Total';

  @override
  String get fieldReactivePowerTotal => 'Reactive Power Total';

  @override
  String get fieldApparentPowerTotal => 'Apparent Power Total';

  @override
  String get fieldEnergyTotal => 'Energy Total';

  @override
  String get fieldCombinedPower => 'Combined Power';

  @override
  String get fieldPowerPhase1 => 'Power Phase 1';

  @override
  String get fieldPowerPhase2 => 'Power Phase 2';

  @override
  String get fieldPowerPhase3 => 'Power Phase 3';

  @override
  String get fieldActivePowerPhase1 => 'Active Power Phase 1';

  @override
  String get fieldActivePowerPhase2 => 'Active Power Phase 2';

  @override
  String get fieldActivePowerPhase3 => 'Active Power Phase 3';

  @override
  String get fieldReactivePowerPhase1 => 'Reactive Power Phase 1';

  @override
  String get fieldReactivePowerPhase2 => 'Reactive Power Phase 2';

  @override
  String get fieldReactivePowerPhase3 => 'Reactive Power Phase 3';

  @override
  String get fieldApparentPowerPhase1 => 'Apparent Power Phase 1';

  @override
  String get fieldApparentPowerPhase2 => 'Apparent Power Phase 2';

  @override
  String get fieldApparentPowerPhase3 => 'Apparent Power Phase 3';

  @override
  String get fieldFrequencyPhase1 => 'Frequency Phase 1';

  @override
  String get fieldFrequencyPhase2 => 'Frequency Phase 2';

  @override
  String get fieldFrequencyPhase3 => 'Frequency Phase 3';

  @override
  String get fieldInverterType => 'Inverter Type';

  @override
  String get fieldAccessModel => 'Access Model';

  @override
  String get fieldDtuSerialNumber => 'DTU Serial Number';

  @override
  String get fieldNetworkMode => 'Network Mode';

  @override
  String get fieldServerDomain => 'Server Domain';

  @override
  String get fieldServerPort => 'Server Port';

  @override
  String get fieldSendInterval => 'Send Interval';

  @override
  String get fieldChannel => 'Channel';

  @override
  String get fieldMeterKind => 'Meter Kind';

  @override
  String get fieldMeterInterface => 'Meter Interface';

  @override
  String get fieldZeroExportEnabled => 'Zero Export Enabled';

  @override
  String get fieldZeroExportAddress => 'Zero Export Address';

  @override
  String get fieldLockPasswordSet => 'Lock Password Set';

  @override
  String get fieldLockTimeMinutes => 'Lock Time Minutes';

  @override
  String get fieldInverter => 'Inverter';

  @override
  String get fieldInverterToggleDescription => 'Turn inverter on or off';

  @override
  String get fieldNumberOfInverters => 'Number of Inverters';

  @override
  String get fieldCurrentPvPower => 'Current PV Power';

  @override
  String get fieldMonthlyYield => 'Monthly Yield';

  @override
  String get fieldYearlyYield => 'Yearly Yield';

  @override
  String get fieldVoltage => 'Voltage';

  @override
  String get fieldCurrent => 'Current';

  @override
  String get fieldBatteryCycles => 'Cycles';

  @override
  String get fieldBatteryCapacityGross => 'Capacity (Gross)';

  @override
  String get fieldBatteryCapacityNet => 'Capacity (Net)';

  @override
  String get fieldTotalConsumption => 'Total Consumption';

  @override
  String get fieldConsumptionFromPv => 'Consumption from PV';

  @override
  String get fieldConsumptionFromGrid => 'Consumption from Grid';

  @override
  String get fieldConsumptionFromBattery => 'Consumption from Battery';

  @override
  String get fieldFrequency => 'Frequency';

  @override
  String get fieldMaxInverterPower => 'Max Inverter Power';

  @override
  String get fieldInverterGenerationPower => 'Inverter Generation Power';

  @override
  String get fieldIsolationResistance => 'Isolation Resistance';

  @override
  String get categoryPv1 => 'PV1';

  @override
  String get categoryPv2 => 'PV2';

  @override
  String get categoryPv3 => 'PV3';

  @override
  String get categoryPv4 => 'PV4';

  @override
  String get categoryAcGrid => 'AC (Grid)';

  @override
  String get categoryAcTotal => 'AC Total';

  @override
  String get categoryPhase1 => 'Phase 1';

  @override
  String get categoryPhase2 => 'Phase 2';

  @override
  String get categoryPhase3 => 'Phase 3';

  @override
  String get categoryTotals => 'Totals';

  @override
  String get categoryAcPhase1 => 'AC Phase 1';

  @override
  String get categoryAcPhase2 => 'AC Phase 2';

  @override
  String get categoryAcPhase3 => 'AC Phase 3';

  @override
  String get categoryDcString1 => 'DC String 1';

  @override
  String get categoryDcString2 => 'DC String 2';

  @override
  String get categoryDcString3 => 'DC String 3';

  @override
  String get categorySystem => 'System';

  @override
  String get categoryDeviceInfo => 'Device Information';

  @override
  String get categoryBattery => 'Battery';

  @override
  String get categoryInverter => 'Inverter';

  @override
  String get categoryMemory => 'Memory';

  @override
  String get categoryStorage => 'Storage';

  @override
  String get categoryPowerMeter => 'Power Meter';

  @override
  String get categoryHomeConsumption => 'Home Consumption';

  @override
  String categoryMeasurementInstance(String instanceNum) {
    return 'Measurement $instanceNum';
  }

  @override
  String categorySwitchInstance(String instanceNum) {
    return 'Switch $instanceNum';
  }

  @override
  String categoryPmMeasurementInstance(String instanceNum) {
    return 'PM Measurement $instanceNum';
  }

  @override
  String categoryInverterInstance(String instanceNum) {
    return 'Inverter $instanceNum';
  }

  @override
  String categoryStringInstance(String instanceNum) {
    return 'String $instanceNum';
  }

  @override
  String get categoryEm1Combined => 'Combined';

  @override
  String get categoryPm1Combined => 'PM Combined';

  @override
  String get categorySwitchCombined => 'Switch Combined';

  @override
  String get categoryPowerMeterPhase1 => 'Power Meter Phase 1';

  @override
  String get categoryPowerMeterPhase2 => 'Power Meter Phase 2';

  @override
  String get categoryPowerMeterPhase3 => 'Power Meter Phase 3';

  @override
  String get fieldSolarPower => 'Solar Power';

  @override
  String get fieldConsumption => 'Consumption';

  @override
  String get fieldGridImport => 'Grid Import';

  @override
  String get fieldBatteryChargeDischargePower =>
      'Battery Charge/Discharge Power';

  @override
  String get fieldSolarInputPower => 'Solar Input Power';

  @override
  String get fieldHomeOutputPower => 'Home Output Power';

  @override
  String get fieldAcMode => 'AC Mode';

  @override
  String get fieldPackCount => 'Pack Count';

  @override
  String get menuWifiConfiguration => 'Configure WiFi';

  @override
  String get menuOnlineMonitoringConfiguration => 'Configure Online Monitoring';

  @override
  String get menuRestartDevice => 'Restart Device';

  @override
  String get menuAccessPointConfiguration => 'Configure Access Point';

  @override
  String get menuPowerLimit => 'Power Limit';

  @override
  String get menuAuthentication => 'Authentication';

  @override
  String get menuAutomation => 'Automation';

  @override
  String get menuPowerSettings => 'Power Settings';

  @override
  String get menuBatteryLimits => 'Battery Limits';

  @override
  String get menuAdvancedPowerSettings => 'Advanced Power Settings';

  @override
  String get menuPortConfiguration => 'Configure Port';

  @override
  String get menuSubtitleGeneralSettings => 'Manage basic device settings';

  @override
  String get menuSubtitleWifiConfiguration => 'Setup network connection';

  @override
  String get menuSubtitleOnlineMonitoring =>
      'Setup server for data transmission';

  @override
  String get menuSubtitleRestartDevice => 'Restart the device';

  @override
  String get menuSubtitleAccessPoint => 'Setup WiFi access point';

  @override
  String get menuSubtitlePowerLimit => 'Limit output power';

  @override
  String get menuSubtitleAuthentication => 'Configure credentials';

  @override
  String get menuSubtitleDeviceInfo => 'View device information';

  @override
  String get menuSubtitlePowerSettings => 'Configure power parameters';

  @override
  String get menuSubtitleBatteryLimits => 'Configure battery limits';

  @override
  String get menuSubtitleAdvancedPowerSettings => 'Advanced power options';

  @override
  String get menuSubtitlePortConfiguration => 'Configure RPC UDP port';

  @override
  String get menuSubtitleAutomation => 'Manage Shelly scripts';

  @override
  String get menuPercentagePowerLimit => 'Power Limit (Percentage)';

  @override
  String get menuSubtitlePercentagePowerLimit => 'Limit inverter power';

  @override
  String get menuInverterToggle => 'Toggle Inverters On/Off';

  @override
  String get menuSubtitleInverterToggle => 'Toggles all inverters';

  @override
  String get menuMqttConfiguration => 'Configure MQTT';

  @override
  String get menuSubtitleMqttConfiguration => 'Setup MQTT broker connection';

  @override
  String get fieldChipModel => 'Chip Model';

  @override
  String get fieldHeap => 'Heap';

  @override
  String get fieldSketch => 'Sketch';

  @override
  String get fieldLittleFs => 'LittleFS';

  @override
  String get fieldSocSet => 'SOC Set';

  @override
  String get fieldMinSoc => 'Min SOC';

  @override
  String get fieldGridReverse => 'Grid Reverse';

  @override
  String get fieldLampSwitch => 'Lamp Switch';

  @override
  String get fieldGridOffMode => 'Grid Off Mode';

  @override
  String get fieldFanMode => 'Fan Mode';

  @override
  String get fieldFanSpeed => 'Fan Speed';

  @override
  String get fieldSmartMode => 'Smart Mode';

  @override
  String get fieldTimestamp => 'Timestamp';

  @override
  String get fieldTimezone => 'Timezone';

  @override
  String get fieldBatteryPacks => 'Battery Packs';

  @override
  String get fieldSolarInput => 'Solar Input';

  @override
  String get fieldOutputPower => 'Output Power';

  @override
  String get fieldInputVoltage => 'Input Voltage';

  @override
  String fieldDcStringPower(String name) {
    return '$name - DC String Power';
  }

  @override
  String fieldDcStringVoltage(String name) {
    return '$name - DC String Voltage';
  }

  @override
  String fieldDcInputPower(String prefix) {
    return '$prefix - DC Input Power';
  }

  @override
  String fieldAcOutputPower(String prefix) {
    return '$prefix - AC Output Power';
  }

  @override
  String get fieldAllInverters => 'All Inverters';

  @override
  String get fieldLamp => 'Lamp';

  @override
  String get fieldEmergencyPowerSupply => 'Emergency Power Supply';

  @override
  String get fieldDeviceLightingDescription => 'Turn device lighting on or off';

  @override
  String get fieldGridPowerModeDescription => 'Grid power mode for the device';

  @override
  String get fieldNoInverterData => 'No inverter data available';

  @override
  String get fieldStatusProducing => 'Producing';

  @override
  String get fieldStatusReachable => 'Reachable';

  @override
  String get fieldStatusNotReachable => 'Not reachable';

  @override
  String get fieldAcFrequency => 'AC Frequency';

  @override
  String get fieldPower => 'Power';

  @override
  String fieldInverterFallback(String num) {
    return 'Inverter $num';
  }

  @override
  String fieldStringFallback(String num) {
    return 'String $num';
  }

  @override
  String errorLoadingAuthConfig(String error) {
    return 'Failed to load authentication configuration: $error';
  }

  @override
  String errorLoadingWifiConfig(String error) {
    return 'Failed to load WiFi configuration: $error';
  }

  @override
  String get firmwareNotSupported => 'Firmware Not Supported';

  @override
  String get firmwareNotSupportedMessage =>
      'This feature is not supported by your OpenDTU firmware.\n\nPlease install the modified firmware with REST API support.';

  @override
  String get downloadFirmware => 'Download Firmware';

  @override
  String get noInvertersFound => 'No inverters found';

  @override
  String get toggleInverters => 'Toggle Inverters';

  @override
  String get toggleInvertersPrompt =>
      'Would you like to turn all inverters on or off?';

  @override
  String get selectInverterToToggle => 'Select Inverter';

  @override
  String get inverterCurrentlyOn => 'Inverter is currently ON. Turn off?';

  @override
  String get inverterCurrentlyOff => 'Inverter is currently OFF. Turn on?';

  @override
  String get turnOff => 'Turn Off';

  @override
  String get turnOn => 'Turn On';

  @override
  String get turningOnInverters => 'Turning on inverters...';

  @override
  String get turningOffInverters => 'Turning off inverters...';

  @override
  String get invertersTurnedOn => 'Inverters turned on';

  @override
  String get invertersTurnedOff => 'Inverters turned off';

  @override
  String get restartDeviceConfirm => 'The device will be restarted. Continue?';

  @override
  String get menuRestartInverter => 'Restart Inverter';

  @override
  String get menuSubtitleRestartInverter => 'Restarts an inverter';

  @override
  String get selectInverterToRestart => 'Select Inverter to Restart';

  @override
  String get selectInverterToSetLimit => 'Select Inverter for Power Limit';

  @override
  String get restartInverterConfirm => 'Restart inverter?';

  @override
  String get restartingInverter => 'Restarting inverter...';

  @override
  String get inverterRestarted => 'Inverter restarted';
}
