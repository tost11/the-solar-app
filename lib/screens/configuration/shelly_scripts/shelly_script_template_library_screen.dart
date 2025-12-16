import 'package:flutter/material.dart';
import '../../../models/device.dart';
import '../../../models/shelly_script_template.dart';
import '../../../services/script_template_service.dart';
import '../../../utils/version_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';
import 'shelly_script_template_config_screen.dart';

/// Screen for browsing and selecting Shelly script templates
///
/// Shows all available templates with smart filtering based on required devices.
/// Users can tap a template to configure parameters and deploy to their Shelly device.
class ShellyScriptTemplateLibraryScreen extends StatefulWidget {
  final Device device;
  final String? systemId;

  const ShellyScriptTemplateLibraryScreen({
    super.key,
    required this.device,
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

      // Group by ID and get latest version only
      final latestTemplatesMap = <String, ShellyScriptTemplate>{};
      for (final template in allTemplates) {
        final existing = latestTemplatesMap[template.id];
        if (existing == null ||
            VersionUtils.compareVersions(template.version, existing.version) > 0) {
          latestTemplatesMap[template.id] = template;
        }
      }
      final latestTemplates = latestTemplatesMap.values.toList();

      final tags = await ScriptTemplateService.getAllTags();

      // Apply initial compatibility filter (only if toggle is OFF)
      var initialFiltered = latestTemplates;
      if (!_showAllScripts && widget.device.getDeviceModelGroup() != null) {
        initialFiltered = ScriptTemplateService.filterByCompatibleDevice(
          latestTemplates,
          widget.device.getDeviceModelGroup()!,
        );
      }

      setState(() {
        _templates = latestTemplates;  // Store latest only
        _filteredTemplates = initialFiltered;
        _availableTags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Vorlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    // Apply compatibility filter (only if toggle is OFF)
    if (!_showAllScripts) {
      // Filter by compatible device model ONLY
      if (widget.device.deviceModel != null) {
        filtered = ScriptTemplateService.filterByCompatibleDevice(
          filtered,
          widget.device.deviceModel!,
        );
      }
    }

    setState(() {
      _filteredTemplates = filtered;
    });
  }

  /// Check if template is compatible with current device (device model only)
  bool _isTemplateCompatible(ShellyScriptTemplate template) {
    String? model = widget.device.getDeviceModelGroup();
    // Check device model compatibility ONLY (use device.deviceModel directly)
    return template.compatibleDevices.isEmpty || (model != null && template.compatibleDevices.contains(model));
  }

  void _onTemplateSelected(ShellyScriptTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShellyScriptTemplateConfigScreen(
          device: widget.device,
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
            const Text('Kompatibilitäts-Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktuelles Gerät:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              widget.device.deviceModel ?? 'Unbekannt',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kompatible Geräte:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              template.compatibleDevices.isEmpty
                  ? 'Alle Geräte'
                  : template.compatibleDevices.join(', '),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Schließen'),
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
                        'Nicht für dieses Gerät vorgesehen',
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
                        Text(
                          template.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${template.version}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              if (template.author != null) ...[
                const SizedBox(height: 8),
                Text(
                  'von ${template.author}',
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
                        'Benötigt: ${template.requiredDevices.join(", ")}',
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
                    '${template.parameters.length} Parameter',
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(
        title: 'Script-Vorlagen',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Vorlagen durchsuchen...',
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

          // Compatibility toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 20),
                const SizedBox(width: 8),
                const Text('Alle Scripte anzeigen'),
                const Spacer(),
                Switch(
                  value: _showAllScripts,
                  onChanged: (value) {
                    setState(() => _showAllScripts = value);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),

          // Tag filter chips
          if (_availableTags.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Alle'),
                    selected: _selectedTag == null,
                    onSelected: (selected) {
                      setState(() => _selectedTag = null);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._availableTags.map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            setState(() => _selectedTag = selected ? tag : null);
                            _applyFilters();
                          },
                        ),
                      )),
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
                              'Keine Vorlagen gefunden',
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
