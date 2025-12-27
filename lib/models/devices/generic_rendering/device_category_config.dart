import 'device_data_field.dart';

/// Configuration for a data field category
///
/// Defines how a category of data fields should be displayed,
/// including display name, layout style, ordering, and filtering behavior.
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

  /// Hide this category when all field values are null/empty (default: false)
  /// When true, the category will not be displayed if all fields are null or empty
  final bool hideWhenAllNull;

  /// Hide this category when all field values are zero (default: false)
  /// When true, the category will not be displayed if all numeric fields are 0.0
  final bool hideWhenAllZero;

  const DeviceCategoryConfig({
    required this.category,
    required this.displayName,
    this.layout = CategoryLayout.standard,
    this.order = 100,
    this.hideWhenAllNull = false,
    this.hideWhenAllZero = false,
  });
}
