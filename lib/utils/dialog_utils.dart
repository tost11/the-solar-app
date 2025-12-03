import 'package:flutter/material.dart';
import 'message_utils.dart';

/// Utility functions for showing dialogs
class DialogUtils {
  /// Shows a loading dialog with a spinner and message
  ///
  /// [context] - The build context
  /// [message] - The message to display below the spinner
  ///
  /// To dismiss the dialog, call Navigator.pop(context)
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Execute an async operation with a loading dialog
  ///
  /// Shows a loading dialog, executes the operation, dismisses the dialog,
  /// and handles errors automatically.
  ///
  /// Example:
  /// ```dart
  /// final result = await DialogUtils.executeWithLoading(
  ///   context,
  ///   loadingMessage: 'Lade Daten...',
  ///   operation: () => device.sendCommand(COMMAND_FETCH_DATA, {}),
  /// );
  ///
  /// if (result != null) {
  ///   // Use result
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [context] - BuildContext for showing dialogs
  /// - [loadingMessage] - Message to display in loading dialog
  /// - [operation] - Async operation to execute
  /// - [onSuccess] - Optional callback executed on success (with result)
  /// - [onError] - Optional error handler (if null, shows default error dialog)
  /// - [showErrorDialog] - Whether to show error dialog automatically (default true)
  ///
  /// Returns: Result of the operation, or null if error occurred
  static Future<T?> executeWithLoading<T>(
    BuildContext context, {
    required String loadingMessage,
    required Future<T> Function() operation,
    void Function(T result)? onSuccess,
    void Function(dynamic error)? onError,
    bool showErrorDialog = true,
  }) async {
    // Show loading dialog
    showLoadingDialog(context, loadingMessage);

    try {
      // Execute operation
      final result = await operation();

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Call success callback if provided
      if (onSuccess != null && context.mounted) {
        onSuccess(result);
      }

      return result;
    } catch (e) {
      // Dismiss loading dialog on error
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Handle error
      if (onError != null) {
        onError(e);
      } else if (showErrorDialog && context.mounted) {
        MessageUtils.showError(context, 'Fehler: $e');
      }

      return null;
    }
  }
}
