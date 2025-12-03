import 'package:flutter/material.dart';

/// Represents a general setting item with a toggle (on/off) behavior
class GeneralSettingItem {
  /// The name/identifier of the setting (used both for display and command)
  final String name;

  /// The current status of the setting (true = on, false = off)
  final bool currentStatus;

  /// Whether to show a confirmation popup before changing the value
  final bool popUpOnChange;

  /// Optional description text shown below the setting name
  final String? description;

  /// Optional icon shown next to the setting name
  final IconData? icon;

  /// Optional confirmation dialog title (if popUpOnChange is true)
  final String? confirmationTitle;

  /// Optional confirmation dialog message (if popUpOnChange is true)
  final String? confirmationMessage;

  final String commandName;

  GeneralSettingItem({
    required this.name,
    required this.currentStatus,
    this.popUpOnChange = false,
    this.description,
    this.icon,
    this.confirmationTitle,
    this.confirmationMessage,
    required this.commandName,
  });

  /// Creates a copy of this item with updated values
  GeneralSettingItem copyWith({
    String? name,
    bool? currentStatus,
    bool? popUpOnChange,
    String? description,
    IconData? icon,
    String? confirmationTitle,
    String? confirmationMessage,
    String? commandName,
  }) {
    return GeneralSettingItem(
      name: name ?? this.name,
      currentStatus: currentStatus ?? this.currentStatus,
      popUpOnChange: popUpOnChange ?? this.popUpOnChange,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      confirmationTitle: confirmationTitle ?? this.confirmationTitle,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
      commandName: commandName ?? this.commandName,
    );
  }
}
