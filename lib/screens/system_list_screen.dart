import 'package:flutter/material.dart';
import 'package:the_solar_app/models/system.dart';
import 'package:the_solar_app/services/system_storage_service.dart';
import 'package:the_solar_app/screens/system_detail_screen.dart';
import 'package:the_solar_app/screens/system_edit_screen.dart';
import 'package:uuid/uuid.dart';

/// System list screen showing all configured systems
///
/// Replaces the current SystemHomeScreen in the "System" tab.
/// Shows a list of all systems with FAB to create new system.
class SystemListScreen extends StatefulWidget {
  final bool isExpanded;

  const SystemListScreen({
    super.key,
    this.isExpanded = true,
  });

  @override
  State<SystemListScreen> createState() => _SystemListScreenState();
}

class _SystemListScreenState extends State<SystemListScreen> {
  final SystemStorageService _storageService = SystemStorageService();
  List<System> _systems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystems();
  }

  Future<void> _loadSystems() async {
    setState(() => _isLoading = true);
    final systems = await _storageService.getAllSystems();
    setState(() {
      _systems = systems;
      _isLoading = false;
    });
  }

  Future<void> _createNewSystem() async {
    // Show dialog to enter system name
    final name = await _showNameDialog(context, 'Neues System erstellen');
    if (name == null || name.isEmpty) return;

    // Create new system
    final newSystem = System(
      id: const Uuid().v4(),
      name: name,
      deviceReferences: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.saveSystem(newSystem);
    await _loadSystems();

    // Navigate to edit screen to add devices
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SystemEditScreen(system: newSystem),
        ),
      ).then((_) => _loadSystems());
    }
  }

  Future<void> _deleteSystem(System system) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System löschen'),
        content: Text('Möchten Sie "${system.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteSystem(system.id);
      await _loadSystems();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_systems.isEmpty) {
      // Show empty state only when expanded
      if (widget.isExpanded) {
        return _buildEmptyState();
      } else {
        // When collapsed and empty, show nothing
        return const SizedBox.shrink();
      }
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _systems.length,
        itemBuilder: (context, index) {
          final system = _systems[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(system.name),
              subtitle: Text('${system.deviceReferences.length} Geräte'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteSystem(system),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SystemDetailScreen(system: system),
                  ),
                ).then((_) => _loadSystems());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Keine Systeme', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Erstellen Sie Ihr erstes System'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewSystem,
            icon: const Icon(Icons.add),
            label: const Text('System erstellen'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showNameDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'System-Name',
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }
}
