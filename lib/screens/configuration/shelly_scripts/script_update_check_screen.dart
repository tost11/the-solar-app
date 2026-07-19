import 'package:flutter/material.dart';
import '../../../models/shelly_script_template.dart';
import '../../../services/script_template_service.dart';
import '../../../utils/globals.dart';
import '../../../utils/localization_extension.dart';
import '../../../utils/message_utils.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/app_scaffold.dart';

/// Screen for checking and installing script template updates from remote repository.
///
/// Split into two tabs:
/// - "Official" tab: Checks the global manifest for built-in template updates (auto-check on load)
/// - "Custom" tab: Lists user-imported templates with updatePath for per-template opt-in update checks
class ScriptUpdateCheckScreen extends StatefulWidget {
  const ScriptUpdateCheckScreen({super.key});

  @override
  State<ScriptUpdateCheckScreen> createState() =>
      _ScriptUpdateCheckScreenState();
}

class _ScriptUpdateCheckScreenState extends State<ScriptUpdateCheckScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // === Tab 1 (Official) state ===
  List<RemoteUpdateInfo>? _updates;
  bool _isChecking = false;
  bool _isInstalling = false;
  final Set<String> _installingIds = {};
  final Set<String> _installedIds = {};
  final Map<String, String> _errorIds = {};

  // === Tab 2 (Custom) state ===
  List<ShellyScriptTemplate> _customTemplates = [];
  bool _isLoadingCustom = true;
  final Set<String> _checkingCustomIds = {};
  final Map<String, RemoteUpdateInfo> _customUpdateResults = {};
  final Set<String> _customUpToDateIds = {};
  final Set<String> _customInstallingIds = {};
  final Set<String> _customInstalledIds = {};
  final Map<String, String> _customErrorIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkForUpdates();
    _loadCustomTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== Tab 1 (Official) Methods =====

  /// Check for available remote updates from global manifest
  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _updates = null;
      _installedIds.clear();
      _errorIds.clear();
    });

    final updates = await ScriptTemplateService.checkForRemoteUpdates();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _updates = updates;
    });

    if (updates == null) {
      MessageUtils.showError(context, context.l10n.scriptUpdatesErrorNetwork);
    }
  }

  /// Install a single official update
  Future<void> _installUpdate(RemoteUpdateInfo update) async {
    setState(() {
      _installingIds.add(update.templateId);
      _errorIds.remove(update.templateId);
    });

    final result = await ScriptTemplateService.installRemoteUpdate(update);

    if (!mounted) return;

    setState(() {
      _installingIds.remove(update.templateId);
      if (result != null) {
        _installedIds.add(update.templateId);
      } else {
        _errorIds[update.templateId] = context.l10n.scriptUpdatesErrorInvalid;
      }
    });
  }

  /// Install all available official updates
  Future<void> _installAllUpdates() async {
    if (_updates == null || _updates!.isEmpty) return;

    setState(() => _isInstalling = true);

    int successCount = 0;
    for (final update in _updates!) {
      if (_installedIds.contains(update.templateId)) continue;

      setState(() {
        _installingIds.add(update.templateId);
        _errorIds.remove(update.templateId);
      });

      final result = await ScriptTemplateService.installRemoteUpdate(update);

      if (!mounted) return;

      setState(() {
        _installingIds.remove(update.templateId);
        if (result != null) {
          _installedIds.add(update.templateId);
          successCount++;
        } else {
          _errorIds[update.templateId] = context.l10n.scriptUpdatesErrorInvalid;
        }
      });
    }

    if (!mounted) return;

    setState(() => _isInstalling = false);

    if (successCount > 0) {
      MessageUtils.showSuccess(
        context,
        context.l10n.scriptUpdatesSuccess(successCount),
      );
    }
  }

  // ===== Tab 2 (Custom) Methods =====

  /// Load custom templates that have an updatePath configured
  Future<void> _loadCustomTemplates() async {
    final templates =
        await ScriptTemplateService.getCustomUpdatableTemplates();

    if (!mounted) return;

    setState(() {
      _customTemplates = templates;
      _isLoadingCustom = false;
    });
  }

  /// Check for update of a single custom template
  Future<void> _checkCustomUpdate(ShellyScriptTemplate template) async {
    setState(() {
      _checkingCustomIds.add(template.id);
      _customErrorIds.remove(template.id);
      _customUpdateResults.remove(template.id);
      _customUpToDateIds.remove(template.id);
    });

    try {
      final updateInfo =
          await ScriptTemplateService.checkForSingleTemplateUpdate(template);

      if (!mounted) return;

      setState(() {
        _checkingCustomIds.remove(template.id);
        if (updateInfo != null) {
          _customUpdateResults[template.id] = updateInfo;
        } else {
          _customUpToDateIds.add(template.id);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _checkingCustomIds.remove(template.id);
        _customErrorIds[template.id] =
            context.l10n.scriptUpdatesErrorNetwork;
      });
    }
  }

  /// Install update for a single custom template
  Future<void> _installCustomUpdate(RemoteUpdateInfo update) async {
    setState(() {
      _customInstallingIds.add(update.templateId);
      _customErrorIds.remove(update.templateId);
    });

    final result = await ScriptTemplateService.installRemoteUpdate(update);

    if (!mounted) return;

    setState(() {
      _customInstallingIds.remove(update.templateId);
      if (result != null) {
        _customInstalledIds.add(update.templateId);
        _customUpdateResults.remove(update.templateId);
      } else {
        _customErrorIds[update.templateId] =
            context.l10n.scriptUpdatesErrorInvalid;
      }
    });
  }

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.scriptUpdatesTitle,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.system_update),
              text: context.l10n.scriptUpdatesTabOfficial,
            ),
            Tab(
              icon: const Icon(Icons.person),
              text: context.l10n.scriptUpdatesTabCustom,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfficialTab(),
          _buildCustomTab(),
        ],
      ),
    );
  }

  // ===== Tab 1: Official Updates =====

  Widget _buildOfficialTab() {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.sync),
          title: Text(context.l10n.autoScriptUpdate),
          value: Globals.autoScriptUpdate,
          onChanged: (bool value) async {
            await Globals.setAutoScriptUpdate(value);
            setState(() {});
          },
        ),
        const Divider(height: 1),
        Expanded(child: _buildOfficialTabContent()),
      ],
    );
  }

  Widget _buildOfficialTabContent() {
    if (_isChecking) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(context.l10n.scriptUpdatesChecking),
          ],
        ),
      );
    }

    if (_updates == null) {
      // Network error state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.scriptUpdatesErrorNetwork,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkForUpdates,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.scriptUpdatesCheckButton),
            ),
          ],
        ),
      );
    }

    if (_updates!.isEmpty) {
      // All up to date
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.scriptUpdatesNoUpdates,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkForUpdates,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.scriptUpdatesCheckButton),
            ),
          ],
        ),
      );
    }

    // Updates available
    final pendingUpdates = _updates!
        .where((u) => !_installedIds.contains(u.templateId))
        .toList();

    return Column(
      children: [
        // Header with update count and "Update All" button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.system_update, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.scriptUpdatesAvailable(_updates!.length),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (pendingUpdates.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _isInstalling ? null : _installAllUpdates,
                  icon: _isInstalling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(context.l10n.scriptUpdatesUpdateAll),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // List of updates
        Expanded(
          child: ListView.separated(
            itemCount: _updates!.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _buildOfficialUpdateTile(_updates![index]),
          ),
        ),
        // Refresh button at bottom
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isChecking ? null : _checkForUpdates,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.scriptUpdatesCheckButton),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialUpdateTile(RemoteUpdateInfo update) {
    final isInstalling = _installingIds.contains(update.templateId);
    final isInstalled = _installedIds.contains(update.templateId);
    final error = _errorIds[update.templateId];

    return ListTile(
      leading: _buildStatusIcon(update, isInstalling, isInstalled, error),
      title: Text(
        update.templateId,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: _buildVersionInfo(update, isInstalled, error),
      trailing: _buildActionButton(update, isInstalling, isInstalled),
    );
  }

  Widget _buildStatusIcon(
    RemoteUpdateInfo update,
    bool isInstalling,
    bool isInstalled,
    String? error,
  ) {
    if (isInstalling) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (isInstalled) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (error != null) {
      return const Icon(Icons.error, color: Colors.red);
    }
    if (update.isNewTemplate) {
      return const Icon(Icons.add_circle_outline, color: Colors.blue);
    }
    return Icon(Icons.system_update, color: Colors.orange[700]);
  }

  Widget _buildVersionInfo(
    RemoteUpdateInfo update,
    bool isInstalled,
    String? error,
  ) {
    if (error != null) {
      return Text(error, style: const TextStyle(color: Colors.red));
    }
    if (isInstalled) {
      return Text(
        context.l10n.scriptUpdatesUpToDate,
        style: const TextStyle(color: Colors.green),
      );
    }

    final localText = update.localVersion != null
        ? context.l10n.scriptUpdatesCurrentVersion(update.localVersion!)
        : context.l10n.scriptUpdatesNotInstalled;
    final remoteText =
        context.l10n.scriptUpdatesNewVersion(update.remoteVersion);

    return Text('$localText\n$remoteText');
  }

  Widget? _buildActionButton(
    RemoteUpdateInfo update,
    bool isInstalling,
    bool isInstalled,
  ) {
    if (isInstalled) return null;
    if (isInstalling) return null;

    return TextButton(
      onPressed: () => _installUpdate(update),
      child: Text(
        update.isNewTemplate
            ? context.l10n.scriptUpdatesInstall
            : context.l10n.update,
      ),
    );
  }

  // ===== Tab 2: Custom Templates =====

  Widget _buildCustomTab() {
    if (_isLoadingCustom) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_customTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                context.l10n.scriptUpdatesCustomEmpty,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _customTemplates.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _buildCustomTemplateTile(_customTemplates[index]),
    );
  }

  Widget _buildCustomTemplateTile(ShellyScriptTemplate template) {
    final isChecking = _checkingCustomIds.contains(template.id);
    final updateInfo = _customUpdateResults[template.id];
    final isUpToDate = _customUpToDateIds.contains(template.id);
    final isInstalling = _customInstallingIds.contains(template.id);
    final isInstalled = _customInstalledIds.contains(template.id);
    final error = _customErrorIds[template.id];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template name and version
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.scriptUpdatesCurrentVersion(template.version),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.scriptUpdatesCustomSource(
                        _truncateUrl(template.updatePath!),
                      ),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildCustomActionArea(
                template,
                isChecking: isChecking,
                updateInfo: updateInfo,
                isUpToDate: isUpToDate,
                isInstalling: isInstalling,
                isInstalled: isInstalled,
                error: error,
              ),
            ],
          ),
          // Result row (shown after checking)
          if (updateInfo != null && !isInstalled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.system_update, color: Colors.orange[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.scriptUpdatesNewVersion(updateInfo.remoteVersion),
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                  if (!isInstalling)
                    ElevatedButton(
                      onPressed: () => _installCustomUpdate(updateInfo),
                      child: Text(context.l10n.update),
                    ),
                  if (isInstalling)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          if (isInstalled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.scriptUpdatesUpToDate,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomActionArea(
    ShellyScriptTemplate template, {
    required bool isChecking,
    required RemoteUpdateInfo? updateInfo,
    required bool isUpToDate,
    required bool isInstalling,
    required bool isInstalled,
    required String? error,
  }) {
    if (isChecking) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isUpToDate && updateInfo == null && !isInstalled) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (isInstalled) {
      return const SizedBox.shrink();
    }

    // Show check button if not yet checked, or if there was an error (allow retry)
    if (updateInfo == null) {
      return OutlinedButton.icon(
        onPressed: () => _checkCustomUpdate(template),
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(context.l10n.scriptUpdatesCheckSingle),
      );
    }

    return const SizedBox.shrink();
  }

  /// Truncate a URL for display (show domain + last path segment)
  String _truncateUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (pathSegments.length > 2) {
        return '$host/.../${pathSegments.last}';
      }
      return '$host/${pathSegments.join('/')}';
    } catch (_) {
      if (url.length > 50) {
        return '${url.substring(0, 47)}...';
      }
      return url;
    }
  }
}
