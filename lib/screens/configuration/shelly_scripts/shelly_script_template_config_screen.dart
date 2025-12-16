import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/command_constants.dart';
import '../../../models/device.dart';
import '../../../models/resolved_resource.dart';
import '../../../models/shelly_script_template.dart';
import '../../../models/shelly_script_parameter.dart';
import '../../../services/resource_resolver_service.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/globals.dart';
import '../../../utils/message_utils.dart';
import '../../../utils/script_template_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';
import 'shelly_script_template_preview_screen.dart';

/// Screen for configuring script template parameters
///
/// Provides dynamic form fields based on parameter types with real-time validation.
class ShellyScriptTemplateConfigScreen extends StatefulWidget {
  final Device device;
  final ShellyScriptTemplate template;
  final String? systemId;

  const ShellyScriptTemplateConfigScreen({
    super.key,
    required this.device,
    required this.template,
    this.systemId,
  });

  @override
  State<ShellyScriptTemplateConfigScreen> createState() =>
      _ShellyScriptTemplateConfigScreenState();
}

class _ShellyScriptTemplateConfigScreenState
    extends State<ShellyScriptTemplateConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _parameterValues = {};
  final Map<String, TextEditingController> _controllers = {};
  final ResourceResolverService _resourceResolver = ResourceResolverService();
  final Map<String, List<ResolvedResource>> _resolvedResources = {};
  bool _isResolvingResources = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _resolveSourceParameters();
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
    // Set default values
    final defaults = ScriptTemplateUtils.getDefaultParameterValues(widget.template);
    _parameterValues.addAll(defaults);

    // Create controllers for text fields
    for (final param in widget.template.parameters) {
      if (param.type != ScriptParameterType.boolean) {
        final defaultValue = defaults[param.name];
        _controllers[param.name] = TextEditingController(
          text: defaultValue?.toString() ?? '',
        );
      }
    }
  }

  /// Resolve all source-based parameters
  Future<void> _resolveSourceParameters() async {
    setState(() => _isResolvingResources = true);

    for (final param in widget.template.parameters) {
      // Skip if not a source parameter
      if (param.sourceConfig == null) continue;

      try {
        // Resolve based on context
        final List<ResolvedResource> resources;
        if (widget.systemId != null) {
          resources = await _resourceResolver.resolveFromSystem(
            widget.systemId!,
            param.sourceConfig!.source,
            param.sourceConfig!.sourceProperty,
            param.sourceConfig!.sourceFilter,
          );
        } else {
          resources = await _resourceResolver.resolveFromAllDevices(
            param.sourceConfig!.source,
            param.sourceConfig!.sourceProperty,
            param.sourceConfig!.sourceFilter,
          );
        }

        // Store results
        _resolvedResources[param.name] = resources;

        // Auto-populate if exactly 1 result
        if (resources.length == 1) {
          final value = resources.first.extractedValue;
          _parameterValues[param.name] = value;
          if (_controllers.containsKey(param.name)) {
            _controllers[param.name]!.text = value;
          }
        }
      } catch (e) {
        debugPrint('Error resolving parameter ${param.name}: $e');
        _resolvedResources[param.name] = [];
      }
    }

    setState(() => _isResolvingResources = false);
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

  void _onPreview() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate parameters
      final errors = ScriptTemplateUtils.validateParameters(
        widget.template,
        _parameterValues,
      );

      if (errors.isNotEmpty) {
        // Show first error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.values.first),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShellyScriptTemplatePreviewScreen(
            device: widget.device,
            template: widget.template,
            parameterValues: _parameterValues,
          ),
        ),
      );
    }
  }

  Future<void> _onDirectDeploy() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate parameters
      final errors = ScriptTemplateUtils.validateParameters(
        widget.template,
        _parameterValues,
      );

      if (errors.isNotEmpty) {
        // Show first error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.values.first),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Script installieren?'),
          content: Text(
            'Möchten Sie das Script "${widget.template.name}" ohne Vorschau installieren?',
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

      // Generate deployment ID and staging script name (0.0.0 for atomic deployment)
      final deploymentId = const Uuid().v4().substring(0, 8);
      final stagingName = '__auto_${widget.template.id}_0.0.0_$deploymentId';

      // Generate script code
      final generatedCode = ScriptTemplateUtils.generateScript(
        widget.template,
        _parameterValues,
        deploymentId,
      );

      // Deploy script to device
      try {
        // Step 1: Create script on device with staging name
        final createResult = await DialogUtils.executeWithLoading(
          context,
          loadingMessage: 'Erstelle Script auf Gerät...',
          operation: () => widget.device.sendCommand(
            COMMAND_CREATE_SCRIPT,
            {"name": stagingName},
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
        bool uploadSuccess = false;

        await DialogUtils.executeWithLoading(
          context,
          loadingMessage: 'Lade Script-Code hoch...',
          operation: () => widget.device.sendCommand(
            COMMAND_PUT_SCRIPT_CODE,
            {
              "id": scriptId,
              "code": generatedCode,
              "append": false,
            },
          ),
          onSuccess: (_) {
            uploadSuccess = true;
          },
          onError: (e) {
            MessageUtils.showError(
              context,
              'Fehler beim Hochladen: $e\nScript bleibt im Staging-Status (0.0.0).',
            );
          },
        );

        // Step 3: Rename to final version (only if upload succeeded)
        if (uploadSuccess && mounted) {
          final finalName =
              '__auto_${widget.template.id}_${widget.template.version}_$deploymentId';

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Finalisiere Installation...',
            operation: () => widget.device.sendCommand(
              COMMAND_RENAME_SCRIPT,
              {"id": scriptId, "name": finalName},
            ),
            showErrorDialog: false,
          );
        }

        // Step 4: Enable script (only if upload succeeded)
        if (uploadSuccess && mounted) {
          await widget.device.sendCommand(
            COMMAND_SET_SCRIPT_ENABLE,
            {"id": scriptId, "enable": true},
          );

          // Step 5: Start script
          await widget.device.sendCommand(
            COMMAND_START_SCRIPT,
            {"id": scriptId},
          );
        }

        if (uploadSuccess && mounted) {
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
  }

  Widget _buildParameterField(ScriptParameter param) {
    // Check if this is a source parameter
    if (param.sourceConfig != null) {
      return _buildSourceParameterField(param);
    }

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
      appBar: AppBarWidget(
        title: widget.template.name,
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
                                  Icons.tune,
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
                                        'Parameter konfigurieren',
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
                            child: Text(
                              'Füllen Sie alle Parameter aus und tippen Sie auf "Vorschau", '
                              'um den generierten Script-Code zu sehen.',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 13,
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

            // Bottom buttons
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onPreview,
                      icon: const Icon(Icons.visibility),
                      label: const Text('Vorschau'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onDirectDeploy,
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Direkt installieren'),
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
          ],
        ),
      ),
    );
  }

  /// Build parameter field with device source resolution
  Widget _buildSourceParameterField(ScriptParameter param) {
    final resources = _resolvedResources[param.name] ?? [];
    final controller = _controllers[param.name]!;

    // Determine suffix icon based on resolution results
    Widget? suffixIcon;
    String? suffixTooltip;

    if (_isResolvingResources) {
      suffixIcon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
      suffixTooltip = 'Suche Geräte...';
    } else if (resources.isEmpty) {
      suffixIcon = Icon(Icons.info_outline, color: Colors.orange[700]);
      suffixTooltip = 'Keine passenden Geräte gefunden';
    } else if (resources.length == 1) {
      suffixIcon = Icon(Icons.check_circle, color: Colors.green[600]);
      suffixTooltip = 'Auto-ausgefüllt von: ${resources.first.device.name}';
    } else {
      // Multiple results - show select button
      suffixIcon = IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Gerät auswählen (${resources.length} gefunden)',
        onPressed: () => _showResourcePicker(param, resources),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: param.label,
          hintText: param.placeholder,
          helperText: _buildSourceHelperText(param, resources),
          helperMaxLines: 2,
          suffixIcon: suffixTooltip != null
              ? Tooltip(message: suffixTooltip, child: suffixIcon)
              : suffixIcon,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (param.required && (value == null || value.isEmpty)) {
            return 'Dieses Feld ist erforderlich';
          }
          // Apply additional validation if specified
          if (param.validationPattern != null && value != null) {
            final regex = RegExp(param.validationPattern!);
            if (!regex.hasMatch(value)) {
              return param.validationErrorMessage ?? 'Ungültiger Wert';
            }
          }
          return null;
        },
        onSaved: (value) => _parameterValues[param.name] = value,
      ),
    );
  }

  /// Build helper text showing source info
  String _buildSourceHelperText(ScriptParameter param, List<ResolvedResource> resources) {
    final parts = <String>[];

    // Source description
    if (param.sourceConfig != null) {
      parts.add('Quelle: ${param.sourceConfig!.sourceProperty}');
      if (param.sourceConfig!.sourceFilter != null) {
        parts.add('Filter: ${param.sourceConfig!.sourceFilter}');
      }
    }

    // Result count
    if (!_isResolvingResources) {
      if (resources.isEmpty) {
        parts.add('(keine Geräte gefunden)');
      } else if (resources.length == 1) {
        parts.add('(automatisch ausgefüllt)');
      } else {
        parts.add('(${resources.length} Geräte gefunden)');
      }
    }

    return parts.join(' • ');
  }

  /// Show modal picker for multiple resolved resources
  Future<void> _showResourcePicker(
    ScriptParameter param,
    List<ResolvedResource> resources,
  ) async {
    final selected = await showModalBottomSheet<ResolvedResource>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Gerät auswählen für "${param.label}"',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    final device = resource.device;

                    return ListTile(
                      leading: Icon(device.deviceIcon),
                      title: _buildDevicePickerTitle(context, resource.device.name, resource.extractedValue),
                      subtitle: Text(device.deviceModel ?? "Unknown"),
                      onTap: () => Navigator.pop(context, resource),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _parameterValues[param.name] = selected.extractedValue;
        _controllers[param.name]!.text = selected.extractedValue;
      });
    }
  }

  /// Build title for device picker with emphasized extracted value
  Widget _buildDevicePickerTitle(BuildContext context, String deviceName, String extractedValue) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.textTheme.bodyLarge?.color,
        ),
        children: [
          TextSpan(text: deviceName),
          TextSpan(text: ' ('),
          TextSpan(
            text: extractedValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          TextSpan(text: ')'),
        ],
      ),
    );
  }
}
