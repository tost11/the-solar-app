import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/localization_extension.dart';
import '../utils/permission_utils.dart';
import '../utils/globals.dart';
import '../screens/app_info_screen.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  PackageInfo? _packageInfo;

  // Git hash from build-time constant
  static const String gitHashShort = String.fromEnvironment('GIT_HASH_SHORT', defaultValue: 'dev');

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.settings,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(context.l10n.permissions),
            subtitle: Text(context.l10n.permissionsDescription),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              PermissionUtils.checkAndRequestPermissions(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.l10n.language),
            subtitle: Text(context.l10n.languageDescription),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Globals.languageNotifier.value.languageCode == 'de'
                      ? context.l10n.german
                      : context.l10n.english,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () {
                    final currentLanguage = Globals.languageNotifier.value.languageCode;
                    final newLanguage = currentLanguage == 'de' ? 'en' : 'de';
                    Globals.setLanguage(newLanguage);
                  },
                  tooltip: 'Switch language',
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: Text(context.l10n.expertMode),
            subtitle: Text(context.l10n.expertModeDescription),
            trailing: Switch(
              value: Globals.expertMode,
              onChanged: (bool value) async {
                await Globals.setExpertMode(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: Text(
              context.l10n.exitApp,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              _packageInfo != null
                ? '${context.l10n.version}: v${_packageInfo!.version} ($gitHashShort)'
                : '${context.l10n.version}: ...',
            ),
            subtitle: Text(context.l10n.tapForDetails),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInfoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
