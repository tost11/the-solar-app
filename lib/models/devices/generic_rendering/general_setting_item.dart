import 'package:flutter/material.dart';

/// Type of general setting input
enum SettingType {
  toggle,    // Boolean on/off switch
  dropdown,  // Single-select dropdown
}

/// Option for dropdown/select settings
class SettingOption {
  final String label;        // User-visible text
  final dynamic value;       // Value to send to device
  final String? description; // Optional description

  const SettingOption({
    required this.label,
    required this.value,
    this.description,
  });
}

/// Represents a general setting item with a toggle (on/off) behavior
class GeneralSettingItem {
  /// The name/identifier of the setting (used both for display and command)
  final String name;

  /// The command name to send to device
  final String commandName;

  /// Optional icon shown next to the setting name
  final IconData? icon;

  /// Optional description text shown below the setting name
  final String? description;

  /// Whether to show a confirmation popup before changing the value
  final bool popUpOnChange;

  /// Optional confirmation dialog title (if popUpOnChange is true)
  final String? confirmationTitle;

  /// Optional confirmation dialog message (if popUpOnChange is true)
  final String? confirmationMessage;

  /// Type of setting input (toggle, dropdown, etc.)
  final SettingType type;

  /// The current status of the setting (used when type == toggle)
  final bool? currentStatus;

  /// The current value (used when type == dropdown)
  final dynamic currentValue;

  /// Available options (used when type == dropdown)
  final List<SettingOption>? options;

  const GeneralSettingItem({
    required this.name,
    required this.commandName,
    this.icon,
    this.description,
    this.popUpOnChange = true,
    this.confirmationTitle,
    this.confirmationMessage,
    this.type = SettingType.toggle,  // Default to toggle for backward compatibility
    this.currentStatus,               // Used when type == toggle
    this.currentValue,                // Used when type == dropdown
    this.options,                     // Used when type == dropdown
  });

  /// Creates a copy of this item with updated values
  GeneralSettingItem copyWith({
    String? name,
    String? commandName,
    IconData? icon,
    String? description,
    bool? popUpOnChange,
    String? confirmationTitle,
    String? confirmationMessage,
    SettingType? type,
    bool? currentStatus,
    dynamic currentValue,
    List<SettingOption>? options,
  }) {
    return GeneralSettingItem(
      name: name ?? this.name,
      commandName: commandName ?? this.commandName,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      popUpOnChange: popUpOnChange ?? this.popUpOnChange,
      confirmationTitle: confirmationTitle ?? this.confirmationTitle,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
      type: type ?? this.type,
      currentStatus: currentStatus ?? this.currentStatus,
      currentValue: currentValue ?? this.currentValue,
      options: options ?? this.options,
    );
  }
}
