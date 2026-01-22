import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class BatterySocScreen extends BaseCommandScreen {
  final int currentMinSoc;
  final int currentMaxSoc;
  final int minSocRangeMin;
  final int minSocRangeMax;
  final int maxSocRangeMin;
  final int maxSocRangeMax;

  const BatterySocScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    required this.currentMinSoc,
    required this.currentMaxSoc,
    required this.minSocRangeMin,
    required this.minSocRangeMax,
    required this.maxSocRangeMin,
    required this.maxSocRangeMax,
  });

  @override
  State<BatterySocScreen> createState() => _BatterySocScreenState();
}

class _BatterySocScreenState extends State<BatterySocScreen> {
  late int _minSocValue;
  late int _maxSocValue;
  late TextEditingController _minSocController;
  late TextEditingController _maxSocController;
  bool _isSaving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _minSocValue = widget.currentMinSoc;
    _maxSocValue = widget.currentMaxSoc;
    _minSocController = TextEditingController(text: _minSocValue.toString());
    _maxSocController = TextEditingController(text: _maxSocValue.toString());
    _validateValues();
  }

  @override
  void dispose() {
    _minSocController.dispose();
    _maxSocController.dispose();
    super.dispose();
  }

  void _validateValues() {
    setState(() {
      if (_minSocValue >= _maxSocValue) {
        _validationError = context.l10n.validationMinSocLessThanMax;
      } else {
        _validationError = null;
      }
    });
  }

  void _onMinSocSliderChanged(double value) {
    setState(() {
      _minSocValue = value.round();
      _minSocController.text = _minSocValue.toString();
      _validateValues();
    });
  }

  void _onMaxSocSliderChanged(double value) {
    setState(() {
      _maxSocValue = value.round();
      _maxSocController.text = _maxSocValue.toString();
      _validateValues();
    });
  }

  void _onMinSocTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null &&
        intValue >= widget.minSocRangeMin &&
        intValue <= widget.minSocRangeMax) {
      setState(() {
        _minSocValue = intValue;
        _validateValues();
      });
    }
  }

  void _onMaxSocTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null &&
        intValue >= widget.maxSocRangeMin &&
        intValue <= widget.maxSocRangeMax) {
      setState(() {
        _maxSocValue = intValue;
        _validateValues();
      });
    }
  }

  Future<void> _saveBatteryLimits() async {
    if (_validationError != null) {
      MessageUtils.showError(context, _validationError!);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Convert percentage to 0.1% units (multiply by 10)
      final command = <String, dynamic>{
        'minSoc': _minSocValue,
        'maxSoc': _maxSocValue,
      };

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_BATTERY_LIMITS, command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          context.l10n.messageBatteryLimitsSet(_minSocValue.toString(), _maxSocValue.toString()),
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.errorSettingBatteryLimits(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenBatterySoc,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current values display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      context.l10n.sectionCurrentValues,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Min SOC Display
                        Column(
                          children: [
                            const Icon(
                              Icons.battery_alert,
                              size: 32,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.labelMinimum,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_minSocValue%',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        // Separator
                        Container(
                          width: 1,
                          height: 80,
                          color: Colors.grey[300],
                        ),
                        // Max SOC Display
                        Column(
                          children: [
                            const Icon(
                              Icons.battery_charging_full,
                              size: 32,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.labelMaximum,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_maxSocValue%',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Validation error
            if (_validationError != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_validationError != null) const SizedBox(height: 16),

            // Min SOC Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.battery_alert, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.sectionMinSoc,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _minSocValue.toDouble(),
                      min: widget.minSocRangeMin.toDouble(),
                      max: widget.minSocRangeMax.toDouble(),
                      divisions: widget.minSocRangeMax - widget.minSocRangeMin,
                      label: '$_minSocValue%',
                      onChanged: _onMinSocSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.minSocRangeMin}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          '${widget.minSocRangeMax}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Max SOC Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.battery_charging_full, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.sectionMaxSoc,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _maxSocValue.toDouble(),
                      min: widget.maxSocRangeMin.toDouble(),
                      max: widget.maxSocRangeMax.toDouble(),
                      divisions: widget.maxSocRangeMax - widget.maxSocRangeMin,
                      label: '$_maxSocValue%',
                      onChanged: _onMaxSocSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.maxSocRangeMin}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          '${widget.maxSocRangeMax}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Precise input fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sectionPreciseInput,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Min SOC TextField
                        Expanded(
                          child: TextField(
                            controller: _minSocController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: context.l10n.labelMinSoc,
                              suffixText: '%',
                              helperText: '${widget.minSocRangeMin}-${widget.minSocRangeMax}%',
                              prefixIcon: const Icon(Icons.battery_alert, color: Colors.orange),
                            ),
                            onChanged: _onMinSocTextChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Max SOC TextField
                        Expanded(
                          child: TextField(
                            controller: _maxSocController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: context.l10n.labelMaxSoc,
                              suffixText: '%',
                              helperText: '${widget.maxSocRangeMin}-${widget.maxSocRangeMax}%',
                              prefixIcon: const Icon(Icons.battery_charging_full, color: Colors.green),
                            ),
                            onChanged: _onMaxSocTextChanged,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: (_isSaving || _validationError != null) ? null : _saveBatteryLimits,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? context.l10n.messageSaving : context.l10n.buttonSavePowerLimit),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
