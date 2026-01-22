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
