import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Utilities for Shelly Gen2 digest authentication (SHA-256)
///
/// Implements RFC7616 digest authentication for Shelly devices.
/// Used for both Bluetooth and WiFi/HTTP connections.
class ShellyAuthUtils {
  /// Generate random client nonce (cnonce)
  ///
  /// Returns a random integer between 0 and 999999999
  static int generateCnonce() {
    return Random().nextInt(999999999);
  }

  /// Compute HA1: SHA256(username:realm:password)
  ///
  /// This is the first hash in the digest authentication process.
  /// The realm is typically the device ID (e.g., "shellypro3em-9454c5b986f0")
  static String computeHA1(String username, String realm, String password) {
    final input = '$username:$realm:$password';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compute HA2: SHA256("dummy_method:dummy_uri")
  ///
  /// For Shelly Gen2 devices, HA2 always uses the literal strings
  /// "dummy_method" and "dummy_uri" as per the official documentation.
  static String computeHA2() {
    const input = 'dummy_method:dummy_uri';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compute authentication response hash
  ///
  /// Formula: SHA256(ha1:nonce:nc:cnonce:auth:ha2)
  ///
  /// Parameters:
  /// - ha1: Pre-computed HA1 hash
  /// - nonce: Server nonce from 401 challenge
  /// - nc: Nonce counter from 401 challenge
  /// - cnonce: Client-generated random nonce
  static String computeResponse(
    String ha1,
    int nonce,
    int nc,
    int cnonce,
  ) {
    final ha2 = computeHA2();
    final input = '$ha1:$nonce:$nc:$cnonce:auth:$ha2';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Build complete authentication object for JSON-RPC request
  ///
  /// Returns a Map that should be added as "auth" field in JSON-RPC requests.
  ///
  /// Parameters:
  /// - realm: Device ID (e.g., "shellypro3em-9454c5b986f0")
  /// - username: Username (typically "admin")
  /// - nonce: Server nonce from 401 challenge
  /// - ha1: Pre-computed HA1 hash
  /// - nc: Nonce counter (defaults to 1 if not provided)
  static Map<String, dynamic> buildAuthObject({
    required String realm,
    required String username,
    required int nonce,
    required String ha1,
    int? nc,
  }) {
    final int nonceCounter = nc ?? 1;
    final int clientNonce = generateCnonce();

    return {
      'realm': realm,
      'username': username,
      'nonce': nonce,
      'cnonce': clientNonce,
      'response': computeResponse(ha1, nonce, nonceCounter, clientNonce),
      'algorithm': 'SHA-256',
    };
  }

  /// Parse authentication challenge from 401 error message
  ///
  /// The error message is a JSON string containing:
  /// - auth_type: "digest"
  /// - nonce: Server nonce
  /// - nc: Nonce counter
  /// - realm: Device ID
  /// - algorithm: "SHA-256"
  ///
  /// Example error message:
  /// {"auth_type": "digest", "nonce": 1625038762, "nc": 1, "realm": "shellypro3em-9454c5b986f0", "algorithm": "SHA-256"}
  ///
  /// Returns a Map with the parsed challenge data, or null if parsing fails.
  static Map<String, dynamic>? parseAuthChallenge(String errorMessage) {
    try {
      final challenge = jsonDecode(errorMessage) as Map<String, dynamic>;

      // Validate required fields
      if (!challenge.containsKey('nonce') || !challenge.containsKey('realm')) {
        return null;
      }

      return {
        'nonce': challenge['nonce'] as int,
        'nc': challenge['nc'] as int? ?? 1,
        'realm': challenge['realm'] as String,
        'algorithm': challenge['algorithm'] as String? ?? 'SHA-256',
        'auth_type': challenge['auth_type'] as String? ?? 'digest',
      };
    } catch (e) {
      // Failed to parse JSON
      return null;
    }
  }

  /// Parse WWW-Authenticate Digest header
  ///
  /// Parses HTTP WWW-Authenticate header for Digest authentication.
  ///
  /// Example header:
  /// WWW-Authenticate: Digest qop="auth", realm="shellyplusplugs-fcb4672696f8", nonce="1763746991", algorithm=SHA-256
  ///
  /// Returns a Map with the parsed challenge data in the same format as parseAuthChallenge(),
  /// or null if parsing fails.
  static Map<String, dynamic>? parseWWWAuthenticateHeader(String headerValue) {
    try {
      // Check if it's a Digest authentication
      if (!headerValue.toLowerCase().startsWith('digest ')) {
        return null;
      }

      // Remove "Digest " prefix
      final paramsString = headerValue.substring(7).trim();

      // Parse parameters using regex to handle quoted and unquoted values
      final params = <String, String>{};
      final regex = RegExp(r'(\w+)=("[^"]*"|[^,\s]*)');
      final matches = regex.allMatches(paramsString);

      for (final match in matches) {
        final key = match.group(1)?.toLowerCase();
        var value = match.group(2);

        if (key != null && value != null) {
          // Remove quotes if present
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }
          params[key] = value;
        }
      }

      // Extract required fields
      final realm = params['realm'];
      final nonceStr = params['nonce'];
      final algorithm = params['algorithm'] ?? 'SHA-256';

      if (realm == null || nonceStr == null) {
        return null;
      }

      // Convert nonce to int
      final nonce = int.tryParse(nonceStr);
      if (nonce == null) {
        return null;
      }

      // Return challenge in same format as parseAuthChallenge()
      return {
        'nonce': nonce,
        'nc': 1, // Default to 1 for HTTP (not provided in headers)
        'realm': realm,
        'algorithm': algorithm,
        'auth_type': 'digest',
      };
    } catch (e) {
      // Failed to parse header
      return null;
    }
  }
}
