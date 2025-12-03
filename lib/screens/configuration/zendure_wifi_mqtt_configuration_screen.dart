import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';

import '../../services/wifi_service.dart';
import '../../widgets/wifi_config_widget.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class ZendureWifiMqttConfigurationScreen
    extends BaseCommandScreen {
  final String? currentSsid;
  final String? currentPassword;
  final String currentMqtt;

  const ZendureWifiMqttConfigurationScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.currentSsid,
    this.currentPassword,
    required this.currentMqtt,
  });

  @override
  State<ZendureWifiMqttConfigurationScreen>
      createState() =>
          _ZendureWifiMqttConfigurationScreen();
}

class _ZendureWifiMqttConfigurationScreen
    extends State<ZendureWifiMqttConfigurationScreen> {
  final WiFiService _wifiService = WiFiService();
  bool _isSendingWifi = false;
  final TextEditingController _mqttController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mqttController.text = widget.currentMqtt;
  }

  @override
  void dispose() {
    _mqttController.dispose();
    super.dispose();
  }

  Future<void> _sendWifiConfiguration(
      String ssid, String password, String mqtt) async {
    setState(() => _isSendingWifi = true);

    try {
      await widget.sendCommandToDevice(COMMAND_SET_WIFI_MQTT,
          {"ssid": ssid, "password": password, "mqtt": mqtt});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WiFi-Konfiguration erfolgreich gesendet!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Wait a moment for user to see success message
        await Future.delayed(const Duration(seconds: 2));

        // Navigate back to device detail screen
        if (mounted) {
          Navigator.pop(context, true); // true indicates success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden: $e'),
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
      appBar: const AppBarWidget(
        title: 'WiFi konfigurieren',
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
                                'Netzwerk einrichten',
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
                                    ? 'Gerät'
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
                      'Verbinden Sie Ihr Gerät mit Ihrem WLAN-Netzwerk, ',
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

            // MQTT Info Card
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
                      'Bei älteren Firmware-Versionen kann MQTT nur zusammen mit den WiFi-Einstellungen gesetzt werden. Falls Sie keine MQTT-Konfiguration benötigen, lassen Sie das Feld unverändert.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
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
                onSendConfig: (ssid, passwrod) async {
                  _sendWifiConfiguration(ssid, passwrod, _mqttController.text);
                },
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
                        'WiFi-Konfiguration wird gesendet...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bitte warten Sie einen Moment',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // MQTT Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MQTT Konfiguration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mqttController,
                      enabled: !_isSendingWifi,
                      decoration: InputDecoration(
                        labelText: 'MQTT Server',
                        helperText: 'z.B. broker.example.com:1883',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.storage),
                      ),
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
                      '• Stellen Sie sicher, dass Ihr Gerät eingeschaltet ist\n'
                      '• Das WLAN-Passwort wird sicher übertragen\n'
                      '• Nach erfolgreicher Konfiguration kann es einige Sekunden dauern, bis das Gerät verbunden ist',
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
