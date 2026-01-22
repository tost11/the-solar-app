import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import '../../utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

class PowerLimitScreen extends BaseCommandScreen {
  final int currentInverseMaxPower;
  final int maxInverseMaxPower;
  final int currentGridReverse;
  final int currentGridStandard;

  const PowerLimitScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    required this.currentInverseMaxPower,
    required this.maxInverseMaxPower,
    required this.currentGridReverse,
    required this.currentGridStandard,
  });

  @override
  State<PowerLimitScreen> createState() => _PowerLimitScreenState();
}

class _PowerLimitScreenState extends State<PowerLimitScreen> {
  late int _inverseMaxPower;
  late int _gridReverse;
  late int _gridStandard;
  late TextEditingController _powerController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _inverseMaxPower = widget.currentInverseMaxPower;
    _gridReverse = widget.currentGridReverse;
    _gridStandard = widget.currentGridStandard;
    _powerController = TextEditingController(text: _inverseMaxPower.toString());
  }

  @override
  void dispose() {
    _powerController.dispose();
    super.dispose();
  }

  void _onPowerSliderChanged(double value) {
    setState(() {
      _inverseMaxPower = value.round();
      _powerController.text = _inverseMaxPower.toString();
    });
  }

  void _onPowerTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue >= 0 && intValue <= widget.maxInverseMaxPower) {
      setState(() {
        _inverseMaxPower = intValue;
      });
    }
  }

  void _onGridReverseChanged(int value) {
    setState(() {
      _gridReverse = value;
    });
  }

  void _onGridStandardChanged(int value) {
    setState(() {
      _gridStandard = value;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final command = <String, dynamic>{
        'inverseMaxPower': _inverseMaxPower,
        'gridReverse': _gridReverse,
        'gridStandard': _gridStandard,
      };

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_SET_POWER_CONFIG, command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          context.l10n.messagePowerLimitSetWithValue(_inverseMaxPower.toString()),
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.errorSettingPowerLimit(e.toString()));
      }
    } finally{
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getGridReverseLabel(BuildContext context, int value) {
    switch (value) {
      case 0:
        return context.l10n.segmentDisabled;
      case 1:
        return context.l10n.segmentAllowed;
      case 2:
        return context.l10n.segmentForbidden;
      default:
        return context.l10n.labelUnknown;
    }
  }

  String _getGridStandardLabel(BuildContext context, int value) {
    switch (value) {
      case 0:
        return context.l10n.segmentGermany;
      case 1:
        return context.l10n.segmentFrance;
      case 2:
        return context.l10n.segmentAustria;
      default:
        return context.l10n.labelUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenPowerLimit,
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
                      context.l10n.sectionCurrentValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Power Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.power_settings_new,
                          size: 32,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.labelMaxInverterPower,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_inverseMaxPower W',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Grid Settings Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Grid Reverse
                        Column(
                          children: [
                            const Icon(Icons.sync_alt, color: Colors.orange),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.labelGridFeedback,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGridReverseLabel(context, _gridReverse),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Grid Standard
                        Column(
                          children: [
                            const Icon(Icons.public, color: Colors.green),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.labelGridStandard,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGridStandardLabel(context, _gridStandard),
                              style: const TextStyle(fontWeight: FontWeight.bold),
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

            // Inverse Max Power Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.power_settings_new, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.labelMaxInverterPower,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _inverseMaxPower.toDouble(),
                      min: 0,
                      max: widget.maxInverseMaxPower.toDouble(),
                      divisions: widget.maxInverseMaxPower ~/ 10,
                      label: '$_inverseMaxPower W',
                      onChanged: _onPowerSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0 W',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          '${widget.maxInverseMaxPower} W',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Precise input field
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
                    TextField(
                      controller: _powerController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: context.l10n.power,
                        suffixText: 'W',
                        helperText: context.l10n.helpPowerRange(widget.maxInverseMaxPower.toString()),
                        prefixIcon: const Icon(Icons.power_settings_new, color: Colors.blue),
                      ),
                      onChanged: _onPowerTextChanged,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grid Reverse Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sync_alt, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.sectionGridFeedback,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(
                          value: 0,
                          label: Text(context.l10n.segmentDisabled),
                          icon: const Icon(Icons.block),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text(context.l10n.segmentAllowed),
                          icon: const Icon(Icons.check_circle),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text(context.l10n.segmentForbidden),
                          icon: const Icon(Icons.cancel),
                        ),
                      ],
                      selected: {_gridReverse},
                      onSelectionChanged: (Set<int> selection) {
                        _onGridReverseChanged(selection.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.helpGridFeedbackDescription,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Grid Standard Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.public, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.sectionGridStandard,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(
                          value: 0,
                          label: Text(context.l10n.segmentGermany),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text(context.l10n.segmentFrance),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text(context.l10n.segmentAustria),
                        ),
                      ],
                      selected: {_gridStandard},
                      onSelectionChanged: (Set<int> selection) {
                        _onGridStandardChanged(selection.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.helpGridStandardDescription,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
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
