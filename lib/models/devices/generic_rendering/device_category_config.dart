import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'device_data_field.dart';
import '../../../utils/field_translation_helper.dart';

/// Configuration for a data field category
///
/// Defines how a category of data fields should be displayed,
/// including display name, layout style, ordering, and filtering behavior.
class DeviceCategoryConfig {
  /// Category name/key (must match the category field in DeviceDataField)
  final String category;

  /// Display name for the category heading shown to the user (used as fallback if displayNameKey is not provided)
  final String displayName;

  /// Optional translation key for localized category display name
  /// When provided, getLocalizedDisplayName() will use this key to retrieve the translated name
  final String? displayNameKey;

  /// Optional parameters for parameterized translations (e.g., {"instanceNum": "2"} for "Switch {instanceNum}")
  /// Used with displayNameKey to generate dynamic category names like "Messung 2", "Phase 1"
  final Map<String, String>? displayNameParams;

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
    this.displayNameKey,
    this.displayNameParams,
    this.layout = CategoryLayout.standard,
    this.order = 100,
    this.hideWhenAllNull = false,
    this.hideWhenAllZero = false,
  });

  /// Get the localized display name for this category
  ///
  /// If displayNameKey is provided, uses it to retrieve the translated name from AppLocalizations.
  /// If displayNameParams are provided, replaces placeholders in the translated string.
  /// Falls back to the hardcoded [displayName] if displayNameKey is not provided.
  String getLocalizedDisplayName(AppLocalizations l10n) {
    // Fallback to hardcoded display name if no translation key
    if (displayNameKey == null) return displayName;

    // Get the translation method dynamically based on the key
    final translatedName = _getTranslation(l10n, displayNameKey!);

    // If no parameters, return the translation directly
    if (displayNameParams == null || displayNameParams!.isEmpty) {
      return translatedName;
    }

    // Replace parameters in the translated string
    String result = translatedName;
    displayNameParams!.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });

    return result;
  }

  /// Helper method to get translation by key
  /// Uses the field_translation_helper to map keys to l10n getters
  /// Falls back to the hardcoded displayName if translation is not found
  String _getTranslation(AppLocalizations l10n, String key) {
    try {
      // Use the helper function to get translation
      final translation = getCategoryTranslation(l10n, key);
      if (translation != null) {
        return translation;
      }
    } catch (e) {
      debugPrint('Warning: Translation key "$key" not found: $e');
    }

    // Fallback to hardcoded displayName
    return displayName;
  }
}
