import 'device_data_field.dart';

/// Configuration for a data field category
///
/// Defines how a category of data fields should be displayed,
/// including display name, layout style, and ordering.
class DeviceCategoryConfig {
  /// Category name/key (must match the category field in DeviceDataField)
  final String category;

  /// Display name for the category heading shown to the user
  final String displayName;

  /// Layout style for this category (standard, oneLine, or singleColumn)
  final CategoryLayout layout;

  /// Order/priority for displaying categories (lower = shown first)
  /// Default is 100. Uncategorized fields always appear first.
  final int order;

  const DeviceCategoryConfig({
    required this.category,
    required this.displayName,
    this.layout = CategoryLayout.standard,
    this.order = 100,
  });
}
