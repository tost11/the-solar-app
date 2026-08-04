import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import '../../utils/message_utils.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/charts/historical_energy_bar_chart_card.dart';
import '../../widgets/charts/historical_power_chart_card.dart';
import 'base_command_screen.dart';

/// Screen showing Hoymiles historical data: the intraday power curve on top and
/// the daily energy history below.
///
/// While the screen is open, the power curve is refreshed every 30 seconds and
/// the daily energy history every 5 minutes.
class HoymilesHistoryScreen extends BaseCommandScreen {
  final String? inverterSerial;

  const HoymilesHistoryScreen({
    super.key,
    required super.device,
    super.additionalParams = const {},
    this.inverterSerial,
  });

  @override
  State<HoymilesHistoryScreen> createState() => _HoymilesHistoryScreenState();
}

class _HoymilesHistoryScreenState extends State<HoymilesHistoryScreen> {
  static const Duration _powerRefreshInterval = Duration(seconds: 30);
  static const Duration _energyRefreshInterval = Duration(minutes: 5);

  Timer? _powerTimer;
  Timer? _energyTimer;

  Map<String, dynamic>? _powerData;
  Map<String, dynamic>? _energyData;

  bool _loading = true;
  String? _error;

  Map<String, dynamic> get _params =>
      {if (widget.inverterSerial != null) 'inverterSerial': widget.inverterSerial};

  @override
  void initState() {
    super.initState();
    _initialLoad();
    _powerTimer = Timer.periodic(_powerRefreshInterval, (_) => _fetchPower());
    _energyTimer = Timer.periodic(_energyRefreshInterval, (_) => _fetchEnergy());
  }

  @override
  void dispose() {
    _powerTimer?.cancel();
    _energyTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future.wait([_fetchPower(), _fetchEnergy()]);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchPower() async {
    try {
      final result = await widget.sendCommandToDevice(COMMAND_FETCH_HIST_POWER, _params);
      if (!mounted || result == null) return;
      setState(() => _powerData = result);
    } catch (e) {
      // Keep previous data on transient errors; only surface via error banner
      // during the initial load.
      if (mounted && _loading) rethrow;
    }
  }

  Future<void> _fetchEnergy() async {
    try {
      final result = await widget.sendCommandToDevice(COMMAND_FETCH_HIST_ENERGY, _params);
      if (!mounted || result == null) return;
      setState(() => _energyData = result);
    } catch (e) {
      if (mounted && _loading) rethrow;
    }
  }

  Future<void> _manualRefresh() async {
    await _initialLoad();
    if (mounted && _error == null) {
      MessageUtils.showSuccess(context, context.l10n.historyRefreshed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenDeviceHistory,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
            onPressed: _loading ? null : _manualRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _manualRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading && _powerData == null && _energyData == null) ...[
                const SizedBox(height: 80),
                const Center(child: CircularProgressIndicator()),
              ] else ...[
                if (_error != null) ...[
                  _buildErrorBanner(),
                  const SizedBox(height: 16),
                ],
                HistoricalPowerChartCard(
                  title: context.l10n.historyPowerCurve,
                  data: _powerData,
                  emptyMessage: context.l10n.historyNoData,
                ),
                const SizedBox(height: 16),
                HistoricalEnergyBarChartCard(
                  title: context.l10n.historyDailyEnergy,
                  data: _energyData,
                  emptyMessage: context.l10n.historyNoData,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
