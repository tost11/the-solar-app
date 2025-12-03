
mixin FetchDataTimeoutMixin {

  late Duration fetchDataInterval;

  /// Serializes fetch data interval to JSON
  ///
  /// Returns a map containing fetchDataInterval in seconds.
  Map<String, dynamic> fetchDataIntervalToJson() {
    return {
      'fetchDataInterval': fetchDataInterval.inSeconds
    };
  }

  /// Deserializes fetch data interval from JSON
  ///
  /// Restores fetchDataInterval from the provided map.
  /// If not present in JSON, uses the provided defaultInterval.
  void fetchDataIntervalFromJson(Map<String, dynamic> json, Duration defaultInterval) {
    final seconds = json['fetchDataInterval'] as int?;
    fetchDataInterval = seconds != null
        ? Duration(seconds: seconds)
        : defaultInterval;
  }
}
