import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import '../../utils/globals.dart';
import '../../utils/debug_log.dart';
import '../../utils/message_utils.dart';
import '../../utils/localization_extension.dart';

class DebugSettingsScreen extends StatefulWidget {
  const DebugSettingsScreen({super.key});

  @override
  State<DebugSettingsScreen> createState() => _DebugSettingsScreenState();
}

class _DebugSettingsScreenState extends State<DebugSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _logScrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 1, vsync: this);

    // Listen for new log entries to auto-scroll
    DebugLog.logStream.listen((_) {
      if (_autoScroll && _logScrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logScrollController.hasClients) {
            _logScrollController.animateTo(
              _logScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    // Detect manual scroll (disable auto-scroll if user scrolls up)
    _logScrollController.addListener(() {
      if (_logScrollController.hasClients) {
        final atBottom = _logScrollController.position.pixels >=
            _logScrollController.position.maxScrollExtent - 50;
        if (_autoScroll != atBottom) {
          setState(() => _autoScroll = atBottom);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.loggingMenuTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Einstellungen'),
            Tab(icon: Icon(Icons.list_alt), text: 'Log-Anzeige'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTab(),
          _buildViewerTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1 && !_autoScroll
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              tooltip: 'Zum Ende scrollen',
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
  }

  Widget _buildSettingsTab() {
    return ValueListenableBuilder<String>(
      valueListenable: Globals.logLevelNotifier,
      builder: (context, logLevel, _) {
        return ValueListenableBuilder<Map<String, String>>(
          valueListenable: Globals.categoryLogLevelsNotifier,
          builder: (context, categoryLevels, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLogLevelSection(logLevel),
                const SizedBox(height: 24),
                _buildCategoriesSection(categoryLevels),
                const SizedBox(height: 24),
                _buildQuickSettingsSection(),
                const SizedBox(height: 24),
                _buildExportSection(),
                const SizedBox(height: 24),
                _buildStatusSection(logLevel, categoryLevels),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLogLevelSection(String currentLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log-Level',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: currentLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Keine')),
                DropdownMenuItem(value: 'error', child: Text('Fehler')),
                DropdownMenuItem(value: 'warning', child: Text('Warnung')),
                DropdownMenuItem(value: 'info', child: Text('Info')),
                DropdownMenuItem(value: 'debug', child: Text('Debug')),
                DropdownMenuItem(value: 'verbose', child: Text('Ausführlich')),
              ],
              onChanged: (value) {
                if (value != null) {
                  Globals.setLogLevel(value);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getLogLevelDescription(currentLevel),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _getLogLevelDescription(String level) {
    return switch (level) {
      'none' => 'Keine Logs werden aufgezeichnet',
      'error' => 'Nur Fehler werden protokolliert',
      'warning' => 'Fehler und Warnungen',
      'info' => 'Fehler, Warnungen und Informationen',
      'debug' => 'Alle wichtigen Ereignisse für Debugging',
      'verbose' => 'Maximale Details für umfassende Analyse',
      _ => '',
    };
  }

  Widget _buildCategoriesSection(Map<String, String> categoryLevels) {
    final categories = [
      ('bluetooth', 'Bluetooth'),
      ('network', 'Netzwerk'),
      ('device', 'Gerät'),
      ('storage', 'Speicher'),
      ('crypto', 'Verschlüsselung'),
      ('ui', 'Benutzeroberfläche'),
      ('system', 'System'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log-Kategorien',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Per-category dropdown
            ...categories.map((cat) {
              final currentLevel = categoryLevels[cat.$1] ?? 'default';
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(cat.$2),
                    ),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        value: currentLevel,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'default', child: Text('Von Standard')),
                          DropdownMenuItem(value: 'none', child: Text('Keine')),
                          DropdownMenuItem(value: 'error', child: Text('Fehler')),
                          DropdownMenuItem(value: 'warning', child: Text('Warnung')),
                          DropdownMenuItem(value: 'info', child: Text('Info')),
                          DropdownMenuItem(value: 'debug', child: Text('Debug')),
                          DropdownMenuItem(value: 'verbose', child: Text('Ausführlich')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            final newLevels = Map<String, String>.from(categoryLevels);
                            newLevels[cat.$1] = value;
                            Globals.setCategoryLogLevels(newLevels);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setAllCategories('default'),
                    child: const Text('Alle auf Standard'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setAllCategories('none'),
                    child: const Text('Alle deaktivieren'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setAllCategories(String level) {
    final categories = ['bluetooth', 'network', 'device', 'storage', 'crypto', 'ui', 'system'];
    final newLevels = Map<String, String>.fromIterable(
      categories,
      value: (_) => level,
    );
    Globals.setCategoryLogLevels(newLevels);
  }

  Widget _buildQuickSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schnelleinstellungen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _applyPreset('default'),
                icon: const Icon(Icons.restore),
                label: const Text('Standard wiederherstellen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyPreset(String preset) async {
    switch (preset) {
      case 'default':
        await Globals.setLogLevel('info');
        await Globals.setCategoryLogLevels({
          'bluetooth': 'default',
          'network': 'default',
          'device': 'default',
          'storage': 'default',
          'crypto': 'default',
          'ui': 'default',
          'system': 'default',
        });
        if (mounted) {
          MessageUtils.showSuccess(context, 'Standard-Einstellungen wiederhergestellt');
        }
        break;
    }
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log exportieren',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Logs werden direkt in eine Datei geschrieben und können für Fehlerberichte exportiert werden.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportCurrentLog,
                icon: const Icon(Icons.download),
                label: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aktuelles Log exportieren'),
                    Text(
                      'debug.log (aktuelle Sitzung)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportAllLogs,
                icon: const Icon(Icons.download),
                label: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alle Logs exportieren'),
                    Text(
                      'debug.log + letzte 3 Sitzungen (ZIP)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.delete),
                label: const Text('Alle Logs löschen'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCurrentLog() async {
    final logFile = await DebugLog.getCurrentLogFile();

    if (logFile == null) {
      if (mounted) {
        MessageUtils.showWarning(context, 'Keine Log-Datei vorhanden');
      }
      return;
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = 'thesolarapp_debug_$timestamp.log';

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Log-Datei speichern',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['log', 'txt'],
    );

    if (path != null) {
      await logFile.copy(path);
      if (mounted) {
        MessageUtils.showSuccess(context, 'Log erfolgreich exportiert');
      }
    }
  }

  Future<void> _exportAllLogs() async {
    final logFiles = await DebugLog.getAllLogFiles();

    if (logFiles.isEmpty) {
      if (mounted) {
        MessageUtils.showWarning(context, 'Keine Log-Dateien vorhanden');
      }
      return;
    }

    // Create ZIP archive
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final zipFilename = 'thesolarapp_debug_all_$timestamp.zip';

    final archive = Archive();

    for (final logFile in logFiles) {
      final bytes = await logFile.readAsBytes();
      final filename = logFile.path.split('/').last;
      archive.addFile(ArchiveFile(filename, bytes.length, bytes));
    }

    final zipData = ZipEncoder().encode(archive);

    if (zipData == null) {
      if (mounted) {
        MessageUtils.showError(context, 'Fehler beim Erstellen des ZIP-Archivs');
      }
      return;
    }

    // Save ZIP file
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Log-Archiv speichern',
      fileName: zipFilename,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (path != null) {
      await File(path).writeAsBytes(zipData);
      if (mounted) {
        MessageUtils.showSuccess(context, 'Alle Logs exportiert (${logFiles.length} Dateien)');
      }
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle Logs löschen?'),
        content: const Text(
          'Dies löscht alle gespeicherten Log-Dateien unwiderruflich. '
          'Möchten Sie fortfahren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DebugLog.clearLogs();
      setState(() {}); // Refresh status info
      if (mounted) {
        MessageUtils.showSuccess(context, 'Alle Logs gelöscht');
      }
    }
  }

  Widget _buildStatusSection(String logLevel, Map<String, String> categoryLevels) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _getLogStatus(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final status = snapshot.data!;
                final currentSizeMB =
                    (status['currentSize'] / 1024 / 1024).toStringAsFixed(2);
                final totalSizeMB =
                    (status['totalSize'] / 1024 / 1024).toStringAsFixed(2);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Globales Level: ${_getLevelLabel(logLevel)}'),
                    const SizedBox(height: 12),
                    Text(
                      'Kategorie-Levels:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._buildCategoryStatusList(categoryLevels),
                    const SizedBox(height: 12),
                    Text('Aktuelle Log-Datei: $currentSizeMB MB'),
                    const SizedBox(height: 8),
                    Text('Gesamt (${status['fileCount']} Dateien): $totalSizeMB MB'),
                    const SizedBox(height: 8),
                    Text('Im Puffer: ${DebugLog.recentLogs.length} Einträge'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryStatusList(Map<String, String> categoryLevels) {
    final categoryNames = {
      'bluetooth': 'Bluetooth',
      'network': 'Netzwerk',
      'device': 'Gerät',
      'storage': 'Speicher',
      'crypto': 'Verschlüsselung',
      'ui': 'Benutzeroberfläche',
      'system': 'System',
    };

    return categoryNames.entries.map((entry) {
      final level = categoryLevels[entry.key] ?? 'default';
      final displayLevel = level == 'default' 
          ? 'Von Standard' 
          : _getLevelLabel(level);
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const Text('  • ', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Text(
                '${entry.value}: $displayLevel',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getLevelLabel(String level) {
    return switch (level) {
      'none' => 'Keine',
      'error' => 'Fehler',
      'warning' => 'Warnung',
      'info' => 'Info',
      'debug' => 'Debug',
      'verbose' => 'Ausführlich',
      _ => level,
    };
  }

  Future<Map<String, dynamic>> _getLogStatus() async {
    final logFiles = await DebugLog.getAllLogFiles();

    int totalSize = 0;
    int currentSize = 0;

    for (final file in logFiles) {
      final size = await file.length();
      totalSize += size;
      if (file.path.endsWith('debug.log')) {
        currentSize = size;
      }
    }

    return {
      'fileCount': logFiles.length,
      'currentSize': currentSize,
      'totalSize': totalSize,
    };
  }

  Widget _buildViewerTab() {
    return Column(
      children: [
        // Info banner if logging disabled
        if (Globals.logLevel == 'none')
          MaterialBanner(
            content: const Text(
              'Logging ist deaktiviert. Aktivieren Sie ein Log-Level in den Einstellungen.',
            ),
            actions: [
              TextButton(
                onPressed: () => _tabController.animateTo(0),
                child: const Text('Zu Einstellungen'),
              ),
            ],
          ),

        // Log list
        Expanded(
          child: StreamBuilder<LogEntry>(
            stream: DebugLog.logStream,
            builder: (context, snapshot) {
              final logs = DebugLog.recentLogs;

              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Keine Log-Einträge vorhanden',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Logs erscheinen hier in Echtzeit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _logScrollController,
                padding: const EdgeInsets.all(8),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final entry = logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: SelectableText(
                      entry.formatted,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: entry.color,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Bottom info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Text(
                '${DebugLog.recentLogs.length} Einträge (letzte 100)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (_autoScroll)
                const Chip(
                  label: Text('Auto-Scroll', style: TextStyle(fontSize: 11)),
                  avatar: Icon(Icons.arrow_downward, size: 14),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _scrollToBottom() {
    if (_logScrollController.hasClients) {
      _logScrollController.animateTo(
        _logScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _autoScroll = true);
    }
  }
}
