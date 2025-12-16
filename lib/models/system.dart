import 'package:the_solar_app/models/system_device_reference.dart';

/// Represents a user-defined system of devices
///
/// A system is a collection of devices (referenced by serial number)
/// that work together. Each device can have a different role in different systems.
class System {
  /// Unique identifier for this system (UUID)
  final String id;

  /// User-defined name for this system
  String name;

  /// List of devices in this system (referenced by serial number)
  final List<SystemDeviceReference> deviceReferences;

  /// Timestamp when this system was created
  final DateTime createdAt;

  /// Timestamp of last update to this system
  DateTime updatedAt;

  System({
    required this.id,
    required this.name,
    required this.deviceReferences,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor from JSON
  factory System.fromJson(Map<String, dynamic> json) {
    return System(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceReferences: (json['deviceReferences'] as List<dynamic>)
          .map((e) => SystemDeviceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceReferences': deviceReferences.map((d) => d.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get all device serial numbers in this system
  List<String> get deviceSerialNumbers =>
      deviceReferences.map((ref) => ref.deviceSn).toList();
}
