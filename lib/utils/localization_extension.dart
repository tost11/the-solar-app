import 'package:flutter/material.dart';
import 'package:the_solar_app/generated/l10n/app_localizations.dart';

/// Extension to simplify localization access
///
/// Usage:
/// ```dart
/// context.l10n.connected
/// ```
///
/// Instead of:
/// ```dart
/// AppLocalizations.of(context)!.connected
/// ```
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Helper function to get localized field from base value and language map
///
/// Returns the translation from [lngMap] if available for the current locale,
/// otherwise falls back to [baseValue] (English).
///
/// Usage:
/// ```dart
/// final localizedName = getLocalizedField(
///   context,
///   template.name,
///   template.nameLng,
/// );
/// ```
String getLocalizedField(
  BuildContext context,
  String baseValue,
  Map<String, String>? lngMap,
) {
  if (lngMap == null || lngMap.isEmpty) {
    return baseValue;
  }

  final locale = Localizations.localeOf(context);
  final languageCode = locale.languageCode;

  return lngMap[languageCode] ?? baseValue;
}
