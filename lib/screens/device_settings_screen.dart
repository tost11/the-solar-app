import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/devices/mixins/additional_port_mixin.dart';
import '../models/devices/mixins/device_authentication_mixin.dart';
import '../models/devices/mixins/device_wifi_mixin.dart';
import '../models/devices/mixins/fetch_data_timeout_mixin.dart';
import '../services/device_storage_service.dart';
import '../utils/localization_extension.dart';
import '../utils/message_utils.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';

/// Screen for configuring device settings (name and authentication)
class DeviceSettingsScreen extends StatefulWidget {
  final Device device;

  const DeviceSettingsScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _ipAddressController;
  late TextEditingController _hostnameController;
  late TextEditingController _portController;
  late TextEditingController _additionalPortController;
  late TextEditingController _fetchDataIntervalController;
  bool _obscurePassword = true;
  bool _isSavingName = false;
  bool _isSavingAuth = false;
  bool _isSavingNetwork = false;
  bool _isSavingFetchDataInterval = false;

  // Check if device supports authentication
  bool get _hasAuthSupport => widget.device is DeviceAuthenticationMixin;

  // Check if device supports WiFi configuration
  bool get _hasWifiSupport => widget.device is DeviceWifiMixin;

  // Check if device supports additional protocol port (e.g., Modbus)
  bool get _hasAdditionalPortSupport => widget.device is AdditionalPortMixin;

  // Check if device supports fetch data interval configuration
  bool get _hasFetchDataIntervalSupport => widget.device is FetchDataTimeoutMixin;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);

    if (_hasAuthSupport) {
      final authDevice = widget.device as DeviceAuthenticationMixin;
      _usernameController =
          TextEditingController(text: authDevice.authUsername ?? '');
      _passwordController =
          TextEditingController(text: authDevice.authPassword ?? '');
    } else {
      _usernameController = TextEditingController();
      _passwordController = TextEditingController();
    }

    if (_hasWifiSupport) {
      final wifiDevice = widget.device as DeviceWifiMixin;
      _ipAddressController = TextEditingController(text: wifiDevice.netIpAddress ?? '');
      _hostnameController = TextEditingController(text: wifiDevice.netHostname ?? '');
      _portController = TextEditingController(text: wifiDevice.netPort?.toString() ?? '80');
    } else {
      _ipAddressController = TextEditingController();
      _hostnameController = TextEditingController();
      _portController = TextEditingController();
    }

    if (_hasAdditionalPortSupport) {
      final additionalPortDevice = widget.device as AdditionalPortMixin;
      _additionalPortController = TextEditingController(
        text: additionalPortDevice.additionalPort.toString()
      );
    } else {
      _additionalPortController = TextEditingController();
    }

    if (_hasFetchDataIntervalSupport) {
      final fetchDataDevice = widget.device as FetchDataTimeoutMixin;
      _fetchDataIntervalController = TextEditingController(
        text: fetchDataDevice.fetchDataInterval.inSeconds.toString()
      );
    } else {
      _fetchDataIntervalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _ipAddressController.dispose();
    _hostnameController.dispose();
    _portController.dispose();
    _additionalPortController.dispose();
    _fetchDataIntervalController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      MessageUtils.showError(context, context.l10n.validationDeviceNameCannotBeEmpty);
      return;
    }

    setState(() {
      _isSavingName = true;
    });

    try {

      widget.device.name = _nameController.text.trim();

      // Save to storage
      await DeviceStorageService().saveDevice(widget.device);

      if (context.mounted) {
        MessageUtils.showSuccess(context, context.l10n.messageDeviceNameSaved);
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showError(context, context.l10n.errorWhileSaving(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingName = false;
        });
      }
    }
  }

  Future<void> _saveAuthentication() async {
    setState(() {
      _isSavingAuth = true;
    });

    try {
      // Update authentication fields
      final authDevice = widget.device as DeviceAuthenticationMixin;
      authDevice.authUsername = _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim();
      authDevice.authPassword = _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim();

      // Save to storage
      await DeviceStorageService().saveDevice(widget.device);

      if (context.mounted) {
        MessageUtils.showSuccess(context, context.l10n.messageAuthSaved);
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showError(context, context.l10n.errorWhileSaving(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAuth = false;
        });
      }
    }
  }

  Future<void> _saveNetwork() async {
    setState(() {
      _isSavingNetwork = true;
    });

    try {
      final wifiDevice = widget.device as DeviceWifiMixin;

      // Update network fields
      wifiDevice.netIpAddress = _ipAddressController.text.trim().isEmpty
          ? null
          : _ipAddressController.text.trim();
      wifiDevice.netHostname = _hostnameController.text.trim().isEmpty
          ? null
          : _hostnameController.text.trim();

      // Parse port with validation
      final portText = _portController.text.trim();
      if (portText.isNotEmpty) {
        final port = int.tryParse(portText);
        if (port == null || port < 1 || port > 65535) {
          MessageUtils.showError(context, 'Port muss zwischen 1 und 65535 liegen');
          setState(() {
            _isSavingNetwork = false;
          });
          return;
        }
        wifiDevice.netPort = port;
      } else {
        wifiDevice.netPort = 80; // Default port
      }

      // Save additional protocol port if supported
      if (_hasAdditionalPortSupport) {
        final additionalPortDevice = widget.device as AdditionalPortMixin;
        final additionalPortText = _additionalPortController.text.trim();

        if (additionalPortText.isNotEmpty) {
          final additionalPort = int.tryParse(additionalPortText);
          if (additionalPort == null || additionalPort < 1 || additionalPort > 65535) {
            MessageUtils.showError(context, 'Protokoll-Port muss zwischen 1 und 65535 liegen');
            setState(() {
              _isSavingNetwork = false;
            });
            return;
          }
          additionalPortDevice.additionalPort = additionalPort;
        }
      }

      // Validate at least one connection method
      if (wifiDevice.netIpAddress == null && wifiDevice.netHostname == null) {
        MessageUtils.showError(context, context.l10n.validationEnterIpOrHostname);
        setState(() {
          _isSavingNetwork = false;
        });
        return;
      }

      // Save to storage
      await DeviceStorageService().saveDevice(widget.device);

      if (context.mounted) {
        MessageUtils.showSuccess(context, context.l10n.messageNetworkSaved);
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showError(context, context.l10n.errorWhileSaving(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingNetwork = false;
        });
      }
    }
  }

  Future<void> _saveFetchDataInterval() async {
    setState(() {
      _isSavingFetchDataInterval = true;
    });

    try {
      final fetchDataDevice = widget.device as FetchDataTimeoutMixin;
      final intervalText = _fetchDataIntervalController.text.trim();

      if (intervalText.isEmpty) {
        MessageUtils.showError(context, 'Aktualisierungsintervall darf nicht leer sein');
        setState(() {
          _isSavingFetchDataInterval = false;
        });
        return;
      }

      final intervalSeconds = int.tryParse(intervalText);
      if (intervalSeconds == null || intervalSeconds < 1 || intervalSeconds > 300) {
        MessageUtils.showError(context, 'Intervall muss zwischen 1 und 300 Sekunden liegen');
        setState(() {
          _isSavingFetchDataInterval = false;
        });
        return;
      }

      fetchDataDevice.fetchDataInterval = Duration(seconds: intervalSeconds);

      // Save to storage
      await DeviceStorageService().saveDevice(widget.device);

      if (context.mounted) {
        MessageUtils.showSuccess(context, context.l10n.messageIntervalSaved);
      }
    } catch (e) {
      if (context.mounted) {
        MessageUtils.showError(context, context.l10n.errorWhileSaving(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingFetchDataInterval = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenDeviceSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.devices,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.screenDeviceSettings,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.helpDeviceSettingsDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Device Name Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.deviceName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.l10n.name,
                        hintText: 'z.B. Wohnzimmer Steckdose',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isSavingName ? null : _saveName,
                      icon: _isSavingName
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSavingName ? context.l10n.messageSaving : context.l10n.save),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Device Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.deviceInfo,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.fingerprint, color: Colors.grey),
                      title: const Text('Geräte-ID'),
                      subtitle: Text(widget.device.id),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (widget.device.deviceSn != null)
                      ListTile(
                        leading: const Icon(Icons.qr_code, color: Colors.grey),
                        title: const Text('Seriennummer'),
                        subtitle: Text(widget.device.deviceSn!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ListTile(
                      leading: Icon(
                        widget.device.connectionType == ConnectionType.bluetooth
                            ? Icons.bluetooth
                            : Icons.wifi,
                        color: Colors.grey,
                      ),
                      title: const Text('Verbindungstyp'),
                      subtitle: Text(widget.device.connectionType.displayName),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (widget.device.deviceModel != null)
                      ListTile(
                        leading: const Icon(Icons.devices, color: Colors.grey),
                        title: Text(context.l10n.deviceType),
                        subtitle: Text(widget.device.deviceModel!),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),

            // Network Configuration Card (only if device has WiFi mixin)
            if (_hasWifiSupport) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Netzwerkkonfiguration',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IP-Adresse, Hostname und Port für die Geräteverbindung',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ipAddressController,
                        decoration: InputDecoration(
                          labelText: context.l10n.formIpAddress,
                          hintText: '192.168.1.100',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.computer),
                          helperText: 'Optional: Direkte IP-Verbindung',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _hostnameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.formHostname,
                          hintText: 'device.local',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.dns),
                          helperText: 'Optional: mDNS/DNS Hostname',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _portController,
                        decoration: InputDecoration(
                          labelText: context.l10n.formPort,
                          hintText: '80',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.settings_ethernet),
                          helperText: 'Standard: 80',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      if (_hasAdditionalPortSupport) ...[
                        TextField(
                          controller: _additionalPortController,
                          decoration: InputDecoration(
                            labelText: context.l10n.formProtocolPort,
                            hintText: '1502',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.cable),
                            helperText: context.l10n.formAdditionalPortHelper,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isSavingNetwork ? null : _saveNetwork,
                        icon: _isSavingNetwork
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSavingNetwork ? context.l10n.messageSaving : context.l10n.actionSaveNetwork),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Fetch Data Interval Card (only if device has mixin)
            if (_hasFetchDataIntervalSupport) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.update, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.intervalUpdateInterval,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.helpUpdateIntervalDescription,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fetchDataIntervalController,
                        decoration: InputDecoration(
                          labelText: context.l10n.intervalEnterInterval,
                          hintText: '30',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.timer),
                          helperText: context.l10n.helpIntervalDefault,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isSavingFetchDataInterval ? null : _saveFetchDataInterval,
                        icon: _isSavingFetchDataInterval
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSavingFetchDataInterval
                            ? context.l10n.messageSaving
                            : context.l10n.actionSaveInterval),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Authentication Card (only if device has mixin)
            if (_hasAuthSupport) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.screenAuthentication,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.helpAuthDescription,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        enabled: !(widget.device as DeviceAuthenticationMixin).fixedUserName,
                        decoration: InputDecoration(
                          labelText: context.l10n.formUsername,
                          hintText: 'admin',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                          helperText: (widget.device as DeviceAuthenticationMixin).fixedUserName
                              ? context.l10n.authUsernameCannotBeChanged
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: context.l10n.formPassword,
                          hintText: context.l10n.formEnterPassword,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isSavingAuth ? null : _saveAuthentication,
                        icon: _isSavingAuth
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSavingAuth ? context.l10n.messageSaving : context.l10n.actionSaveAuth),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
