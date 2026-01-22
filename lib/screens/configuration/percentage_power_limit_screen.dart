import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import '../../constants/command_constants.dart';
import '../../utils/message_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

/// Screen for configuring power limit by percentage or watt
class PercentagePowerLimitScreen extends BaseCommandScreen {
  final int? currentLimit; // Current percentage (1-100)
  final int? totalPower; // Total power rating in watts

  const PercentagePowerLimitScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.currentLimit,
    this.totalPower,
  });

  @override
  State<PercentagePowerLimitScreen> createState() =>
      _PercentagePowerLimitScreenState();
}

class _PercentagePowerLimitScreenState
    extends State<PercentagePowerLimitScreen> {
  late int _percentage;
  late int _watt;

  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _wattController = TextEditingController();

  bool _isUpdatingFromSlider = false;

  @override
  void initState() {
    super.initState();

    // Initialize with current limit or default to 100%
    _percentage = widget.currentLimit ?? 100;

    // Calculate watt if total power is available
    if (widget.totalPower != null) {
      _watt = ((_percentage * widget.totalPower!) / 100).round();
    } else {
      _watt = 0;
    }

    _updateTextFields();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _wattController.dispose();
    super.dispose();
  }

  /// Update text fields with current values
  void _updateTextFields() {
    _percentageController.text = _percentage.toString();
    if (widget.totalPower != null) {
      _wattController.text = _watt.toString();
    }
  }

  /// Update percentage and recalculate watt
  void _updatePercentage(int newPercentage) {
    if (newPercentage < 1) newPercentage = 1;
    if (newPercentage > 100) newPercentage = 100;

    setState(() {
      _percentage = newPercentage;
      if (widget.totalPower != null) {
        _watt = ((_percentage * widget.totalPower!) / 100).round();
      }
      _updateTextFields();
    });
  }

  /// Update watt and recalculate percentage (snap to nearest full percentage)
  void _updateWatt(int newWatt) {
    if (widget.totalPower == null) return;

    // Clamp watt to valid range
    final maxWatt = widget.totalPower!;
    if (newWatt < 0) newWatt = 0;
    if (newWatt > maxWatt) newWatt = maxWatt;

    // Calculate percentage and snap to nearest full number
    final calculatedPercentage = ((newWatt / widget.totalPower!) * 100).round();
    final snappedPercentage = calculatedPercentage.clamp(1, 100);

    // Recalculate watt based on snapped percentage for exact value
    final snappedWatt = ((snappedPercentage * widget.totalPower!) / 100).round();

    setState(() {
      _percentage = snappedPercentage;
      _watt = snappedWatt;
      _updateTextFields();
    });
  }

  /// Save power limit to device
  Future<void> _savePowerLimit() async {
    final result = await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.dialogPowerLimitSetting(_percentage.toString()),
      operation: () => widget.sendCommandToDevice(COMMAND_SET_LIMIT, {
        'limit': _percentage,
      }),
      onError: (e) => MessageUtils.showError(
          context, context.l10n.errorSettingPercentageLimit(e.toString())),
    );

    if (result != null && mounted) {
      Navigator.pop(context, true); // Return to previous screen with success
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWattControl = widget.totalPower != null;
    final maxWatt = widget.totalPower ?? 0;

    return AppScaffold(
      appBar: AppBarWidget(title: context.l10n.screenPercentagePowerLimit),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current limit info
            if (widget.currentLimit != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.helpCurrentPercentageLimit(widget.currentLimit.toString()),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Percentage section
            Text(
              context.l10n.sectionPercentageLimit,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Percentage value display
            Center(
              child: Text(
                '$_percentage%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Percentage slider
            Slider(
              value: _percentage.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: '$_percentage%',
              onChanged: (value) {
                _isUpdatingFromSlider = true;
                _updatePercentage(value.round());
                _isUpdatingFromSlider = false;
              },
            ),

            const SizedBox(height: 16),

            // Percentage text input
            TextFormField(
              controller: _percentageController,
              decoration: InputDecoration(
                labelText: context.l10n.labelPercent,
                suffixText: '%',
                border: const OutlineInputBorder(),
                helperText: context.l10n.helpWattValue,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                if (!_isUpdatingFromSlider && value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    _updatePercentage(parsed);
                  }
                }
              },
            ),

            // Watt section (only if totalPower is available)
            if (hasWattControl) ...[
              const SizedBox(height: 32),

              Text(
                context.l10n.sectionWattLimit,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Watt text input
              TextFormField(
                controller: _wattController,
                decoration: InputDecoration(
                  labelText: context.l10n.labelWatt,
                  suffixText: 'W',
                  border: const OutlineInputBorder(),
                  helperText: context.l10n.helpMaxWatt(maxWatt.toString()),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  // Update as user types (for preview)
                  if (value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      setState(() {
                        _watt = parsed;
                      });
                    }
                  }
                },
                onEditingComplete: () {
                  // Snap to nearest percentage when done editing
                  final parsed = int.tryParse(_wattController.text);
                  if (parsed != null) {
                    _updateWatt(parsed);
                  }
                  FocusScope.of(context).unfocus();
                },
              ),

              const SizedBox(height: 16),

              // Info card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.infoWattRoundingNote,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Power rating info
            if (hasWattControl)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.sectionDeviceInfo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(context.l10n.helpNominalPower(maxWatt.toString())),
                      Text(context.l10n.helpCurrentLimit(_watt.toString(), _percentage.toString())),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _savePowerLimit,
                icon: const Icon(Icons.save),
                label: Text(
                  context.l10n.buttonSavePowerLimit,
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.cancel,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            // Bottom padding to prevent overflow
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
