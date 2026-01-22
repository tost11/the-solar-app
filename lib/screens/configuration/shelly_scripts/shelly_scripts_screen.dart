import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants/command_constants.dart';
import '../../../models/shelly_script.dart';
import '../../../models/shelly_script_parameter.dart';
import '../../../services/script_template_service.dart';
import '../../../utils/message_utils.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/localization_extension.dart';
import '../../../utils/script_parameter_extractor.dart';
import '../../../utils/script_template_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';
import '../base_command_screen.dart';
import 'shelly_script_detail_screen.dart';
import 'shelly_script_template_library_screen.dart';
import 'shelly_script_update_screen.dart';

/// Screen displaying a list of Shelly scripts (automations)
///
/// Shows all scripts configured on the device with Edit and Delete actions.
/// Automatically polls script status every 10 seconds.
class ShellyScriptsScreen extends BaseCommandScreen {
  final List<ShellyScript> scripts;
  final String? systemId;

  const ShellyScriptsScreen({
    super.key,
    required super.device,
    required this.scripts,
    this.systemId,
  });

  @override
  State<ShellyScriptsScreen> createState() => _ShellyScriptsScreenState();
}

class _ShellyScriptsScreenState extends State<ShellyScriptsScreen> {
  /// Timer for periodic status polling
  Timer? _statusTimer;

  /// Track updated script data (updated from periodic status checks)
  final Map<int, ShellyScript> _scriptsData = {};

  /// Track which automation scripts have updates available
  final Map<int, bool> _hasUpdates = {};

  @override
  void initState() {
    super.initState();
    _initScriptsData();
    _startPeriodicStatusCheck();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  /// Initialize scripts data map
  void _initScriptsData() {
    for (var script in widget.scripts) {
      _scriptsData[script.id] = script;
    }
  }

  /// Start periodic status polling every 10 seconds
  void _startPeriodicStatusCheck() {
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchAllScriptsStatus();
    });
  }

  /// Fetch status for all scripts in background using Script.List
  Future<void> _fetchAllScriptsStatus() async {
    try {
      final resp = await widget.sendCommandToDevice(
        COMMAND_FETCH_SCRIPTS,  // Single batch call
        {},
      );

      if (!mounted || resp == null) return;

      // Parse scripts array from response
      final scriptsData = resp['scripts'] as List<dynamic>?;
      if (scriptsData == null) return;

      // Convert to map for efficient lookup
      final fetchedScripts = <int, ShellyScript>{};
      for (final scriptJson in scriptsData) {
        final script = ShellyScript.fromJson(scriptJson as Map<String, dynamic>);
        fetchedScripts[script.id] = script;
      }

      // Check for template updates for automation scripts
      for (final script in fetchedScripts.values) {
        if (ScriptParameterExtractor.isTemplateScript(script.name)) {
          final meta = ScriptParameterExtractor.parseScriptName(script.name);
          if (meta != null) {
            final templateId = meta['template_id']!;
            final currentVersion = meta['version']!;
            final hasUpdate = await ScriptTemplateService.hasNewerVersion(
              templateId,
              currentVersion,
            );
            _hasUpdates[script.id] = hasUpdate;
          }
        }
      }

      // Update state: replace with fetched scripts
      if (mounted) {
        setState(() {
          _scriptsData.clear();
          _scriptsData.addAll(fetchedScripts);
        });
      }
    } catch (e) {
      // Silent fail for background polling
    }
  }

  /// Navigate to script detail screen
  Future<void> _editScript(ShellyScript script) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShellyScriptDetailScreen(
          device: widget.device,
          script: _scriptsData[script.id] ?? script,
        ),
      ),
    );

    // Refresh status after returning from detail screen
    _fetchAllScriptsStatus();
  }

  /// Update parameters of a template-created script
  Future<void> _updateTemplateScript(ShellyScript script) async {
    // Step 1: Fetch current script code
    final codeResult = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.shellyScriptsLoadingCode,
      operation: () => widget.sendCommandToDevice(
        COMMAND_GET_SCRIPT_CODE,
        {"id": script.id},
      ),
      showErrorDialog: false,
    );

    if (codeResult == null || !mounted) return;

    final code = codeResult['code'] as String?;
    if (code == null) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.shellyScriptsErrorLoadingCode);
      }
      return;
    }

    // Step 2: Extract metadata and parameters
    final metadata = ScriptParameterExtractor.extractTemplateMetadata(code);
    if (metadata == null) {
      if (mounted) {
        MessageUtils.showError(
            context, context.l10n.shellyScriptsErrorNoMetadata);
      }
      return;
    }

    final currentParams = ScriptParameterExtractor.extractParameters(code);

    // Step 3: Load template by ID and version
    final templateId = metadata['template_id'] as String?;
    if (templateId == null) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.shellyScriptsErrorNoTemplateId);
      }
      return;
    }

    // Extract deployed template version for exact matching
    final deployedVersion = metadata['template_version'] as String?;

    // Load template matching deployed version, or latest if not found
    final template = await ScriptTemplateService.getTemplateById(
      templateId,
      version: deployedVersion,
    );

    if (template == null) {
      if (mounted) {
        MessageUtils.showError(
          context,
          context.l10n.shellyScriptsErrorTemplateNotFound('$templateId${deployedVersion != null ? " v$deployedVersion" : ""}'),
        );
      }
      return;
    }

    // Step 4: Navigate to update screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShellyScriptUpdateScreen(
            device: widget.device,
            script: script,
            template: template,
            currentParameters: currentParams,
          ),
        ),
      );

      // Refresh scripts list after update
      _fetchAllScriptsStatus();
    }
  }

  /// Upgrade automation script to latest template version
  Future<void> _upgradeTemplateScript(ShellyScript script, Map<String, String> scriptMeta) async {
    final templateId = scriptMeta['template_id']!;
    final currentVersion = scriptMeta['version']!;

    // Get latest template version
    final latestTemplate = await ScriptTemplateService.getLatestTemplateVersion(templateId);
    if (latestTemplate == null) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.shellyScriptsErrorLoadingCode);
      }
      return;
    }

    if (!mounted) return;

    // Fetch current script code to extract parameters
    final codeResult = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.shellyScriptsLoadingCurrent,
      operation: () => widget.sendCommandToDevice(
        COMMAND_GET_SCRIPT_CODE,
        {"id": script.id},
      ),
      showErrorDialog: false,
    );

    if (codeResult == null || !mounted) return;

    final code = codeResult['code'] as String?;
    if (code == null) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.shellyScriptsErrorLoadingCode);
      }
      return;
    }

    // Extract current parameters
    final currentParams = ScriptParameterExtractor.extractParameters(code);

    // Detect new parameters in latest template
    final newParameters = <ScriptParameter>[];
    for (final param in latestTemplate.parameters) {
      if (!currentParams.containsKey(param.name)) {
        newParameters.add(param);
      }
    }

    // Branch flow based on whether new parameters exist
    if (newParameters.isNotEmpty) {
      // NEW PARAMETERS: Show dialog and navigate to edit screen
      final shouldEdit = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(context.l10n.shellyScriptsDialogNewParamsTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.shellyScriptsDialogNewParamsMessage(
                    latestTemplate.version,
                    newParameters.map((p) => p.label).join(', '),
                    currentVersion,
                    latestTemplate.version,
                  ),
                ),
                const SizedBox(height: 8),
                ...newParameters.map((param) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          '${param.label}${param.required ? ' ${context.l10n.shellyScriptsParamRequired}' : ''}\n${param.description}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                Text(
                  'Aktuelle Version: $currentVersion\n'
                  'Neue Version: ${latestTemplate.version}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: Text(context.l10n.shellyScriptsConfigureParams),
            ),
          ],
        ),
      );

      if (shouldEdit != true || !mounted) return;

      // Merge current parameters with defaults for new parameters
      final mergedParams = Map<String, dynamic>.from(currentParams);
      for (final param in newParameters) {
        if (param.defaultValue != null) {
          mergedParams[param.name] = param.defaultValue;
        } else {
          // Provide sensible defaults based on type
          switch (param.type) {
            case ScriptParameterType.boolean:
              mergedParams[param.name] = false;
              break;
            case ScriptParameterType.number:
            case ScriptParameterType.port:
            case ScriptParameterType.duration:
              mergedParams[param.name] = param.minValue?.toInt() ?? 0;
              break;
            default:
              mergedParams[param.name] = '';
          }
        }
      }

      // Navigate to parameter edit screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShellyScriptUpdateScreen(
            device: widget.device,
            script: script,
            template: latestTemplate,
            currentParameters: mergedParams,
          ),
        ),
      );

      // Refresh scripts list after user edits (screen handles the update)
      _fetchAllScriptsStatus();
      return;
    }

    // NO NEW PARAMETERS: Show simple confirmation and proceed with direct upgrade
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.shellyScriptsDialogUpgradeTitle),
        content: Text(
          context.l10n.shellyScriptsDialogUpgradeMessage(latestTemplate.version),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(context.l10n.update),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // STEP 1: Stop script if running (required for code update)
    final wasRunning = script.running;
    if (wasRunning) {
      await DialogUtils.executeWithLoading(
        context,
        loadingMessage: context.l10n.shellyScriptsStoppingScript,
        operation: () => widget.sendCommandToDevice(
          COMMAND_STOP_SCRIPT,
          {"id": script.id},
        ),
        showErrorDialog: false,
      );

      if (!mounted) return;

      // Wait briefly for script to fully stop
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    // STEP 2: Rename script to 0.0.0 (staging)
    final deploymentId = scriptMeta['deployment_id'] ?? 'unknown';
    final stagingName = _generateAutomationScriptName(
      templateId,
      '0.0.0',
      deploymentId,
    );

    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.shellyScriptsPreparingUpdate,
      operation: () => widget.sendCommandToDevice(
        COMMAND_RENAME_SCRIPT,
        {"id": script.id, "name": stagingName},
      ),
      showErrorDialog: false,
    );

    if (!mounted) return;

    // STEP 3: Generate and upload new script code
    final newCode = ScriptTemplateUtils.generateScript(
      latestTemplate,
      currentParams,
      deploymentId,
    );

    if (!mounted) return;

    bool updateSuccess = false;

    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.shellyScriptsUpdatingScript,
      operation: () => widget.sendCommandToDevice(
        COMMAND_PUT_SCRIPT_CODE,
        {
          "id": script.id,
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
          context.l10n.shellyScriptsErrorUpdatingStaging(e.toString()),
        );
      },
    );

    // STEP 4: Rename script to correct version (only if update succeeded)
    if (updateSuccess && mounted) {
      final finalName = _generateAutomationScriptName(
        templateId,
        latestTemplate.version,
        deploymentId,
      );

      await DialogUtils.executeWithLoading(
        context,
        loadingMessage: context.l10n.shellyScriptsFinalizingUpdate,
        operation: () => widget.sendCommandToDevice(
          COMMAND_RENAME_SCRIPT,
          {"id": script.id, "name": finalName},
        ),
        showErrorDialog: false,
      );

      if (mounted) {
        MessageUtils.showSuccess(
          context,
          context.l10n.shellyScriptsScriptUpdated(latestTemplate.version),
        );
      }
    }

    // STEP 5: Restart script if it was running before
    if (updateSuccess && wasRunning && mounted) {
      await widget.sendCommandToDevice(
        COMMAND_START_SCRIPT,
        {"id": script.id},
      );
    }

    // Refresh scripts list
    _fetchAllScriptsStatus();
  }

  /// Generate automation script name with specified version
  String _generateAutomationScriptName(String templateId, String version, String deploymentId) {
    return '__auto_${templateId}_${version}_$deploymentId';
  }

  /// Delete a script with confirmation
  Future<void> _deleteScript(ShellyScript script) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.shellyScriptsDialogDeleteTitle),
        content: Text(
          context.l10n.shellyScriptsDialogDeleteMessage(script.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Execute delete with loading dialog
    final result = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.shellyScriptsDeletingScript,
      operation: () => widget.sendCommandToDevice(
        COMMAND_DELETE_SCRIPT,
        {"id": script.id},
      ),
      showErrorDialog: false,
    );

    if (result != null && mounted) {
      setState(() {
        _scriptsData.remove(script.id);
      });
      MessageUtils.showSuccess(context, context.l10n.shellyScriptsScriptDeleted);
    }
  }

  /// Build a script card for the list
  Widget _buildScriptCard(ShellyScript originalScript) {
    final script = _scriptsData[originalScript.id] ?? originalScript;

    // Check if this is a template-created script
    final isTemplateScript = ScriptParameterExtractor.isTemplateScript(script.name);
    final scriptMeta = isTemplateScript
        ? ScriptParameterExtractor.parseScriptName(script.name)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: isTemplateScript ? Colors.purple.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (icon + title + badge)
            Row(
              children: [
                Icon(
                  isTemplateScript ? Icons.auto_awesome : Icons.code,
                  color: script.enable ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTemplateScript && scriptMeta != null
                        ? scriptMeta['template_id']!
                        : script.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isTemplateScript) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade300),
                    ),
                    child: Text(
                      context.l10n.shellyScriptsInfoAutomation,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ),
                ],
                // Add staging warning badge for 0.0.0 versions
                if (isTemplateScript && scriptMeta != null && scriptMeta['version'] == '0.0.0') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      context.l10n.shellyScriptsInfoFailed,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Version and Script ID info
            if (isTemplateScript && scriptMeta != null) ...[
              Text(
                context.l10n.shellyScriptsInfoVersion(
                  scriptMeta['version'] == '0.0.0' ? context.l10n.unknownUpdating : scriptMeta['version']!,
                  scriptMeta['deployment_id']?.substring(0, 8) ?? '',
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              context.l10n.shellyScriptsInfoScriptId(script.id.toString()),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 12),

            // Status Chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    script.enable ? context.l10n.statusActivated : context.l10n.statusDeactivated,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: script.enable
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  side: BorderSide(
                    color: script.enable ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Chip(
                  label: Text(
                    script.running ? context.l10n.statusRunning : context.l10n.statusStopped,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: script.running
                      ? Colors.blue.shade100
                      : Colors.grey.shade200,
                  side: BorderSide(
                    color: script.running ? Colors.blue : Colors.grey,
                    width: 1,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons at Bottom
            _buildActionButtons(script, scriptMeta),
          ],
        ),
      ),
    );
  }

  /// Build action buttons for a script card
  Widget _buildActionButtons(ShellyScript script, Map<String, String>? scriptMeta) {
    final isTemplateScript = ScriptParameterExtractor.isTemplateScript(script.name);

    // Check if version is 0.0.0 (staging/failed update)
    final isStaging = scriptMeta != null && scriptMeta['version'] == '0.0.0';

    // Treat 0.0.0 as always having updates available
    final hasUpdate = isStaging || (_hasUpdates[script.id] ?? false);

    // For automation scripts with updates available (or in staging)
    if (isTemplateScript && hasUpdate && scriptMeta != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prominent update button (different text for staging)
          ElevatedButton.icon(
            onPressed: () => _upgradeTemplateScript(script, scriptMeta),
            icon: Icon(isStaging ? Icons.build : Icons.system_update),
            label: Text(isStaging
                ? context.l10n.shellyScriptsRepairScript
                : context.l10n.shellyScriptsUpgradeVersion),
            style: ElevatedButton.styleFrom(
              backgroundColor: isStaging ? Colors.red : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _updateTemplateScript(script),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Parameter', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editScript(script),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(context.l10n.edit, style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteScript(script),
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(context.l10n.delete, style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // For automation scripts without updates
    if (isTemplateScript) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateTemplateScript(script),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('Parameter', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editScript(script),
              icon: const Icon(Icons.edit, size: 18),
              label: Text(context.l10n.edit, style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _deleteScript(script),
              icon: const Icon(Icons.delete, size: 18),
              label: Text(context.l10n.delete, style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    // For regular scripts (no update params button)
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _editScript(script),
            icon: const Icon(Icons.edit, size: 18),
            label: Text(context.l10n.edit, style: const TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _deleteScript(script),
            icon: const Icon(Icons.delete, size: 18),
            label: Text(context.l10n.delete, style: const TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current scripts list from live data
    final currentScripts = _scriptsData.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));  // Sort by ID for consistent order

    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.shellyScriptsScreenTitle,
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
                          Icons.auto_awesome,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.shellyScriptsScreenTitle,
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
                      context.l10n.shellyScriptsHelpEditTip,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Scripts List or Empty State
            if (currentScripts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.code_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.shellyScriptsEmptyStateTitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.shellyScriptsEmptyStateMessage,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...currentScripts.map(_buildScriptCard),

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
                          context.l10n.shellyScriptsInfoTitle,
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.shellyScriptsInfoContent,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to template library
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShellyScriptTemplateLibraryScreen(
                device: widget.device,
                systemId: widget.systemId,  // Pass systemId for device filtering
              ),
            ),
          );
          // Refresh scripts list after deployment
          _fetchAllScriptsStatus();
        },
        icon: const Icon(Icons.add),
        label: const Text('Aus Vorlage erstellen'),
      ),
    );
  }
}
