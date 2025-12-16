/// Configuration for parameter source resolution
///
/// Defines how a script parameter should automatically resolve its value
/// from available devices (e.g., extracting IP addresses, serial numbers, etc.)
class ParameterSourceConfig {
  /// Resource type to extract from (e.g., "device")
  final String source;

  /// Property name to extract (e.g., "serialNumber", "hostname", "port", "ipAddress")
  final String sourceProperty;

  /// Comma-separated manufacturer filter (e.g., "zendure,shelly")
  ///
  /// When specified, only devices from these manufacturers will be considered
  /// during source resolution
  final String? sourceFilter;

  const ParameterSourceConfig({
    required this.source,
    required this.sourceProperty,
    this.sourceFilter,
  });

  /// Create from JSON
  factory ParameterSourceConfig.fromJson(Map<String, dynamic> json) {
    return ParameterSourceConfig(
      source: json['source'] as String,
      sourceProperty: json['sourceProperty'] as String,
      sourceFilter: json['sourceFilter'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'sourceProperty': sourceProperty,
      if (sourceFilter != null) 'sourceFilter': sourceFilter,
    };
  }

  @override
  String toString() {
    return 'ParameterSourceConfig(source: $source, sourceProperty: $sourceProperty, sourceFilter: $sourceFilter)';
  }
}
