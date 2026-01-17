import 'package:flutter/material.dart';
import '../../models/devices/generic_rendering/general_setting_item.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/message_utils.dart';
import '../../constants/command_constants.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

/// A generic configuration screen for displaying and managing general device settings
/// with toggle switches.
///
/// Each setting can optionally show a confirmation dialog before changing.
class GeneralSettingsScreen extends BaseCommandScreen {
  final List<GeneralSettingItem> settings;

  const GeneralSettingsScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    required this.settings,
  });

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  // Track local state of each setting
  late Map<String, dynamic> _settingsState;

  // Track which settings are currently being changed
  final Set<String> _changingSettings = {};

  @override
  void initState() {
    super.initState();
    // Initialize local state from provided settings
    _settingsState = {};
    for (final setting in widget.settings) {
      if (setting.type == SettingType.toggle) {
        _settingsState[setting.commandName] = setting.currentStatus ?? false;
      } else if (setting.type == SettingType.dropdown) {
        _settingsState[setting.commandName] = setting.currentValue;
      }
    }
  }

  Future<void> _handleSettingChange(GeneralSettingItem setting, dynamic newValue) async {
    // Check if confirmation is needed
    if (setting.popUpOnChange) {
      final confirmed = await _showConfirmationDialog(setting, newValue);
      if (confirmed != true) return;
    }

    // Mark this setting as changing
    setState(() {
      _changingSettings.add(setting.name);
    });

    try {
      await DialogUtils.executeWithLoading(
        context,
        loadingMessage: 'Einstellung wird geändert...',
        operation: () async {
          await widget.sendCommandToDevice(
            COMMAND_SET_GENERAL_SETTING,
            {
              'name': setting.commandName,
              'value': newValue,
            },
          );

          // Update local state
          setState(() {
            _settingsState[setting.commandName] = newValue;
          });
        },
        onSuccess: (_) => MessageUtils.showSuccess(
          context,
          '${setting.name} wurde aktualisiert',
        ),
        onError: (e) => MessageUtils.showError(
          context,
          'Fehler beim Ändern der Einstellung: $e',
          title: 'Fehler',
        ),
      );
    } finally {
      // Remove from changing set
      setState(() {
        _changingSettings.remove(setting.name);
      });
    }
  }

  Future<bool?> _showConfirmationDialog(
      GeneralSettingItem setting, dynamic newValue) async {
    final title = setting.confirmationTitle ??
        '${setting.name} ${newValue == true ? "aktivieren" : "deaktivieren"}?';
    final message = setting.confirmationMessage ??
        'Möchten Sie ${setting.name} wirklich ${newValue == true ? "aktivieren" : "deaktivieren"}?';

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(GeneralSettingItem setting) {
    final currentValue = _settingsState[setting.commandName];
    final isChanging = _changingSettings.contains(setting.name);

    // Determine icon color based on setting type
    Color iconColor = Colors.grey;
    if (setting.type == SettingType.toggle && currentValue == true) {
      iconColor = Colors.green;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (setting.icon != null) ...[
                  Icon(
                    setting.icon,
                    color: iconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    setting.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Only show toggle switches in trailing position
                if (setting.type == SettingType.toggle) ...[
                  if (isChanging)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Switch(
                      value: currentValue as bool? ?? false,
                      onChanged: (newValue) => _handleSettingChange(setting, newValue),
                    ),
                ],
              ],
            ),
            // Show dropdown below title if it's a dropdown type
            if (setting.type == SettingType.dropdown) ...[
              const SizedBox(height: 12),
              if (isChanging)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                DropdownButtonFormField<dynamic>(
                  value: currentValue,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  isExpanded: true,
                  items: setting.options?.map((option) {
                    return DropdownMenuItem<dynamic>(
                      value: option.value,
                      child: Text(option.label),
                    );
                  }).toList() ?? [],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _handleSettingChange(setting, newValue);
                    }
                  },
                ),
            ],
            if (setting.description != null) ...[
              const SizedBox(height: 8),
              Text(
                setting.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (setting.popUpOnChange) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Bestätigung erforderlich',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(
        title: 'Allgemeine Einstellungen',
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
                          Icons.settings,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Allgemeine Einstellungen',
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
                      'Verwalten Sie die grundlegenden Einstellungen Ihres Geräts.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings Cards
            if (widget.settings.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Keine Einstellungen verfügbar',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...widget.settings.map((setting) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildSettingCard(setting),
                  )),

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
                      'Änderungen werden sofort auf das Gerät übertragen. '
                      'Einstellungen mit Bestätigungsanforderung zeigen einen '
                      'Dialog vor der Änderung an.',
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
    );
  }
}
