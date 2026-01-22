import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/localization_extension.dart';
import '../utils/url_utils.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';

/// Screen displaying app information (version, git hash, links)
class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  PackageInfo? _packageInfo;

  // Git hash from build-time constant
  static const String gitHash = String.fromEnvironment('GIT_HASH', defaultValue: 'unknown');

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.messageCopiedToClipboard)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(title: context.l10n.screenAppInfo),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Icon and Name
          Center(
            child: Column(
              children: [
                Icon(Icons.solar_power, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text('The Solar App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Version Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.version, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${_packageInfo?.version ?? '...'} (Build ${_packageInfo?.buildNumber ?? '...'})'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Git Hash Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Git Commit', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gitHash,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(gitHash),
                        tooltip: context.l10n.buttonCopy,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Links Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Links', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('GitHub Repository'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => UrlUtils.openUrl(context, 'https://github.com/tost11/the-solar-app'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.system_update),
                    title: const Text('Updates & Releases'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => UrlUtils.openUrl(context, 'https://github.com/tost11/the-solar-app/releases'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
