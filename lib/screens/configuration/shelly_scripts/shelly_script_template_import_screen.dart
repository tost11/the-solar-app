import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/shelly_script_template.dart';
import '../../../services/script_template_service.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/localization_extension.dart';
import '../../../utils/message_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';

/// Screen for importing script templates
///
/// Supports:
/// - Paste JSON from clipboard
/// - Manual JSON input
/// - Real-time validation
/// - Preview before import
class ShellyScriptTemplateImportScreen extends StatefulWidget {
  const ShellyScriptTemplateImportScreen({super.key});

  @override
  State<ShellyScriptTemplateImportScreen> createState() =>
      _ShellyScriptTemplateImportScreenState();
}

class _ShellyScriptTemplateImportScreenState
    extends State<ShellyScriptTemplateImportScreen> {
  final _jsonController = TextEditingController();
  bool _overrideExisting = false;
  ShellyScriptTemplate? _previewTemplate;
  String? _validationError;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  /// Validate and preview template
  Future<void> _validateAndPreview() async {
    setState(() {
      _validationError = null;
      _previewTemplate = null;
    });

    try {
      final json = _jsonController.text.trim();
      if (json.isEmpty) {
        throw Exception('JSON content is empty');
      }

      // Parse JSON
      final jsonData = jsonDecode(json) as Map<String, dynamic>;
      final template = ShellyScriptTemplate.fromJson(
        jsonData,
        source: TemplateSource.user,
      );

      // Validate required fields
      if (template.id.isEmpty) {
        throw Exception('Template ID is required');
      }
      if (template.version.isEmpty) {
        throw Exception('Template version is required');
      }
      if (template.sourceCode.isEmpty) {
        throw Exception('Template source code is required');
      }

      // Check for existing template
      final existing = await ScriptTemplateService.getTemplateById(
        template.id,
        version: template.version,
      );

      if (existing != null) {
        if (!mounted) return;
        MessageUtils.showWarning(
          context,
          existing.source == TemplateSource.asset
              ? context.l10n.shellyScriptsWillOverrideAssetTemplate
              : context.l10n.shellyScriptsWillOverrideUserTemplate,
        );
      }

      setState(() => _previewTemplate = template);
    } catch (e) {
      setState(() => _validationError = e.toString());
    }
  }

  /// Import template
  Future<void> _importTemplate() async {
    if (_previewTemplate == null) return;

    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.shellyScriptsImportingTemplate,
      operation: () async {
        await ScriptTemplateService.importTemplate(
          _jsonController.text,
          overrideExisting: _overrideExisting,
        );
      },
    );

    if (!mounted) return;

    MessageUtils.showSuccess(
      context,
      context.l10n.shellyScriptsTemplateImported,
    );

    Navigator.pop(context, true); // Return true to trigger refresh
  }

  /// Paste from clipboard
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _jsonController.text = data!.text!;
      _validateAndPreview();
    }
  }

  /// Select and load JSON file from file system
  Future<void> _selectJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      // Check file size (reject if > 3 KB)
      if (file.size > 3072) {
        if (!mounted) return;
        MessageUtils.showError(
          context,
          context.l10n.shellyScriptsFileTooLargeDetail(
            (file.size / 1024).toStringAsFixed(1),
          ),
          title: context.l10n.shellyScriptsFileTooLarge,
        );
        return;
      }

      if (file.path == null) {
        throw Exception('File path is null');
      }

      final fileContent = await File(file.path!).readAsString();
      _jsonController.text = fileContent;
      _validateAndPreview();
    } catch (e) {
      if (!mounted) return;
      MessageUtils.showError(
        context,
        e.toString(),
        title: context.l10n.shellyScriptsErrorLoadingFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.shellyScriptsImportTemplate,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.shellyScriptsImportInstructions,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(context.l10n.shellyScriptsImportInstructionsDetail),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // JSON input
            TextField(
              controller: _jsonController,
              decoration: InputDecoration(
                labelText: context.l10n.shellyScriptsTemplateJson,
                hintText: '{"id": "my-template", "name": "...", ...}',
                border: const OutlineInputBorder(),
              ),
              maxLines: 15,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),

            const SizedBox(height: 12),

            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _selectJsonFile,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: Text(context.l10n.shellyScriptsSelectFile),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste, size: 18),
                  label: Text(context.l10n.shellyScriptsPasteFromClipboard),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Override checkbox
            CheckboxListTile(
              title: Text(context.l10n.shellyScriptsOverrideExisting),
              subtitle: Text(context.l10n.shellyScriptsOverrideExistingDetail),
              value: _overrideExisting,
              onChanged: (value) {
                setState(() => _overrideExisting = value ?? false);
              },
            ),

            const SizedBox(height: 16),

            // Validate button
            ElevatedButton.icon(
              onPressed: _validateAndPreview,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(context.l10n.shellyScriptsValidateTemplate),
            ),

            const SizedBox(height: 16),

            // Validation error
            if (_validationError != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Preview card
            if (_previewTemplate != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.shellyScriptsTemplateValid,
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('ID: ${_previewTemplate!.id}'),
                      Text('Name: ${_previewTemplate!.name}'),
                      Text('Version: ${_previewTemplate!.version}'),
                      Text('Parameters: ${_previewTemplate!.parameters.length}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Import button
            if (_previewTemplate != null)
              ElevatedButton.icon(
                onPressed: _importTemplate,
                icon: const Icon(Icons.upload),
                label: Text(context.l10n.shellyScriptsImportTemplate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
