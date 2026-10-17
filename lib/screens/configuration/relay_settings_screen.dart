import 'package:flutter/material.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import '../../models/devices/generic_rendering/general_setting_item.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/message_utils.dart';
import '../../constants/command_constants.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

/// Configuration screen that renders related settings grouped under a header
/// (one group per relay). Each group shows a header (the relay's name) followed
/// by its settings, e.g. a Shelly v1 relay's button action and power-on state.
class RelaySettingsScreen extends BaseCommandScreen {
  final List<SettingsGroup> groups;

  const RelaySettingsScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    required this.groups,
  });

  @override
  State<RelaySettingsScreen> createState() => _RelaySettingsScreenState();
}

class _RelaySettingsScreenState extends State<RelaySettingsScreen> {
  // Current value per setting, keyed by commandName (unique per relay)
  late Map<String, dynamic> _values;

  // Settings currently being changed
  final Set<String> _changing = {};

  @override
  void initState() {
    super.initState();
    _values = {};
    for (final group in widget.groups) {
      for (final item in group.items) {
        _values[item.commandName] = item.currentValue;
      }
    }
  }

  Future<void> _handleChange(GeneralSettingItem item, dynamic newValue) async {
    setState(() {
      _changing.add(item.commandName);
    });

    final ctx = context;
    try {
      await DialogUtils.executeWithLoading(
        ctx,
        loadingMessage: ctx.l10n.dialogSettingChanging,
        operation: () async {
          await widget.sendCommandToDevice(
            COMMAND_SET_GENERAL_SETTING,
            {
              'name': item.commandName,
              'value': newValue,
            },
          );

          if (!mounted) return;
          setState(() {
            _values[item.commandName] = newValue;
          });
        },
        onSuccess: (_) {
          if (ctx.mounted) {
            MessageUtils.showSuccess(
              ctx,
              ctx.l10n.messageSettingUpdated(item.name.getText(ctx)),
            );
          }
        },
        onError: (e) {
          if (ctx.mounted) {
            MessageUtils.showError(
              ctx,
              ctx.l10n.errorChangingSetting(e.toString()),
              title: ctx.l10n.error,
            );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _changing.remove(item.commandName);
        });
      }
    }
  }

  Widget _buildDropdownItem(GeneralSettingItem item) {
    final currentValue = _values[item.commandName];
    final isChanging = _changing.contains(item.commandName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.name.getText(context),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isChanging)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            DropdownButtonFormField<dynamic>(
              value: currentValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              isExpanded: true,
              items: item.options?.map((option) {
                return DropdownMenuItem<dynamic>(
                  value: option.value,
                  child: Text(option.label),
                );
              }).toList() ?? [],
              onChanged: (newValue) {
                if (newValue != null && newValue != currentValue) {
                  _handleChange(item, newValue);
                }
              },
            ),
          if (item.description != null) ...[
            const SizedBox(height: 6),
            Text(
              item.description!.getText(context),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupCard(SettingsGroup group) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.power,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...group.items.map((item) => _buildDropdownItem(item)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.menuRelaySettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.groups.isEmpty)
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
                          context.l10n.helpNoSettingsAvailable,
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...widget.groups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGroupCard(group),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
