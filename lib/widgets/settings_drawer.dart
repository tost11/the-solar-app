import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/permission_utils.dart';
import '../utils/globals.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {

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
                const Text(
                  'Einstellungen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Berechtigungen'),
            subtitle: const Text('App-Berechtigungen prüfen'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              PermissionUtils.checkAndRequestPermissions(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text('Expertenmodus'),
            subtitle: const Text('Erweiterte Optionen anzeigen'),
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
            title: const Text(
              'App beenden',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
