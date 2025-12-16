import '../models/shelly_script_template.dart';

/// Utility class for semantic version comparison
class VersionUtils {
  /// Compare two semantic version strings (e.g., "1.0.0", "2.1.3")
  ///
  /// Returns:
  ///   negative if v1 < v2
  ///   0 if v1 == v2
  ///   positive if v1 > v2
  ///
  /// Example:
  ///   compareVersions("1.0.0", "1.1.0") returns -1
  ///   compareVersions("2.0.0", "1.9.0") returns 1
  ///   compareVersions("1.0.0", "1.0.0") returns 0
  static int compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    // Compare up to 3 parts (major.minor.patch)
    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1 - p2;
    }
    return 0;
  }

  /// Sort templates by version in descending order (newest first)
  ///
  /// Modifies the list in place.
  static void sortTemplatesByVersion(List<ShellyScriptTemplate> templates) {
    templates.sort((a, b) => compareVersions(b.version, a.version));
  }
}
