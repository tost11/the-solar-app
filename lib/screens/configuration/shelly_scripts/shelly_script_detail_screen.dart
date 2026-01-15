import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants/command_constants.dart';
import '../../../models/shelly_script.dart';
import '../../../utils/message_utils.dart';
import '../../../utils/dialog_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';
import '../base_command_screen.dart';

/// Detailed view for a single Shelly script with controls and real-time status updates
///
/// Shows script details, enable/disable toggle, start/stop controls, and error information.
/// Subscribes to device data stream for automatic status updates.
class ShellyScriptDetailScreen extends BaseCommandScreen {
  final ShellyScript script;

  const ShellyScriptDetailScreen({
    super.key,
    required super.device,
    required this.script,
  });

  @override
  State<ShellyScriptDetailScreen> createState() =>
      _ShellyScriptDetailScreenState();
}

class _ShellyScriptDetailScreenState extends State<ShellyScriptDetailScreen> {
  late ShellyScript _currentScript;
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  /// Error type translations from English to German
  static const Map<String, String> _errorTranslations = {
    'crashed': 'Absturz',
    'syntax_error': 'Syntaxfehler',
    'reference_error': 'Referenzfehler',
    'type_error': 'Typfehler',
    'out_of_memory': 'Speicher voll',
    'out_of_codespace': 'Code-Speicher voll',
    'internal_error': 'Interner Fehler',
    'not_implemented': 'Nicht implementiert',
    'file_read_error': 'Datei-Lesefehler',
    'bad_arguments': 'Ungültige Parameter',
  };

  @override
  void initState() {
    super.initState();
    _currentScript = widget.script;

    // Subscribe to device data updates
    _dataSubscription = widget.device.dataStream.listen((data) {
      _updateScriptStatus(data);
    });

    // Initial status update from current data
    _updateScriptStatus(widget.device.data);
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  /// Update script status from device data stream
  void _updateScriptStatus(Map<String, dynamic> data) {
    if (!mounted) return;

    // Extract script status from main data
    final scriptKey = 'script:${_currentScript.id}';
    final scriptData = data['data']?[scriptKey];

    if (scriptData != null) {
      setState(() {
        _currentScript = _currentScript.copyWith(
          running: scriptData['running'] as bool?,
          memUsed: scriptData['mem_used'] as int?,
          memPeak: scriptData['mem_peak'] as int?,
          errors: (scriptData['errors'] as List?)?.cast<String>() ?? [],
        );
      });
    }
  }

  /// Toggle script enable/disable (autostart)
  Future<void> _toggleScriptEnable(bool enable) async {
    final result = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: enable ? 'Aktiviere Script...' : 'Deaktiviere Script...',
      operation: () => widget.sendCommandToDevice(
        COMMAND_SET_SCRIPT_ENABLE,
        {"id": _currentScript.id, "enable": enable},
      ),
      showErrorDialog: false,
    );

    if (result != null && mounted) {
      setState(() {
        _currentScript = _currentScript.copyWith(enable: enable);
      });
      MessageUtils.showSuccess(
        context,
        enable ? 'Script aktiviert' : 'Script deaktiviert',
      );
    }
  }

  /// Start the script
  Future<void> _startScript() async {
    final result = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: 'Starte Script...',
      operation: () => widget.sendCommandToDevice(
        COMMAND_START_SCRIPT,
        {"id": _currentScript.id},
      ),
      showErrorDialog: false,
    );

    if (result != null && mounted) {
      setState(() {
        _currentScript = _currentScript.copyWith(running: true);
      });
      MessageUtils.showSuccess(context, 'Script gestartet');
    }
  }

  /// Stop the script
  Future<void> _stopScript() async {
    final result = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: 'Stoppe Script...',
      operation: () => widget.sendCommandToDevice(
        COMMAND_STOP_SCRIPT,
        {"id": _currentScript.id},
      ),
      showErrorDialog: false,
    );

    if (result != null && mounted) {
      setState(() {
        _currentScript = _currentScript.copyWith(running: false);
      });
      MessageUtils.showSuccess(context, 'Script gestoppt');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: _currentScript.name,
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
                          Icons.code,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentScript.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Script ID: ${_currentScript.id}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Info Card
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            _currentScript.enable ? 'Aktiviert' : 'Deaktiviert',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: _currentScript.enable
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          side: BorderSide(
                            color:
                                _currentScript.enable ? Colors.green : Colors.grey,
                            width: 1,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            _currentScript.running ? 'Läuft' : 'Gestoppt',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: _currentScript.running
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          side: BorderSide(
                            color:
                                _currentScript.running ? Colors.blue : Colors.grey,
                            width: 1,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Enable/Disable Switch
            Card(
              child: SwitchListTile(
                title: const Text('Autostart aktiviert'),
                subtitle: const Text(
                    'Script startet automatisch bei konfigurierten Events'),
                value: _currentScript.enable,
                onChanged: _toggleScriptEnable,
                secondary: Icon(
                  _currentScript.enable ? Icons.check_circle : Icons.cancel,
                  color: _currentScript.enable ? Colors.green : Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Start/Stop Button
            ElevatedButton.icon(
              onPressed: () {
                if (_currentScript.running) {
                  _stopScript();
                } else {
                  _startScript();
                }
              },
              icon: Icon(
                  _currentScript.running ? Icons.stop : Icons.play_arrow),
              label: Text(_currentScript.running
                  ? 'Script stoppen'
                  : 'Script starten'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentScript.running ? Colors.orange : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            // Error Display (if errors exist)
            if (_currentScript.errors != null &&
                _currentScript.errors!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Fehler',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._currentScript.errors!.map((error) => Padding(
                          padding: const EdgeInsets.only(left: 28, top: 4),
                          child: Text(
                            '• ${_errorTranslations[error] ?? error}',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 13,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steuerung:',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Autostart: Script läuft automatisch bei Events\n'
                          '• Start/Stop: Manuelles Starten/Stoppen des Scripts\n'
                          '• Status wird automatisch aktualisiert',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
