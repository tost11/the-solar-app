import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/command_constants.dart';
import '../../../models/device.dart';
import '../../../models/shelly_script_template.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/message_utils.dart';
import '../../../utils/script_template_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';

/// Screen for previewing generated script code before deployment
///
/// Shows the final script code with parameters substituted.
/// Provides a button to deploy the script to the Shelly device.
class ShellyScriptTemplatePreviewScreen extends StatefulWidget {
  final Device device;
  final ShellyScriptTemplate template;
  final Map<String, dynamic> parameterValues;

  const ShellyScriptTemplatePreviewScreen({
    super.key,
    required this.device,
    required this.template,
    required this.parameterValues,
  });

  @override
  State<ShellyScriptTemplatePreviewScreen> createState() =>
      _ShellyScriptTemplatePreviewScreenState();
}

class _ShellyScriptTemplatePreviewScreenState
    extends State<ShellyScriptTemplatePreviewScreen> {
  late String _generatedCode;
  late String _deploymentId;
  late String _scriptName;

  @override
  void initState() {
    super.initState();

    // Generate unique deployment ID (8 characters)
    _deploymentId = const Uuid().v4().substring(0, 8);

    // Generate script name with naming convention:
    // __auto_{template-id}_{version}_{deployment-id}
    _scriptName = '__auto_${widget.template.id}_${widget.template.version}_$_deploymentId';

    // Generate script code with auto-generated parameters and metadata
    _generatedCode = ScriptTemplateUtils.generateScript(
      widget.template,
      widget.parameterValues,
      _deploymentId,
    );
  }

  Future<void> _deployScript() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Script auf Gerät installieren?'),
        content: Text(
          'Möchten Sie das Script "${widget.template.name}" wirklich auf Ihrem Shelly-Gerät installieren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Installieren'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Deploy script to device
    try {
      // Step 1: Create script on device with template naming convention
      final createResult = await DialogUtils.executeWithLoading(
        context,
        loadingMessage: 'Erstelle Script auf Gerät...',
        operation: () => widget.device.sendCommand(
          COMMAND_CREATE_SCRIPT,
          {"name": _scriptName},
        ),
        showErrorDialog: false,
      );

      if (createResult == null || !mounted) return;

      // Get script ID from response
      final scriptId = createResult['id'] as int?;
      if (scriptId == null) {
        if (mounted) {
          MessageUtils.showError(
              context, 'Fehler: Konnte Script-ID nicht abrufen');
        }
        return;
      }

      // Step 2: Upload code to device
      final uploadResult = await DialogUtils.executeWithLoading(
        context,
        loadingMessage: 'Lade Script-Code hoch...',
        operation: () => widget.device.sendCommand(
          COMMAND_PUT_SCRIPT_CODE,
          {
            "id": scriptId,
            "code": _generatedCode,
            "append": false,
          },
        ),
        showErrorDialog: false,
      );

      if (uploadResult == null && mounted) {
        MessageUtils.showError(context, 'Fehler beim Hochladen des Codes');
        return;
      }

      // Step 3: Enable script
      await widget.device.sendCommand(
        COMMAND_SET_SCRIPT_ENABLE,
        {"id": scriptId, "enable": true},
      );

      // Step 4: Start script
      await widget.device.sendCommand(
        COMMAND_START_SCRIPT,
        {"id": scriptId},
      );

      if (mounted) {
        MessageUtils.showSuccess(
          context,
          'Script erfolgreich installiert und gestartet',
        );

        // Navigate back to scripts list (pop all the way back)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(
          context,
          'Fehler beim Installieren des Scripts: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: widget.template.name,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
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
                        'Code-Vorschau',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prüfen Sie den generierten Code vor der Installation',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Code view
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _generatedCode,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey[300],
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Info and deploy button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info
                Container(
                  padding: const EdgeInsets.all(12.0),
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
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Das Script wird auf Ihrem Shelly-Gerät installiert, '
                          'aktiviert und automatisch gestartet.',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Deploy button
                ElevatedButton.icon(
                  onPressed: _deployScript,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Auf Gerät installieren'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
