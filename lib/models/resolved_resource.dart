import 'device.dart';

/// Represents a resolved resource with extracted value from a device
///
/// Used when automatically populating script parameters from device properties.
/// Contains the source device, extracted value, and a human-readable label
/// for display in picker UIs.
class ResolvedResource {
  /// Reference to the source device
  final DeviceBase device;

  /// Extracted property value as string
  final String extractedValue;

  /// Display label for picker (e.g., "Shelly Plug Küche (192.168.1.50)")
  final String displayLabel;

  ResolvedResource({
    required this.device,
    required this.extractedValue,
    required this.displayLabel,
  });

  /// Generate display label from device name and extracted value
  factory ResolvedResource.create(DeviceBase device, String extractedValue) {
    final label = '${device.name} ($extractedValue)';
    return ResolvedResource(
      device: device,
      extractedValue: extractedValue,
      displayLabel: label,
    );
  }

  @override
  String toString() {
    return 'ResolvedResource(device: ${device.name}, value: $extractedValue)';
  }
}
