import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:the_solar_app/models/devices/mixins/additional_port_mixin.dart';
import 'package:the_solar_app/models/devices/mixins/device_authentication_mixin.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../models/authentication_mode.dart';
import '../models/device.dart';
import '../models/network_device.dart';
import '../models/manufacturer_detector_info.dart';
import '../services/network_scan_service.dart';
import '../services/device_storage_service.dart';
import '../widgets/app_bar_widget.dart';

class ManualDeviceAddScreen extends StatefulWidget {
  const ManualDeviceAddScreen({super.key});

  @override
  State<ManualDeviceAddScreen> createState() => _ManualDeviceAddScreenState();
}

class _ManualDeviceAddScreenState extends State<ManualDeviceAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceStorageService = DeviceStorageService();
  final _networkInfo = NetworkInfo();

  // Form fields
  String? _selectedManufacturer;
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _additionalPortController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isProbing = false;
  ManufacturerDetectorInfo? _currentDetectorInfo;

  // Validation states
  bool _manufacturerValid = false;
  bool _ipValid = false;
  bool _portValid = false;
  bool _additionalPortValid = true; // Optional field, valid by default
  bool _usernameValid = true; // Optional unless auth required
  bool _passwordValid = true; // Optional unless auth required

  @override
  void initState() {
    super.initState();
    NetworkScanService.initializeDetectors();
    _initializeNetworkPrefix();

    // Add listeners for real-time validation
    _ipController.addListener(_validateIp);
    _portController.addListener(_validatePort);
    _additionalPortController.addListener(_validateAdditionalPort);
    _usernameController.addListener(_validateUsername);
    _passwordController.addListener(_validatePassword);
  }

  Future<void> _initializeNetworkPrefix() async {
    final wifiIP = await _networkInfo.getWifiIP();
    if (wifiIP != null && wifiIP.isNotEmpty) {
      final prefix = ipToCSubnet(wifiIP);
      _ipController.text = '$prefix.';
    }
  }

  void _onManufacturerChanged(String? manufacturer) {
    setState(() {
      _selectedManufacturer = manufacturer;
      _manufacturerValid = manufacturer != null;

      if (manufacturer != null) {
        _currentDetectorInfo = NetworkScanService.getDetectorInfo(manufacturer);

        // Update defaults
        _portController.text = _currentDetectorInfo!.defaultPort.toString();

        if (_currentDetectorInfo!.additionalPort != null) {
          _additionalPortController.text = _currentDetectorInfo!.additionalPort.toString();
        } else {
          _additionalPortController.clear();
        }

        // Update auth fields based on requirements
        if (_currentDetectorInfo!.usernameMode != AuthenticationMode.none) {
          _usernameController.text = _currentDetectorInfo!.defaultUsername ?? '';
        } else {
          _usernameController.clear();
        }

        if (_currentDetectorInfo!.passwordMode != AuthenticationMode.none) {
          _passwordController.text = _currentDetectorInfo!.defaultPassword ?? '';
        } else {
          _passwordController.clear();
        }
      }
    });

    // Re-validate all fields when manufacturer changes
    _validateIp();
    _validatePort();
    _validateAdditionalPort();
    _validateUsername();
    _validatePassword();
  }

  /// Validate IP address or hostname
  void _validateIp() {
    final value = _ipController.text.trim();
    setState(() {
      if (value.isEmpty) {
        _ipValid = false;
      } else {
        _ipValid = _isIpAddress(value) || _isValidHostname(value);
      }
    });
  }

  /// Validate port number
  void _validatePort() {
    final value = _portController.text.trim();
    setState(() {
      if (value.isEmpty) {
        _portValid = false;
      } else {
        final port = int.tryParse(value);
        _portValid = port != null && port >= 1 && port <= 65535;
      }
    });
  }

  /// Validate additional port (optional field)
  void _validateAdditionalPort() {
    final value = _additionalPortController.text.trim();
    setState(() {
      // If no additional port is required by manufacturer, always valid
      if (_currentDetectorInfo?.additionalPort == null) {
        _additionalPortValid = true;
        return;
      }

      // If additional port is shown but empty, it's optional (valid)
      if (value.isEmpty) {
        _additionalPortValid = true;
        return;
      }

      // If not empty, validate the port number
      final port = int.tryParse(value);
      _additionalPortValid = port != null && port >= 1 && port <= 65535;
    });
  }

  /// Validate username (required only if mode is required)
  void _validateUsername() {
    final value = _usernameController.text.trim();
    setState(() {
      final usernameMode = _currentDetectorInfo?.usernameMode ?? AuthenticationMode.none;
      // Valid if: mode is none/optional OR (mode is required AND has value)
      _usernameValid = usernameMode != AuthenticationMode.required || value.isNotEmpty;
    });
  }

  /// Validate password (required only if mode is required)
  void _validatePassword() {
    final value = _passwordController.text.trim();
    setState(() {
      final passwordMode = _currentDetectorInfo?.passwordMode ?? AuthenticationMode.none;
      // Valid if: mode is none/optional OR (mode is required AND has value)
      _passwordValid = passwordMode != AuthenticationMode.required || value.isNotEmpty;
    });
  }

  /// Check if input is a valid hostname
  bool _isValidHostname(String input) {
    // Basic hostname validation: alphanumeric, hyphens, dots
    // Must not start/end with hyphen or dot
    final hostnamePattern = RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9\-\.]{0,253}[a-zA-Z0-9])?$');
    return hostnamePattern.hasMatch(input);
  }

  bool _canProbe() {
    return _manufacturerValid &&
           _ipValid &&
           _portValid &&
           _additionalPortValid &&
           _usernameValid &&
           _passwordValid;
  }

  /// Check if input is a valid IP address
  bool _isIpAddress(String input) {
    final ipv4Pattern = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return ipv4Pattern.hasMatch(input);
  }

  /// Resolve hostname to IP address
  Future<String?> _resolveHostnameToIp(String hostname) async {
    try {
      final addresses = await InternetAddress.lookup(hostname);
      if (addresses.isEmpty) {
        return null;
      }

      // Separate IPv4 and IPv6 addresses
      final ipv4Addresses = addresses
          .where((addr) => addr.type == InternetAddressType.IPv4)
          .toList();
      final ipv6Addresses = addresses
          .where((addr) => addr.type == InternetAddressType.IPv6)
          .toList();

      // Prefer IPv4, fallback to IPv6
      if (ipv4Addresses.isNotEmpty) {
        debugPrint('Resolved $hostname to IPv4: ${ipv4Addresses.first.address}');
        return ipv4Addresses.first.address;
      } else if (ipv6Addresses.isNotEmpty) {
        debugPrint('Resolved $hostname to IPv6 (no IPv4 available): ${ipv6Addresses.first.address}');
        return ipv6Addresses.first.address;
      }

      return null;
    } catch (e) {
      debugPrint('Failed to resolve hostname $hostname: $e');
    }
    return null;
  }

  /// Try to resolve IP address back to hostname
  Future<String?> _resolveIpToHostname(String ipAddress) async {
    try {
      final address = InternetAddress(ipAddress);
      final host = await address.reverse();
      // Remove trailing dot if present
      return host.host.endsWith('.') ? host.host.substring(0, host.host.length - 1) : host.host;
    } catch (e) {
      debugPrint('Failed to reverse resolve IP $ipAddress: $e');
    }
    return null;
  }

  Future<void> _probeDevice() async {
    if (!_canProbe() || _isProbing) return;

    setState(() => _isProbing = true);

    try {
      final inputValue = _ipController.text.trim();
      final isIp = _isIpAddress(inputValue);

      // Resolve hostname to IP if needed
      String ipAddressToProbe = inputValue;
      String? hostnameForDevice;

      if (!isIp) {
        // Input is a hostname, resolve to IP
        final resolvedIp = await _resolveHostnameToIp(inputValue);
        if (resolvedIp == null) {
          if (mounted) {
            MessageUtils.showError(
              context,
              context.l10n.errorWhileLoading('Hostname'),
              title: 'DNS-Fehler',
            );
          }
          return;
        }
        ipAddressToProbe = resolvedIp;
        hostnameForDevice = inputValue; // Store hostname for later
        debugPrint('Resolved hostname $inputValue to IP $resolvedIp');
      }

      // Determine username based on authentication mode
      final username = _currentDetectorInfo!.usernameMode != AuthenticationMode.none
          ? (_usernameController.text.isEmpty ? null : _usernameController.text)
          : (_currentDetectorInfo!.passwordMode != AuthenticationMode.none ? 'admin' : null);

      final device = await NetworkScanService.probeManufacturer(
        manufacturerKey: _selectedManufacturer!,
        ipAddress: ipAddressToProbe,
        port: int.parse(_portController.text),
        username: username,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        additionalPort: _additionalPortController.text.isEmpty
            ? null
            : int.tryParse(_additionalPortController.text),
        timeout: const Duration(seconds: 5),
      );

      debugPrint("Probing manually created device complete");

      if (device != null && mounted) {
        //TODO check what this here is for and if it even is working
        // If input was IP, try to resolve back to hostname
        if (isIp && hostnameForDevice == null) {
          hostnameForDevice = await _resolveIpToHostname(ipAddressToProbe);
          if (hostnameForDevice != null) {
            debugPrint('Reverse resolved IP $ipAddressToProbe to hostname $hostnameForDevice');
          }
        }

        // Convert NetworkDevice to DeviceBase and save
        final knownDevice = await _connectToNetworkDevice(device, hostnameForDevice);
        if (mounted) {
          Navigator.pop(context, knownDevice);
        }
      } else if (mounted) {
        MessageUtils.showError(
          context,
          context.l10n.statusDeviceNotFound,
          title: context.l10n.error,
        );
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
          context,
          e.toString(),
          title: 'Verbindungsfehler',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProbing = false);
      }
    }
  }

  Future<DeviceBase> _connectToNetworkDevice(
    NetworkDevice networkDevice,
    String? resolvedHostname,
  ) async {
    // Use resolved hostname if available, otherwise use networkDevice hostname or IP
    final effectiveHostname = resolvedHostname ?? networkDevice.hostname;

    // Display hostname in device name if available
    final addressDisplay = effectiveHostname ?? networkDevice.ipAddress;
    final deviceName = networkDevice.deviceModel != null
        ? '${networkDevice.manufacturer} ${networkDevice.deviceModel} ($addressDisplay)'
        : '${networkDevice.manufacturer} ($addressDisplay)';

    final knownDevice = DeviceFactory.createWiFiDevice(
      id: "${networkDevice.serialNumber}_wifi",
      ipAddress: networkDevice.ipAddress,
      name: deviceName,
      deviceModel: networkDevice.deviceModel,
      deviceSn: networkDevice.serialNumber,
      manufacturer: networkDevice.manufacturer,
      hostname: effectiveHostname, // Use resolved hostname
      port: networkDevice.port
    );

    if(knownDevice is AdditionalPortMixin){
      (knownDevice as AdditionalPortMixin).additionalPort = networkDevice.additionalPort!;
    }

    if(networkDevice.username != null && knownDevice is DeviceAuthenticationMixin){
      (knownDevice as DeviceAuthenticationMixin).authUsername = networkDevice.username!;
    }
    if(networkDevice.password != null && knownDevice is DeviceAuthenticationMixin){
      (knownDevice as DeviceAuthenticationMixin).authPassword = networkDevice.password!;
    }

    await _deviceStorageService.saveDevice(knownDevice);
    return knownDevice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.screenManualDeviceAdd),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Manufacturer dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: context.l10n.formManufacturer,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _selectedManufacturer == null
                          ? Colors.red
                          : _manufacturerValid
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _selectedManufacturer == null
                          ? Colors.red
                          : _manufacturerValid
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _selectedManufacturer == null
                          ? Colors.blue
                          : _manufacturerValid
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: _selectedManufacturer == null
                      ? null
                      : Icon(
                          _manufacturerValid ? Icons.check_circle : Icons.error,
                          color: _manufacturerValid ? Colors.green : Colors.red,
                        ),
                ),
                value: _selectedManufacturer,
                items: NetworkScanService.getSupportedManufacturers()
                    .map((key) {
                      final info = NetworkScanService.getDetectorInfo(key)!;
                      return DropdownMenuItem(
                        value: key,
                        child: Text(info.manufacturerName),
                      );
                    })
                    .toList(),
                onChanged: _onManufacturerChanged,
                validator: (value) => value == null ? context.l10n.validationFieldCannotBeEmpty : null,
              ),
              const SizedBox(height: 16),

              // IP Address or Hostname
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: context.l10n.validationEnterIpOrHostname,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _ipController.text.isEmpty
                          ? Colors.red
                          : _ipValid
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _ipController.text.isEmpty
                          ? Colors.red
                          : _ipValid
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _ipController.text.isEmpty
                          ? Colors.blue
                          : _ipValid
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  hintText: '192.168.1.100 oder opendtu.local',
                  suffixIcon: _ipController.text.isEmpty
                      ? null
                      : Icon(
                          _ipValid ? Icons.check_circle : Icons.error,
                          color: _ipValid ? Colors.green : Colors.red,
                        ),
                ),
                keyboardType: TextInputType.text,
                validator: (value) => value?.isEmpty ?? true ? context.l10n.validationEnterIpOrHostname : null,
              ),
              const SizedBox(height: 16),

              // Port
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: context.l10n.formPort,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _portController.text.isEmpty
                          ? Colors.red
                          : _portValid
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _portController.text.isEmpty
                          ? Colors.red
                          : _portValid
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _portController.text.isEmpty
                          ? Colors.blue
                          : _portValid
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: _portController.text.isEmpty
                      ? null
                      : Icon(
                          _portValid ? Icons.check_circle : Icons.error,
                          color: _portValid ? Colors.green : Colors.red,
                        ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Bitte Port eingeben';
                  final port = int.tryParse(value!);
                  if (port == null || port < 1 || port > 65535) {
                    return 'Port muss zwischen 1 und 65535 liegen';
                  }
                  return null;
                },
              ),

              // Additional port (conditional)
              if (_currentDetectorInfo?.additionalPort != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _additionalPortController,
                  decoration: InputDecoration(
                    labelText: '${_currentDetectorInfo!.additionalPortLabel} Port',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _additionalPortController.text.isEmpty
                            ? Colors.red
                            : _additionalPortValid
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _additionalPortController.text.isEmpty
                            ? Colors.red
                            : _additionalPortValid
                                ? Colors.green
                                : Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _additionalPortController.text.isEmpty
                            ? Colors.blue
                            : _additionalPortValid
                                ? Colors.green
                                : Colors.red,
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: _additionalPortController.text.isEmpty
                        ? null
                        : Icon(
                            _additionalPortValid ? Icons.check_circle : Icons.error,
                            color: _additionalPortValid ? Colors.green : Colors.red,
                          ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],

              // Authentication (conditional)
              // Show username field if mode is optional or required
              if (_currentDetectorInfo?.usernameMode != null &&
                  _currentDetectorInfo!.usernameMode != AuthenticationMode.none) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Benutzername',
                    helperText: _currentDetectorInfo!.usernameMode == AuthenticationMode.optional
                        ? 'Optional'
                        : null,
                    border: _currentDetectorInfo!.usernameMode == AuthenticationMode.optional
                        ? const OutlineInputBorder()
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _usernameController.text.isEmpty
                                  ? Colors.red
                                  : _usernameValid
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                    enabledBorder: _currentDetectorInfo!.usernameMode == AuthenticationMode.optional
                        ? const OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _usernameController.text.isEmpty
                                  ? Colors.red
                                  : _usernameValid
                                      ? Colors.green
                                      : Colors.red,
                              width: 2.0,
                            ),
                          ),
                    focusedBorder: _currentDetectorInfo!.usernameMode == AuthenticationMode.optional
                        ? const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _usernameController.text.isEmpty
                                  ? Colors.blue
                                  : _usernameValid
                                      ? Colors.green
                                      : Colors.red,
                              width: 2.0,
                            ),
                          ),
                    suffixIcon: _currentDetectorInfo!.usernameMode == AuthenticationMode.optional
                        ? null
                        : (_usernameController.text.isEmpty
                            ? null
                            : Icon(
                                _usernameValid ? Icons.check_circle : Icons.error,
                                color: _usernameValid ? Colors.green : Colors.red,
                              )),
                  ),
                  validator: (value) {
                    if (_currentDetectorInfo!.usernameMode != AuthenticationMode.required) {
                      return null; // Optional or none - always valid
                    }
                    return value?.isEmpty ?? true ? 'Bitte Benutzername eingeben' : null;
                  },
                ),
              ],

              // Show password field if mode is optional or required
              if (_currentDetectorInfo?.passwordMode != null &&
                  _currentDetectorInfo!.passwordMode != AuthenticationMode.none) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    helperText: _currentDetectorInfo!.passwordMode == AuthenticationMode.optional
                        ? 'Optional'
                        : null,
                    border: _currentDetectorInfo!.passwordMode == AuthenticationMode.optional
                        ? const OutlineInputBorder()
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordController.text.isEmpty
                                  ? Colors.red
                                  : _passwordValid
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                    enabledBorder: _currentDetectorInfo!.passwordMode == AuthenticationMode.optional
                        ? const OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordController.text.isEmpty
                                  ? Colors.red
                                  : _passwordValid
                                      ? Colors.green
                                      : Colors.red,
                              width: 2.0,
                            ),
                          ),
                    focusedBorder: _currentDetectorInfo!.passwordMode == AuthenticationMode.optional
                        ? const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordController.text.isEmpty
                                  ? Colors.blue
                                  : _passwordValid
                                      ? Colors.green
                                      : Colors.red,
                              width: 2.0,
                            ),
                          ),
                    suffixIcon: _currentDetectorInfo!.passwordMode == AuthenticationMode.optional
                        ? null
                        : (_passwordController.text.isEmpty
                            ? null
                            : Icon(
                                _passwordValid ? Icons.check_circle : Icons.error,
                                color: _passwordValid ? Colors.green : Colors.red,
                              )),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_currentDetectorInfo!.passwordMode != AuthenticationMode.required) {
                      return null; // Optional or none - always valid
                    }
                    return value?.isEmpty ?? true ? 'Bitte Passwort eingeben' : null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Connect button
              ElevatedButton.icon(
                onPressed: (_isProbing || !_canProbe()) ? null : _probeDevice,
                icon: _isProbing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(_isProbing ? 'Verbinde...' : 'Verbinden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_canProbe() && !_isProbing)
                      ? Colors.green.shade100
                      : Colors.grey.shade300,
                  foregroundColor: (_canProbe() && !_isProbing)
                      ? Colors.black87
                      : Colors.grey.shade600,
                  minimumSize: const Size(double.infinity, 48),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                ),
              ),

              // Status message (optional)
              if (_isProbing)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'Suche Gerät...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _additionalPortController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
