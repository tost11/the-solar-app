
mixin AdditionalPortMixin {

  late int additionalPort;

  /// Serializes WiFi connection fields to JSON
  ///
  /// Returns a map containing ipAddress and port fields.
  /// Null values are excluded from the map.
  Map<String, dynamic> additionalPortToJson() {
    return {
      'additionalPort': additionalPort
    };
  }

  /// Deserializes WiFi connection fields from JSON
  ///
  /// Restores ipAddress and port from the provided map.
  /// If port is not present in JSON, defaults to 80.
  void additionalPortFromJson(Map<String, dynamic> json,int defaultPort) {
    additionalPort = json['additionalPort'] as int? ?? defaultPort;
  }
}
