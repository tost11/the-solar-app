/// Utility functions for formatting DateTime objects to human-readable strings
///
/// This utility class provides methods for formatting timestamps in different contexts:
/// - Last seen times (e.g., "Vor 5 Minuten", "Gerade eben")
/// - System timestamps (e.g., "vor 2s", "14:24:32 Uhr")
class TimeFormatUtils {
  /// Formats a DateTime to a relative "last seen" string in German
  ///
  /// Examples:
  /// - Less than 1 minute: "Gerade eben"
  /// - Less than 1 hour: "Vor 5 Minuten"
  /// - Less than 1 day: "Vor 2 Stunden"
  /// - Less than 7 days: "Vor 3 Tagen"
  /// - 7+ days: "18.12.2025"
  ///
  /// Used in device lists and connection status displays
  static String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inHours < 1) {
      return 'Vor ${difference.inMinutes} Minuten';
    } else if (difference.inDays < 1) {
      return 'Vor ${difference.inHours} Stunden';
    } else if (difference.inDays < 7) {
      return 'Vor ${difference.inDays} Tagen';
    } else {
      return '${lastSeen.day}.${lastSeen.month}.${lastSeen.year}';
    }
  }

  /// Formats a DateTime to a short relative or absolute timestamp
  ///
  /// Examples:
  /// - Less than 5 seconds: "Gerade eben"
  /// - Less than 60 seconds: "vor 15s"
  /// - Less than 60 minutes: "vor 5m"
  /// - 60+ minutes: "14:24 Uhr"
  ///
  /// Used in system detail screens for update timestamps
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 5) {
      return 'Gerade eben';
    } else if (diff.inSeconds < 60) {
      return 'vor ${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return 'vor ${diff.inMinutes}m';
    } else {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute Uhr';
    }
  }

  /// Formats a DateTime to a full timestamp with seconds
  ///
  /// Example: "14:24:32 Uhr"
  ///
  /// Used for detailed timestamp displays
  static String formatFullTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second Uhr';
  }
}
