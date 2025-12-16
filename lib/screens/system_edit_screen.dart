import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/models/system.dart';
import 'package:the_solar_app/models/system_device_reference.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import 'package:the_solar_app/services/system_storage_service.dart';
import 'package:the_solar_app/utils/message_utils.dart';

/// Screen for editing a system
///
/// Allows adding/removing devices and configuring their roles.
class SystemEditScreen extends StatefulWidget {
  final System system;

  const SystemEditScreen({
    super.key,
    required this.system,
  });

  @override
  State<SystemEditScreen> createState() => _SystemEditScreenState();
}

class _SystemEditScreenState extends State<SystemEditScreen> {
  final DeviceStorageService _deviceStorage = DeviceStorageService();
  final SystemStorageService _systemStorage = SystemStorageService();
  List<DeviceBase> _allDevices = [];
  bool _isLoading = true;
  late System _system;

  @override
  void initState() {
    super.initState();
    _system = widget.system;
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final devices = await _deviceStorage.getKnownDevices();
    setState(() {
      _allDevices = devices;
      _isLoading = false;
    });
  }

  Future<void> _addDevice() async {
    final selectedDevice = await _showDeviceSelectionDialog();
    if (selectedDevice == null) return;

    // Check if device has DeviceRoleConfig mixin
    if (selectedDevice is! DeviceRoleConfig) {
      MessageUtils.showError(context, 'Gerät hat keine Rollen-Konfiguration');
      return;
    }

    final roleConfig = selectedDevice as DeviceRoleConfig;
    final configurableRoles = roleConfig.getConfigurableRoles();
    final fixedRoles = roleConfig.getFixedRoles();

    List<DeviceRole> rolesToAdd = [];

    // Case 1: Device has configurable roles
    if (configurableRoles.isNotEmpty) {
      // Show selection dialog for configurable roles ONLY
      final selectedRole = await _showRoleSelectionDialog(configurableRoles);
      if (selectedRole == null) return;

      rolesToAdd = [selectedRole];
    }
    // Case 2: Device has only fixed roles (no configurable roles)
    else if (fixedRoles.isNotEmpty) {
      // Add ALL fixed roles automatically (no dialog)
      rolesToAdd = fixedRoles;
    }
    // Case 3: No roles available
    else {
      MessageUtils.showError(context, 'Gerät hat keine konfigurierbaren Rollen');
      return;
    }

    // Check if device already in system
    if (_system.deviceReferences.any((ref) => ref.deviceSn == selectedDevice.deviceSn)) {
      MessageUtils.showWarning(context, 'Gerät bereits im System');
      return;
    }

    // Add ONE device reference with ALL roles
    final newRef = SystemDeviceReference(
      deviceSn: selectedDevice.deviceSn,
      rolesInSystem: rolesToAdd,
    );

    setState(() {
      _system.deviceReferences.add(newRef);
      _system.updatedAt = DateTime.now();
    });

    await _systemStorage.saveSystem(_system);

    final roleNames = rolesToAdd.map((r) => r.displayName).join(', ');
    MessageUtils.showSuccess(
      context,
      'Gerät "${selectedDevice.name}" hinzugefügt mit Rolle(n): $roleNames',
    );
  }

  Future<void> _removeDevice(SystemDeviceReference ref) async {
    DeviceBase? device;
    try {
      device = _allDevices.firstWhere(
        (d) => d.deviceSn == ref.deviceSn,
      );
    } catch (e) {
      // Device not found
    }

    final roleNames = ref.rolesInSystem.map((r) => r.displayName).join(', ');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät entfernen'),
        content: Text(
          device != null
              ? 'Möchten Sie "${device.name}" mit ${ref.rolesInSystem.length} Rolle(n) ($roleNames) aus diesem System entfernen?'
              : 'Möchten Sie dieses Gerät mit ${ref.rolesInSystem.length} Rolle(n) ($roleNames) aus dem System entfernen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _system.deviceReferences.remove(ref);
        _system.updatedAt = DateTime.now();
      });

      await _systemStorage.saveSystem(_system);

      MessageUtils.showSuccess(context, 'Gerät entfernt');
    }
  }

  Future<DeviceBase?> _showDeviceSelectionDialog() async {
    return showDialog<DeviceBase>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät hinzufügen'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _allDevices.length,
            itemBuilder: (context, index) {
              final device = _allDevices[index];
              final alreadyAdded = _system.deviceReferences
                  .any((ref) => ref.deviceSn == device.deviceSn);

              return ListTile(
                leading: Icon(device.deviceIcon),
                title: Text(device.name),
                subtitle: Text('SN: ${device.deviceSn}'),
                enabled: !alreadyAdded,
                trailing: alreadyAdded
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: alreadyAdded
                    ? null
                    : () => Navigator.pop(context, device),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  Future<DeviceRole?> _showRoleSelectionDialog(List<DeviceRole> roles) async {
    return showDialog<DeviceRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rolle wählen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles.map((role) {
            return ListTile(
              title: Text(role.displayName),
              onTap: () => Navigator.pop(context, role),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${_system.name} bearbeiten')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_system.name} bearbeiten'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _system.deviceReferences.length + 1,
        itemBuilder: (context, index) {
          if (index == _system.deviceReferences.length) {
            // Add device button
            return Card(
              child: ListTile(
                leading: const Icon(Icons.add, color: Colors.green),
                title: const Text('Gerät hinzufügen'),
                onTap: _addDevice,
              ),
            );
          }

          final ref = _system.deviceReferences[index];
          DeviceBase? device;
          try {
            device = _allDevices.firstWhere(
              (d) => d.deviceSn == ref.deviceSn,
            );
          } catch (e) {
            // Device not found
          }

          if (device == null) {
            return Card(
              child: ListTile(
                title: Text('Gerät ${ref.deviceSn} nicht gefunden'),
                subtitle: Text('Rollen: ${ref.rolesInSystem.map((r) => r.displayName).join(', ')}'),
                leading: const Icon(Icons.error_outline, color: Colors.red),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeDevice(ref),
                ),
              ),
            );
          }

          return Card(
            child: ListTile(
              leading: Icon(device.deviceIcon),
              title: Text(device.name),
              subtitle: Text('Rollen: ${ref.rolesInSystem.map((r) => r.displayName).join(', ')}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeDevice(ref),
              ),
            ),
          );
        },
      ),
    );
  }
}
