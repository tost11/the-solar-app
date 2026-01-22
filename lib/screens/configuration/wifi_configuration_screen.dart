import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';

import '../../services/wifi_service.dart';
import '../../utils/localization_extension.dart';
import '../../widgets/wifi_config_widget.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class WiFiConfigurationScreen extends BaseCommandScreen {
  final String? currentSsid;
  final String? currentPassword;

  const WiFiConfigurationScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.currentSsid,
    this.currentPassword,
  });

  @override
  State<WiFiConfigurationScreen> createState() => _WiFiConfigurationScreenState();
}

class _WiFiConfigurationScreenState extends State<WiFiConfigurationScreen> {
  final WiFiService _wifiService = WiFiService();
  bool _isSendingWifi = false;

  Future<void> _sendWifiConfiguration(String ssid, String password) async {
    setState(() => _isSendingWifi = true);

    try {
      await widget.sendCommandToDevice(
          COMMAND_SET_WIFI, {"ssid": ssid, "password": password});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.messageWifiConfigSent),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Wait a moment for user to see success message
        await Future.delayed(const Duration(seconds: 2));

        // Navigate back to device detail screen
        if (mounted) {
          Navigator.pop(context, true); // true indicates success
        }
      }
    }catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorWhileSending(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isSendingWifi = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenWifiConfig,
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
                          Icons.wifi,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.formSelectOrEnterWifiNetwork,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.device.name.isEmpty ? context.l10n.deviceFallbackName : widget.device.name,
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
                      context.l10n.helpWifiSetupInstructions,
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

            // WiFi Configuration Widget
            if (!_isSendingWifi)
              WiFiConfigWidget(
                wifiService: _wifiService,
                onSendConfig: _sendWifiConfiguration,
                isSending: _isSendingWifi,
                initialSsid: widget.currentSsid,
                initialPassword: widget.currentPassword,
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.dialogWifiConfigSending,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.messageWifiConfigSent,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

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
                          context.l10n.helpWifiSetupInstructions,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.helpWifiSetupInstructions,
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
