import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/utils/device_connection_utils.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

/// Consolidated control screen for Hoymiles devices.
///
/// Provides buttons for power on/off, inverter restart and DTU restart so the
/// device menu doesn't grow too large. Restarting the DTU drops the connection,
/// so the screen closes and triggers a reconnect afterwards.
class HoymilesControlScreen extends BaseCommandScreen {
  /// Inverter serial (hex string) used for inverter-targeted commands.
  /// When null, power on/off and inverter restart buttons are hidden.
  final String? inverterSerial;

  const HoymilesControlScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.inverterSerial,
  });

  @override
  State<HoymilesControlScreen> createState() => _HoymilesControlScreenState();
}

class _HoymilesControlScreenState extends State<HoymilesControlScreen> {
  bool _busy = false;

  bool get _hasInverter =>
      widget.inverterSerial != null && widget.inverterSerial!.isNotEmpty;

  bool get _isWifiDevice =>
      widget.device.connectionType == ConnectionType.wifi;

  Future<bool?> _confirm(String message) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.confirm),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _runCommand(
    String command,
    Map<String, dynamic> params, {
    required String successMessage,
  }) async {
    setState(() => _busy = true);
    try {
      await DialogUtils.executeWithLoading(
        context,
        loadingMessage: context.l10n.controlActionRunning,
        operation: () => widget.sendCommandToDevice(command, params),
        onSuccess: (_) => MessageUtils.showSuccess(context, successMessage),
        onError: (e) => MessageUtils.showError(
          context,
          '${context.l10n.error}: $e',
          title: context.l10n.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _powerOn() async {
    await _runCommand(
      COMMAND_TURN_ON_INVERTER,
      {'inverterSerial': widget.inverterSerial},
      successMessage: context.l10n.controlInverterTurnedOn,
    );
  }

  Future<void> _powerOff() async {
    final successMessage = context.l10n.controlInverterTurnedOff;
    final confirmed = await _confirm(context.l10n.controlPowerOffConfirm);
    if (confirmed != true) return;
    await _runCommand(
      COMMAND_TURN_OFF_INVERTER,
      {'inverterSerial': widget.inverterSerial},
      successMessage: successMessage,
    );
  }

  Future<void> _restartInverter() async {
    final successMessage = context.l10n.inverterRestarted;
    final confirmed = await _confirm(context.l10n.restartInverterConfirm);
    if (confirmed != true) return;
    await _runCommand(
      COMMAND_RESTART_INVERTER,
      {'inverterSerial': widget.inverterSerial},
      successMessage: successMessage,
    );
  }

  Future<void> _restartDtu() async {
    final confirmed = await _confirm(context.l10n.controlRestartDtuConfirm);
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      // Send the restart command. The connection drops during reboot.
      await widget.sendCommandToDevice(COMMAND_RESTART, {});
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(context, '${context.l10n.error}: $e');
        setState(() => _busy = false);
      }
      return;
    }

    if (!mounted) return;

    final device = widget.device;
    final messenger = ScaffoldMessenger.of(context);

    // Reset the connection: disconnect now (device is rebooting), then
    // schedule a reconnect once it has had time to come back up.
    await DeviceConnectionUtils.disconnectDevice(context, device,
        showMessages: false);

    // Fire-and-forget reconnect that doesn't depend on this screen's context.
    _scheduleReconnect(device);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.controlDtuRestarting)),
    );
    Navigator.pop(context, true);
  }

  /// Reconnect the device after it has had time to reboot, without relying on
  /// the (soon-to-be-disposed) screen context.
  void _scheduleReconnect(DeviceBase device) {
    Future<void>.delayed(const Duration(seconds: 8), () async {
      try {
        final service = device.getServiceConnection();
        if (service != null && service.isConnected()) return;
        await device.setUpServiceConnection(null);
        await device.getServiceConnection()?.connect();
      } catch (_) {
        // Reconnection will otherwise be retried by BaseDeviceService /
        // the detail screen's auto-reconnect.
      }
    });
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _busy ? null : onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenDeviceControl,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_remote,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.screenDeviceControl,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
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
              ),
            ),
            const SizedBox(height: 16),

            if (_hasInverter) ...[
              _buildActionCard(
                icon: Icons.power_settings_new,
                color: Colors.green,
                label: context.l10n.controlPowerOn,
                onPressed: _powerOn,
              ),
              _buildActionCard(
                icon: Icons.power_off,
                color: Colors.red,
                label: context.l10n.controlPowerOff,
                onPressed: _powerOff,
              ),
            ],

            if (_hasInverter && !_isWifiDevice)
              _buildActionCard(
                icon: Icons.restart_alt,
                color: Colors.orange,
                label: context.l10n.controlRestartInverter,
                onPressed: _restartInverter,
              ),

            if (!_isWifiDevice)
              _buildActionCard(
                icon: Icons.router,
                color: Colors.red,
                label: context.l10n.controlRestartDtu,
                onPressed: _restartDtu,
              ),
          ],
        ),
      ),
    );
  }
}
