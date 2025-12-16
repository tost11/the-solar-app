import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/command_constants.dart';
import '../../../models/device.dart';
import '../../../models/shelly_script.dart';
import '../../../models/shelly_script_template.dart';
import '../../../models/shelly_script_parameter.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/globals.dart';
import '../../../utils/message_utils.dart';
import '../../../utils/script_parameter_extractor.dart';
import '../../../utils/script_template_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';

/// Screen for updating parameters of a template-created script
///
/// Fetches current script code, extracts parameters, allows editing,
/// and re-uploads the updated script with new parameter values.
class ShellyScriptUpdateScreen extends StatefulWidget {
  final Device device;
  final ShellyScript script;
  final ShellyScriptTemplate template;
  final Map<String, dynamic> currentParameters;

  const ShellyScriptUpdateScreen({
    super.key,
    required this.device,
    required this.script,
    required this.template,
    required this.currentParameters,
  });

  @override
  State<ShellyScriptUpdateScreen> createState() =>
      _ShellyScriptUpdateScreenState();
}

class _ShellyScriptUpdateScreenState extends State<ShellyScriptUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _parameterValues = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeValues() {
    // Use current parameter values from extracted code
    _parameterValues.addAll(widget.currentParameters);

    // Create controllers for text fields
    for (final param in widget.template.parameters) {
      if (param.type != ScriptParameterType.boolean) {
        final currentValue = widget.currentParameters[param.name];
        _controllers[param.name] = TextEditingController(
          text: currentValue?.toString() ?? '',
        );
      }
    }
  }

  /// Determines if a parameter should be shown based on expert mode setting
  bool _shouldShowParameter(ScriptParameter param) {
    // Always show if expert mode is enabled
    if (Globals.expertMode) return true;

    // Always show non-advanced parameters
    if (!param.advancedOption) return true;

    // For advanced parameters: show only if required AND empty
    if (param.required) {
      final value = _parameterValues[param.name];
      return value == null || value.toString().isEmpty;
    }

    // Hide advanced, non-required parameters when expert mode is off
    return false;
  }

  Future<void> _updateScript() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate parameters
      final errors = ScriptTemplateUtils.validateParameters(
        widget.template,
        _parameterValues,
      );

      if (errors.isNotEmpty) {
        MessageUtils.showError(context, errors.values.first);
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Parameter aktualisieren?'),
          content: const Text(
            'Möchten Sie die Parameter wirklich aktualisieren? '
            'Das Script wird mit den neuen Werten neu generiert.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Aktualisieren'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      // Update script with new parameters
      try {
        // Extract deployment ID and template ID from script name
        final scriptMeta =
            ScriptParameterExtractor.parseScriptName(widget.script.name);
        final deploymentId = scriptMeta?['deployment_id'] ?? 'unknown';
        final templateId = scriptMeta?['template_id'] ?? 'unknown';

        // Generate new script code with updated parameters
        final newCode = ScriptTemplateUtils.generateScript(
          widget.template,
          _parameterValues,
          deploymentId,
        );

        // STEP 1: Stop script if running (required for code update)
        final wasRunning = widget.script.running;
        if (wasRunning) {
          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Stoppe Script...',
            operation: () => widget.device.sendCommand(
              COMMAND_STOP_SCRIPT,
              {"id": widget.script.id},
            ),
            showErrorDialog: false,
          );

          if (!mounted) return;

          // Wait briefly for script to fully stop
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (!mounted) return;

        // STEP 2: Rename to staging version (0.0.0)
        final stagingName = '__auto_${templateId}_0.0.0_$deploymentId';

        await DialogUtils.executeWithLoading(
          context,
          loadingMessage: 'Bereite Update vor...',
          operation: () => widget.device.sendCommand(
            COMMAND_RENAME_SCRIPT,
            {"id": widget.script.id, "name": stagingName},
          ),
          showErrorDialog: false,
        );

        if (!mounted) return;

        // STEP 3: Upload new code to device
        bool updateSuccess = false;

        await DialogUtils.executeWithLoading(
          context,
          loadingMessage: 'Aktualisiere Script...',
          operation: () => widget.device.sendCommand(
            COMMAND_PUT_SCRIPT_CODE,
            {
              "id": widget.script.id,
              "code": newCode,
              "append": false,
            },
          ),
          onSuccess: (_) {
            updateSuccess = true;
          },
          onError: (e) {
            MessageUtils.showError(
              context,
              'Fehler beim Aktualisieren: $e\nScript bleibt im Staging-Status (0.0.0).',
            );
          },
        );

        // STEP 4: Rename to final version (only if update succeeded)
        if (updateSuccess && mounted) {
          final finalName = '__auto_${templateId}_${widget.template.version}_$deploymentId';

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Finalisiere Update...',
            operation: () => widget.device.sendCommand(
              COMMAND_RENAME_SCRIPT,
              {"id": widget.script.id, "name": finalName},
            ),
            showErrorDialog: false,
          );

          if (mounted) {
            MessageUtils.showSuccess(
              context,
              'Parameter erfolgreich aktualisiert',
            );
          }
        }

        // STEP 5: Restart script if it was running before
        if (updateSuccess && wasRunning && mounted) {
          await widget.device.sendCommand(
            COMMAND_START_SCRIPT,
            {"id": widget.script.id},
          );
        }

        if (mounted) {
          // Navigate back to scripts list
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          MessageUtils.showError(
            context,
            'Fehler beim Aktualisieren der Parameter: $e',
          );
        }
      }
    }
  }

  Widget _buildParameterField(ScriptParameter param) {
    switch (param.type) {
      case ScriptParameterType.boolean:
        return _buildBooleanField(param);
      case ScriptParameterType.number:
      case ScriptParameterType.port:
      case ScriptParameterType.duration:
        return _buildNumberField(param);
      case ScriptParameterType.string:
      case ScriptParameterType.url:
        return _buildTextField(param);
    }
  }

  Widget _buildTextField(ScriptParameter param) {
    return TextFormField(
      controller: _controllers[param.name],
      decoration: InputDecoration(
        labelText: param.label,
        hintText: param.placeholder,
        helperText: param.description,
        border: const OutlineInputBorder(),
      ),
      keyboardType: param.type == ScriptParameterType.url
          ? TextInputType.url
          : TextInputType.text,
      validator: (value) {
        if (param.required && (value == null || value.isEmpty)) {
          return '${param.label} ist erforderlich';
        }
        return null;
      },
      onSaved: (value) {
        _parameterValues[param.name] = value ?? '';
      },
    );
  }

  Widget _buildNumberField(ScriptParameter param) {
    return TextFormField(
      controller: _controllers[param.name],
      decoration: InputDecoration(
        labelText: param.label,
        hintText: param.placeholder,
        helperText: param.description,
        border: const OutlineInputBorder(),
        suffixText: param.type == ScriptParameterType.duration ? 'ms' : null,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (param.required && (value == null || value.isEmpty)) {
          return '${param.label} ist erforderlich';
        }
        if (value != null && value.isNotEmpty) {
          final numValue = int.tryParse(value);
          if (numValue == null) {
            return '${param.label} muss eine Zahl sein';
          }
          if (param.minValue != null && numValue < param.minValue!) {
            return '${param.label} muss mindestens ${param.minValue} sein';
          }
          if (param.maxValue != null && numValue > param.maxValue!) {
            return '${param.label} darf höchstens ${param.maxValue} sein';
          }
          if (param.type == ScriptParameterType.port &&
              (numValue < 1 || numValue > 65535)) {
            return 'Port muss zwischen 1 und 65535 liegen';
          }
        }
        return null;
      },
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _parameterValues[param.name] = int.parse(value);
        }
      },
    );
  }

  Widget _buildBooleanField(ScriptParameter param) {
    final currentValue = _parameterValues[param.name] as bool? ??
        param.defaultValue as bool? ??
        false;

    return Card(
      child: SwitchListTile(
        title: Text(param.label),
        subtitle: Text(param.description),
        value: currentValue,
        onChanged: (value) {
          setState(() {
            _parameterValues[param.name] = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(
        title: 'Parameter aktualisieren',
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                                  Icons.edit_note,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.template.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.template.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(color: Colors.blue.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Aktualisieren Sie die Parameter. Das Script wird mit '
                                      'den neuen Werten neu generiert und hochgeladen.',
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Parameter fields (filtered by expert mode setting)
                    ValueListenableBuilder<bool>(
                      valueListenable: Globals.expertModeNotifier,
                      builder: (context, expertMode, child) {
                        return Column(
                          children: widget.template.parameters
                              .where(_shouldShowParameter)
                              .map((param) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildParameterField(param),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom button
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
              child: ElevatedButton.icon(
                onPressed: _updateScript,
                icon: const Icon(Icons.check),
                label: const Text('Parameter aktualisieren'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
