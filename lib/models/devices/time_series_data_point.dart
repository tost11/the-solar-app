/// Represents a single data point in a time series
///
/// Used to store timestamped values for graphing device metrics over time
class TimeSeriesDataPoint {
  /// The timestamp when this value was recorded
  final DateTime timestamp;

  /// The numeric value at this timestamp
  final num value;

  TimeSeriesDataPoint({
    required this.timestamp,
    required this.value,
  });
}
