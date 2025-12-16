import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';

import '../../utils/message_utils.dart';
import '../../utils/url_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class OpenDTUOnlineMonitoringScreen extends BaseCommandScreen {
  final bool? currentEnabled;
  final String? currentPrimaryProtocol;
  final String? currentPrimaryHost;
  final String? currentSecondaryProtocol;
  final String? currentSecondaryHost;
  final String? currentSystemId;
  final String? currentToken;
  final int? currentDuration;

  const OpenDTUOnlineMonitoringScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.currentEnabled,
    this.currentPrimaryProtocol,
    this.currentPrimaryHost,
    this.currentSecondaryProtocol,
    this.currentSecondaryHost,
    this.currentSystemId,
    this.currentToken,
    this.currentDuration,
  });

  @override
  State<OpenDTUOnlineMonitoringScreen> createState() =>
      _OpenDTUOnlineMonitoringScreenState();
}

class _OpenDTUOnlineMonitoringScreenState
    extends State<OpenDTUOnlineMonitoringScreen> {
  // Enable/disable toggle
  late bool _enabled;

  // Primary server controllers
  late TextEditingController _primaryHostController;
  late String _primaryProtocol;

  // Secondary server controllers
  late TextEditingController _secondaryHostController;
  late String _secondaryProtocol;

  // Port controllers
  late TextEditingController _primaryPortController;
  late TextEditingController _secondaryPortController;

  // Credentials controllers
  late TextEditingController _systemIdController;
  late TextEditingController _tokenController;
  late TextEditingController _durationController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize enabled state
    _enabled = widget.currentEnabled ?? false;

    // Initialize Primary server controllers
    _primaryHostController =
        TextEditingController(text: widget.currentPrimaryHost ?? '');
    _primaryProtocol = widget.currentPrimaryProtocol ?? 'https';

    // Initialize Secondary server controllers
    _secondaryHostController =
        TextEditingController(text: widget.currentSecondaryHost ?? '');
    _secondaryProtocol = widget.currentSecondaryProtocol ?? 'https';

    // Initialize port controllers with protocol defaults or extracted from URL
    _primaryPortController = TextEditingController(
      text: UrlUtils.extractAndInitializePort(widget.currentPrimaryHost, _primaryProtocol)
    );
    _secondaryPortController = TextEditingController(
      text: UrlUtils.extractAndInitializePort(widget.currentSecondaryHost, _secondaryProtocol)
    );

    // Initialize credentials controllers
    _systemIdController =
        TextEditingController(text: widget.currentSystemId ?? '');
    _tokenController = TextEditingController(text: widget.currentToken ?? '');
    _durationController =
        TextEditingController(text: (widget.currentDuration ?? 30).toString());
  }

  @override
  void dispose() {
    _primaryHostController.dispose();
    _secondaryHostController.dispose();
    _primaryPortController.dispose();
    _secondaryPortController.dispose();
    _systemIdController.dispose();
    _tokenController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  bool _isValidHost(String host) {
    if (host.isEmpty) return true; // Empty is valid for optional field

    // Check for protocol prefix (should not contain protocol)
    if (host.startsWith('http://') || host.startsWith('https://')) {
      return false;
    }

    // Basic domain validation (alphanumeric, dots, hyphens)
    final regex = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9\-\.]*[a-zA-Z0-9]$');
    return regex.hasMatch(host);
  }

  bool _isValidDuration(String duration) {
    if (duration.isEmpty) return false;
    final num = int.tryParse(duration);
    return num != null && num >= 1 && num <= 3600; // 1 second to 1 hour
  }

  Future<void> _saveSettings() async {
    // Validation when monitoring is enabled
    if (_enabled) {
      final primaryHost = _primaryHostController.text.trim();
      final systemId = _systemIdController.text.trim();
      final token = _tokenController.text.trim();

      if (primaryHost.isEmpty) {
        MessageUtils.showError(
            context, 'Primärer Server URL ist erforderlich');
        return;
      }

      if (!_isValidHost(primaryHost)) {
        MessageUtils.showError(context,
            'Ungültige primäre Server URL (kein Protokoll http:// oder https:// verwenden)');
        return;
      }

      if (systemId.isEmpty) {
        MessageUtils.showError(context, 'System-ID ist erforderlich');
        return;
      }

      if (token.isEmpty) {
        MessageUtils.showError(context, 'Token/Passwort ist erforderlich');
        return;
      }

      // Validate secondary host if provided
      final secondaryHost = _secondaryHostController.text.trim();
      if (secondaryHost.isNotEmpty && !_isValidHost(secondaryHost)) {
        MessageUtils.showError(context,
            'Ungültige sekundäre Server URL (kein Protokoll http:// oder https:// verwenden)');
        return;
      }

      // Validate ports
      final primaryPort = _primaryPortController.text.trim();
      if (!UrlUtils.isValidPort(primaryPort)) {
        MessageUtils.showError(context, 'Ungültiger primärer Port (1-65535)');
        return;
      }

      if (secondaryHost.isNotEmpty) {
        final secondaryPort = _secondaryPortController.text.trim();
        if (!UrlUtils.isValidPort(secondaryPort)) {
          MessageUtils.showError(context, 'Ungültiger sekundärer Port (1-65535)');
          return;
        }
      }
    }

    // Validate duration
    final duration = _durationController.text.trim();
    if (!_isValidDuration(duration)) {
      MessageUtils.showError(
          context, 'Upload-Intervall muss zwischen 1 und 3600 Sekunden liegen');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final command = <String, dynamic>{
        'enabled': _enabled,
        'primary_protocol': _primaryProtocol,
        'primary_host': UrlUtils.buildUrl(
          _primaryHostController.text.trim(),
          _primaryProtocol,
          _primaryPortController.text.trim()
        ),
        'secondary_protocol': _secondaryProtocol,
        'secondary_host': UrlUtils.buildUrl(
          _secondaryHostController.text.trim(),
          _secondaryProtocol,
          _secondaryPortController.text.trim()
        ),
        'system_id': _systemIdController.text.trim(),
        'token': _tokenController.text.trim(),
        'duration': int.parse(duration),
      };

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_SET_ONLINE_MONITORING, command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          'Online-Monitoring erfolgreich konfiguriert',
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
            context, 'Fehler beim Konfigurieren des Online-Monitorings: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildServerSection({
    required String title,
    required String subtitle,
    required TextEditingController hostController,
    required TextEditingController portController,
    required String protocol,
    required Function(String) onProtocolChanged,
    required IconData icon,
    required Color color,
    required bool isRequired,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Protocol Dropdown
            DropdownButtonFormField<String>(
              value: protocol,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Protokoll${isRequired ? " *" : ""}',
                prefixIcon: const Icon(Icons.security),
              ),
              items: const [
                DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                DropdownMenuItem(value: 'http', child: Text('HTTP')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onProtocolChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Host Input
            TextField(
              controller: hostController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Server-URL${isRequired ? " *" : ""}',
                hintText: 'z.B. solar.pihost.org',
                prefixIcon: const Icon(Icons.language),
                helperText: 'Ohne http:// oder https://',
              ),
            ),
            const SizedBox(height: 16),

            // Port Input
            TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Port',
                hintText: 'Standard: ${UrlUtils.getDefaultPort(protocol)}',
                prefixIcon: const Icon(Icons.numbers),
                helperText: 'Standard-Ports werden nicht in URL angezeigt',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(
        title: 'Online-Monitoring konfigurieren',
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
                          Icons.cloud_upload,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Online-Monitoring',
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
                      'Konfigurieren Sie die Server für das Online-Monitoring',
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

            // Enable/Disable Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.power_settings_new, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Online-Monitoring aktivieren',
                        style: Theme.of(context).textTheme.titleMedium,
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
              ),
            ),

            const SizedBox(height: 24),

            // Primary Server Section
            _buildServerSection(
              title: 'Primärer Server',
              subtitle: 'Erforderlich',
              hostController: _primaryHostController,
              portController: _primaryPortController,
              protocol: _primaryProtocol,
              onProtocolChanged: (value) {
                setState(() {
                  _primaryProtocol = value;
                  _primaryPortController.text = UrlUtils.getDefaultPort(value);
                });
              },
              icon: Icons.cloud,
              color: Colors.blue,
              isRequired: true,
            ),

            const SizedBox(height: 24),

            // Secondary Server Section
            _buildServerSection(
              title: 'Sekundärer Server',
              subtitle: 'Optional',
              hostController: _secondaryHostController,
              portController: _secondaryPortController,
              protocol: _secondaryProtocol,
              onProtocolChanged: (value) {
                setState(() {
                  _secondaryProtocol = value;
                  _secondaryPortController.text = UrlUtils.getDefaultPort(value);
                });
              },
              icon: Icons.cloud_queue,
              color: Colors.green,
              isRequired: false,
            ),

            const SizedBox(height: 24),

            // Credentials Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        const Icon(Icons.vpn_key,
                            color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Zugangsdaten',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // System ID Input
                    TextField(
                      controller: _systemIdController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'System-ID *',
                        hintText: 'z.B. 1234',
                        prefixIcon: Icon(Icons.fingerprint),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Token Input
                    TextField(
                      controller: _tokenController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Token/Passwort *',
                        prefixIcon: Icon(Icons.password),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Duration Input
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Upload-Intervall (Sekunden)',
                        hintText: 'z.B. 30',
                        prefixIcon: Icon(Icons.timer),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

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
              label: Text(
                  _isSaving ? 'Wird gespeichert...' : 'Einstellungen speichern'),
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
                      '• Primärer Server URL, System-ID und Token sind erforderlich wenn aktiviert\n'
                      '• Sekundärer Server ist optional\n'
                      '• Protokoll wird automatisch hinzugefügt (https:// oder http://)\n'
                      '• Standard-Ports (80 für HTTP, 443 für HTTPS) werden automatisch verwendet\n'
                      '• Nicht-standard Ports werden in der URL angezeigt (z.B. :8080)\n'
                      '• Upload-Intervall zwischen 1 und 3600 Sekunden\n'
                      '• Beispiel-Server: solar.pihost.org, solar.tost-soft.de',
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
