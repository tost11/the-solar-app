import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class PortConfigurationScreen extends BaseCommandScreen {
  final String portName;
  final String portDescription;
  final int? currentPort;
  final String commandParameterName;

  const PortConfigurationScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    required this.portName,
    required this.portDescription,
    this.currentPort,
    this.commandParameterName = 'port',
  });

  @override
  State<PortConfigurationScreen> createState() =>
      _PortConfigurationScreenState();
}

class _PortConfigurationScreenState extends State<PortConfigurationScreen> {
  late TextEditingController _portController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _portController = TextEditingController(
        text: widget.currentPort?.toString() ?? '');
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    // Validation
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

    setState(() {
      _isSaving = true;
    });

    try {
      final command = <String, dynamic>{
        widget.commandParameterName: port,
      };

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_CONFIG_PORT, command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          '${widget.portName} erfolgreich konfiguriert',
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
            context, 'Fehler beim Konfigurieren des Ports: $e');
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
        title: widget.portName,
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
                          Icons.settings_ethernet,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.portName,
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
                      widget.portDescription,
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

            // Port Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.input, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Port-Nummer',
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
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Port',
                        hintText: 'Geben Sie die Port-Nummer ein',
                        prefixIcon: Icon(Icons.input, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Port muss zwischen 1 und 65535 liegen',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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
              label: Text(_isSaving
                  ? 'Wird gespeichert...'
                  : 'Einstellungen speichern'),
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
                      '• Stellen Sie sicher, dass der Port nicht von anderen Diensten verwendet wird\n'
                      '• Nach der Konfiguration wird das Gerät möglicherweise neu gestartet\n'
                      '• Standard-Ports sollten nur geändert werden, wenn notwendig',
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
