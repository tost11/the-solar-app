import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_solar_app/constants/command_constants.dart';

import '../../utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import 'base_command_screen.dart';

enum LimitMode {
  input,  // Taking power from grid
  output, // Giving power to grid
}

class PowerScreen extends BaseCommandScreen {
  final int currentInputLimit;
  final int currentOutputLimit;
  final int maxInputLimit;
  final int maxOutputLimit;
  final LimitMode currentLimitMode;

  const PowerScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    required this.currentInputLimit,
    required this.currentOutputLimit,
    required this.maxInputLimit,
    required this.maxOutputLimit,
    required this.currentLimitMode,
  });

  @override
  State<PowerScreen> createState() => _PowerScreenState();
}

class _PowerScreenState extends State<PowerScreen> {
  late LimitMode _selectedMode = widget.currentLimitMode;
  late int _currentValue;
  late TextEditingController _textController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize mode: prefer output if input is disabled
    if (widget.currentInputLimit <= 0) {
      _selectedMode = LimitMode.output;
      _currentValue = widget.currentOutputLimit;
    } else {
      _currentValue = widget.currentInputLimit;
    }

    _textController = TextEditingController(text: _currentValue.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isInputDisabled => widget.maxInputLimit <= 0;

  int get _maxValue {
    return _selectedMode == LimitMode.input
        ? widget.maxInputLimit
        : widget.maxOutputLimit;
  }

  void _onModeChanged(LimitMode? newMode) {
    if (newMode == null || newMode == _selectedMode) return;

    setState(() {
      _selectedMode = newMode;
      // Switch to the appropriate current value
      _currentValue = _selectedMode == LimitMode.input
          ? widget.currentInputLimit
          : widget.currentOutputLimit;
      _textController.text = _currentValue.toString();
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentValue = value.round();
      _textController.text = _currentValue.toString();
    });
  }

  void _onTextChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue >= 0 && intValue <= _maxValue) {
      setState(() {
        _currentValue = intValue;
      });
    }
  }

  Future<void> _saveLimitSetting() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare command based on mode
      final command = <String, dynamic>{};
      command['inputLimit'] = _currentValue;
      command['outputLimit'] = _currentValue;
      command['acMode'] = _selectedMode ==  LimitMode.input ? 1 : 2;

      // Send command to device
      await widget.sendCommandToDevice(COMMAND_SET_LIMIT,command);

      if (mounted) {
        // Show success message
        MessageUtils.showSuccess(
          context,
          context.l10n.messagePowerLimitSetWithValue(_currentValue.toString()),
        );

        // Return to previous screen with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        MessageUtils.showError(context, context.l10n.errorSettingPowerLimit(e.toString()));
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
        title: context.l10n.screenPower,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode selection toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sectionAdjustLimit,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<LimitMode>(
                      segments: [
                        ButtonSegment<LimitMode>(
                          value: LimitMode.input,
                          label: Text(context.l10n.labelPowerInput),
                          icon: const Icon(Icons.arrow_downward),
                          enabled: !_isInputDisabled,
                        ),
                        ButtonSegment<LimitMode>(
                          value: LimitMode.output,
                          label: Text(context.l10n.labelPowerOutput),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_selectedMode},
                      onSelectionChanged: (Set<LimitMode> selection) {
                        _onModeChanged(selection.first);
                      },
                    ),
                    if (_isInputDisabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          context.l10n.sectionAdjustLimit,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Current value display
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _currentValue.toString(),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'W',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sectionAdjustLimit,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _currentValue.toDouble(),
                      min: 0,
                      max: _maxValue.toDouble(),
                      divisions: _maxValue > 0 ? _maxValue ~/ 10 : 1,
                      label: '$_currentValue W',
                      onChanged: _onSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0 W',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          '$_maxValue W',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Text field for precise input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sectionAdjustLimit,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: context.l10n.labelPowerInWatts,
                        suffixText: 'W',
                        helperText: '${context.l10n.helpPowerRange}: 0 - $_maxValue W',
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveLimitSetting,
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
