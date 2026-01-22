import 'package:flutter/material.dart';
import '../../to.dart';
import '../device_base.dart';

/// Position where the custom section should be rendered
enum CustomSectionPosition {
  /// Render before device info cards
  beforeDeviceInfo,
  /// Render after device info, before connection controls
  afterDeviceInfo,
  /// Render after connection controls, before control items
  afterConnectionControls,
  /// Render after control items, before live data
  afterControls,
  /// Render after live data section
  afterLiveData,
}

/// Represents a custom UI section that a device can inject into the detail screen
class DeviceCustomSection {
  /// Title of the section (optional, if null no title is shown)
  /// Can be either a String or a TO (TranslationObject) for localization
  final dynamic title;  // String? or TO?

  /// Widget builder function that receives context, device, and current data
  final Widget Function(BuildContext context, DeviceBase device, Map<String, Map<String, dynamic>> data) builder;

  /// Position where this section should be rendered
  final CustomSectionPosition position;

  /// Whether this section should only be shown when connected
  final bool requiresConnection;

  const DeviceCustomSection({
    this.title,
    required this.builder,
    this.position = CustomSectionPosition.afterLiveData,
    this.requiresConnection = true,
  });
}
