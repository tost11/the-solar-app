import 'package:flutter/material.dart';

/// Global utility class for displaying messages (errors, success, warnings, info)
/// Provides consistent UI for all message types across the application
class MessageUtils {
  /// Shows an error dialog with customizable title and message
  ///
  /// Parameters:
  /// - context: BuildContext for showing the dialog
  /// - message: Error message to display
  /// - title: Optional custom title (defaults to "Fehler")
  static void showError(
    BuildContext context,
    String message, {
    String? title,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Fehler'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows a success message as a green SnackBar
  ///
  /// Parameters:
  /// - context: BuildContext for showing the SnackBar
  /// - message: Success message to display
  /// - duration: Optional custom duration (defaults to 3 seconds)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a warning message as an orange SnackBar
  ///
  /// Parameters:
  /// - context: BuildContext for showing the SnackBar
  /// - message: Warning message to display
  /// - duration: Optional custom duration (defaults to 4 seconds)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Shows an info message as a blue SnackBar
  ///
  /// Parameters:
  /// - context: BuildContext for showing the SnackBar
  /// - message: Info message to display
  /// - duration: Optional custom duration (defaults to 3 seconds)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a custom colored SnackBar
  ///
  /// Parameters:
  /// - context: BuildContext for showing the SnackBar
  /// - message: Message to display
  /// - backgroundColor: Custom background color
  /// - duration: Optional custom duration (defaults to 3 seconds)
  static void showCustom(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Duration? duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a selection dialog with a list of options
  ///
  /// Returns the selected item or null if cancelled
  /// If only one option is available, returns it immediately without showing dialog
  ///
  /// Parameters:
  /// - context: BuildContext for showing the dialog
  /// - title: Dialog title
  /// - options: Map of value -> display name pairs
  /// - cancelable: Whether dialog can be dismissed (default: true)
  static Future<T?> showSelectionDialog<T>(
    BuildContext context, {
    required String title,
    required Map<T, String> options,
    bool cancelable = true,
  }) async {
    if (!context.mounted) return null;

    // If only one option, return it immediately (skip dialog)
    if (options.length == 1) {
      return options.keys.first;
    }

    T? selectedValue;

    return await showDialog<T>(
      context: context,
      barrierDismissible: cancelable,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.entries.map((entry) {
                return RadioListTile<T>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            if (cancelable)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
            ElevatedButton(
              onPressed: selectedValue != null
                  ? () => Navigator.pop(context, selectedValue)
                  : null,
              child: const Text('Auswählen'),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog with OK and Cancel buttons
  ///
  /// Returns true if user clicks OK, false if cancelled
  ///
  /// Parameters:
  /// - context: BuildContext for showing the dialog
  /// - title: Dialog title
  /// - message: Message text to display (can be multi-line)
  /// - okButtonText: Text for OK button (default: "OK")
  /// - cancelButtonText: Text for Cancel button (default: "Abbrechen")
  /// - okButtonColor: Color for OK button (default: Colors.orange for warnings)
  /// - cancelable: Whether dialog can be dismissed by tapping outside (default: false)
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String okButtonText = 'OK',
    String cancelButtonText = 'Abbrechen',
    Color? okButtonColor,
    bool cancelable = false,
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: cancelable,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: okButtonColor != null
                ? ElevatedButton.styleFrom(backgroundColor: okButtonColor)
                : null,
            child: Text(okButtonText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
