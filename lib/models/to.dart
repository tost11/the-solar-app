import 'package:flutter/material.dart';
import 'package:the_solar_app/utils/field_translation_helper.dart';
import 'package:the_solar_app/utils/localization_extension.dart';

/// Encapsulates a translation key with optional parameters
///
/// Provides automatic fallback: returns key if translation not found
/// This makes missing translations immediately visible to users/developers.
class TO {
  /// The translation key (e.g., 'menuGeneralSettings')
  final String key;

  /// Optional parameters for placeholder replacement (e.g., {'num': 1} or {'num': '1'} for "PV{num}")
  /// Supports any type (String, int, double, bool) - converted to String during resolution
  final Map<String, dynamic>? params;

  const TO({
    required this.key,
    this.params,
  });

  /// Resolves the translation key to localized text
  ///
  /// Returns the key itself if translation not found (makes missing translations visible)
  String getText(BuildContext context) {
    // Get the localized string using the helper function
    String text = getFieldTranslation(context.l10n, key) ??
                  getCategoryTranslation(context.l10n, key) ??
                  getMenuTranslation(context.l10n, key) ??
                  key;  // Fallback to key if not found

    // Apply parameter substitution if params exist
    if (params != null) {
      params!.forEach((placeholder, value) {
        // Convert any type to String for replacement
        final stringValue = value.toString();
        text = text.replaceAll('{$placeholder}', stringValue);
      });
    }

    return text;
  }

  @override
  String toString() => 'TO(key: $key, params: $params)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TO && other.key == key && _mapsEqual(other.params, params);
  }

  @override
  int get hashCode => key.hashCode ^ params.hashCode;

  bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
