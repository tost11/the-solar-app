import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/device.dart';
import '../../../models/shelly_script_template.dart';
import '../../../services/script_template_service.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/localization_extension.dart';
import '../../../utils/message_utils.dart';
import '../../../utils/version_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';
import 'shelly_script_template_config_screen.dart';
import 'shelly_script_template_import_screen.dart';

/// Screen for browsing and selecting Shelly script templates
///
/// Shows all available templates with smart filtering based on required devices.
/// Can be used globally (no device) or device-specific (with device for deployment).
class ShellyScriptTemplateLibraryScreen extends StatefulWidget {
  final Device? device;
  final String? systemId;

  const ShellyScriptTemplateLibraryScreen({
    super.key,
    this.device,
    this.systemId,
  });

  @override
  State<ShellyScriptTemplateLibraryScreen> createState() =>
      _ShellyScriptTemplateLibraryScreenState();
}

class _ShellyScriptTemplateLibraryScreenState
    extends State<ShellyScriptTemplateLibraryScreen> {
  List<ShellyScriptTemplate> _templates = [];
  List<ShellyScriptTemplate> _filteredTemplates = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedTag;
  List<String> _availableTags = [];
  bool _showAllScripts = false;
  bool _showAllVersions = false; // Show all template versions

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);

    try {
      // Load all templates (includes all versions)
      final allTemplates = await ScriptTemplateService.loadTemplates();

      // Conditionally filter to latest version only
      final displayTemplates = _showAllVersions
          ? allTemplates
          : _getLatestVersionsOnly(allTemplates);

      final tags = await ScriptTemplateService.getAllTags();

      // Apply initial compatibility filter (only if toggle is OFF and device provided)
      var initialFiltered = displayTemplates;
      if (!_showAllScripts && widget.device != null && widget.device!.getDeviceModelGroup() != null) {
        initialFiltered = ScriptTemplateService.filterByCompatibleDevice(
          displayTemplates,
          widget.device!.getDeviceModelGroup()!,
        );
      }

      setState(() {
        _templates = displayTemplates;
        _filteredTemplates = initialFiltered;
        _availableTags = tags;
        _isLoading = false;
      });

      // Reapply search and tag filters after loading
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.shellyScriptsErrorLoadingTemplates(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get only latest version of each template
  List<ShellyScriptTemplate> _getLatestVersionsOnly(List<ShellyScriptTemplate> templates) {
    final latestTemplatesMap = <String, ShellyScriptTemplate>{};
    for (final template in templates) {
      final existing = latestTemplatesMap[template.id];
      if (existing == null ||
          VersionUtils.compareVersions(template.version, existing.version) > 0) {
        latestTemplatesMap[template.id] = template;
      }
    }
    return latestTemplatesMap.values.toList();
  }

  void _applyFilters() {
    var filtered = _templates;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = ScriptTemplateService.searchTemplates(filtered, _searchQuery);
    }

    // Apply tag filter
    if (_selectedTag != null) {
      filtered = ScriptTemplateService.filterByTags(filtered, [_selectedTag!]);
    }

    // Apply compatibility filter (only if toggle is OFF and device provided)
    if (!_showAllScripts && widget.device != null) {
      // Filter by compatible device model ONLY
      if (widget.device!.deviceModel != null) {
        filtered = ScriptTemplateService.filterByCompatibleDevice(
          filtered,
          widget.device!.getDeviceModelGroup()!,
        );
      }
    }

    setState(() {
      _filteredTemplates = filtered;
    });
  }

  /// Get count of active filters (for badge display)
  int _getActiveFilterCount() {
    int count = 0;
    if (_showAllScripts) count++;
    if (_showAllVersions) count++;
    if (_selectedTag != null) count++;
    return count;
  }

  /// Check if template is compatible with current device (device model only)
  bool _isTemplateCompatible(ShellyScriptTemplate template) {
    // If no device provided, assume compatible
    if (widget.device == null) return true;

    String? model = widget.device!.getDeviceModelGroup();
    // Check device model compatibility ONLY (use device.deviceModel directly)
    return template.compatibleDevices.isEmpty || (model != null && template.compatibleDevices.contains(model));
  }

  void _onTemplateSelected(ShellyScriptTemplate template) {
    // If no device, just view the template without deploying
    if (widget.device == null) {
      // TODO: Show template details view instead of config screen
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShellyScriptTemplateConfigScreen(
          device: widget.device!,
          template: template,
          systemId: widget.systemId,  // Pass systemId for device filtering
        ),
      ),
    );
  }

  void _showCompatibilityInfo(ShellyScriptTemplate template) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(dialogContext.l10n.shellyScriptsDialogCompatibilityTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dialogContext.l10n.shellyScriptsCurrentDevice,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              widget.device?.deviceModel ?? dialogContext.l10n.shellyScriptsUnknownModel,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              dialogContext.l10n.shellyScriptsCompatibleDevices,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              template.compatibleDevices.isEmpty
                  ? dialogContext.l10n.shellyScriptsAllDevices
                  : template.compatibleDevices.join(', '),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(ShellyScriptTemplate template) {
    final isCompatible = _isTemplateCompatible(template);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _onTemplateSelected(template),
        child: Column(
          children: [
            // User template badge
            if (template.isUserTemplate)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.shellyScriptsUserTemplate,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Incompatibility warning banner
            if (!isCompatible)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border(
                    bottom: BorderSide(color: Colors.orange.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.shellyScriptsNotCompatibleWarning,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showCompatibilityInfo(template),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                children: [
                  Icon(
                    Icons.code,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                getLocalizedField(context, template.name, template.nameLng),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (_showAllVersions) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'v${template.version}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.shellyScriptsVersionDisplay(template.version),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Context menu for user templates
                  if (template.isUserTemplate)
                    PopupMenuButton<String>(
                      onSelected: (action) => _handleTemplateAction(action, template),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'export',
                          child: Row(
                            children: [
                              const Icon(Icons.download),
                              const SizedBox(width: 8),
                              Text(context.l10n.shellyScriptsExportTemplate),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                getLocalizedField(context, template.description, template.descriptionLng),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              if (template.author != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.shellyScriptsAuthorCredit(template.author!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (template.requiredDevices.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(
                        context.l10n.shellyScriptsRequiresDevices(template.requiredDevices.join(", ")),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.orange.shade100,
                      side: BorderSide(color: Colors.orange.shade700),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ],
              if (template.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: template.tags
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide(color: Colors.blue.shade200),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.shellyScriptsParamCount(template.parameters.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  /// Navigate to import screen
  Future<void> _showImportScreen() async {
    final imported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ShellyScriptTemplateImportScreen(),
      ),
    );

    if (imported == true) {
      // Reload templates from service (includes newly imported template)
      await _loadTemplates();
    }
  }

  /// Handle template actions (export, delete)
  Future<void> _handleTemplateAction(String action, ShellyScriptTemplate template) async {
    switch (action) {
      case 'export':
        final json = ScriptTemplateService.exportTemplate(template);
        await Clipboard.setData(ClipboardData(text: json));
        if (!mounted) return;
        MessageUtils.showSuccess(
          context,
          context.l10n.shellyScriptsExportSuccess,
        );
        break;

      case 'delete':
        final confirmed = await DialogUtils.showConfirmDialog(
          context,
          title: context.l10n.shellyScriptsDeleteTemplateConfirm,
          content: '${getLocalizedField(context, template.name, template.nameLng)} (${template.version})',
        );

        if (confirmed != true || !mounted) return;

        await DialogUtils.executeWithLoading(
          context,
          loadingMessage: context.l10n.deleting,
          operation: () async {
            await ScriptTemplateService.deleteUserTemplate(template);
          },
        );

        if (!mounted) return;
        MessageUtils.showSuccess(context, context.l10n.shellyScriptsTemplateDeleted);

        // Reload templates from service (deleted template will be removed)
        await _loadTemplates();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.shellyScriptLibraryTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: context.l10n.shellyScriptsImportTemplate,
            onPressed: _showImportScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.shellyScriptsSearchPlaceholder,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
          ),

          // Collapsible filter accordion
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ExpansionTile(
              title: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 20),
                  const SizedBox(width: 8),
                  Text(context.l10n.filters),
                  if (_getActiveFilterCount() > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getActiveFilterCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show All Scripts toggle
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.l10n.shellyScriptsShowAllToggle),
                        value: _showAllScripts,
                        onChanged: (value) {
                          setState(() => _showAllScripts = value);
                          _applyFilters();
                        },
                      ),

                      // Show All Versions toggle
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.l10n.shellyScriptsShowAllVersions),
                        subtitle: Text(context.l10n.shellyScriptsShowAllVersionsDetail),
                        value: _showAllVersions,
                        onChanged: (value) {
                          setState(() => _showAllVersions = value);
                          _loadTemplates();
                        },
                      ),

                      // Tag filter chips
                      if (_availableTags.isNotEmpty) ...[
                        const Divider(height: 32),
                        Text(
                          context.l10n.shellyScriptsFilterByTag,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            FilterChip(
                              label: Text(context.l10n.shellyScriptsFilterAll),
                              selected: _selectedTag == null,
                              onSelected: (selected) {
                                setState(() => _selectedTag = null);
                                _applyFilters();
                              },
                            ),
                            ..._availableTags.map((tag) => FilterChip(
                                  label: Text(tag),
                                  selected: _selectedTag == tag,
                                  onSelected: (selected) {
                                    setState(() => _selectedTag = selected ? tag : null);
                                    _applyFilters();
                                  },
                                )),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Templates list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTemplates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.shellyScriptsEmptyLibrary,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filteredTemplates.length,
                        itemBuilder: (context, index) {
                          return _buildTemplateCard(_filteredTemplates[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
