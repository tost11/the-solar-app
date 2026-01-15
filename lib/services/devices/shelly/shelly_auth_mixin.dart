import 'package:flutter/cupertino.dart';
import '../../../models/devices/device_base.dart';
import '../../../models/devices/mixins/device_authentication_mixin.dart';
import '../../../utils/shelly_auth_utils.dart';
import '../base_device_service.dart';

/// Mixin providing Shelly authentication functionality
///
/// This mixin can be applied to any service extending BaseDeviceService
/// to add Shelly-specific authentication capabilities including:
/// - Challenge-response authentication (RFC7616 Digest with SHA-256)
/// - Authentication caching
/// - Credential management
///
/// Used by both ShellyBluetoothService and ShellyWifiService to share
/// authentication logic without duplicating code.
mixin ShellyAuthMixin on BaseDeviceService {

  // Shared authentication state
  Map<String, dynamic>? _cachedAuthObject;
  String? _cachedHA1;

  /// Reset authentication cache
  ///
  /// Should be called when:
  /// - Authentication credentials change
  /// - Device disconnects
  /// - Authentication fails
  void resetAuthCache() {
    _cachedHA1 = null;
    _cachedAuthObject = null;
  }

  /// Get cached authentication object (if available)
  Map<String, dynamic>? get cachedAuthObject => _cachedAuthObject;

  /// Get device with authentication mixin
  ///
  /// Throws exception if device doesn't support authentication
  DeviceAuthenticationMixin _getAuthDevice() {
    return device as DeviceAuthenticationMixin;
  }

  /// Build authentication object from 401 challenge
  ///
  /// This method:
  /// 1. Validates device has authentication enabled and credentials configured
  /// 2. Computes/caches HA1 hash if not already cached
  /// 3. Builds auth object using challenge parameters
  /// 4. Caches auth object for subsequent requests
  ///
  /// Returns the built authentication object
  /// Throws exception if credentials are missing or invalid
  Map<String, dynamic> buildAuthFromChallenge(Map<String, dynamic> challenge) {
    debugPrint('Building auth from challenge: $challenge');

    final authDevice = _getAuthDevice();

    // Check if credentials are available
    if (authDevice.authUsername == null ||
        authDevice.authPassword == null) {
      debugPrint('Authentication credentials not configured');
      throw Exception(
          'Gerät erfordert Authentifizierung. Bitte konfigurieren Sie Benutzername und Passwort.');
    }

    // Get realm from challenge
    final realm = challenge['realm'] as String;

    // Access deviceScr dynamically (available on all Shelly device templates)
    final deviceScr = (device as dynamic).deviceScr as String?;

    // Warn if realm mismatch
    if (deviceScr != null && deviceScr != realm) {
      debugPrint(
          'Warning: Realm mismatch. Device: $deviceScr, Challenge: $realm');
    }

    // Compute or use cached HA1
    if (_cachedHA1 == null) {
      debugPrint('Computing HA1 hash');
      _cachedHA1 = ShellyAuthUtils.computeHA1(
        authDevice.authUsername!,
        realm,
        authDevice.authPassword!,
      );
    }

    // Build authentication object
    _cachedAuthObject = ShellyAuthUtils.buildAuthObject(
      realm: realm,
      username: authDevice.authUsername!,
      nonce: challenge['nonce'] as int,
      ha1: _cachedHA1!,
      nc: challenge['nc'] as int?,
    );

    debugPrint('Auth object built successfully');
    return _cachedAuthObject!;
  }

  /// Parse 401 error message and build authentication object
  ///
  /// This method:
  /// 1. Parses the error message JSON to extract challenge parameters
  /// 2. Calls buildAuthFromChallenge() to build the auth object
  ///
  /// Returns the built authentication object, or null if parsing fails
  Map<String, dynamic>? parseAndBuildAuth(String errorMessage) {
    debugPrint('Parsing authentication challenge from error message');

    // Parse authentication challenge
    final challenge = ShellyAuthUtils.parseAuthChallenge(errorMessage);
    if (challenge == null) {
      debugPrint('Failed to parse authentication challenge');
      return null;
    }

    return buildAuthFromChallenge(challenge);
  }
}
