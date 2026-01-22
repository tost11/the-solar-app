import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';

import '../../utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class OnlineMonitoringConfigurationScreen extends BaseCommandScreen {
  final String? currentIpA;
  final String? currentDomainA;
  final String? currentPortA;
  final String? currentProtocolA;
  final String? currentIpB;
  final String? currentDomainB;
  final String? currentPortB;
  final String? currentProtocolB;

  const OnlineMonitoringConfigurationScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.currentIpA,
    this.currentDomainA,
    this.currentPortA,
    this.currentProtocolA,
    this.currentIpB,
    this.currentDomainB,
    this.currentPortB,
    this.currentProtocolB,
  });

  @override
  State<OnlineMonitoringConfigurationScreen> createState() =>
      _OnlineMonitoringConfigurationScreenState();
}

class _OnlineMonitoringConfigurationScreenState
    extends State<OnlineMonitoringConfigurationScreen> {
  // Server A controllers
  late TextEditingController _ipAController;
  late TextEditingController _domainAController;
  late TextEditingController _portAController;
  late String _protocolA;

  // Server B controllers
  late TextEditingController _ipBController;
  late TextEditingController _domainBController;
  late TextEditingController _portBController;
  late String _protocolB;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize Server A controllers
    _ipAController = TextEditingController(text: widget.currentIpA ?? '');
    _domainAController = TextEditingController(text: widget.currentDomainA ?? '');
    _portAController = TextEditingController(text: widget.currentPortA ?? '');
    _protocolA = widget.currentProtocolA ?? 'TCP';

    // Initialize Server B controllers
    _ipBController = TextEditingController(text: widget.currentIpB ?? '');
    _domainBController = TextEditingController(text: widget.currentDomainB ?? '');
    _portBController = TextEditingController(text: widget.currentPortB ?? '');
    _protocolB = widget.currentProtocolB ?? 'TCP';
  }

  @override
  void dispose() {
    _ipAController.dispose();
    _domainAController.dispose();
    _portAController.dispose();
    _ipBController.dispose();
    _domainBController.dispose();
    _portBController.dispose();
    super.dispose();
  }

  bool _isValidIpAddress(String ip) {
    if (ip.isEmpty) return true; // Empty is valid (optional field)
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (var part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  bool _isValidPort(String port) {
    if (port.isEmpty) return false;
    final num = int.tryParse(port);
    return num != null && num >= 1 && num <= 65534;
  }

  Future<void> _saveSettings() async {
    // Validation for Server A
    final ipA = _ipAController.text.trim();
    final domainA = _domainAController.text.trim();
    final portA = _portAController.text.trim();

    if (ipA.isEmpty && domainA.isEmpty) {
      MessageUtils.showError(
          context, context.l10n.validationServerAIpRequired);
      return;
    }

    if (ipA.isNotEmpty && !_isValidIpAddress(ipA)) {
      MessageUtils.showError(context, context.l10n.validationServerAIpInvalid);
      return;
    }

    if (!_isValidPort(portA)) {
      MessageUtils.showError(
          context, context.l10n.validationServerAPortRange);
      return;
    }

    // Validation for Server B
    final ipB = _ipBController.text.trim();
    final domainB = _domainBController.text.trim();
    final portB = _portBController.text.trim();

    if (ipB.isEmpty && domainB.isEmpty) {
      MessageUtils.showError(
          context, context.l10n.validationServerBIpRequired);
      return;
    }

    if (ipB.isNotEmpty && !_isValidIpAddress(ipB)) {
      MessageUtils.showError(context, context.l10n.validationServerBIpInvalid);
      return;
    }

    if (!_isValidPort(portB)) {
      MessageUtils.showError(
          context, context.l10n.validationServerBPortRange);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final command = <String, dynamic>{
        'ip_a': ipA,
        'domain_a': domainA,
        'port_a': portA,
        'protocol_a': _protocolA,
        'ip_b': ipB,
        'domain_b': domainB,
        'port_b': portB,
        'protocol_b': _protocolB,
      };

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_SET_ONLINE_MONITORING, command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          context.l10n.messageOnlineMonitoringConfigured,
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
            context, context.l10n.errorConfiguringOnlineMonitoring(e.toString()));
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
    required TextEditingController ipController,
    required TextEditingController domainController,
    required TextEditingController portController,
    required String protocol,
    required Function(String) onProtocolChanged,
    required IconData icon,
    required Color color,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // IP Address Input
            Builder(
              builder: (context) => TextField(
                controller: ipController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.l10n.labelIpAddress,
                  hintText: context.l10n.helpServerExampleIp,
                  prefixIcon: const Icon(Icons.computer),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),

            // Domain Input
            Builder(
              builder: (context) => TextField(
                controller: domainController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.l10n.labelDomain,
                  hintText: context.l10n.helpServerExampleDomain,
                  prefixIcon: const Icon(Icons.language),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Port Input
            Builder(
              builder: (context) => TextField(
                controller: portController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.l10n.labelPortField,
                  hintText: context.l10n.helpPortExample,
                  prefixIcon: const Icon(Icons.settings_ethernet),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),

            // Protocol Dropdown
            Builder(
              builder: (context) => DropdownButtonFormField<String>(
                value: protocol,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.l10n.labelProtocol(''),
                  prefixIcon: const Icon(Icons.sync_alt),
                ),
                items: const [
                  DropdownMenuItem(value: 'TCP', child: Text('TCP')),
                  DropdownMenuItem(value: 'UDP', child: Text('UDP')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onProtocolChanged(value);
                  }
                },
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
      appBar: AppBarWidget(
        title: context.l10n.screenOnlineMonitoring,
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
                                context.l10n.sectionOnlineMonitoring,
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
                                    ? context.l10n.device
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
                      context.l10n.helpConfigureOnlineMonitoring,
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

            // Server A Section
            _buildServerSection(
              title: context.l10n.sectionServerA,
              ipController: _ipAController,
              domainController: _domainAController,
              portController: _portAController,
              protocol: _protocolA,
              onProtocolChanged: (value) {
                setState(() {
                  _protocolA = value;
                });
              },
              icon: Icons.cloud,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            // Server B Section
            _buildServerSection(
              title: context.l10n.sectionServerB,
              ipController: _ipBController,
              domainController: _domainBController,
              portController: _portBController,
              protocol: _protocolB,
              onProtocolChanged: (value) {
                setState(() {
                  _protocolB = value;
                });
              },
              icon: Icons.cloud_queue,
              color: Colors.green,
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
                  ? context.l10n.messageSaving
                  : context.l10n.buttonSavePowerLimit),
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
                          context.l10n.sectionNote,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.helpOnlineMonitoringDescription,
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
