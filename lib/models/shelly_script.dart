/// Represents a Shelly Gen2 script (automation)
///
/// Scripts can be enabled/disabled and running/stopped independently.
/// This model represents the script metadata returned by Script.List and Script.GetStatus APIs.
class ShellyScript {
  /// Script ID (unique identifier)
  final int id;

  /// Script name
  final String name;

  /// Whether the script is enabled (will run automatically)
  final bool enable;

  /// Whether the script is currently running
  final bool running;

  /// Errors from Script.GetStatus (optional)
  /// Contains error types like 'crashed', 'syntax_error', etc.
  final List<String>? errors;

  /// Memory used by script in bytes (optional, from Script.GetStatus)
  final int? memUsed;

  /// Peak memory used by script in bytes (optional, from Script.GetStatus)
  final int? memPeak;

  ShellyScript({
    required this.id,
    required this.name,
    required this.enable,
    required this.running,
    this.errors,
    this.memUsed,
    this.memPeak,
  });

  /// Create a ShellyScript from Script.List JSON response
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": 0,
  ///   "name": "My Script",
  ///   "enable": true,
  ///   "running": false
  /// }
  /// ```
  factory ShellyScript.fromJson(Map<String, dynamic> json) {
    return ShellyScript(
      id: json['id'] as int,
      name: json['name'] as String,
      enable: json['enable'] as bool,
      running: json['running'] as bool,
    );
  }

  /// Create a copy of this script with updated fields
  ShellyScript copyWith({
    int? id,
    String? name,
    bool? enable,
    bool? running,
    List<String>? errors,
    int? memUsed,
    int? memPeak,
  }) {
    return ShellyScript(
      id: id ?? this.id,
      name: name ?? this.name,
      enable: enable ?? this.enable,
      running: running ?? this.running,
      errors: errors ?? this.errors,
      memUsed: memUsed ?? this.memUsed,
      memPeak: memPeak ?? this.memPeak,
    );
  }

  /// Update this script with data from Script.GetStatus response
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": 0,
  ///   "running": false,
  ///   "mem_used": 1024,
  ///   "mem_peak": 2048,
  ///   "mem_free": 10000,
  ///   "cpu": 5,
  ///   "errors": ["syntax_error"]
  /// }
  /// ```
  ShellyScript updateFromStatus(Map<String, dynamic> statusData) {
    // Extract errors array if present
    List<String>? errorsList;
    if (statusData['errors'] != null) {
      final errorsData = statusData['errors'] as List<dynamic>;
      errorsList = errorsData.map((e) => e.toString()).toList();
    }

    return copyWith(
      running: statusData['running'] as bool? ?? running,
      memUsed: statusData['mem_used'] as int?,
      memPeak: statusData['mem_peak'] as int?,
      errors: errorsList,
    );
  }

  @override
  String toString() {
    return 'ShellyScript(id: $id, name: $name, enable: $enable, running: $running, errors: $errors)';
  }
}
