import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart';

/// Log levels for debug logging
enum LogLevel {
  none(0),
  error(1),
  warning(2),
  info(3),
  debug(4),
  verbose(5);

  const LogLevel(this.value);
  final int value;

  static LogLevel fromString(String level) {
    return switch (level.toLowerCase()) {
      'error' => LogLevel.error,
      'warning' => LogLevel.warning,
      'info' => LogLevel.info,
      'debug' => LogLevel.debug,
      'verbose' => LogLevel.verbose,
      _ => LogLevel.none,
    };
  }
}

/// Individual log entry
class LogEntry {
  final DateTime timestamp;
  final String category;
  final String level;
  final String message;

  const LogEntry({
    required this.timestamp,
    required this.category,
    required this.level,
    required this.message,
  });

  /// Formatted output: [15:42:31.234][BLUETOOTH][DEBUG] Message
  String get formatted =>
      '${_formatTimestamp(timestamp)}[$category][$level] $message';

  /// Color for UI rendering based on log level
  Color get color => switch (level.toLowerCase()) {
        'error' => Colors.red,
        'warning' => Colors.orange,
        'info' => Colors.blue,
        'debug' => Colors.grey,
        'verbose' => Colors.grey.shade400,
        _ => Colors.black,
      };

  static String _formatTimestamp(DateTime dt) {
    return '[${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.'
        '${dt.millisecond.toString().padLeft(3, '0')}]';
  }
}

/// Centralized debug logging system with file persistence and RAM buffer
class DebugLog {
  // File handles
  static File? _logFile;
  static IOSink? _logSink;
  static int _writeCount = 0;

  // RAM buffer for viewer (last 100 entries)
  static final List<LogEntry> _recentLogs = [];
  static const int _recentLogsSize = 100;

  // Stream for real-time viewer updates
  static final StreamController<LogEntry> _logStreamController =
      StreamController<LogEntry>.broadcast();

  static Stream<LogEntry> get logStream => _logStreamController.stream;
  static List<LogEntry> get recentLogs => List.unmodifiable(_recentLogs);

  // Configuration
  static const int _maxLogFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int _maxRotatedLogs = 3; // Keep debug.log.1 through debug.log.3

  /// Initialize logging system - creates/opens log file
  static Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/debug.log');

      // Open file for appending (create if doesn't exist)
      _logSink = _logFile!.openWrite(mode: FileMode.append);

      // Write session header
      _logSink!.writeln('');
      _logSink!.writeln('═══════════════════════════════════════════════════════════════');
      _logSink!.writeln('App Session Started: ${DateTime.now().toIso8601String()}');
      _logSink!.writeln('Global Log Level: ${Globals.logLevel}');
      _logSink!.writeln('Category Levels:');
      for (final entry in Globals.categoryLogLevels.entries) {
        final effectiveLevel = entry.value == 'default' ? Globals.logLevel : entry.value;
        _logSink!.writeln('  ${entry.key}: ${entry.value} (effective: $effectiveLevel)');
      }
      _logSink!.writeln('═══════════════════════════════════════════════════════════════');
      _logSink!.writeln('');
      await _logSink!.flush();
    } catch (e) {
      debugPrint('Failed to initialize debug log: $e');
    }
  }

  /// Dispose logging system - flush and close file
  static Future<void> dispose() async {
    try {
      // Null out sink FIRST to prevent concurrent _log() calls from
      // interfering during async flush/close operations
      final sinkToClose = _logSink;
      _logSink = null;
      _logFile = null;

      if (sinkToClose != null) {
        sinkToClose.writeln('');
        sinkToClose.writeln('App Session Ended: ${DateTime.now().toIso8601String()}');
        await sinkToClose.flush();
        await sinkToClose.close();
      }
    } catch (e) {
      debugPrint('Failed to dispose debug log: $e');
    }
  }

  // Category-specific logging methods
  static void bluetooth(String message, {LogLevel level = LogLevel.debug}) {
    _log('bluetooth', message, level);
  }

  static void network(String message, {LogLevel level = LogLevel.debug}) {
    _log('network', message, level);
  }

  static void device(String message, {LogLevel level = LogLevel.debug}) {
    _log('device', message, level);
  }

  static void storage(String message, {LogLevel level = LogLevel.debug}) {
    _log('storage', message, level);
  }

  static void crypto(String message, {LogLevel level = LogLevel.debug}) {
    _log('crypto', message, level);
  }

  static void ui(String message, {LogLevel level = LogLevel.debug}) {
    _log('ui', message, level);
  }

  static void system(String message, {LogLevel level = LogLevel.debug}) {
    _log('system', message, level);
  }

  // Level-specific shortcuts
  static void error(String message, {String? category}) {
    _log(category ?? 'general', message, LogLevel.error);
  }

  static void warning(String message, {String? category}) {
    _log(category ?? 'general', message, LogLevel.warning);
  }

  static void info(String message, {String? category}) {
    _log(category ?? 'general', message, LogLevel.info);
  }

  /// Get effective log level for a category (resolves 'default' to global level)
  /// Returns the actual log level string that will be used for filtering
  static String getEffectiveLogLevel(String category) {
    final categoryLevel = Globals.categoryLogLevels[category] ?? 'default';
    return categoryLevel == 'default' ? Globals.logLevel : categoryLevel;
  }

  /// Core logging logic - writes to file and RAM buffer
  ///
  /// GUARANTEE: This method will NEVER throw an exception to the caller.
  /// The logging framework must never interfere with application logic.
  static void _log(String category, String message, LogLevel level) {
    try {
      // Check if log file is initialized
      if (_logSink == null) return;

      // Get category-specific log level (fallback to 'default' if not set)
      final categoryLevelStr = Globals.categoryLogLevels[category] ?? 'default';
      
      // Resolve 'default' to global log level
      final effectiveLevel = categoryLevelStr == 'default'
          ? Globals.logLevel
          : categoryLevelStr;
      
      // Special case: 'none' disables category completely
      if (effectiveLevel == 'none') return;
      
      // Check if this log level should be recorded
      final categoryLogLevel = LogLevel.fromString(effectiveLevel);
      if (level.value > categoryLogLevel.value) return;

      // Create log entry
      final entry = LogEntry(
        timestamp: DateTime.now(),
        category: category.toUpperCase(),
        level: level.name.toUpperCase(),
        message: message,
      );

      // Write to file (buffered)
      final sink = _logSink;
      if (sink != null) {
        try {
          sink.writeln(entry.formatted);
        } catch (e) {
          debugPrint('Failed to write to log file: $e');
        }
      }

      // Add to RAM buffer (circular - remove oldest if full)
      _recentLogs.add(entry);
      if (_recentLogs.length > _recentLogsSize) {
        _recentLogs.removeAt(0);
      }

      // Emit stream event (for real-time viewer)
      if (!_logStreamController.isClosed) {
        _logStreamController.add(entry);
      }

      // Also output to debugPrint (IDE console in debug mode)
      if (kDebugMode) {
        debugPrint(entry.formatted);
      }

      // Periodic rotation check (no explicit flush - IOSink handles buffering)
      // Note: We avoid calling flush() here because it puts the IOSink into
      // a "bound to stream" state where subsequent writeln() calls throw.
      _writeCount++;
      if (_writeCount % 100 == 0) {
        _checkRotation();
      }
    } catch (e) {
      // NEVER propagate logging errors to application code
      debugPrint('DebugLog internal error: $e');
    }
  }

  /// Check if log file needs rotation and rotate if necessary
  static Future<void> _checkRotation() async {
    try {
      final fileSize = await _logFile?.length() ?? 0;
      if (fileSize <= _maxLogFileSizeBytes) return;

      await _rotateLogFiles();
    } catch (e) {
      debugPrint('Failed to check log rotation: $e');
    }
  }

  /// Rotate log files: current → .1, .1 → .2, .2 → .3, delete .3
  static Future<void> _rotateLogFiles() async {
    try {
      // Null out sink FIRST to prevent concurrent _log() calls from writing
      // to a closed sink during the async rotation operations
      final sinkToClose = _logSink;
      _logSink = null;
      await sinkToClose?.close();

      final dir = await getApplicationDocumentsDirectory();
      final basePath = '${dir.path}/debug.log';

      // Delete oldest (debug.log.3)
      final oldestFile = File('$basePath.3');
      if (await oldestFile.exists()) {
        await oldestFile.delete();
      }

      // Shift files: .2→.3, .1→.2
      for (int i = _maxRotatedLogs - 1; i >= 1; i--) {
        final oldFile = File('$basePath.$i');
        if (await oldFile.exists()) {
          await oldFile.rename('$basePath.${i + 1}');
        }
      }

      // Current → .1
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.rename('$basePath.1');
      }

      // Create new log file and re-enable logging
      _logFile = File(basePath);
      _logSink = _logFile!.openWrite(mode: FileMode.writeOnly);

      // Write rotation notice
      _logSink!.writeln('');
      _logSink!.writeln('═══════════════════════════════════════════════════════════════');
      _logSink!.writeln('Log Rotated: ${DateTime.now().toIso8601String()}');
      _logSink!.writeln('Previous log moved to debug.log.1');
      _logSink!.writeln('═══════════════════════════════════════════════════════════════');
      _logSink!.writeln('');
      await _logSink!.flush();
    } catch (e) {
      debugPrint('Failed to rotate log files: $e');
    }
  }

  /// Get current log file for export
  static Future<File?> getCurrentLogFile() async {
    try {
      await _logSink?.flush();
      if (_logFile != null && await _logFile!.exists()) {
        return _logFile;
      }
    } catch (e) {
      debugPrint('Failed to get current log file: $e');
    }
    return null;
  }

  /// Get all log files (current + rotated) for export
  static Future<List<File>> getAllLogFiles() async {
    try {
      await _logSink?.flush();

      final files = <File>[];
      final dir = await getApplicationDocumentsDirectory();
      final basePath = '${dir.path}/debug.log';

      // Current log
      final currentFile = File(basePath);
      if (await currentFile.exists()) {
        files.add(currentFile);
      }

      // Rotated logs (.1, .2, .3)
      for (int i = 1; i <= _maxRotatedLogs; i++) {
        final rotatedFile = File('$basePath.$i');
        if (await rotatedFile.exists()) {
          files.add(rotatedFile);
        }
      }

      return files;
    } catch (e) {
      debugPrint('Failed to get all log files: $e');
      return [];
    }
  }

  /// Clear all log files and reinitialize
  static Future<void> clearLogs() async {
    try {
      // Null out sink FIRST to prevent concurrent _log() calls
      final sinkToClose = _logSink;
      _logSink = null;

      // Flush and close current log
      if (sinkToClose != null) {
        await sinkToClose.flush();
        await sinkToClose.close();
      }

      // Delete all log files
      final dir = await getApplicationDocumentsDirectory();
      final basePath = '${dir.path}/debug.log';

      final currentFile = File(basePath);
      if (await currentFile.exists()) {
        await currentFile.delete();
      }

      for (int i = 1; i <= _maxRotatedLogs; i++) {
        final rotatedFile = File('$basePath.$i');
        if (await rotatedFile.exists()) {
          await rotatedFile.delete();
        }
      }

      // Clear RAM buffer
      _recentLogs.clear();

      // Reinitialize
      await initialize();
    } catch (e) {
      debugPrint('Failed to clear logs: $e');
    }
  }
}
