import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';

import '../../utils/globals.dart';
import '../../utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class WiFiApConfigurationScreen extends BaseCommandScreen {
  final bool showSsidOption;
  final bool showEnabledOption;
  final bool showOpenOption;
  final bool showRangeExtenderOption;
  final String? currentSsid;
  final String? currentPassword;
  final bool currentIsOpen;
  final bool currentEnabled;
  final bool currentRangeExtender;

  const WiFiApConfigurationScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.showSsidOption = true,
    this.showEnabledOption = false,
    this.showOpenOption = false,
    this.showRangeExtenderOption = false,
    this.currentSsid,
    this.currentPassword,
    this.currentIsOpen = false,
    this.currentEnabled = true,
    this.currentRangeExtender = false,
  });

  @override
  State<WiFiApConfigurationScreen> createState() =>
      _WiFiApConfigurationScreenState();
}

class _WiFiApConfigurationScreenState extends State<WiFiApConfigurationScreen> {
  late TextEditingController _ssidController;
  late TextEditingController _passwordController;
  late bool _isOpen;
  late bool _enabled;
  late bool _rangeExtender;
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController(text: widget.currentSsid ?? '');
    _passwordController =
        TextEditingController(text: widget.currentPassword ?? '');
    _isOpen = widget.currentIsOpen;
    _enabled = widget.currentEnabled;
    _rangeExtender = widget.currentRangeExtender;
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    // Validation
    if (widget.showSsidOption && _ssidController.text.trim().isEmpty) {
      MessageUtils.showError(context, context.l10n.validationFieldCannotBeEmpty);
      return;
    }

    if (!_isOpen && _passwordController.text.trim().isEmpty) {
      MessageUtils.showError(
          context, context.l10n.validationEnterSecurePassword);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final command = <String, dynamic>{};

      // Only include SSID if shown on screen
      if (widget.showSsidOption) {
        command['ssid'] = _ssidController.text.trim();
      }

      // Only include is_open if shown on screen
      if (widget.showOpenOption) {
        command['isOpen'] = _isOpen;
      }

      // Only include enable if shown on screen (requires expert mode)
      if (widget.showEnabledOption && Globals.expertMode) {
        command['enable'] = _enabled;
      }

      // Only include range_extender_enable if shown on screen
      if (widget.showRangeExtenderOption) {
        command['rangeRxtenderEnable'] = _rangeExtender;
      }

      // Only include password if network is not open and password field is shown
      if (!_isOpen) {
        command['password'] = _passwordController.text;
      }

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_SET_AP_CONFIG, command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          context.l10n.savedSuccessfully,
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
            context, context.l10n.errorWhileSaving(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenAccessPointConfig,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.router,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.actionSetupAccessPoint,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.device.name.isEmpty
                                    ? context.l10n.deviceFallbackName
                                    : widget.device.name,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.infoConfigureAccessPoint,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SSID Input (only if showSsidOption)
            if (widget.showSsidOption)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Netzwerkname (SSID)',
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
                        controller: _ssidController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: context.l10n.formSsid,
                          hintText: context.l10n.formEnterSsid,
                          prefixIcon: const Icon(Icons.wifi, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.showSsidOption) const SizedBox(height: 16),

            // Enabled Switch (only if showEnabledOption && expertMode)
            if (widget.showEnabledOption && Globals.expertMode)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.power_settings_new,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.wifiEnableAccessPoint,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Switch(
                            value: _enabled,
                            onChanged: (value) {
                              setState(() {
                                _enabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.helpEnableOrDisableAp,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.helpApWarning,
                                style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.showEnabledOption && Globals.expertMode)
              const SizedBox(height: 16),

            // Open Network Switch (only if showOpenOption)
            if (widget.showOpenOption)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_open, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.wifiOpenNetwork,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Switch(
                            value: _isOpen,
                            onChanged: (value) {
                              setState(() {
                                _isOpen = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.helpOpenNetwork,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.showOpenOption) const SizedBox(height: 16),

            // Password Input (only if not open)
            if (!_isOpen)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.formPassword,
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
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: context.l10n.formPassword,
                          hintText: context.l10n.formEnterPassword,
                          prefixIcon: const Icon(Icons.lock, color: Colors.red),
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
                      const SizedBox(height: 8),
                      Text(
                        'Mindestens 8 Zeichen empfohlen',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isOpen) const SizedBox(height: 16),

            // Range Extender Switch (only if showRangeExtenderOption)
            if (widget.showRangeExtenderOption)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.compare_arrows,
                              color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Range Extender',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Switch(
                            value: _rangeExtender,
                            onChanged: (value) {
                              setState(() {
                                _rangeExtender = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Erweitert die Reichweite des WiFi-Netzwerks',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.showRangeExtenderOption) const SizedBox(height: 24),

            const SizedBox(height: 8),

            // Save button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving
                  ? context.l10n.messageSaving
                  : context.l10n.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Hinweis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.l10n.helpDevicePoweredOn}\n'
                      '• Nach der Konfiguration wird der Access Point neu gestartet\n'
                      '${context.l10n.helpStrongPassword}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
