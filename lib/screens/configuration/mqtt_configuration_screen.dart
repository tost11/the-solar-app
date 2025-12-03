import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

/// Screen for configuring MQTT connection settings
///
/// Allows enable/disable, server/port configuration, and optional authentication
class MqttConfigurationScreen extends BaseCommandScreen {
  final bool currentEnabled;
  final String? currentServer;
  final int currentPort;
  final String? currentUsername;
  final String? currentPassword;

  const MqttConfigurationScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.currentEnabled = false,
    this.currentServer,
    this.currentPort = 1883,
    this.currentUsername,
    this.currentPassword,
  });

  @override
  State<MqttConfigurationScreen> createState() =>
      _MqttConfigurationScreenState();
}

class _MqttConfigurationScreenState extends State<MqttConfigurationScreen> {
  late TextEditingController _serverController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late bool _enabled;
  late bool _authEnabled;
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _serverController =
        TextEditingController(text: widget.currentServer ?? '');
    _portController =
        TextEditingController(text: widget.currentPort.toString());
    _usernameController =
        TextEditingController(text: widget.currentUsername ?? '');
    _passwordController =
        TextEditingController(text: widget.currentPassword ?? '');
    _enabled = widget.currentEnabled;
    _authEnabled = widget.currentUsername != null &&
        widget.currentUsername!.isNotEmpty;
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    // Validation when enabled
    if (_enabled) {
      if (_serverController.text.trim().isEmpty) {
        MessageUtils.showError(context, 'MQTT-Server darf nicht leer sein');
        return;
      }

      final portText = _portController.text.trim();
      if (portText.isEmpty) {
        MessageUtils.showError(context, 'Port darf nicht leer sein');
        return;
      }

      final port = int.tryParse(portText);
      if (port == null || port < 1 || port > 65535) {
        MessageUtils.showError(
            context, 'Port muss eine Zahl zwischen 1 und 65535 sein');
        return;
      }

      // Validate authentication fields if enabled
      if (_authEnabled) {
        if (_usernameController.text.trim().isEmpty) {
          MessageUtils.showError(
              context, 'Benutzername darf nicht leer sein');
          return;
        }

        if (_passwordController.text.trim().isEmpty) {
          MessageUtils.showError(context, 'Passwort darf nicht leer sein');
          return;
        }
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final params = <String, dynamic>{
        'enable': _enabled,
      };

      if (_enabled) {
        params['server'] = _serverController.text.trim();
        params['port'] = int.parse(_portController.text.trim());

        if (_authEnabled) {
          params['username'] = _usernameController.text.trim();
          params['password'] = _passwordController.text.trim();
        }
      }

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_SET_MQTT, params);

      if (mounted) {
        MessageUtils.showSuccess(
          context,
          _enabled
              ? 'MQTT-Verbindung wurde aktiviert'
              : 'MQTT-Verbindung wurde deaktiviert',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
          context,
          'Fehler beim Speichern der MQTT-Konfiguration: $e',
          title: 'Fehler',
        );
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
      appBar: const AppBarWidget(
        title: 'MQTT Konfiguration',
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
                        const Icon(
                          Icons.storage,
                          size: 32,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MQTT Konfiguration',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.device.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verbinden Sie Ihr Gerät mit einem MQTT-Broker für Home Automation Integration.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Enable/Disable Toggle Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _enabled ? Icons.toggle_on : Icons.toggle_off,
                          color: _enabled ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'MQTT aktivieren',
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
                      'Aktiviert oder deaktiviert die MQTT-Verbindung',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Server Configuration (only shown when enabled)
            if (_enabled) ...[
              // Server Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.dns, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'MQTT Server',
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
                        controller: _serverController,
                        decoration: const InputDecoration(
                          labelText: 'Server',
                          hintText: 'broker.example.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.dns),
                          helperText: 'Hostname oder IP-Adresse',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _portController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          hintText: '1883',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.settings_ethernet),
                          helperText: 'Standard: 1883',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Authentication Toggle Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _authEnabled ? Icons.lock : Icons.lock_open,
                            color: _authEnabled ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Authentifizierung verwenden',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Switch(
                            value: _authEnabled,
                            onChanged: (value) {
                              setState(() {
                                _authEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aktiviert Benutzername und Passwort für MQTT',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Authentication Fields (only shown when auth enabled)
              if (_authEnabled) ...[
                // Username Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Benutzername',
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
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Benutzername',
                            hintText: 'mqtt-user',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Password Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.key, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Passwort',
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
                            labelText: 'Passwort',
                            hintText: 'Geben Sie Ihr Passwort ein',
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ],

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Wird gespeichert...' : 'Speichern'),
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
                          'Hinweise',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Standard MQTT-Port ist 1883 (unverschlüsselt) oder 8883 (TLS)\n'
                      '• Stellen Sie sicher, dass Ihr MQTT-Broker erreichbar ist\n'
                      '• Die Authentifizierung ist optional, wird aber empfohlen\n'
                      '• Nach der Konfiguration verbindet sich das Gerät automatisch',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!_enabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'MQTT ist deaktiviert. Das Gerät wird nicht mit einem MQTT-Broker verbunden sein.',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
